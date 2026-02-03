import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'bill_model.dart';
import 'bill_service.dart';
import 'package:intl/intl.dart';
import 'thai_baht_utils.dart'; // ตรวจสอบว่ามีไฟล์นี้จริงหรือไม่ ถ้าไม่มีให้ comment ออก

const Color primaryAppColor = Color.fromRGBO(28, 134, 223, 1);
const Color meaOrange = Color(0xFFE85E26);

@RoutePage()
class EBillingPage extends StatefulWidget {
  const EBillingPage({super.key});

  @override
  State<EBillingPage> createState() => _EBillingPageState();
}

class _EBillingPageState extends State<EBillingPage> {
  final BillService _billService = BillService();

  // [โจทย์ข้อ 1] ตัวแปรควบคุมโหมด: 0 = General Meter, 1 = TOU Meter
  final int _meterMode = 1;

  @override
  void initState() {
    super.initState();
    _billService.startRealtimeSimulation();
  }

  @override
  void dispose() {
    _billService.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Billing'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _meterMode == 0
            ? _buildStreamBillView(
                stream: _billService.generalBillStream,
                meterType: 'General Meter',
                isTouMode: false)
            : _buildStreamBillView(
                stream: _billService.touBillStream,
                meterType: 'TOU Meter',
                isTouMode: true),
      ),
    );
  }

  Widget _buildStreamBillView({
    required Stream<BillModel> stream,
    required String meterType,
    required bool isTouMode,
  }) {
    return StreamBuilder<BillModel>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) return const Center(child: Text('No Data'));

        final data = snapshot.data!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: BillContentWidget(
              meterType: meterType,
              data: data,
              isTouMode: isTouMode,
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
  final bool isTouMode;
  final String companyNameLeft = 'บริษัท โปรลอจิค จำกัด';
  final String companyNameRight = 'UTI ENERGY CO.,LTD.';

  const BillContentWidget({
    super.key,
    required this.meterType,
    required this.data,
    required this.isTouMode,
  });

  // --- Styles ---
  TextStyle get _textStyle => const TextStyle(
        fontFamily: 'Sarabun',
        fontSize: 9,
        color: Colors.black,
        height: 1.2,
      );

  TextStyle get _headerStyle => _textStyle.copyWith(
        fontWeight: FontWeight.bold,
      );

  Color get _headerColor => const Color(0xFFD9D9D9);
  Color get _summaryHeaderColor => const Color(0xFFDAE3F3);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    DateTime prevReadDate;
    if (now.day >= 27) {
      // ถ้าวันนี้เลยวันที่ 27 แล้ว -> รอบก่อนคือวันที่ 27 เดือนนี้
      prevReadDate = DateTime(now.year, now.month, 27);
    } else {
      // ถ้ายังไม่ถึงวันที่ 27 -> รอบก่อนคือวันที่ 27 เดือนที่แล้ว
      // จัดการกรณีข้ามปี (เดือน 1 ถอยไปเดือน 12 ปีก่อน)
      if (now.month == 1) {
        prevReadDate = DateTime(now.year - 1, 12, 27);
      } else {
        prevReadDate = DateTime(now.year, now.month - 1, 27);
      }
    }
    final String prevReadDateStr = DateFormat('dd/MM/yyyy').format(prevReadDate);
    final targetDate = now.day >= 27
        ? DateTime(now.year, now.month + 1, 1)
        : now;
    final String billMonthYear = DateFormat('MM/yyyy').format(targetDate);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              children: [
                // Layer 1: Logo
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Image.asset(
                            'assets/images/Prologic_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Row(children: [
                              Icon(Icons.flash_on, color: Colors.blue),
                              Text("UTI ENERGY",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue))      
                            ]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(companyNameLeft,style: _headerStyle.copyWith(fontSize: 10)),    
                      ],
                    ),
                  ),
                ),

                // Layer 2: Title
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text('ใบเสร็จรับเงิน / ใบกำกับภาษี',style: _headerStyle.copyWith(fontSize: 14)),
                      Text('(Receipt / Tax invoice)',style: _headerStyle.copyWith(fontSize: 14)),  
                    ],
                  ),
                ),

                // Layer 3: Date
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: RichText(
                      text: TextSpan(
                        style: _headerStyle,
                        children: [
                          const TextSpan(text: 'บิลประจำเดือน   '),
                          TextSpan(
                              text: billMonthYear,
                              style: _headerStyle.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),
          // 2. CUSTOMER INFO
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: _headerColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ชื่อผู้ใช้ไฟฟ้า (Name)', companyNameRight),
                _buildInfoRow('สถานที่ใช้ไฟฟ้า (Premise)','66 1 อำเภอบางบัวทอง นนทบุรี 11110'),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 3. METER READING TABLE
          Table(
            columnWidths: isTouMode
                ? const {
                    0: FlexColumnWidth(1.3),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.0),
                    3: FlexColumnWidth(1.0),
                    4: FlexColumnWidth(0.9),
                    5: FlexColumnWidth(0.9),
                    6: FlexColumnWidth(0.9),
                    7: FlexColumnWidth(1.0),
                  }
                : const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.0),
                    3: FlexColumnWidth(1.0),
                    4: FlexColumnWidth(1.0),
                  },
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              // Row 1: Header (TH)
              TableRow(
                decoration: BoxDecoration(color: _headerColor),
                children: [
                  _buildCellHeader('เลขเครื่องมือวัด'),
                  _buildCellHeader('วันที่จดอ่านเลข'),
                  _buildCellHeader('เลขอ่านครั้งก่อน'),
                  _buildCellHeader('เลขอ่านครั้งหลัง'),
                  if (isTouMode) ...[
                    _buildCellHeader('จำนวนหน่วย On Peak'),
                    _buildCellHeader('จำนวนหน่วย Off Peak'),
                    _buildCellHeader('จำนวนหน่วย Holiday'),
                  ],
                  _buildCellHeader('จำนวนหน่วยรวม'),
                ],
              ),
              // Row 2: Header (EN)
              TableRow(
                decoration: BoxDecoration(color: _headerColor),
                children: [
                  _buildCellHeader('Meter serial no.', isSub: true),
                  _buildCellHeader('Meter reading date', isSub: true),
                  _buildCellHeader('Previous meter reading', isSub: true),
                  _buildCellHeader('Last meter reading', isSub: true),
                  if (isTouMode) ...[
                    _buildCellHeader('On Peak kWh', isSub: true),
                    _buildCellHeader('Off Peak kWh', isSub: true),
                    _buildCellHeader('Holiday kWh', isSub: true),
                  ],
                  _buildCellHeader('Total kWh', isSub: true),
                ],
              ),
              // Data Row 1
              TableRow(
                children: [
                  _buildCellData('SN251507270', isBold: true),
                  _buildCellData(prevReadDateStr, isBold: true),
                  _buildCellData(data.prevRead, isBold: true),
                  _buildCellData(data.lastRead, isBold: true),
                  if (isTouMode) ...[
                    _buildCellData(data.onPeakUnit, isBold: true),
                    _buildCellData(data.offPeakUnit, isBold: true),
                    _buildCellData(data.holidayUnit, isBold: true),
                  ],
                  _buildCellData(data.totalUnit, isBold: true),
                ],
              ),
              // Data Row 2 (Empty)
              TableRow(
                children: [
                  _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true),
                  _buildCellData('-', isBold: true),
                  if (isTouMode) ...[
                    _buildCellData('-', isBold: true),
                    _buildCellData('-', isBold: true),
                    _buildCellData('-', isBold: true),
                  ],
                  _buildCellData('-', isBold: true),
                ],
              ),
              // Total Row
              TableRow(
                children: [
                  const SizedBox(),
                  const SizedBox(),
                  const SizedBox(),
                  const SizedBox(),
                  if (isTouMode) ...[
                    _buildCellData(data.onPeakUnit, isBold: true, fontSize: 11),
                    _buildCellData(data.offPeakUnit,isBold: true, fontSize: 11),
                    _buildCellData(data.holidayUnit,isBold: true, fontSize: 11),
                  ],
                  _buildCellData(data.totalUnit, isBold: true, fontSize: 11),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. CALCULATION & SUMMARY SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Container(
                      color: _headerColor,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      width: double.infinity,
                      child: Center(
                          child: Text('รายละเอียดค่าพลังงานไฟฟ้า',
                              style: _headerStyle)),
                    ),
                    _buildCalculationTable(),
                    const SizedBox(height: 15),

                    // Blue Summary Box
                    Container(
                      color: _summaryHeaderColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('รายละเอียดค่าไฟฟ้า (Description)',
                              style: _headerStyle),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isTouMode) ...[
                      _buildSummaryLine('ค่าพลังงานไฟฟ้า On Peak (${data.onPeakUnit} หน่วย)','${NumberFormat("#,##0.00").format((double.tryParse(data.onPeakAmount.replaceAll(',', '')) ?? 0.0))} บาท'),
                      _buildSummaryLine('ค่าพลังงานไฟฟ้า Off Peak (${data.offPeakUnit} หน่วย)','${NumberFormat("#,##0.00").format((double.tryParse(data.offPeakAmount.replaceAll(',', '')) ?? 0.0))} บาท'),
                      _buildSummaryLine('ค่าพลังงานไฟฟ้า Holiday (${data.holidayUnit} หน่วย)','${NumberFormat("#,##0.00").format((double.tryParse(data.holidayAmount.replaceAll(',', '')) ?? 0.0))} บาท'),
                    ] else ...[
                      _buildSummaryLine('ค่าพลังงานไฟฟ้า (${data.totalUnit} หน่วย)','${NumberFormat("#,##0.00").format((double.tryParse(data.generalAmount.replaceAll(',', '')) ?? 0.0))} บาท'),
                    ],
                    _buildSummaryLine('ค่าบริการรายเดือน', '${data.serviceCharge} บาท'),
                    _buildSummaryLine('ค่า Ft (${data.ftRate} บาท/หน่วย)','${data.ftAmount} บาท'),  
                    const Divider(color: Colors.black, thickness: 1),
                    if (isTouMode) ...[
                      _buildSummaryLine('รวมค่าไฟฟ้า', '${data.TOUtotalBeforeVat} บาท'),
                      _buildSummaryLine('ภาษีมูลค่าเพิ่ม 7%', '${data.TOUvatAmount} บาท'),
                    ] else ...[
                      _buildSummaryLine('รวมค่าไฟฟ้า', '${data.GeneraltotalBeforeVat} บาท'),
                      _buildSummaryLine('ภาษีมูลค่าเพิ่ม 7%', '${data.GeneralvatAmount} บาท'),         
                    ],

                    const Divider(color: Colors.black, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('รวมค่าไฟฟ้าเดือนปัจจุบัน',style: _headerStyle.copyWith(fontSize: 12)),
                          if (isTouMode) ...[
                            Text('${data.TOUgrandTotal} บาท',style: _headerStyle.copyWith(fontSize: 14)),
                          ] else ...[
                            Text('${data.GeneralgrandTotal} บาท',style: _headerStyle.copyWith(fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black, thickness: 1),
                    const Divider(color: Colors.black, thickness: 1),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // 5. FOOTER
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 20),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSignatureLine(companyNameLeft),
                        _buildSignatureLine(companyNameRight),
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

  // [แก้ไข] เปลี่ยน Return Type เป็น TableRow โดยตรง เพื่อให้ใช้ใน Children ของ Table ได้
  ({TableRow row, double returnAmount}) _buildDynamicRow(String label, String rateStr, String amountStr) {
    // 1. แปลง String เป็น Double
    double rate = double.tryParse(rateStr.replaceAll(',', '')) ?? 0.0;
    double amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;

    // 2. คำนวณ (จ่าย 45% คือลด 55%)
    double discountedRate = rate * 0.45;

    // 3. จัด Format
    final fmt4 = NumberFormat("#,##0.0000");
    final fmt2 = NumberFormat("#,##0.00");

    // สร้าง Row
    TableRow rowWidget = TableRow(children: [
      _buildCellText(label),
      _buildCellText(rateStr, align: TextAlign.right),
      _buildCellText(fmt4.format(discountedRate), align: TextAlign.right),
      _buildCellText('${fmt2.format(amount)} บาท', align: TextAlign.right),
    ]);

    // return ออกไปทั้ง Widget (row) และ ค่าเงิน (returnAmount)
    return (row: rowWidget, returnAmount: amount);
  }
  // --- Helper Widgets ---

  Widget _buildCalculationTable() {
    List<TableRow> myTableRows = [];
    double totalSum = 0.0; // ตัวแปรสำหรับรวมยอดเงิน

    // 1. ส่วนหัวตาราง (Header)
    myTableRows.add(TableRow(
      children: [
        _buildCellHeader('จำนวนหน่วย', align: TextAlign.left),
        _buildCellHeader('ค่าไฟฟ้าต่อหน่วย\nอัตราปกติ', align: TextAlign.right),
        _buildCellHeader('ค่าไฟฟ้าต่อหน่วย\nส่วนลด 55%', align: TextAlign.right),
        _buildCellHeader('หักส่วนลด 55% เหลือ', align: TextAlign.right),
      ],
    ));

    // 2. เรียกฟังก์ชัน และแยกค่าที่ได้
    if (isTouMode) {
      // On Peak
      var onPeakResult = _buildDynamicRow('On Peak จำนวน ${data.onPeakUnit} หน่วย',data.onPeakRate,data.onPeakAmount);
      myTableRows.add(onPeakResult.row);
      totalSum += onPeakResult.returnAmount;

      // Off Peak
      var offPeakResult = _buildDynamicRow('Off Peak จำนวน ${data.offPeakUnit} หน่วย',data.offPeakRate,data.offPeakAmount);
      myTableRows.add(offPeakResult.row);
      totalSum += offPeakResult.returnAmount;

      // Holiday
      var holidayResult = _buildDynamicRow('Holiday จำนวน ${data.holidayUnit} หน่วย',data.holidayRate,data.holidayAmount);
      myTableRows.add(holidayResult.row);
      totalSum += holidayResult.returnAmount;
    } else {
      // General
      var genResult = _buildDynamicRow('ค่าพลังงานไฟฟ้า จำนวน ${data.totalUnit} หน่วย',data.generalRate,data.generalAmount); 
      myTableRows.add(genResult.row);
      totalSum += genResult.returnAmount;
    }

    // 3. เพิ่ม Row รวม (Total)
    myTableRows.add(TableRow(children: [
      _buildCellText('รวม', isBold: true),
      const SizedBox(),
      const SizedBox(),
      _buildCellText('${NumberFormat("#,##0.00").format(totalSum)} บาท',
          align: TextAlign.right, isBold: true),
    ]));

    // 4. Return Widget Table ออกไป
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.5),
      },
      children: myTableRows,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: _textStyle.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: _textStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildCellHeader(String text,
      {bool isSub = false, TextAlign align = TextAlign.center}) {
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

  Widget _buildCellData(String text,
      {bool isBold = false, double fontSize = 9}) {
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

  Widget _buildCellText(String text,
      {TextAlign align = TextAlign.left, bool isBold = false}) {
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