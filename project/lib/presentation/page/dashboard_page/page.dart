import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/gen/assets.gen.dart';
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
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    // เริ่มเชื่อมต่อเมื่อเข้าหน้านี้
    _mqttService.connect();
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
            const SizedBox(height: 28),
            _InformationRow(
               totalProduction: data.PV_Total_Energy,
               gridFeedIn: data.GRID_Total_Import_Energy,
               co2Prevention: data.EMS_CO2_Equivalent,
               netRevenue: (data.GRID_Daily_Export_Energy - data.GRID_Daily_Import_Energy)*4.5, // ตัวอย่าง: รายรับ - รายจ่าย
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
            // ...
          ],
        );
      },
    );
  }
}
