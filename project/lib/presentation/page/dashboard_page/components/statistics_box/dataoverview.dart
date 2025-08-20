part of '../../page.dart';

class Data_overview extends StatelessWidget {
  const Data_overview();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Total_production(Prod_Battery_Charge: DataOverview[1], Prod_used: DataOverview[0]),
          VerticalDivider(color: Palette.lightGrey),
          Total_consumption(Cons_Battery_Charge: 86.7, Cons_used: 13.3),
        ],
      ),
    );
  }
}

class Total_production extends StatelessWidget {
  const Total_production({
    required this.Prod_used,
    required this.Prod_Battery_Charge,
  });

  final double Prod_used;
  final double Prod_Battery_Charge;

  List<PieChartSectionData> generateSections(
    double Prod_used,
    double Prod_Battery_Charge,
  ) {
    return [
      PieChartSectionData(
        color: Palette.lightBlue,
        value: Prod_used,
        radius: 20,
        title: '',
      ),
      PieChartSectionData(
        color: Palette.orange,
        value: Prod_Battery_Charge,
        radius: 20,
        title: '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 31, right: 47),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 80,
                    sections: generateSections(
                      malePercent,
                      femalePercent,
                    ),
                  ),
                ),
                const Text(
                  'Total Production',
                  style: TextStyles.myriadProSemiBold16DarkBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Total_productionInfo(
                text: 'Self-used',
                color: Palette.lightBlue,
                totalPercent: malePercent,
                growthPercent: 3.9,
              ),
              const SizedBox(width: 50),
              Total_productionInfo(
                text: 'Battery Charge',
                color: Palette.orange,
                totalPercent: femalePercent,
                growthPercent: 38.9,
                haveIncreased: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Total_productionInfo extends StatelessWidget {
  const Total_productionInfo({
    required this.text,
    required this.color,
    required this.growthPercent,
    required this.totalPercent,
    this.haveIncreased = true,
  });

  final String text;

  final Color color;

  final double totalPercent;
  final double growthPercent;

  final bool haveIncreased;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(backgroundColor: color, radius: 5),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyles.myriadProRegular13DarkBlue,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            const SizedBox(width: 20),
            Text(
              '$totalPercent%',
              style: TextStyles.myriadProSemiBold16DarkBlue,
            ),
            Icon(
              haveIncreased ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 20,
              color: haveIncreased ? Palette.green : Palette.red,
            ),
            Text(
              '$growthPercent%',
              style: haveIncreased
                  ? TextStyles.myriadProSemiBold12Green
                  : TextStyles.myriadProSemiBold12Red,
            ),
          ],
        ),
      ],
    );
  }
}

class Total_consumption extends StatelessWidget {
  const Total_consumption({
    required this.malePercent,
    required this.femalePercent,
  });

  final double malePercent;
  final double femalePercent;

  List<PieChartSectionData> generateSections(
    double malePercent,
    double femalePercent,
  ) {
    return [
      PieChartSectionData(
        color: Palette.lightBlue,
        value: malePercent,
        radius: 20,
        title: '',
      ),
      PieChartSectionData(
        color: Palette.orange,
        value: femalePercent,
        radius: 20,
        title: '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 31, right: 47),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 80,
                    sections: generateSections(
                      malePercent,
                      femalePercent,
                    ),
                  ),
                ),
                const Text(
                  'Total Consumption',
                  style: TextStyles.myriadProSemiBold16DarkBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Total_productionInfo(
                text: 'Production',
                color: Palette.lightBlue,
                totalPercent: malePercent,
                growthPercent: 3.9,
              ),
              const SizedBox(width: 50),
              Total_productionInfo(
                text: 'Power Purchased',
                color: Palette.orange,
                totalPercent: femalePercent,
                growthPercent: 38.9,
                haveIncreased: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Total_consumptionInfo extends StatelessWidget {
  const Total_consumptionInfo({
    required this.text,
    required this.color,
    required this.growthPercent,
    required this.totalPercent,
    this.haveIncreased = true,
  });

  final String text;

  final Color color;

  final double totalPercent;
  final double growthPercent;

  final bool haveIncreased;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(backgroundColor: color, radius: 5),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyles.myriadProRegular13DarkBlue,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            const SizedBox(width: 20),
            Text(
              '$totalPercent%',
              style: TextStyles.myriadProSemiBold16DarkBlue,
            ),
            Icon(
              haveIncreased ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 20,
              color: haveIncreased ? Palette.green : Palette.red,
            ),
            Text(
              '$growthPercent%',
              style: haveIncreased
                  ? TextStyles.myriadProSemiBold12Green
                  : TextStyles.myriadProSemiBold12Red,
            ),
          ],
        ),
      ],
    );
  }
}
