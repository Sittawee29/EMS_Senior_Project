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
  String currentSelectedPlant = 'UTI';
  

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
    // ใช้ <dynamic> เพื่อให้รองรับได้ทั้งคลาส DashboardDataUTI และ DashboardDataTPI
    return StreamBuilder<dynamic>(
      stream: _mqttService.dataStream,
      // ตั้งค่า initialData ตามโรงไฟฟ้าที่เลือกอยู่ เพื่อไม่ให้เกิด Error ตอนเริ่มรัน
      initialData: currentSelectedPlant == 'UTI' ? DashboardDataUTI() : DashboardDataTPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        String activePlant = 'UTI';
        List<double> powerFlowData = [0.0, 0.0, 0.0, 0.0, 0.0];
        List<double> dataOverview = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        
        dynamic row1Col1, row1Col2, row1Col3, row1Col4;
        dynamic row2Col2, row2Col3, row2Col4;

        if (data is DashboardDataUTI) {
          activePlant = 'UTI';
          // --- แมปข้อมูลสำหรับ UTI ---
          powerFlowData = [
            data.EMS_SolarPower_kW,
            data.METER_Grid_Power_KW,
            data.BESS_KW,
            data.BESS_SOC,
            (data.EMS_LoadPower_kW).abs()
          ];
          dataOverview = [
            data.EMS_EnergyProducedFromPV_Daily,
            data.BESS_Daily_Charge_Energy,
            data.EMS_EnergyFeedToGrid_Daily,
            data.EMS_EnergyConsumption_Daily,
            data.EMS_EnergyFeedFromGrid_Daily,
            data.BESS_Daily_Discharge_Energy
          ];
          
          row1Col1 = data.EMS_EnergyConsumption_kWh;
          row1Col2 = data.EMS_EnergyConsumption_Daily;
          row1Col3 = data.EMS_EnergyProducedFromPV_kWh;
          row1Col4 = data.EMS_EnergyProducedFromPV_Daily;
          row2Col2 = data.EMS_CO2_Equivalent;
          row2Col3 = data.EMS_RenewRatioDaily;
          row2Col4 = data.EMS_RenewRatioLifetime;

        } else if (data is DashboardDataTPI) {
          activePlant = 'TPI';
          powerFlowData = [
            data.SOLAR_SOLAR1_LOGGER1_P,
            data.METER_P,
            -data.BESS_SCU_P,
            data.BESS_SCU_SOC,
            (data.EMS_PLOAD).abs()
          ];
          
          dataOverview = [
            data.SOLAR_SOLAR1_LOGGER1_KWHDAILY,
            data.BESS_SCU_KWHCHARGEDAILY,
            data.METER_KWHNEGDAILY,
            data.EMS_KWHLOADDAILY,
            data.METER_KWHPOSDAILY,
            data.BESS_SCU_KWHDISCHARGEDAILY
          ];
          
          row1Col1 = data.EMS_KWHLOADTOTAL; 
          row1Col2 = data.EMS_KWHLOADDAILY; 
          row1Col3 = data.SOLAR_SOLAR1_LOGGER1_KWHTOTAL; 
          row1Col4 = data.SOLAR_SOLAR1_LOGGER1_KWHDAILY; 
          row2Col2 = data.EMS_CO2E; 
          row2Col3 = data.EMS_RENEWRATIO; 
          row2Col4 = data.EMS_RENEWRATIOLIFETIME; 
        }

        // 3. นำตัวแปรกลางที่แมปค่าเสร็จแล้ว มาใส่ใน UI ให้ดูสะอาดตา
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          children: <Widget>[
            const SizedBox(height: 22),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: <Widget>[
                _StatisticsBox(
                   powerFlowData: powerFlowData,
                   powerCurveData: const {},
                   dataOverview: dataOverview,
                ),
                _WeatherBox(plant: activePlant),
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
              // ใช้ตัวแปรกลางที่เราเตรียมไว้
              column1: row1Col1,
              column2: row1Col2,
              column3: row1Col3,
              column4: row1Col4,
            ),
            const SizedBox(height: 22),
            _InformationRow2(
              currentDate: _currentDate,
              holidayDates: _holidayDates,
              holidayDetails: _holidayDetails,
              // ใช้ตัวแปรกลางที่เราเตรียมไว้
              column2: row2Col2,
              column3: row2Col3,
              column4: row2Col4,
            ),
          ],
        );
      },
    );
  }
}
