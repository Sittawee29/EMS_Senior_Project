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

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 784),
      child: LineChart(
        LineChartData(
          maxY: 1500,
          lineTouchData: LineTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                //interval: 0.25,
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
            bottomTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Palette.darkGrey,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Palette.darkGrey, width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: Palette.lightBlue,
              barWidth: 3,
              spots: activeUsersData.entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.first))
                  .toList(),
            ),
            LineChartBarData(
              isCurved: false,
              color: Palette.orange,
              barWidth: 3,
              spots: activeUsersData.entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.last))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
