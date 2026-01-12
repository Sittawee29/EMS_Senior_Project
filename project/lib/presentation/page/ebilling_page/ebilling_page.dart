import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
  final BillModel data;

  const BillContentWidget({
    super.key,
    required this.meterType,
    required this.data,
  });

  // --- Styles ---
  TextStyle get _textStyle => const TextStyle(
        fontFamily: 'Sarabun',
        fontSize: 9, // ลดขนาดฟอนต์เพื่อให้ตารางพอดี
        color: Colors.black,
        height: 1.2,
      );

  TextStyle get _headerStyle => _textStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
  
  // สีหัวตาราง (เทาอ่อน)
  Color get _headerColor => const Color(0xFFD9D9D9);
  // สีหัวข้อสรุป (ฟ้าอ่อน)
  Color get _summaryHeaderColor => const Color(0xFFDAE3F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================================
          // 1. HEADER (Logo & Document Title)
          // =========================================
          // [แก้ไข] ใช้ Stack เพื่อให้ Title อยู่ตรงกลางหน้ากระดาษพอดี โดยไม่เบียดกับ Logo
          SizedBox(
            height: 80, // กำหนดความสูงพื้นที่ Header
            child: Stack(
              children: [
                // Layer 1: Logo & Company Name (ชิดซ้าย)
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 200, // จำกัดความกว้างไม่ให้ทับชื่อตรงกลาง
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Image.asset('assets/images/Prologic_logo.png', fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Row(children: [Icon(Icons.flash_on, color: Colors.blue), Text("UTI ENERGY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))])),
                        ),
                        const SizedBox(height: 5),
                        Text('บริษัท โปรลอจิค จำกัด', style: _headerStyle.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                ),

                // Layer 2: Bill Title (อยู่ตรงกลางหน้ากระดาษเป๊ะๆ)
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text('ใบเสร็จรับเงิน / ใบกำกับภาษี', style: _headerStyle.copyWith(fontSize: 14)),
                      Text('(Receipt / Tax invoice)', style: _headerStyle.copyWith(fontSize: 14)),
                    ],
                  ),
                ),

                // Layer 3: Date (ชิดขวา)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0), // ขยับลงมานิดหน่อยให้สวยงาม
                    child: RichText(
                      text: TextSpan(
                        style: _headerStyle,
                        children: [
                          const TextSpan(text: 'บิลประจำเดือน   '),
                          TextSpan(text: '11/2025', style: _headerStyle.copyWith(fontSize: 12)), 
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 5),
          // =========================================
          // 2. CUSTOMER INFO (Grey Box)
          // =========================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: _headerColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ชื่อผู้ใช้ไฟฟ้า (Name)', 'บริษัท โรบินสัน จำกัด (มหาชน)'),
                _buildInfoRow('สถานที่ใช้ไฟฟ้า (Premise)', 'โรบินสัน ไลฟ์สไตล์ ลาดกระบัง'),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // =========================================
          // 3. METER READING TABLE (ตารางบน)
          // =========================================
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.0), 5: FlexColumnWidth(1.0), 6: FlexColumnWidth(1.0), 7: FlexColumnWidth(1.0),
            },
            children: [
              // Header Row 1 (Thai)
              TableRow(
                decoration: BoxDecoration(color: _headerColor),
                children: [
                  _buildCellHeader('เลขเครื่องมือวัด'),
                  _buildCellHeader('วันที่จดอ่านเลข'),
                  _buildCellHeader('เลขอ่านครั้งก่อน'),
                  _buildCellHeader('เลขอ่านครั้งหลัง'),
                  _buildCellHeader('จำนวนหน่วย On Peak'),
                  _buildCellHeader('จำนวนหน่วย Off Peak'),
                  _buildCellHeader('จำนวนหน่วย Holiday'),
                  _buildCellHeader('จำนวนหน่วยรวม'),
                ],
              ),
              // Header Row 2 (English)
              TableRow(
                decoration: BoxDecoration(color: _headerColor),
                children: [
                  _buildCellHeader('Meter serial no.', isSub: true),
                  _buildCellHeader('Meter reading date', isSub: true),
                  _buildCellHeader('Previous meter reading', isSub: true),
                  _buildCellHeader('Last meter reading', isSub: true),
                  _buildCellHeader('On Peak kWh', isSub: true),
                  _buildCellHeader('Total kWh', isSub: true), // ในรูปเขียน Total kWh ที่ช่อง Off Peak (?) ตามรูปต้นฉบับ
                  _buildCellHeader('Total kWh', isSub: true),
                  _buildCellHeader('Total kWh', isSub: true),
                ],
              ),
              // Data Row 1 (ตัวอย่างใช้ค่าจาก data)
              TableRow(
                children: [
                  _buildCellData('SN251507270', isBold: true),
                  _buildCellData(data.meterLastReadDate, isBold: true),
                  _buildCellData(data.prevRead, isBold: true), // <--- ตัวแปร
                  _buildCellData(data.lastRead, isBold: true), // <--- ตัวแปร
                  _buildCellData(data.onPeakUnit, isBold: true), // <--- ตัวแปร
                  _buildCellData(data.offPeakUnit, isBold: true), // <--- ตัวแปร
                  _buildCellData(data.holidayUnit, isBold: true), // <--- ตัวแปร
                  _buildCellData(data.totalUnit, isBold: true),   // <--- ตัวแปร
                ],
              ),
              // Data Row 2 (ถ้ามีมิเตอร์ลูกที่ 2 ก็ทำเหมือนกัน หรือปล่อยว่างไว้ก่อน)
              TableRow(
                children: [
                  _buildCellData('-', isBold: true), _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true), _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true), _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true), _buildCellData('-', isBold: true),
                ],
              ),
              // Total Row
              TableRow(
                children: [
                  const SizedBox(), const SizedBox(), const SizedBox(), const SizedBox(),
                  _buildCellData(data.onPeakUnit, isBold: true, fontSize: 11), // <--- ตัวแปร
                  _buildCellData(data.offPeakUnit, isBold: true, fontSize: 11), // <--- ตัวแปร
                  _buildCellData(data.holidayUnit, isBold: true, fontSize: 11), // <--- ตัวแปร
                  _buildCellData(data.totalUnit, isBold: true, fontSize: 11,), // <--- ตัวแปร
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // =========================================
          // 4. CALCULATION & SUMMARY SECTION
          // =========================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Spacer Left ---
              const Expanded(flex: 3, child: SizedBox()), // เว้นว่างด้านซ้ายให้ตรงตามรูป

              // --- Right Side Content ---
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // Grey Header for Calculation
                    Container(
                      color: _headerColor,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      width: double.infinity,
                      child: Center(child: Text('รายละเอียดค่าพลังงานไฟฟ้า', style: _headerStyle)),
                    ),
                    
                    // Calculation Table
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5), // Description
                        1: FlexColumnWidth(1.2), // Rate Normal
                        2: FlexColumnWidth(1.2), // Rate Discount
                        3: FlexColumnWidth(1.5), // Total
                      },
                      children: [
                        // Header
                        TableRow(
                          children: [
                            _buildCellHeader('จำนวนหน่วย', align: TextAlign.left),
                            _buildCellHeader('ค่าไฟฟ้าต่อหน่วย\nอัตราปกติ', align: TextAlign.right),
                            _buildCellHeader('ค่าไฟฟ้าต่อหน่วย\nส่วนลด 55%', align: TextAlign.right),
                            _buildCellHeader('หักส่วนลด 55% เหลือ', align: TextAlign.right),
                          ],
                        ),
                        // Row: On Peak
                        TableRow(children: [
                          _buildCellText('On Peak จำนวน 120520 หน่วย'),
                          _buildCellText('4.1839', align: TextAlign.right),
                          _buildCellText('1.8828', align: TextAlign.right),
                          _buildCellText('226,909.63 บาท', align: TextAlign.right),
                        ]),
                        // Row: Off Peak
                         TableRow(children: [
                          _buildCellText('Off Peak จำนวน 14586 หน่วย'),
                          _buildCellText('2.6037', align: TextAlign.right),
                          _buildCellText('1.1717', align: TextAlign.right),
                          _buildCellText('17,089.91 บาท', align: TextAlign.right),
                        ]),
                        // Row: Holiday
                         TableRow(children: [
                          _buildCellText('Holiday จำนวน 69018 หน่วย'),
                          _buildCellText('2.6037', align: TextAlign.right),
                          _buildCellText('1.1717', align: TextAlign.right),
                          _buildCellText('80,865.97 บาท', align: TextAlign.right),
                        ]),
                        // Row: Total
                         TableRow(children: [
                          _buildCellText('รวม'),
                          const SizedBox(),
                          const SizedBox(),
                          _buildCellText('324,865.51 บาท', align: TextAlign.right, isBold: true),
                        ]),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // --- Blue Summary Box ---
                    Container(
                      color: _summaryHeaderColor,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('รายละเอียดค่าไฟฟ้า (Description)', style: _headerStyle),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Summary Rows
                    _buildSummaryLine('ค่าพลังงานไฟฟ้าทั้งหมด', '324,865.51 บาท'),
                    _buildSummaryLine('ค่า Ft 0.0755 บาท/หน่วย', '15,411.36 บาท'),
                    const Divider(color: Colors.black, thickness: 1), // ขีดเส้นใต้ 1
                    _buildSummaryLine('รวมค่าไฟฟ้า', '340,276.87 บาท'),
                    _buildSummaryLine('ภาษีมูลค่าเพิ่ม 7%', '23,819.38 บาท'),
                    const Divider(color: Colors.black, thickness: 1), // ขีดเส้นใต้ 2
                    
                    // Grand Total
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('รวมค่าไฟฟ้าเดือนปัจจุบัน', style: _headerStyle.copyWith(fontSize: 12)),
                          Text('364,096.25 บาท', style: _headerStyle.copyWith(fontSize: 14)), // ใช้ data.amount ถ้าต้องการ Realtime
                        ],
                      ),
                    ),
                     const Divider(color: Colors.black, thickness: 1), 
                     const Divider(color: Colors.black, thickness: 1), // เส้นคู่ปิดท้าย
                  ],
                ),
              ),
            ],
          ),

          // =========================================
          // 5. FOOTER (QR, Banner, Sign)
          // =========================================
          
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left Footer
              /*
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QR Code
                    Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[200], // Placeholder สีเทา
                      child: Image.asset('assets/images/qr_code.png', fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => const Icon(Icons.qr_code, size: 50)),
                    ),
                    const SizedBox(height: 10),
                    // Banner Image
                    Container(
                      height: 50,
                      width: double.infinity,
                      color: Colors.blue[100], // Placeholder
                      child: Image.asset('assets/images/banner.png', fit: BoxFit.cover,
                         errorBuilder: (c,e,s) => const Center(child: Text('BANNER IMG'))),
                    ),
                    const SizedBox(height: 5),
                    Text('E-mail : uti@uboltech.com, Tel : 02-926-3791', style: _textStyle.copyWith(fontSize: 8)),
                    Text('Uboltech Intertrade Company S.L. All rights reserved.', style: _textStyle.copyWith(fontSize: 8)),
                  ],
                ),
              ),*/
              const SizedBox(width: 20),
              // Right Footer (Signatures)
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSignatureLine('บริษัท โปรลอจิค จำกัด'),
                        _buildSignatureLine('บมจ. โรบินสัน สาขาลาดกระบัง'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Page 1/2', style: _textStyle),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: _textStyle.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: _textStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildCellHeader(String text, {bool isSub = false, TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(
        text,
        textAlign: align,
        style: _textStyle.copyWith(
          fontSize: isSub ? 7 : 8,
          fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
          color: isSub ? Colors.black54 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildCellData(String text, {bool isBold = false, double fontSize = 9}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _textStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildCellText(String text, {TextAlign align = TextAlign.left, bool isBold = false}) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(
        text,
        textAlign: align,
        style: _textStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _textStyle),
          Text(value, style: _textStyle),
        ],
      ),
    );
  }

  Widget _buildSignatureLine(String text) {
    return Column(
      children: [
        Container(width: 120, height: 1, color: Colors.black),
        const SizedBox(height: 4),
        Text(text, style: _textStyle.copyWith(fontSize: 8)),
      ],
    );
  }
}