part of '../../page.dart';

class Power_flow extends StatefulWidget {
  const Power_flow({super.key});

  @override
  State<Power_flow> createState() => _Power_flowState();
}

class _Power_flowState extends State<Power_flow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // วิ่งวนตลอด
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            // Layer วาดเส้นและลูกศร
            Positioned.fill(
              child: CustomPaint(
                painter: FlowPainter(_controller),
              ),
            ),

            // Layer วางไอคอนและข้อความ
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildItem('assets/images/solar.png', 'Production','${PowerFlow[0]} kW'),
                    _buildItem('assets/images/grid.png', 'Grid', '${PowerFlow[1]} kW'), 
                  ],
                ),
                _buildItem('assets/images/house.png', '', ''),
                const SizedBox(height: 80 * 0.15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildItem('assets/images/BESS.png', 'Battery ${PowerFlow[3]}%', '${PowerFlow[2]} kW'),
                        
                    _buildItem('assets/images/consumption.png', '${PowerFlow[4]} kW','1.79kW'),
                        
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String imagePath, String title, String value) {
    return Column(
      children: [
        Image.asset(imagePath, width: 80, height: 80),
        if (title.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
        if (value.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }
}

class FlowPainter extends CustomPainter {
  final Animation<double> animation;
  FlowPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Solar -> House
    final p1 = Offset(size.width * 0.3, size.height * 0.15);
    final p2 = Offset(size.width * 0.375, size.height * 0.15);
    final p3 = Offset(size.width * 0.375, size.height * 0.475);
    final p4 = Offset(size.width * 0.425, size.height * 0.475);
    final path1 = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy);
    canvas.drawPath(path1, paintLine);

    // Grid -> House
    final p5 = Offset(size.width * 0.7, size.height * 0.15);
    final p6 = Offset(size.width * 0.625, size.height * 0.15);
    final p7 = Offset(size.width * 0.625, size.height * 0.475);
    final p8 = Offset(size.width * 0.575, size.height * 0.475);
    final path2 = Path()
      ..moveTo(p5.dx, p5.dy)
      ..lineTo(p6.dx, p6.dy)
      ..lineTo(p7.dx, p7.dy)
      ..lineTo(p8.dx, p8.dy);
    canvas.drawPath(path2, paintLine);

    // House -> Battery
    final p9 = Offset(size.width * 0.3, size.height * 0.75);
    final p10 = Offset(size.width * 0.375, size.height * 0.75);
    final p11 = Offset(size.width * 0.375, size.height * 0.525);
    final p12 = Offset(size.width * 0.425, size.height * 0.525);
    final path3 = Path()
      ..moveTo(p9.dx, p9.dy)
      ..lineTo(p10.dx, p10.dy)
      ..lineTo(p11.dx, p11.dy)
      ..lineTo(p12.dx, p12.dy);
    canvas.drawPath(path3, paintLine);

    // House -> Consumption
    final p13 = Offset(size.width * 0.7, size.height * 0.75);
    final p14 = Offset(size.width * 0.625, size.height * 0.75);
    final p15 = Offset(size.width * 0.625, size.height * 0.525);
    final p16 = Offset(size.width * 0.575, size.height * 0.525);
    final path4 = Path()
      ..moveTo(p13.dx, p13.dy)
      ..lineTo(p14.dx, p14.dy)
      ..lineTo(p15.dx, p15.dy)
      ..lineTo(p16.dx, p16.dy);
    canvas.drawPath(path4, paintLine);

    // วาดจุดวิ่งแต่ละเส้น
    _drawMovingDot(canvas, [p1, p2, p3, p4], animation.value);
    _drawMovingDot(canvas, [p5, p6, p7, p8], animation.value);
    _drawMovingDot(canvas, [p9, p10, p11, p12], animation.value);
    _drawMovingDot(canvas, [p13, p14, p15, p16], animation.value);
  }

  void _drawMovingDot(Canvas canvas, List<Offset> points, double progress) {
    if (points.length < 2) return;

    double totalLength = 0;
    List<double> segmentLengths = [];
    for (int i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    double targetDist = totalLength * progress;

    double distSoFar = 0;
    for (int i = 0; i < segmentLengths.length; i++) {
      if (distSoFar + segmentLengths[i] >= targetDist) {
        double segmentProgress = (targetDist - distSoFar) / segmentLengths[i];
        Offset pos = Offset.lerp(points[i], points[i + 1], segmentProgress)!;

        final paintDot = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 6, paintDot);
        return;
      }
      distSoFar += segmentLengths[i];
    }
  }

  @override
  bool shouldRepaint(covariant FlowPainter oldDelegate) => true;
}
