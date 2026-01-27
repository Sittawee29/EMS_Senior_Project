// bill_model.dart
class BillModel {
  final String invoiceNo;
  final String documentDate;
  final String payerName;
  
  // --- ส่วนมิเตอร์ (Meter Reading) ---
  final String meterLastReadDate;
  final String prevRead;      // เลขอ่านครั้งก่อน
  final String lastRead;      // เลขอ่านครั้งหลัง
  
  // --- ส่วนหน่วยการใช้ (Units) ---
  final String onPeakUnit;    // หน่วย On Peak
  final String offPeakUnit;   // หน่วย Off Peak
  final String holidayUnit;   // หน่วย Holiday
  final String totalUnit;     // หน่วยรวม
  
  // --- ส่วนราคา (Rates) ---
  final String generalRate;  // เรทราคา General (3.1471)
  final String onPeakRate;    // เรทราคา On Peak (4.1839)
  final String offPeakRate;   // เรทราคา Off Peak (2.6037)
  final String holidayRate;   // เรทราคา Holiday (2.6037)
  final String serviceCharge; // ค่าบริการรายเดือน (38.22)
  
  // --- ส่วนจำนวนเงิน (Amounts) ---
  final String generalAmount; // เงินค่าพลังงานไฟฟ้า (General)
  final String onPeakAmount;  // เงินค่า On Peak
  final String offPeakAmount; // เงินค่า Off Peak
  final String holidayAmount; // เงินค่า Holiday
  final String baseAmount;    // รวมเงินค่าพลังงานไฟฟ้า (ก่อน Ft)
  
  // --- ส่วนสรุป (Summary) ---
  final String ftRate;        // เรท Ft
  final String ftAmount;      // รวมเงินค่า Ft
  final String GeneraltotalBeforeVat;// รวมค่าไฟฟ้า (General Base + Ft)
  final String GeneralvatAmount;   // ภาษี 7%
  final String GeneralgrandTotal;  // รวมทั้งสิ้น
  final String TOUtotalBeforeVat;// รวมค่าไฟฟ้า (TOU Base + Ft)
  final String TOUvatAmount;     // ภาษี 7%
  final String TOUgrandTotal;    // รวมทั้งสิ้น

  const BillModel({
    required this.invoiceNo,
    required this.documentDate,
    required this.payerName,
    required this.meterLastReadDate,
    required this.prevRead,
    required this.lastRead,
    required this.onPeakUnit,
    required this.offPeakUnit,
    required this.holidayUnit,
    required this.totalUnit,
    required this.generalRate,
    required this.onPeakRate,
    required this.offPeakRate,
    required this.holidayRate,
    required this.generalAmount,
    required this.onPeakAmount,
    required this.offPeakAmount,
    required this.holidayAmount,
    required this.serviceCharge,
    required this.baseAmount,
    required this.ftRate,
    required this.ftAmount,
    required this.GeneraltotalBeforeVat,
    required this.GeneralvatAmount,
    required this.GeneralgrandTotal,
    required this.TOUtotalBeforeVat,
    required this.TOUvatAmount,
    required this.TOUgrandTotal,
  });
}