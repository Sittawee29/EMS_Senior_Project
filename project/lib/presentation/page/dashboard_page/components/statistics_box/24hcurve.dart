part of '../../page.dart';

class H_Curve extends StatelessWidget {
  const H_Curve({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: const Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 32.0, top: 32.0, right: 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily Curve',
                  style: TextStyles.myriadProSemiBold22DarkBlue,
                ),
                SizedBox(height: 24),
                _LineChart(),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    NameAndColorRow(
                        color: Palette.lightBlue, text: 'Power Production'),
                    SizedBox(width: 36),
                    NameAndColorRow(
                        color: Palette.orange, text: 'Power Consumption'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> lineNames = ['Power Prod', 'Power Cons'];

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 784),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 95,
          minY: 0,
          maxY: 1000,
          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: Palette.darkGrey,
                    strokeWidth: 2,
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, idx) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Palette.darkGrey,
                        strokeWidth: 0,
                      );
                    },
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(6),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((barSpot) {
                  // ใช้ barSpot.barIndex เพื่อดึงชื่อเส้น
                  final lineName = lineNames[barSpot.barIndex];
                  return LineTooltipItem(
                    '$lineName: ${barSpot.y.toStringAsFixed(0)} kW',
                    TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 200,
                getTitlesWidget: (value, _) => SideTitleWidget(
                  axisSide: AxisSide.left,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$value',
                      style: TextStyles.myriadProRegular13DarkBlue60,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2, // step = 15 นาที
                getTitlesWidget: (value, _) {
                  if (value == 95) {
                    return const SizedBox.shrink();
                  }
                  int minutes = (value.toInt() * 15); // index → minutes
                  int hour = minutes ~/ 60;
                  int minute = minutes % 60;
                  String label =
                      "${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}";
                  return SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Transform.rotate(
                      angle: 90 * 3.1415926535 / 180, // rotate 90
                      child: Text(
                        label,
                        style: TextStyles.myriadProRegular13DarkBlue60,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Palette.mediumGrey40,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Palette.darkGrey, width: 1),
              left: BorderSide(color: Palette.darkGrey, width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              dotData: FlDotData(show: false),
              color: Palette.lightBlue,
              barWidth: 3,
              final spotsProd = List.generate(timeLabels.length, (i) {
  final data = PowerData[timeLabels[i]];
  if (data == null || data[0] == null) return null; // null → หยุดเส้น
  return FlSpot(i.toDouble(), data[0]!);
}).whereType<FlSpot>().toList();
            ),
            LineChartBarData(
              isCurved: false,
              dotData: FlDotData(show: false),
              color: Palette.orange,
              barWidth: 3,
              spots: List.generate(96, (i) {
                final data = PowerData[i];
                if (data == null || data.last == null) return null;
                return FlSpot(i.toDouble(), data.last!);
              }).whereType<FlSpot>().toList(),
            ),
          ],
        ),
      ),
    );
  }
}
