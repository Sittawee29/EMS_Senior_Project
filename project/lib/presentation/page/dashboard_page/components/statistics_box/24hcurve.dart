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

final List<String> lineNames = ['Power Production', 'Power Consumption'];

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600, // ✅ กว้างพอ tooltip
        height: 300,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            maxY: 1500,
            lineTouchData: LineTouchData(
              enabled: true,
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(color: Palette.darkGrey, strokeWidth: 2),
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
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final lineName = lineNames[barSpot.barIndex];
                    return LineTooltipItem(
                      '$lineName: ${barSpot.y.toStringAsFixed(0)} kW',
                      const TextStyle(
                        fontSize: 10,
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
                  interval: 4, // step = 1 hour (4 * 15 minutes)
                  getTitlesWidget: (value, _) {
                    int minutes = (value.toInt() * 15); // index → minutes
                    int hour = minutes ~/ 60;
                    int minute = minutes % 60;
                    String label =
                        "${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}";
                    return SideTitleWidget(
                      axisSide: AxisSide.bottom,
                      child: Text(
                        label,
                        style: TextStyles.myriadProRegular13DarkBlue60,
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
                dotData: FlDotData(
                  show: false,
                ),
                color: Palette.lightBlue,
                barWidth: 3,
                spots: PowerData.entries
                    .where((e) => e.value.first != null)
                    .map((e) => FlSpot(e.key.toDouble(), e.value.first!))
                    .toList(),
              ),
              LineChartBarData(
                isCurved: false,
                dotData: FlDotData(
                  show: false,
                ),
                color: Palette.orange,
                barWidth: 3,
                spots: PowerData.entries
                    .where((e) => e.value.last != null)
                    .map((e) => FlSpot(e.key.toDouble(), e.value.last!))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
