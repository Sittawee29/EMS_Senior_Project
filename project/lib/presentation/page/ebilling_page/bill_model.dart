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
  final String onPeakRate;    // เรทราคา On Peak (4.1839)
  final String offPeakRate;   // เรทราคา Off Peak (2.6037)
  final String holidayRate;   // เรทราคา Holiday (2.6037)
  
  // --- ส่วนจำนวนเงิน (Amounts) ---
  final String onPeakAmount;  // เงินค่า On Peak
  final String offPeakAmount; // เงินค่า Off Peak
  final String holidayAmount; // เงินค่า Holiday
  final String baseAmount;    // รวมเงินค่าพลังงานไฟฟ้า (ก่อน Ft)
  
  // --- ส่วนสรุป (Summary) ---
  final String ftRate;        // เรท Ft
  final String ftAmount;      // รวมเงินค่า Ft
  final String totalBeforeVat;// รวมค่าไฟฟ้า (Base + Ft)
  final String vatAmount;     // ภาษี 7%
  final String grandTotal;    // รวมทั้งสิ้น

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
    required this.onPeakRate,
    required this.offPeakRate,
    required this.holidayRate,
    required this.onPeakAmount,
    required this.offPeakAmount,
    required this.holidayAmount,
    required this.baseAmount,
    required this.ftRate,
    required this.ftAmount,
    required this.totalBeforeVat,
    required this.vatAmount,
    required this.grandTotal,
  });
}