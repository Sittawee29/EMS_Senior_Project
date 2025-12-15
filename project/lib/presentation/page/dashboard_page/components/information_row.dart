part of '../page.dart';

class _InformationRow extends StatelessWidget {
  // ประกาศตัวแปร 4 ตัว
  final double totalProduction;
  final double gridFeedIn;
  final double co2Prevention;
  final double netRevenue;

  // Constructor ต้องรับ 4 ตัว (required)
  const _InformationRow({
    required this.totalProduction,
    required this.gridFeedIn,
    required this.co2Prevention,
    required this.netRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      children: <Widget>[
        _InformationBox(
          icon: ProjectAssets.icons.production.svg(),
          backgroundColor: Palette.orange.withOpacity(0.1),
          number: totalProduction/1000, // <--- ใช้ตัวแปรที่รับมา
          unit: 'MWh', 
          text: 'Total Production',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.gridfeedin.svg(),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: gridFeedIn/1000, // <--- ใช้ตัวแปรที่รับมา
          unit: 'MWh',
          text: 'Total Grid Feed-in',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.carbonprevention.svg(),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: co2Prevention, // <--- ใช้ตัวแปรที่รับมา
          unit: 'CO₂e',
          text: 'CO₂ Prevention',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.coin.svg(),
          backgroundColor: Palette.yellow.withOpacity(0.2),
          number: netRevenue, // <--- ใช้ตัวแปรที่รับมา
          unit: 'Baht',
          text: 'Net revenue',
        ),
      ],
    );
  }
}