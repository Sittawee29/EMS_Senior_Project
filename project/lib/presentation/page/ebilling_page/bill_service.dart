import 'dart:async';
import 'dart:convert'; // เพิ่มสำหรับการแปลง JSON
import 'package:http/http.dart' as http; // ต้องเพิ่ม http ใน pubspec.yaml
import 'package:intl/intl.dart';
import 'bill_model.dart';
import '../../../../services/mqtt_service.dart';

class BillService {
  final _generalBillController = StreamController<BillModel>.broadcast();
  final _touBillController = StreamController<BillModel>.broadcast();

  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';

  Stream<BillModel> get generalBillStream => _generalBillController.stream;
  Stream<BillModel> get touBillStream => _touBillController.stream;

  final MqttService _mqttService = MqttService();
  StreamSubscription? _mqttSubscription;

  final _fmt = NumberFormat("#,##0.00");
  //final _fmtUnit = NumberFormat("#,##0");

  // ตัวแปรเก็บค่าเลขอ่าน
  double _prevRead = 0.0; // เลขอ่านครั้งก่อน (จากวันที่ 27)
  double _lastRead = 0.0; // เลขอ่านครั้งหลัง (จาก Realtime MQTT)

  // URL ของ Python Server (เปลี่ยน IP ให้ตรงกับเครื่อง Server ของคุณ)
  final String _apiUrl = "http://$serverIp:$serverPort/api/bill/reading_start";
  final String _touApiUrl = "http://$serverIp:$serverPort/api/bill/calculate_tou";

  double _cachedOnPeak = 0.0;
  double _cachedOffPeak = 0.0;
  double _cachedHoliday = 0.0;

  // ฟังก์ชันดึงค่าตั้งต้นจาก API
  Future<void> _fetchPrevReading() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _prevRead = (data['prev_read'] as num).toDouble();
      }
    } catch (e) {
      print("Error fetching prev reading: $e");
      // กรณี Error อาจจะกำหนดค่า Default หรือปล่อยเป็น 0
    }
  }

  // ฟังก์ชันดึงค่า TOU จาก Server
  Future<void> _fetchTouData() async {
    try {
      final response = await http.get(Uri.parse(_touApiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // อัปเดตตัวแปร Cache
        _cachedOnPeak = (data['on_peak_unit'] as num).toDouble();
        _cachedOffPeak = (data['off_peak_unit'] as num).toDouble();
        _cachedHoliday = (data['holiday_unit'] as num).toDouble();
        print("Updated TOU: On=$_cachedOnPeak, Off=$_cachedOffPeak, Holiday=$_cachedHoliday");
      }
    } catch (e) {
      print("Error fetching TOU: $e");
    }
  }

  void startRealtimeSimulation() async {
    _mqttSubscription?.cancel();
  
    // 1. ไปดึงค่าเลขอ่านครั้งก่อน (วันที่ 27 00:00) มาก่อน
    await _fetchPrevReading();
    await _fetchTouData();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchTouData();
    });
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      double currentVal = data.EMS_EnergyProducedFromPV_kWh ?? 0.0; 
      _lastRead = currentVal;
      // ถ้าค่า prevRead เป็น 0 (หาไม่เจอ) อาจจะให้เท่ากับค่าปัจจุบันไปก่อนเพื่อไม่ให้ติดลบ
      if (_prevRead == 0) _prevRead = _lastRead;
      // คำนวณหน่วยที่ใช้จริง (Unit = Last - Prev)
      double totalUnit = _lastRead - _prevRead;
      if (totalUnit < 0) totalUnit = 0.0; // ป้องกันค่าติดลบ

      // --- ส่วนการคำนวณเงิน (คงเดิม) ---
      // แบ่งสัดส่วนสมมติ (หรือจะดึงจริงถ้ามี data)
      double onPeakUnit = _cachedOnPeak;
      double offPeakUnit = _cachedOffPeak;
      double holidayUnit = _cachedHoliday;

      double discountedRate = 0.45;

      // เรทราคา (บาท/หน่วย)
      double rateGeneral = 3.1471;
      double rateOnPeak = 4.1839;
      double rateOffPeak = 2.6037;
      double rateHoliday = 2.6037;
      double serviceCharge = 38.22; // ค่าบริการรายเดือน

      // คำนวณเงิน
      double amountGeneral = totalUnit * rateGeneral*discountedRate;
      double amountOnPeak = onPeakUnit * rateOnPeak*discountedRate;
      double amountOffPeak = offPeakUnit * rateOffPeak*discountedRate;
      double amountHoliday = holidayUnit * rateHoliday*discountedRate;
      double baseAmount = amountOnPeak + amountOffPeak + amountHoliday;

      // ค่า Ft และ Vat
      double ftUnitRate = 0.3972; 
      double ftAmount = totalUnit * ftUnitRate;

      double GeneraltotalBeforeVat = amountGeneral + ftAmount + 38.22; // +ค่าบริการ
      double Generalvat = GeneraltotalBeforeVat * 0.07;
      double GeneralgrandTotal = GeneraltotalBeforeVat + Generalvat;

      double TOUtotalBeforeVat = baseAmount + ftAmount + 38.22; // +ค่าบริการ
      double TOUvat = TOUtotalBeforeVat * 0.07;
      double TOUgrandTotal = TOUtotalBeforeVat + TOUvat;

      // สร้าง Model ส่งกลับไปหน้า UI
      final bill = BillModel(
        invoiceNo: "INV-${DateTime.now().millisecondsSinceEpoch}", 
        documentDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        payerName: "คุณสมชาย รักพลังงาน", 
        meterLastReadDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        
        // --- ใช้ค่าจริงที่ได้มา ---
        prevRead: _fmt.format(_prevRead),  // ค่าจาก API วันที่ 27
        lastRead: _fmt.format(_lastRead),  // ค่าล่าสุดจาก MQTT

        onPeakUnit: _fmt.format(onPeakUnit),
        offPeakUnit: _fmt.format(offPeakUnit),
        holidayUnit: _fmt.format(holidayUnit),
        totalUnit: _fmt.format(totalUnit), // ผลต่างจริง

        generalRate: rateGeneral.toStringAsFixed(4),
        onPeakRate: rateOnPeak.toStringAsFixed(4),
        offPeakRate: rateOffPeak.toStringAsFixed(4),
        holidayRate: rateHoliday.toStringAsFixed(4),
        serviceCharge: serviceCharge.toStringAsFixed(2),

        generalAmount: _fmt.format(amountGeneral),
        onPeakAmount: _fmt.format(amountOnPeak),
        offPeakAmount: _fmt.format(amountOffPeak),
        holidayAmount: _fmt.format(amountHoliday),
        baseAmount: _fmt.format(baseAmount),

        ftRate: ftUnitRate.toStringAsFixed(4),
        ftAmount: _fmt.format(ftAmount),
        GeneraltotalBeforeVat: _fmt.format(GeneraltotalBeforeVat),
        GeneralvatAmount: _fmt.format(Generalvat),
        GeneralgrandTotal: _fmt.format(GeneralgrandTotal),
        TOUtotalBeforeVat: _fmt.format(TOUtotalBeforeVat),
        TOUvatAmount: _fmt.format(TOUvat),
        TOUgrandTotal: _fmt.format(TOUgrandTotal),
      );

      _generalBillController.add(bill);
      _touBillController.add(bill);

    }, onError: (error) {
      print("Error receiving MQTT data: $error");
    });
  }

  void stopSimulation() {
    _mqttSubscription?.cancel();
    _generalBillController.close();
    _touBillController.close();
  }
}