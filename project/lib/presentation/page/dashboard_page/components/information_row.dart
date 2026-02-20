part of '../page.dart';

class _InformationRow extends StatelessWidget {
  // ประกาศตัวแปร 4 ตัว
  final double column1;
  final double column2;
  final double column3;
  final double column4;

  // Constructor ต้องรับ 4 ตัว (required)
  const _InformationRow({
    required this.column1,
    required this.column2,
    required this.column3,
    required this.column4,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      children: <Widget>[
        _InformationBox(
          icon: Icon(Icons.electrical_services,color: Colors.black,),
          backgroundColor: Palette.orange.withOpacity(0.1),
          number: column1/1000,
          unit: 'MWh', 
          text: 'Lifetime Total Consumption',
        ),
        _InformationBox(
          icon: Icon(Icons.electrical_services,color: Colors.black,),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: column2,
          unit: 'kWh',
          text: 'Daily Consumption',
        ),
        _InformationBox(
          icon: Icon(Icons.solar_power,color: Colors.black,),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: column3/1000,
          unit: 'MWh',
          text: 'Lifetime Total Production',
        ),
        _InformationBox(
          icon: Icon(Icons.solar_power,color: Colors.black,),
          backgroundColor: Palette.yellow.withOpacity(0.2),
          number: column4,
          unit: 'kWh',
          text: 'Daily Production',
        ),
      ],
    );
  }
}

class _InformationRow2 extends StatelessWidget {
  final double column1;
  final double column2;
  final double column3;
  final double column4;

  const _InformationRow2({
    required this.column1,
    required this.column2,
    required this.column3,
    required this.column4,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      children: <Widget>[
        _InformationBox(
          icon: Icon(Icons.energy_savings_leaf,color: Colors.black,),
          backgroundColor: Palette.orange.withOpacity(0.1),
          number: column1,
          unit: 'CO₂e', 
          text: 'CO₂ Prevention',
        ),
        _InformationBox(
          icon: Icon(Icons.recycling,color: Colors.black,),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: column2*100,
          unit: '%',
          text: 'RE Lifetime Ratio',
        ),
        _InformationBox(
          icon: Icon(Icons.recycling,color: Colors.black,),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: column3*100,
          unit: '%',
          text: 'RE Daily Ratio',
        ),
      ],
    );
  }
}