part of '../page.dart';

class _InformationRow extends StatelessWidget {
  const _InformationRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      children: <Widget>[
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.orange.withOpacity(0.1),
          number: InformationRow[0],
          unit: 'kW',


          text: 'Total Production',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: InformationRow[1],
          unit: 'kW',

          text: 'Total Grid Feed-in',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.yellow.withOpacity(0.2),
          number: InformationRow[2],
          unit: 'CO₂e',

          text: 'CO₂ Prevention',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: InformationRow[3],
          unit: 'Baht',

          text: 'Net revenue',
        ),
      ],
    );
  }
}
