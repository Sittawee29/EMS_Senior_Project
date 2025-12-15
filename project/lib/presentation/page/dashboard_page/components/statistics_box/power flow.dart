part of '../../page.dart';

class PowerFlow extends StatefulWidget {
  final List<double> data;
  // data[0] = PV1
  // data[1] = PV2
  // data[2] = PV3
  // data[3] = PV4
  // data[4] = Grid Power (+Import / -Export)
  // data[5] = BESS Power (+Charge / -Discharge)
  // data[6] = BESS SOC
  // data[7] = Consumption Power

  const PowerFlow({super.key, required this.data});

  @override
  State<PowerFlow> createState() => _PowerFlowState();
}

class _PowerFlowState extends State<PowerFlow> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // เพิ่ม Observer เพื่อดักจับตอนแอปพับหน้าจอ/กลับมา
    WidgetsBinding.instance.addObserver(this);
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    // ลบ Observer ออกเมื่อหน้านี้ถูกปิด
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // ฟังก์ชันดักจับสถานะแอป (User สลับแอป หรือ ปิดหน้าจอ)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // เมื่อกลับมาที่หน้าแอป ให้สั่ง Animation เริ่มใหม่เพื่อให้ลื่นไหล
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
      // TIP: ตรงนี้คุณอาจจะ Call Function ไปบอก Parent ให้ Fetch Data ใหม่ก็ได้
      print("App Resumed: Should fetch fresh data now.");
    }
  }

  // ฟังก์ชันนี้จะทำงานทุกครั้งที่ Parent ส่ง data ใหม่เข้ามา
  @override
  void didUpdateWidget(PowerFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // เช็คว่าถ้าข้อมูลเปลี่ยน เราต้องการ Reset Animation หรือไม่?
    // ปกติไม่ต้องทำอะไร ถ้า build() ทำงาน Text ก็จะเปลี่ยนเอง
    
    // ใส่ Print เพื่อ Debug ว่าข้อมูลใหม่เข้ามาจริงหรือไม่
    // print("New Data received: ${widget.data}"); 
  }

  @override
  Widget build(BuildContext context) {
    // 1. ป้องกัน Error และเตรียมข้อมูลให้ปลอดภัย (ต้องมีอย่างน้อย 5 ตัว)
    final safeData = widget.data.length >= 5 
        ? widget.data 
        : List.filled(5, 0.0);

    // 2. ดึงค่า ตาม Index ใหม่
    double solarPower = safeData[0];
    double gridPower = safeData[1];
    double bessPower = safeData[2];
    double bessSOC = safeData[3];
    double loadPower = safeData[4].abs();

    // --- เตรียมข้อมูลสำหรับ Painter (จัดระเบียบใหม่ให้ Painter ใช้ง่าย) ---
    // [0] Solar Power
    // [1] Grid
    // [2] BESS Power
    // [3] SOC
    // [4] Load
    final painterData = [solarPower, gridPower, bessPower, bessSOC, loadPower];

    // --- เตรียม Text แสดงผล ---

    // Grid Text
    String gridText = "${gridPower.abs().toStringAsFixed(2)} kW";
    String gridStatus = "Idle";
    Color gridColor = Colors.grey;
    if (gridPower > 0) {
      gridStatus = "Import";
      gridColor = Color.fromARGB(255, 255, 0, 0);
    } else if (gridPower < 0) {
      gridStatus = "Export";
      gridColor = Color.fromARGB(255, 0, 255, 0);
    }

    // Battery Text (+ Charge, - Discharge)
    String battText = "${bessPower.abs().toStringAsFixed(2)} kW";
    String battStatus = "Idle";
    Color battColor = Colors.grey;
    if (bessPower > 0) {
      battStatus = "Charging";
      battColor = const Color.fromARGB(255, 0, 255, 0);
    } else if (bessPower < 0) {
      battStatus = "Discharging";
      battColor = Color.fromARGB(255, 255, 0, 0);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                // ส่งข้อมูลที่จัดระเบียบแล้วไปให้ Painter
                painter: FlowPainter(_controller, painterData),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // --- ส่วนบน: Solar & Grid ---
                // นำ Padding มาครอบ Row นี้
                Transform.translate(
                  offset: const Offset(0, 40), // แกน X=0, แกน Y=40 (เลื่อนลง)
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Solar (Show Total)
                      _buildComplexItem('assets/images/solar.png','Production','${solarPower.toStringAsFixed(2)} kW','',Colors.orange),
                      // Grid
                      _buildComplexItem('assets/images/grid.png','Grid',gridText,gridStatus,gridColor), 
                    ],
                  ),
                ),
                // --- ส่วนกลาง: House ---
                _buildItem('assets/images/house.png', '', ''),
                // --- ส่วนล่าง: Battery & Consumption ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Battery
                    _buildComplexItem('assets/images/BESS.png','Battery ${bessSOC.toStringAsFixed(1)}%',battText,battStatus,battColor),
                    // Consumption
                    _buildComplexItem('assets/images/consumption.png','Consumption','${loadPower.toStringAsFixed(2)} kW','',Colors.blue),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexItem(String img, String title, String mainValue, String subValue, Color color) {
    return Column(
      children: [
        Image.asset(img, width: 80, height: 80),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(mainValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        if (subValue.isNotEmpty)
          Text(subValue, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildItem(String img, String title, String val) {
    return Column(
      children: [
        Image.asset(img, width: 80, height: 80),
        if (title.isNotEmpty) Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (val.isNotEmpty) Text(val),
      ],
    );
  }
}

class FlowPainter extends CustomPainter {
  final Animation<double> animation;
  final List<double> data; 
  // data ที่รับเข้ามาในนี้คือ painterData ที่เราจัดเรียงแล้ว:
  // [0] Total Solar
  // [1] Grid
  // [2] BESS Power (+Charge, -Discharge)
  // [3] SOC
  // [4] Load

  FlowPainter(this.animation, this.data) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = Colors.blue.withOpacity(0.3)..strokeWidth = 3..style = PaintingStyle.stroke;

    // --- Points Configuration ---
    final centerLeft = Offset(size.width * 0.425, size.height * 0.475);
    final centerRight = Offset(size.width * 0.575, size.height * 0.475);
    final centerBotLeft = Offset(size.width * 0.425, size.height * 0.525);
    final centerBotRight = Offset(size.width * 0.575, size.height * 0.525);

    final pSolar = Offset(size.width * 0.3, size.height * 0.25);
    final pGrid = Offset(size.width * 0.7, size.height * 0.25);
    final pBatt = Offset(size.width * 0.3, size.height * 0.75);
    final pCons = Offset(size.width * 0.7, size.height * 0.75);

    final elbowSolar = Offset(size.width * 0.375, size.height * 0.25);
    final elbowSolarDown = Offset(size.width * 0.375, size.height * 0.475);
    final elbowGrid = Offset(size.width * 0.625, size.height * 0.25);
    final elbowGridDown = Offset(size.width * 0.625, size.height * 0.475);
    final elbowBatt = Offset(size.width * 0.375, size.height * 0.75);
    final elbowBattUp = Offset(size.width * 0.375, size.height * 0.525);
    final elbowCons = Offset(size.width * 0.625, size.height * 0.75);
    final elbowConsUp = Offset(size.width * 0.625, size.height * 0.525);

    // 1. Total Solar Logic (data[0])
    if (data[0] > 0.01) {
      _drawPathAndDot(canvas, [pSolar, elbowSolar, elbowSolarDown, centerLeft], paintLine, Paint()..color = Colors.orange..style = PaintingStyle.fill);
    }

    // 2. Grid Logic (data[1])
    if (data[1].abs() > 0.01) {
      List<Offset> points = [pGrid, elbowGrid, elbowGridDown, centerRight];
      if (data[1] > 0) { // Import
         _drawPathAndDot(canvas, points, paintLine, Paint()..color = Color.fromARGB(255, 255, 0, 0)..style = PaintingStyle.fill);
      } else { // Export
         _drawPathAndDot(canvas, points.reversed.toList(), paintLine, Paint()..color = Color.fromARGB(255, 0, 255, 0)..style = PaintingStyle.fill);
      }
    }

    // 3. Battery Logic (data[2])
    // (+) Charge: House -> Battery
    // (-) Discharge: Battery -> House
    if (data[2].abs() > 0.01) {
      List<Offset> points = [pBatt, elbowBatt, elbowBattUp, centerBotLeft];
      if (data[2] > 0) {
        // (+) Charging : House -> Battery (Reversed)
        _drawPathAndDot(canvas, points.reversed.toList(), paintLine, Paint()..color = Color.fromARGB(255, 0, 255, 0)..style = PaintingStyle.fill);
      } else {
        // (-) Discharging : Battery -> House (Normal)
        _drawPathAndDot(canvas, points, paintLine, Paint()..color = const Color.fromARGB(255, 255, 0, 0)..style = PaintingStyle.fill);
      }
    }

    // 4. Consumption Logic (data[4])
    if (data[4] > 0.01) {
      List<Offset> points = [pCons, elbowCons, elbowConsUp, centerBotRight];
      _drawPathAndDot(canvas, points.reversed.toList(), paintLine, Paint()..color = Colors.blue..style = PaintingStyle.fill);
    }
  }

  void _drawPathAndDot(Canvas canvas, List<Offset> points, Paint linePaint, Paint dotPaint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) path.lineTo(points[i].dx, points[i].dy);
    canvas.drawPath(path, linePaint);

    double totalLength = 0;
    List<double> segmentLengths = [];
    for (int i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }
    double targetDist = totalLength * animation.value;
    double distSoFar = 0;
    for (int i = 0; i < segmentLengths.length; i++) {
      if (distSoFar + segmentLengths[i] >= targetDist) {
        double segmentProgress = (targetDist - distSoFar) / segmentLengths[i];
        Offset pos = Offset.lerp(points[i], points[i + 1], segmentProgress)!;
        canvas.drawCircle(pos, 6, dotPaint);
        return;
      }
      distSoFar += segmentLengths[i];
    }
  }

  @override
  bool shouldRepaint(covariant FlowPainter oldDelegate) => true;
}