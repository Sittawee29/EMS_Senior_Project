part of '../../page.dart';

class DataOverview extends StatelessWidget {
  // [0]: PV_Daily (Total Prod)
  // [1]: BESS_Charge
  // [2]: Grid_Export (Feed-in)
  // [3]: Load_Daily (Total Cons)
  // [4]: Grid_Import (Purchased)
  // [5]: BESS_Discharge
  final List<double> data;

  const DataOverview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // ป้องกันกรณี data ว่างหรือ index ไม่ครบ
    final safeData = data.length >= 6 ? data : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

    // --- 1. แยกตัวแปรออกมาให้ชัดเจน ---
    final double totalProduction = safeData[0];
    final double batteryCharge = safeData[1];
    final double feedIn = safeData[2];

    final double totalConsumption = safeData[3];
    final double powerPurchased = safeData[4];
    final double batteryDischarge = safeData[5];

    // --- 2. คำนวณค่า Self-used (ผลิตใช้เอง) ---
    // สูตร: ผลิตรวม - ส่งออก - ชาร์จแบต = ใช้เอง
    double selfUsed = totalProduction - feedIn - batteryCharge;
    // ป้องกันค่าติดลบกรณี Data คลาดเคลื่อนเล็กน้อย
    if (selfUsed < 0) selfUsed = 0;

    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // --- กราฟฝั่ง Production ---
          TotalProduction(
            totalValue: totalProduction,
            prodUsed: selfUsed,
            prodBatteryCharge: batteryCharge,
            prodFeedIn: feedIn, // เพิ่ม param นี้
          ),
          const VerticalDivider(color: Palette.lightGrey),
          // --- กราฟฝั่ง Consumption ---
          TotalConsumption(
            totalValue: totalConsumption,
            consSelfUsed: selfUsed, // ใช้ค่าเดียวกับฝั่ง Prod ได้ หรือจะคำนวณใหม่จาก Cons - Buy - Discharge ก็ได้
            consPowerPurchased: powerPurchased,
            consBatteryDischarge: batteryDischarge, // เพิ่ม param นี้
          ),
        ],
      ),
    );
  }
}

class SmartLabel extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double angle;

  const SmartLabel({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    double visualAngle = (angle + 180) % 360;
    bool isLeft = visualAngle > 90 && visualAngle < 270;
    bool isTop = visualAngle >= 250 && visualAngle <= 290;

    const titleStyle = TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.1);
    const valueStyle = TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold, height: 1.1);

    return CustomPaint(
      painter: RadialLinePainter(
        angle: angle,
        color: Colors.grey.withOpacity(0.5),
        // 👇 นี่คือ "ระยะห่างจากกึ่งกลางป้าย ถึง ปลายเส้น"
        // ต้องกำหนดให้ยาวพอที่จะพ้นคำที่ยาวที่สุด (เช่น BESS Discharge)
        // ถ้าเลขนี้คงที่ -> ปลายเส้นจะคงที่เสมอ
        fixedTipDistance: 65, 
      ),
      child: Container(
        padding: const EdgeInsets.all(4), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isTop ? CrossAxisAlignment.center : (isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start),
          children: [
            Text(title, 
              style: titleStyle, 
              textAlign: isTop ? TextAlign.center : (isLeft ? TextAlign.right : TextAlign.left),
              softWrap: false,
            ),
            Text(value, 
              style: valueStyle,
              textAlign: isTop ? TextAlign.center : (isLeft ? TextAlign.right : TextAlign.left),
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

class RadialLinePainter extends CustomPainter {
  final double angle;
  final Color color;
  final double fixedTipDistance; // เปลี่ยนจาก lineLength เป็น fixedTipDistance

  RadialLinePainter({
    required this.angle,
    required this.color,
    required this.fixedTipDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    // คำนวณทิศทาง (ชี้เข้าหากราฟ)
    double radians = angle * (pi / 180); 
    double dx = cos(radians);
    double dy = sin(radians);

    // --- 1. หาจุดเริ่ม (Start) ที่ขอบกล่องข้อความ ---
    double halfW = size.width / 2;
    double halfH = size.height / 2;
    
    double tx = (dx == 0) ? double.infinity : halfW / dx.abs();
    double ty = (dy == 0) ? double.infinity : halfH / dy.abs();
    double t = (tx < ty) ? tx : ty;

    Offset startPoint = center + Offset(dx * t, dy * t);

    // --- 2. หาจุดจบ (End) ที่ระยะ Fixed Distance ---
    // แทนที่จะบวกความยาวเพิ่ม เรากำหนดเลยว่าปลายต้องห่างจาก Center เท่ากับ fixedTipDistance
    // สูตรนี้จะทำให้ปลายเส้นนิ่งสนิท ไม่สนว่ากล่องข้อความจะกว้างแค่ไหน
    Offset endPoint = center + Offset(dx * fixedTipDistance, dy * fixedTipDistance);

    // วาดเส้น (ถ้ากล่องข้อความใหญ่เกินระยะเส้น เส้นจะหดหายไปเอง ไม่บั๊ก)
    if (fixedTipDistance > t) {
       canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --------------------------------------------------------------------------
// 1. Total Production (สีฟ้า)
// --------------------------------------------------------------------------
class TotalProduction extends StatelessWidget {
  const TotalProduction({
    super.key,
    required this.totalValue,
    required this.prodUsed,
    required this.prodBatteryCharge,
    required this.prodFeedIn,
  });

  final double totalValue;
  final double prodUsed;
  final double prodBatteryCharge;
  final double prodFeedIn;

  final Color colorSelfUsed = const Color(0xFF1976D2);
  final Color colorFeedIn = const Color(0xFF90CAF9);
  final Color colorBatteryCharge = const Color(0xFF42A5F5);

  List<PieChartSectionData> generateSections() {
    // เตรียมข้อมูลเพื่อคำนวณองศา
    final dataList = [
      {'value': prodUsed, 'color': colorSelfUsed, 'title': 'Self-used'},
      {'value': prodFeedIn, 'color': colorFeedIn, 'title': 'Feed-in'},
      {'value': prodBatteryCharge, 'color': colorBatteryCharge, 'title': 'BESS Charge'},
    ];

    // คำนวณผลรวม (ถ้าเป็น 0 ให้กันหารด้วย 0)
    double sum = dataList.fold(0.0, (p, c) => p + (c['value'] as double));
    if (sum == 0) sum = 1;

    double currentAngle = 0; // เริ่มต้นที่ 0 (ในโค้ด) ซึ่งจะเท่ากับ 180 (Visual)
    List<PieChartSectionData> sections = [];

    for (var item in dataList) {
      double value = item['value'] as double;
      Color color = item['color'] as Color;
      String title = item['title'] as String;

      if (value > 0) {
        // คำนวณ Sweep Angle (กินพื้นที่กี่องศา)
        double sweepAngle = (value / sum) * 360;
        // คำนวณ Mid Angle (จุดกึ่งกลางของชิ้นนี้) เพื่อใช้ระบุตำแหน่งป้าย
        double midAngle = currentAngle + (sweepAngle / 2);

        sections.add(
          PieChartSectionData(
            color: color,
            value: value,
            radius: 20, // ความหนาวงกลม
            showTitle: false,
            badgeWidget: SmartLabel(
              title: title,
              value: '${value.toStringAsFixed(2)} kWh',
              color: color,
              angle: midAngle, // ส่งองศากึ่งกลางไปให้ SmartLabel ตัดสินใจ
            ),
            // ปรับระยะห่าง: ถ้าอยู่ข้างบน (Feed-in) อาจต้องดันออกไปเยอะหน่อยกันชน
            badgePositionPercentageOffset: (midAngle > 80 && midAngle < 100) ? 4.3 : 4.3,
          ),
        );
        // ขยับจุดเริ่มต้นไปยังชิ้นถัดไป
        currentAngle += sweepAngle;
      }
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 400, // ขยายพื้นที่ให้กว้างพอ
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    startDegreeOffset: 180, // เริ่มวาดจาก 9 นาฬิกา
                    sectionsSpace: 2,
                    centerSpaceRadius: 70, // รัศมีวงใน
                    sections: generateSections(),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Total Production', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('${totalValue.toStringAsFixed(2)} kWh',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. Total Consumption (สีแดง)
// --------------------------------------------------------------------------
class TotalConsumption extends StatelessWidget {
  const TotalConsumption({
    super.key,
    required this.totalValue,
    required this.consPowerPurchased,
    required this.consSelfUsed,
    required this.consBatteryDischarge,
  });

  final double totalValue;
  final double consPowerPurchased;
  final double consSelfUsed;
  final double consBatteryDischarge;

  final Color colorProduction = const Color(0xFFFF8A80);
  final Color colorPurchased = const Color(0xFFEF5350);
  final Color colorDischarge = const Color(0xFFFFCCBC);

  List<PieChartSectionData> generateSections() {
    final dataList = [
      {'value': consSelfUsed, 'color': colorProduction, 'title': 'Production'},
      {'value': consPowerPurchased, 'color': colorPurchased, 'title': 'Purchased'},
      {'value': consBatteryDischarge, 'color': colorDischarge, 'title': 'BESS Discharge'},
    ];

    double sum = dataList.fold(0.0, (p, c) => p + (c['value'] as double));
    if (sum == 0) sum = 1;

    double currentAngle = 0;
    List<PieChartSectionData> sections = [];

    for (var item in dataList) {
      double value = item['value'] as double;
      Color color = item['color'] as Color;
      String title = item['title'] as String;

      if (value > 0) {
        double sweepAngle = (value / sum) * 360;
        double midAngle = currentAngle + (sweepAngle / 2);

        sections.add(
          PieChartSectionData(
            color: color,
            value: value,
            radius: 20,
            showTitle: false,
            badgeWidget: SmartLabel(
              title: title,
              value: '${value.toStringAsFixed(2)} kWh',
              color: color,
              angle: midAngle,
            ),
            badgePositionPercentageOffset: (midAngle > 80 && midAngle < 100) ? 4.3 : 4.3,
          ),
        );
        currentAngle += sweepAngle;
      }
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 400,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    startDegreeOffset: 180,
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    sections: generateSections(),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Total Consumption', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('${totalValue.toStringAsFixed(2)} kWh',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}