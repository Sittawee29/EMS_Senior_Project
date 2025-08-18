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
          number: 14730,
          haveIncreased: true,
          percent: 3.9,
          text: 'Total Production',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: 22424,
          haveIncreased: true,
          percent: 3.9,
          text: 'Total Grid Feed-in',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.yellow.withOpacity(0.2),
          number: 34,
          haveIncreased: true,
          percent: 3.9,
          text: 'CO₂ Prevention',
        ),
        _InformationBox(
          icon: ProjectAssets.icons.chartPurple.svg(),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: 10000000,
          haveIncreased: true,
          percent: 3.9,
          text: 'Net revenue',
        ),
      ],
    );
  }
}
