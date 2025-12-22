import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// Import ไฟล์ Model และ Service ที่ท่านสร้างไว้
import 'bill_model.dart';
import 'bill_service.dart';
import 'thai_baht_utils.dart';

const Color primaryAppColor = Color.fromRGBO(28, 134, 223, 1);
const Color meaOrange = Color(0xFFE85E26);

@RoutePage()
class EBillingPage extends StatefulWidget {
  const EBillingPage({super.key});

  @override
  State<EBillingPage> createState() => _EBillingPageState();
}

class _EBillingPageState extends State<EBillingPage> {
  // สร้าง Instance ของ Service
  final BillService _billService = BillService();

  @override
  void initState() {
    super.initState();
    // เริ่มต้นจำลองข้อมูล Realtime เมื่อเปิดหน้าจอ
    _billService.startRealtimeSimulation();
  }

  @override
  void dispose() {
    // หยุดการทำงานเมื่อออกจากหน้าจอ เพื่อคืนหน่วยความจำ
    _billService.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-Billing'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'TOU (Time of Use)'),
            ],
            labelColor: primaryAppColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryAppColor,
            indicatorWeight: 3.0,
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBarView(
            children: [
              // Tab 1: General Meter (ผูกกับ Stream General)
              _buildStreamBillView(
                stream: _billService.generalBillStream, 
                meterType: 'General Meter'
              ),
              // Tab 2: TOU Meter (ผูกกับ Stream TOU)
              _buildStreamBillView(
                stream: _billService.touBillStream, 
                meterType: 'TOU Meter'
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ตัวช่วยสำหรับสร้าง StreamBuilder
  Widget _buildStreamBillView({required Stream<BillModel> stream, required String meterType}) {
    return StreamBuilder<BillModel>(
      stream: stream,
      builder: (context, snapshot) {
        // กรณีรอข้อมูลชุดแรก
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // กรณีมี Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // กรณีไม่มีข้อมูล
        if (!snapshot.hasData) {
          return const Center(child: Text('No Data'));
        }

        // เมื่อได้ข้อมูลมาแล้ว ให้ส่ง data ไปยัง Widget แสดงผล
        final data = snapshot.data!;
        
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: BillContentWidget(
              meterType: meterType,
              data: data, // ส่งข้อมูล Realtime เข้าไป
            ),
          ),
        );
      },
    );
  }
}

class BillContentWidget extends StatelessWidget {
  final String meterType;
  final BillModel data; // รับข้อมูล Model เข้ามา

  const BillContentWidget({
    super.key, 
    required this.meterType,
    required this.data, // บังคับส่งข้อมูล
  });

  // สไตล์ข้อความทั่วไปในบิล
  TextStyle get _billTextStyle => const TextStyle(
        fontFamily: 'Sarabun',
        fontSize: 10,
        color: Colors.black87,
        height: 1.4,
      );

  TextStyle get _headerTextStyle => _billTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              const Center(
                child: Text(
                  'ใบเสร็จรับเงิน / ใบกำกับภาษี\n(Receipt / Tax Invoice)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Address (Left)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40, // กำหนดขนาดความกว้างของโลโก้ (ปรับได้ตามชอบ)
                              height: 40, // กำหนดขนาดความสูง (ควรเท่ากับความกว้างเพื่อให้เป็นวงกลมสวยๆ)
                              child: ClipOval(
                                // ClipOval จะตัด child ข้างในให้เป็นวงกลม
                                child: Image.asset(
                                  'assets/images/mea_logo.png', // <-- path ของไฟล์รูปภาพที่คุณเตรียมไว้
                                  fit: BoxFit.cover, // ปรับให้รูปขยายเต็มพื้นที่วงกลม (หรือลองใช้ BoxFit.contain ถ้าโลโก้โดนตัด)
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('การไฟฟ้านครหลวง',
                                    style: _headerTextStyle.copyWith(fontSize: 14, color: Colors.black)),
                                Text('Metropolitan Electricity Authority',
                                    style: _billTextStyle.copyWith(fontSize: 10, color: Colors.grey[700])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('อาคารวัฒนวิภาส เลขที่ 1192 ถนนพระรามที่ 4 แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110', style: _billTextStyle),
                        Text('เลขประจำตัวผู้เสียภาษีอากร (Tax ID) : 0994000165200', style: _billTextStyle),
                      ],
                    ),
                  ),
                  // Doc No (Right) -> ใช้ข้อมูลจาก data
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        _buildLabelValueRight('เลขที่ (No.) :', data.invoiceNo),
                        _buildLabelValueRight('สำนักงานใหญ่', ''),
                        _buildLabelValueRight('วันที่ (Date) :', data.documentDate),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 2. CUSTOMER INFO SECTION -> ใช้ข้อมูลจาก data
              _buildInfoRow('ผู้ชำระเงิน (Name) :', data.payerName),
              Row(
                children: [
                  Expanded(child: _buildInfoRow('เลขประจำตัวผู้เสียภาษีอากร (Tax ID) :', '-')),
                  Expanded(child: _buildInfoRow('สาขาที่ (Branch) :', '-')),
                ],
              ),
              _buildInfoRow('ที่อยู่ผู้ชำระเงิน (Address) :', data.payerAddress),
              _buildInfoRow('ชื่อผู้ใช้ไฟฟ้า (Name) :', data.payerName),
              _buildInfoRow('สถานที่ใช้ไฟฟ้า (Premise) :', data.payerAddress),
              Row(
                children: [
                  Expanded(flex: 3, child: _buildInfoRow('บัญชีแสดงสัญญา (Contract Account) :', data.contractAccount)),
                  Expanded(flex: 2, child: _buildInfoRow('รหัสเครื่องวัด (Meter No.) :', data.meterNo)),
                ],
              ),
              const SizedBox(height: 20),

              // 3. TABLE SECTION (High density) -> ใช้ข้อมูลจาก data
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1.4), // วันที่จด
                  1: FlexColumnWidth(1.4), // เลขที่ใบแจ้ง
                  2: FlexColumnWidth(0.8), // หน่วย
                  3: FlexColumnWidth(1.4), // ค่าไฟฟ้า
                  4: FlexColumnWidth(1.1), // VAT
                  5: FlexColumnWidth(1.4), // จำนวนเงิน
                  6: FlexColumnWidth(1.0), // วันปรับ
                  7: FlexColumnWidth(1.1), // เบี้ยปรับ
                  8: FlexColumnWidth(0.9), // ft
                },
                children: [
                  // --- Header Row ---
                  TableRow(
                    children: [
                      _buildTableHeader('วันที่จดเลขอ่าน\n(Meter Reading Date)'),
                      _buildTableHeader('เลขที่ใบแจ้งฯ\n(Invoice No.)'),
                      _buildTableHeader('จำนวนหน่วย\n(Unit)'),
                      // ปรับ Header ให้ชิดขวาตามข้อมูลตัวเลข
                      _buildTableHeader('ค่าไฟฟ้า\n(Charge)', align: TextAlign.right),
                      _buildTableHeader('ภาษีมูลค่าเพิ่ม\n(VAT)', align: TextAlign.right),
                      _buildTableHeader('จำนวนเงิน\n(Amount)', align: TextAlign.right),
                      _buildTableHeader('จำนวนวันปรับ\n(Days)'),
                      _buildTableHeader('เบี้ยปรับ\n(Penalty)', align: TextAlign.right),
                      _buildTableHeader('ค่า Ft\n(Ft)', align: TextAlign.right),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 12), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()
                    ]
                  ),
                  // --- Data Row (ใช้ข้อมูล Realtime) ---
                  TableRow(
                    children: [
                      _buildTableData('21/11/2568', align: TextAlign.center),
                      _buildTableData(data.invoiceNo, align: TextAlign.center),
                      _buildTableData(data.unit, align: TextAlign.center), // <--- Realtime
                      _buildTableData(data.electricityCharge, align: TextAlign.right), // <--- Realtime
                      _buildTableData(data.vat, align: TextAlign.right), // <--- Realtime
                      _buildTableData(data.amount, align: TextAlign.right), // <--- Realtime
                      _buildTableData('0', align: TextAlign.center),
                      _buildTableData('0.00', align: TextAlign.right),
                      _buildTableData(data.ftRate, align: TextAlign.right),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 4. FOOTER SECTION -> ใช้ข้อมูลจาก data
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Footer Left
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('วันที่พิมพ์เอกสาร (Print Date) : ${data.documentDate}', style: _billTextStyle), // ใช้วันที่เดียวกับเอกสารไปก่อน
                        const SizedBox(height: 4),
                        Text('ชำระผ่าน : ธ.กรุงไทย', style: _billTextStyle),
                        const SizedBox(height: 4),
                        Text('FICA DOC. 658047150970 TIV001', style: _billTextStyle.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  // Footer Right (Totals)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        _buildSummaryRow('รวมเงิน (Amount) :', data.electricityCharge, 'บาท (Baht)'),
                        _buildSummaryRow('รวมภาษีมูลค่าเพิ่ม 7% (VAT Amount) :', data.vat, 'บาท (Baht)'),
                        _buildSummaryRow('รวม (Total) :', data.amount, 'บาท (Baht)', isBold: true),
                        _buildSummaryRow('เบี้ยปรับผิดนัด (Penalty Charge) :', '0.00', 'บาท (Baht)'),
                        const SizedBox(height: 4),
                        _buildSummaryRow('รวมทั้งสิ้น (Total Amount) :', data.amount, 'บาท (Baht)', isTotal: true),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '(${ThaiBahtUtils.convert(data.amount)})', 
                            style: _billTextStyle.copyWith(fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text('*เอกสารนี้เป็นแบบจำลองการแสดงผลข้อมูล Realtime',
                  style: _billTextStyle.copyWith(color: Colors.red, fontSize: 9)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // Helper Widgets

  Widget _buildLabelValueRight(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: _billTextStyle.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        Text(value, style: _billTextStyle),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        text: TextSpan(
          style: _billTextStyle,
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ปรับแก้ให้รับ Align เพื่อให้ Header ตรงกับ Data (เช่น ชิดขวาสำหรับตัวเลขเงิน)
  Widget _buildTableHeader(String text, {TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        text,
        textAlign: align,
        style: _billTextStyle.copyWith(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildTableData(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        text,
        textAlign: align,
        style: _billTextStyle.copyWith(fontSize: 9),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String unit, {bool isBold = false, bool isTotal = false}) {
    TextStyle style = _billTextStyle.copyWith(
      fontWeight: (isBold || isTotal) ? FontWeight.bold : FontWeight.normal,
      fontSize: isTotal ? 12 : 10,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(value, textAlign: TextAlign.right, style: style),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 60,
                child: Text(unit, textAlign: TextAlign.right, style: style),
              ),
            ],
          ),
        ],
      ),
    );
  }
}