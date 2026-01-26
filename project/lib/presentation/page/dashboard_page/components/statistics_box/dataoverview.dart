part of '../../page.dart';

class DataOverview extends StatefulWidget {
  // รับข้อมูลเริ่มต้น (Daily) มาจาก Parent (ถ้ามี)
  // แต่เราจะใช้ State ภายในจัดการการเปลี่ยนโหมดเอง
  final List<double>? initialData;

  const DataOverview({super.key, this.initialData});

  @override
  State<DataOverview> createState() => _DataOverviewState();
}

class _DataOverviewState extends State<DataOverview> {
  // Default Data (ป้องกัน Null)
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  List<double> data = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  String selectedMode = "Daily"; // Daily, Monthly, Yearly
  bool isLoading = false;
  int touchedIndexProd = -1;
  int touchedIndexCons = -1;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!.length >= 6) {
      data = widget.initialData!;
    } else {
      // ถ้าไม่มีข้อมูลเริ่มต้น ให้ลองดึง Daily เอง
      fetchOverviewData("daily");
    }
  }

  // ฟังก์ชันดึงข้อมูลจาก API (ต้อง import 'http' และ 'convert')
  Future<void> fetchOverviewData(String mode) async {
    setState(() {
      isLoading = true;
      selectedMode = mode.capitalize(); // ทำให้ตัวแรกใหญ่เพื่อความสวยงาม
    });

    try {
      // ** แก้ไข URL ให้ตรงกับ IP ของ Server คุณ **
      final url = Uri.parse('http://$serverIp:$serverPort/api/overview?mode=${mode.toLowerCase()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.length >= 6) {
          setState(() {
            data = jsonList.map((e) => (e as num).toDouble()).toList();
          });
        }
      } else {
        debugPrint("Error fetching overview: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching overview: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // แยกตัวแปรออกมาคำนวณกราฟ
    final double totalProduction = data[0];
    final double batteryCharge = data[1];
    final double feedIn = data[2];

    final double totalConsumption = data[3];
    final double powerPurchased = data[4];
    final double batteryDischarge = data[5];

    // คำนวณ Self-used
    double selfUsed = totalProduction - feedIn - batteryCharge;
    if (selfUsed < 0) selfUsed = 0;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: Column(
        children: [
          // --- ส่วนปุ่มเลือกโหมด ---
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          // --- ส่วนแสดงผล Loading หรือ กราฟ ---
          isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // --- กราฟฝั่ง Production ---
                    TotalProduction(
                      totalValue: totalProduction,
                      prodUsed: selfUsed,
                      prodBatteryCharge: batteryCharge,
                      prodFeedIn: feedIn,
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                        height: 150,
                        child: VerticalDivider(color: Palette.lightGrey)),
                    const SizedBox(width: 10),
                    // --- กราฟฝั่ง Consumption ---
                    TotalConsumption(
                      totalValue: totalConsumption,
                      consSelfUsed: selfUsed,
                      consPowerPurchased: powerPurchased,
                      consBatteryDischarge: batteryDischarge,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton("Daily"),
          _buildPeriodButton("Monthly"),
          _buildPeriodButton("Yearly"),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text) {
    // เช็คว่าโหมดตรงกันหรือไม่ (แปลงเป็นตัวเล็กเพื่อเทียบ)
    bool isSelected = selectedMode.toLowerCase() == text.toLowerCase();
    
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          fetchOverviewData(text.toLowerCase());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Palette.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// Extension เล็กๆ เพื่อทำตัวอักษรพิมพ์ใหญ่
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
    Offset endPoint = center + Offset(dx * fixedTipDistance, dy * fixedTipDistance);
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