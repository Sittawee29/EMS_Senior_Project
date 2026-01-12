// bill_service.dart
import 'dart:async';
import 'package:intl/intl.dart';
import 'bill_model.dart';
import '../../../../services/mqtt_service.dart'; // ตรวจสอบ path ให้ถูกต้อง

class BillService {
  final _generalBillController = StreamController<BillModel>.broadcast();
  final _touBillController = StreamController<BillModel>.broadcast();

  Stream<BillModel> get generalBillStream => _generalBillController.stream;
  Stream<BillModel> get touBillStream => _touBillController.stream;

  final MqttService _mqttService = MqttService();
  StreamSubscription? _mqttSubscription;

  final _fmt = NumberFormat("#,##0.00"); // ตัวจัดรูปแบบทศนิยม 2 ตำแหน่ง
  final _fmtUnit = NumberFormat("#,##0"); // ตัวจัดรูปแบบจำนวนเต็ม (หน่วย)

  void startRealtimeSimulation() {
    _mqttSubscription?.cancel();
    
    // ฟังค่าจาก MQTT (ค่านี้คือ Total Energy สะสม)
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      
      // 1. รับค่า Total Unit จาก MQTT
      double totalEnergy = data.GRID_Daily_Import_Energy; 
      // ถ้าค่าเป็น 0 หรือ null ให้สมมติค่าเริ่มต้นเพื่อเทส (เช่น 147417 ตามรูป)
      if (totalEnergy <= 0) totalEnergy = 147417.0;

      // 2. จำลองการแบ่งสัดส่วนการใช้ไฟ (Simulation Logic)
      // สมมติ: OnPeak 60%, OffPeak 10%, Holiday 30%
      double onPeakUnit = totalEnergy * 0.60;
      double offPeakUnit = totalEnergy * 0.10;
      double holidayUnit = totalEnergy * 0.30;
      
      // ปัดเศษให้เป็นจำนวนเต็ม (เพื่อให้บวกกันลงตัวสวยๆ)
      int onPeakInt = onPeakUnit.round();
      int offPeakInt = offPeakUnit.round();
      int holidayInt = holidayUnit.round();
      int totalInt = onPeakInt + offPeakInt + holidayInt;

      // จำลองเลขมิเตอร์ (เอาค่าปัจจุบัน - หน่วยที่ใช้ = เลขครั้งก่อน)
      double lastMeterRead = 1415983; // สมมติเลขมิเตอร์ล่าสุด
      double prevMeterRead = lastMeterRead - totalInt;

      // 3. กำหนดเรทราคา (ตามรูปภาพต้นฉบับ)
      double rateOnPeak = 4.1839;
      double rateOffPeak = 2.6037;
      double rateHoliday = 2.6037;
      double rateFt = 0.0755;

      // 4. คำนวณจำนวนเงิน
      double amountOnPeak = onPeakInt * rateOnPeak;
      double amountOffPeak = offPeakInt * rateOffPeak;
      double amountHoliday = holidayInt * rateHoliday;
      
      double baseAmount = amountOnPeak + amountOffPeak + amountHoliday; // รวมค่าพลังงาน
      double ftAmount = totalInt * rateFt; // ค่า Ft
      
      double totalBeforeVat = baseAmount + ftAmount;
      double vat = totalBeforeVat * 0.07;
      double grandTotal = totalBeforeVat + vat;

      // 5. สร้าง Model ส่งกลับไปที่ UI
      BillModel bill = BillModel(
        invoiceNo: '01103939724',
        documentDate: _getCurrentDateThai(),
        payerName: 'บริษัท โรบินสัน จำกัด (มหาชน)',
        
        // ข้อมูลมิเตอร์
        meterLastReadDate: '30/11/2025',
        prevRead: _fmtUnit.format(prevMeterRead),
        lastRead: _fmtUnit.format(lastMeterRead),
        
        // หน่วยการใช้
        onPeakUnit: _fmtUnit.format(onPeakInt),
        offPeakUnit: _fmtUnit.format(offPeakInt),
        holidayUnit: _fmtUnit.format(holidayInt),
        totalUnit: _fmtUnit.format(totalInt),
        
        // เรทราคา
        onPeakRate: rateOnPeak.toStringAsFixed(4),
        offPeakRate: rateOffPeak.toStringAsFixed(4),
        holidayRate: rateHoliday.toStringAsFixed(4),
        
        // จำนวนเงิน
        onPeakAmount: _fmt.format(amountOnPeak),
        offPeakAmount: _fmt.format(amountOffPeak),
        holidayAmount: _fmt.format(amountHoliday),
        baseAmount: _fmt.format(baseAmount),
        
        // สรุปยอด
        ftRate: rateFt.toStringAsFixed(4),
        ftAmount: _fmt.format(ftAmount),
        totalBeforeVat: _fmt.format(totalBeforeVat),
        vatAmount: _fmt.format(vat),
        grandTotal: _fmt.format(grandTotal),
      );

      _generalBillController.add(bill);
      _touBillController.add(bill); // ส่งค่าเดียวกันไปทั้ง 2 Tab หรือจะคำนวณแยกก็ได้

    }, onError: (error) {
      print("Error receiving MQTT data: $error");
    });
  }

  void stopSimulation() {
    _mqttSubscription?.cancel();
    _generalBillController.close();
    _touBillController.close();
  }

  String _getCurrentDateThai() {
    DateTime now = DateTime.now();
    List<String> months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${now.day} ${months[now.month]} ${now.year + 543}';
  }
}