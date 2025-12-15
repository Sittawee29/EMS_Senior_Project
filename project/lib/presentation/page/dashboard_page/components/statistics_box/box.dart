part of '../../page.dart';

class _StatisticsBox extends StatefulWidget {
  final List<double> powerFlowData; // [Solar, Grid, BatteryKW, Battery%, Cons]
  final Map<String, List<double?>> powerCurveData; // Key: Time, Value: [Prod, Cons]
  final List<double> dataOverview; // [Prod_used, Prod_Battery, Cons_Purchased, Cons_Prod]

  const _StatisticsBox({
    super.key,
    required this.powerFlowData,
    required this.powerCurveData,
    required this.dataOverview,
  });

  @override
  State<_StatisticsBox> createState() => _StatisticsBoxState();
}

class _StatisticsBoxState extends State<_StatisticsBox> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 920,  //(268*4)+22*3
      height: 530,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 32.0, left: 32.0),
            child: Text(
              'Power Overview',
              style: TextStyles.myriadProSemiBold22DarkBlue,
            ),
          ),
          const SizedBox(height: 26),
          _StatisticsTabs(pageController: _controller),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: <Widget>[
                // ส่งข้อมูลเข้า Power Flow
                PowerFlow(data: widget.powerFlowData),
                HCurve(data: widget.powerCurveData),
                DataOverview(data: widget.dataOverview),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsTabs extends StatefulWidget {
  const _StatisticsTabs({required this.pageController});

  final PageController pageController;

  @override
  _StatisticsTabsState createState() => _StatisticsTabsState();
}

class _StatisticsTabsState extends State<_StatisticsTabs>
    with TickerProviderStateMixin {
  late final TabController _controller;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: selectedIndex,
    );
    _controller.addListener(() {
      widget.pageController.jumpToPage(_controller.index);
      setState(() {
        selectedIndex = _controller.index;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      padding: const EdgeInsets.only(left: 20),
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      controller: _controller,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: const Color.fromRGBO(28, 134, 223, 1),
      tabs: [
        _StatisticsTab(
          isSelected: selectedIndex == 0,
          text: 'Power Flow',
        ),
        _StatisticsTab(
          isSelected: selectedIndex == 1,
          text: '24H Curve',
        ),
        _StatisticsTab(
          isSelected: selectedIndex == 2,
          text: 'Data Overview',
        ),
      ],
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab({required this.text, required this.isSelected});

  final bool isSelected;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Text(
        text,
        style: isSelected
            ? TextStyles.myriadProSemiBold14LightBlue
            : TextStyles.myriadProSemiBold14DarkBlue.copyWith(
                color: Palette.darkBlue.withOpacity(0.4),
              ),
      ),
    );
  }
}