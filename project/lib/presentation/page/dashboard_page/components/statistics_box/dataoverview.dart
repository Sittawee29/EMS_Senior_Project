part of '../../page.dart';

class Data_overview extends StatelessWidget {
  const Data_overview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Total_production(Prod_Battery_Charge: DataOverview[1], Prod_used: DataOverview[0]),
          VerticalDivider(color: Palette.lightGrey),
          Total_consumption(Cons_Prod: DataOverview[3], Cons_Power_Purchased: DataOverview[2]),
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
                      Prod_used,
                      Prod_Battery_Charge,
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
                totalPercent: Prod_used,
                growthPercent: 3.9,
              ),
              const SizedBox(width: 50),
              Total_productionInfo(
                text: 'Battery Charge',
                color: Palette.orange,
                totalPercent: Prod_Battery_Charge,
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
    required this.Cons_Power_Purchased,
    required this.Cons_Prod,
  });

  final double Cons_Power_Purchased;
  final double Cons_Prod;

  List<PieChartSectionData> generateSections(
    double Cons_Power_Purchased,
    double Cons_Prod,
  ) {
    return [
      PieChartSectionData(
        color: Palette.lightBlue,
        value: Cons_Power_Purchased,
        radius: 20,
        title: '',
      ),
      PieChartSectionData(
        color: Palette.orange,
        value: Cons_Prod,
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
                      Cons_Power_Purchased,
                      Cons_Prod,
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
                totalPercent: Cons_Power_Purchased,
                growthPercent: 3.9,
              ),
              const SizedBox(width: 50),
              Total_productionInfo(
                text: 'Power Purchased',
                color: Palette.orange,
                totalPercent: Cons_Prod,
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
