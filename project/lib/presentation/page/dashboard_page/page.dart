import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/palette.dart';
import '../../theme/text_styles.dart';
import '../../widget/name_and_color_row.dart';
import '../../../../services/mqtt_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';


part 'components/devices_box.dart';
part 'components/information_box.dart';
part 'components/information_row.dart';
part 'components/weather_box.dart';
part 'components/statistics_box/box.dart';
part 'components/statistics_box/24hcurve.dart';
part 'components/statistics_box/dataoverview.dart';
part 'components/statistics_box/power flow.dart';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  final MqttService _mqttService = MqttService();
  DateTime _currentDate = DateTime.now();
  List<String> _holidayDates = [];
  Map<String, String> _holidayDetails = {};

  @override
  void initState() {
    super.initState();
    // เริ่มเชื่อมต่อเมื่อเข้าหน้านี้
    _mqttService.connect();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    final year = _currentDate.year.toString();
    final url = Uri.parse('http://$serverIp:$serverPort/api/holidays/$year');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _holidayDates = List<String>.from(data['holidays']);
            if (data['holiday_details'] != null) {
              _holidayDetails = Map<String, String>.from(data['holiday_details']);
            }
          });
          print("Holidays loaded: $_holidayDates");
        }
      }
    } catch (e) {
      print("Error fetching holidays: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardData>(
      stream: _mqttService.dataStream,
      initialData: DashboardData(), // ค่าเริ่มต้นเป็น 0
      builder: (context, snapshot) {
        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text(
                'Welcome back!',
                style: TextStyles.myriadProSemiBold32DarkBlue,
              ),
            ),
            
            const SizedBox(height: 22),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: <Widget>[
                _StatisticsBox(
                   powerFlowData: [
                      data.EMS_SolarPower_kW, // Solar
                      data.METER_Grid_Power_KW, // Grid
                      data.BESS_KW,
                      data.BESS_SOC, // Battery % (ยังไม่มี topic ใน list นี้)
                      data.EMS_LoadPower_kW // Cons
                   ], 
                   powerCurveData: {}, // ต้องสะสมค่า array เองหรือดึงจาก API ประวัติ
                   dataOverview: [
                      data.EMS_EnergyProducedFromPV_Daily, 
                      data.BESS_Daily_Charge_Energy, 
                      data.EMS_EnergyFeedToGrid_Daily,
                      data.EMS_EnergyConsumption_Daily,
                      data.EMS_EnergyFeedFromGrid_Daily,
                      data.BESS_Daily_Discharge_Energy
                   ],
                ),
                _WeatherBox(),
              ],
            ),
            const SizedBox(height: 22),
            _InformationRow(
              currentDate: _currentDate,
              holidayDates: _holidayDates,
              holidayDetails: _holidayDetails,
              onDateSelected: (newDate) {
                setState(() {
                  _currentDate = newDate;
                });
              },
              column1: data.EMS_EnergyConsumption_kWh,
              column2: data.EMS_EnergyConsumption_Daily,
              column3: data.EMS_EnergyProducedFromPV_kWh,
              column4: data.EMS_EnergyProducedFromPV_Daily,
            ),
            const SizedBox(height: 22),
            _InformationRow2(
              column1: data.EMS_CO2_Equivalent,
              column2: data.EMS_RenewRatioLifetime,
              column3: data.EMS_RenewRatioDaily,
              column4: data.BESS_SOC,
            ),
          ],
        );
      },
    );
  }
}
