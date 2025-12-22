// bill_model.dart
class BillModel {
  final String invoiceNo;
  final String documentDate;
  final String payerName;
  final String payerAddress;
  final String contractAccount;
  final String meterNo;
  
  // ตัวแปรที่น่าจะเปลี่ยนแปลงบ่อย (Realtime)
  final String unit;            // จำนวนหน่วย
  final String electricityCharge; // ค่าไฟ
  final String vat;             // ภาษี
  final String amount;          // ยอดรวม
  final String ftRate;          // ค่า ft

  const BillModel({
    required this.invoiceNo,
    required this.documentDate,
    required this.payerName,
    required this.payerAddress,
    required this.contractAccount,
    required this.meterNo,
    required this.unit,
    required this.electricityCharge,
    required this.vat,
    required this.amount,
    required this.ftRate,
  });
}