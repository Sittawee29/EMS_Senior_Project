import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../dummy_data/charts_data.dart';
import '../../../theme/palette.dart';
import '../../../theme/text_styles.dart';
import '../../../widget/name_and_color_row.dart';

class ActiveUsersBox extends StatelessWidget {
  const ActiveUsersBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 558,
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 32.0, top: 32.0, right: 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Active Users',
                  style: TextStyles.myriadProSemiBold22DarkBlue,
                ),
                SizedBox(height: 24),
                _LineChart(),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    NameAndColorRow(color: Palette.lightBlue, text: 'Users'),
                    SizedBox(width: 36),
                    NameAndColorRow(
                        color: Palette.mediumBlue, text: 'New Users'),
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
      constraints: const BoxConstraints(maxHeight: 191, maxWidth: 366),
      child: LineChart(
        LineChartData(
          maxY: 500,
          lineTouchData: LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
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
              color: Palette.mediumGrey40,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Palette.mediumGrey40, width: 1),
            ),
          ),

          // 🔹 ใช้ lineBarsData (ไม่ใช่ lineGroups)
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Palette.lightBlue,
              barWidth: 3,
              spots: activeUsersData.entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.first))
                  .toList(),
            ),
            LineChartBarData(
              isCurved: true,
              color: Palette.mediumBlue,
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
