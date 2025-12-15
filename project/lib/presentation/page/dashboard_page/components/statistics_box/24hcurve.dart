part of '../../page.dart';

class HCurve extends StatelessWidget {
  final Map<String, List<double?>> data;

  const HCurve({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 32.0, right: 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Daily Curve', style: TextStyles.myriadProSemiBold22DarkBlue),
                const SizedBox(height: 24),
                // ส่ง Data ต่อให้ Chart
                _LineChart(powerData: data),
                const SizedBox(height: 20),
                const Row(
                  children: <Widget>[
                    NameAndColorRow(color: Palette.lightBlue, text: 'Power Production'),
                    SizedBox(width: 36),
                    NameAndColorRow(color: Palette.orange, text: 'Power Consumption'),
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
  final Map<String, List<double?>> powerData;

  const _LineChart({required this.powerData});

  @override
  Widget build(BuildContext context) {
    final List<String> timeLabels = powerData.keys.toList();
    
    // Power Production
    final spotsProd = List.generate(timeLabels.length, (i) {
      final dataList = powerData[timeLabels[i]];
      if (dataList == null || dataList.isEmpty || dataList[0] == null) return null;
      return FlSpot(i.toDouble(), dataList[0]!);
    }).whereType<FlSpot>().toList();

    // Power Consumption
    final spotsCons = List.generate(timeLabels.length, (i) {
      final dataList = powerData[timeLabels[i]];
      if (dataList == null || dataList.length < 2 || dataList[1] == null) return null;
      return FlSpot(i.toDouble(), dataList[1]!);
    }).whereType<FlSpot>().toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 784),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (timeLabels.length - 1).toDouble(), // Dynamic Max X
          minY: 0,
          maxY: 1000, // ควรปรับเป็น dynamic ตาม max value ของ data จริง
          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Palette.darkGrey, strokeWidth: 2),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, idx) {
                      return FlDotCirclePainter(radius: 4, color: Palette.darkGrey, strokeWidth: 0);
                    },
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return [];

                final index = touchedSpots.first.x.toInt();
                final time = (index >= 0 && index < timeLabels.length)
                    ? timeLabels[index]
                    : '--:--';

                final buffer = StringBuffer();
                buffer.writeln(time);
                for (var spot in touchedSpots) {
                  final lineName = lineNames[spot.barIndex];
                  buffer.writeln('$lineName: ${spot.y.toStringAsFixed(0)} kW');
                }

                return touchedSpots.asMap().entries.map((entry) {
                  if (entry.key == 0) {
                    return LineTooltipItem(
                      buffer.toString(),
                      const TextStyle(fontSize: 12, color: Colors.white),
                    );
                  } else {
                    return null;
                  }
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
                    child: Text('$value', style: TextStyles.myriadProRegular13DarkBlue60),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 2, 
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= timeLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    angle: 90 * 3.1415926535 / 180,
                    child: Text(timeLabels[index], style: TextStyles.myriadProRegular13DarkBlue60),
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
            getDrawingHorizontalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 1),
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
              spots: spotsProd,
            ),
            LineChartBarData(
              isCurved: false,
              dotData: FlDotData(show: false),
              color: Palette.orange,
              barWidth: 3,
              spots: spotsCons,
            ),
          ],
        ),
      ),
    );
  }
}