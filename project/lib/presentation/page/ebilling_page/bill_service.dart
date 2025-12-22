import 'dart:async';
import 'package:intl/intl.dart';
import 'bill_model.dart';
import '../../../../services/mqtt_service.dart';

class BillService {
  final _generalBillController = StreamController<BillModel>.broadcast();
  final _touBillController = StreamController<BillModel>.broadcast();

  Stream<BillModel> get generalBillStream => _generalBillController.stream;
  Stream<BillModel> get touBillStream => _touBillController.stream;

  final MqttService _mqttService = MqttService(); // เรียกใช้ Instance ของ MQTT Service
  StreamSubscription? _mqttSubscription; // ตัวจัดการการ Subscribe

  final _formatter = NumberFormat("#,##0.00");

  void startRealtimeSimulation() {
    _mqttSubscription?.cancel();
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      double currentUnit = data.GRID_Daily_Import_Energy;
      // 2. คำนวณค่าไฟ (Logic เดิม)
      double ftRate = 0.1572; // ค่า FT
      double serviceCharge = 312.24; // ค่าบริการพื้นฐาน
      double charge = (currentUnit*3.1471)+(currentUnit*ftRate)+serviceCharge; // หน่วยละ 3.1471 บาท (กิจการขนาดกลาง)
      double vat = charge * 0.07;
      double total = charge + vat;

      // 3. ส่งข้อมูลเข้าท่อ General Meter
      _generalBillController.add(BillModel(
        invoiceNo: '-',
        documentDate: _getCurrentDateThai(), // ใช้วันที่ปัจจุบัน
        payerName: 'นายสิทธวีร์ บุญเกิ่ง',
        payerAddress: '358 ม.1 ซ.หนามแดง-บางพลี 3 ถ.ศรีนครินทร์ ต.บางแก้ว อ.บางพลี สมุทรปราการ 10540',
        contractAccount: '-',
        meterNo: '35089970',
        unit: currentUnit.toStringAsFixed(2), // แสดงค่าจริงจาก MQTT
        electricityCharge: _formatter.format(charge),
        vat: _formatter.format(vat),
        amount: _formatter.format(total),
        ftRate: ftRate.toStringAsFixed(4),
      ));

      // 4. ส่งข้อมูลเข้าท่อ TOU (สมมติว่าใช้ค่า Unit เดียวกัน แต่คิดเรทราคาต่างกัน หรือจะใช้ Logic อื่นก็ได้)
      // สมมติ TOU เรทแพงกว่านิดหน่อย
      double chargeTou = currentUnit * 5.2; 
      _touBillController.add(BillModel(
        invoiceNo: '01103999999',
        documentDate: _getCurrentDateThai(),
        payerName: 'นายสุวโรจน์ บุญเกิ่ง',
        payerAddress: '358 ม.1 ซ.หนามแดง-บางพลี 3...',
        contractAccount: '014099395',
        meterNo: '35089970 (TOU)',
        unit: currentUnit.toStringAsFixed(2), // ใช้ค่าจริงจาก MQTT เช่นกัน
        electricityCharge: _formatter.format(chargeTou),
        vat: _formatter.format(chargeTou * 0.07),
        amount: _formatter.format(chargeTou * 1.07),
        ftRate: '0.1572',
      ));

    }, onError: (error) {
      print("Error receiving MQTT data: $error");
    });
  }

  void stopSimulation() {
    _mqttSubscription?.cancel(); // หยุดฟัง MQTT
    _generalBillController.close();
    _touBillController.close();
  }

  // ฟังก์ชันเสริม: หาวันที่ปัจจุบันเป็นภาษาไทย
  String _getCurrentDateThai() {
    DateTime now = DateTime.now();
    List<String> months = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return '${now.day} ${months[now.month]} ${now.year + 543}';
  }
}