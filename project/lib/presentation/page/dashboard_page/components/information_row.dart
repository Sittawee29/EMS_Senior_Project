part of '../page.dart';

class _InformationRow extends StatelessWidget {
  final double column1;
  final double column2;
  final double column3;
  final double column4;

  final DateTime currentDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<String> holidayDates;
  final Map<String, String> holidayDetails;

  const _InformationRow({
    required this.column1,
    required this.column2,
    required this.column3,
    required this.column4,

    required this.currentDate,
    required this.onDateSelected,
    this.holidayDates = const [],
    this.holidayDetails = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalendarBox(
          initialDate: currentDate, 
          holidayDates: holidayDates,
          holidayDetails: holidayDetails,
          onDateSelected: onDateSelected, 
        ),

        const SizedBox(width: 22),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InformationBox(
                      icon: const Icon(Icons.electrical_services, color: Colors.black),
                      backgroundColor: Palette.orange.withOpacity(0.1),
                      number: column1 / 1000,
                      unit: 'MWh', 
                      text: 'Lifetime Total Consumption',
                    ),
                  ),
                  const SizedBox(width: 22), // ระยะห่างระหว่างกล่องซ้าย-ขวา
                  Expanded(
                    child: _InformationBox(
                      icon: const Icon(Icons.electrical_services, color: Colors.black),
                      backgroundColor: Palette.lightPurple.withOpacity(0.8),
                      number: column2,
                      unit: 'kWh',
                      text: 'Daily Consumption',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _InformationBox(
                      icon: const Icon(Icons.solar_power, color: Colors.black),
                      backgroundColor: Palette.green.withOpacity(0.2),
                      number: column3 / 1000,
                      unit: 'MWh',
                      text: 'Lifetime Total Production',
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _InformationBox(
                      icon: const Icon(Icons.solar_power, color: Colors.black),
                      backgroundColor: Palette.yellow.withOpacity(0.2),
                      number: column4,
                      unit: 'kWh',
                      text: 'Daily Production',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationRow2 extends StatelessWidget {
  final double column2;
  final double column3;
  final double column4;

  final DateTime currentDate;
  final List<String> holidayDates;
  final Map<String, String> holidayDetails;

  const _InformationRow2({
    required this.column2,
    required this.column3,
    required this.column4,

    required this.currentDate,
    this.holidayDates = const [],
    this.holidayDetails = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      children: <Widget>[
        _TodayStatusBox(
          currentDate: currentDate,
          holidayDates: holidayDates,
          holidayDetails: holidayDetails,
        ),
        _InformationBox(
          icon: Icon(Icons.energy_savings_leaf,color: Colors.black,),
          backgroundColor: Palette.lightPurple.withOpacity(0.8),
          number: column2,
          unit: 'CO₂e',
          text: 'CO₂ Prevention',
        ),
        _InformationBox(
          icon: Icon(Icons.recycling,color: Colors.black,),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: column3*100,
          unit: '%',
          text: 'RE Daily Ratio',
        ),
        _InformationBox(
          icon: Icon(Icons.recycling,color: Colors.black,),
          backgroundColor: Palette.green.withOpacity(0.2),
          number: column4*100,
          unit: '%',
          text: 'RE Lifetime Ratio',
        ),
      ],
    );
  }
}