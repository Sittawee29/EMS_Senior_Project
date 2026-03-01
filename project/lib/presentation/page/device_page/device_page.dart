import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../services/mqtt_service.dart';


import 'DeviceDetailPage/device_model.dart'; 
import 'DeviceDetailPage/DeviceDetailPage.dart';

@RoutePage()
class DevicePage extends StatefulWidget {
  const DevicePage({super.key});
  
  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final MqttService _mqttService = MqttService();
  DashboardDataUTI dataUTI = DashboardDataUTI();
  DashboardDataTPI dataTPI = DashboardDataTPI();
  StreamSubscription? _mqttSubscription;
  dynamic currentData; 
  String activePlant = 'UTI';
  
  List<DeviceModel> allDevices = [
    InverterModel(
      name: 'Inverter',
      status: 'Waiting...',
      sn: '2408214212',
      inverterType: 'Three phase LV Hybrid',
      ratedPower: '20kW',
    ),
    BatteryModel(
      name: 'BESS Unit 1',
      status: 'Waiting...',
      //ratedCapacity: '874Ah',
      //batteryType: 'Lithium',
    ),
    SolarModel(name: 'Solar Panel Zone 1', status: 'Waiting...'),
    SolarModel(name: 'Solar Panel Zone 2', status: 'Waiting...'),
    SolarModel(name: 'Solar Panel Zone 3', status: 'Waiting...'),
    SolarModel(name: 'Solar Panel Zone 4', status: 'Waiting...'),
  ];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    activePlant = _mqttService.selectedPlant;
    currentData = _mqttService.latestData;
    _updateDeviceStatusBasedOnPlant(); // อัปเดต UI รอบแรก

    // 2. เฝ้าฟังว่ามีการสลับ Plant หรือมีข้อมูลใหม่เข้ามาหรือไม่
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      if (mounted) {
        currentData = data;
        activePlant = _mqttService.selectedPlant;
        _updateDeviceStatusBasedOnPlant(); // อัปเดต UI เมื่อข้อมูลเปลี่ยน
      }
    });
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }


  void _updateDeviceStatusBasedOnPlant() {
    if (currentData == null) return;

    setState(() {
      if (activePlant == 'UTI' && currentData is DashboardDataUTI) {
        DashboardDataUTI dataUTI = currentData as DashboardDataUTI;
        
        String bessStatusText;
        if (dataUTI.BESS_KW < 0) {
          bessStatusText = 'Discharging';
        } else if (dataUTI.BESS_KW > 0) {
          bessStatusText = 'Charging';
        } else {
          bessStatusText = 'Offline';
        }

        allDevices = [
          InverterModel(
            name: 'Inverter UTI', 
            status: dataUTI.METER_I_Total > 0 ? 'Active' : 'Offline',
            sn: '2408214212', 
            inverterType: 'Three phase LV Hybrid',
            ratedPower: '20kW',
            systemTime: DateTime.now().toString().split('.')[0], 

            Export_KWH: '${dataUTI.METER_Export_KWH.toStringAsFixed(2)} kWh',
            Import_KWH: '${dataUTI.METER_Import_KWH.toStringAsFixed(2)} kWh',
            Export_KVARH: '${dataUTI.METER_Export_KVARH.toStringAsFixed(2)} kVARh',
            Import_KVARH: '${dataUTI.METER_Import_KVARH.toStringAsFixed(2)} kVARh',
            Total_KWH: '${dataUTI.METER_Total_KWH.toStringAsFixed(2)} kWh',
            Total_KVARH: '${dataUTI.METER_Total_KVARH.toStringAsFixed(2)} kVARh',
            Hz: '${dataUTI.METER_Hz.toStringAsFixed(2)} Hz',
            PF: '${dataUTI.METER_PF.toStringAsFixed(2)}',
            V1: '${dataUTI.METER_V1.toStringAsFixed(2)} V',
            V2: '${dataUTI.METER_V2.toStringAsFixed(2)} V',
            V3: '${dataUTI.METER_V3.toStringAsFixed(2)} V',
            I1: '${dataUTI.METER_I1.toStringAsFixed(2)} A',
            I2: '${dataUTI.METER_I2.toStringAsFixed(2)} A',
            I3: '${dataUTI.METER_I3.toStringAsFixed(2)} A',
            KW: '${dataUTI.METER_KW.toStringAsFixed(2)} kW',
            KVAR: '${dataUTI.METER_KVAR.toStringAsFixed(2)} kVAR',
            LoadPower_kW: '${dataUTI.METER_KW_Invert.abs().toStringAsFixed(2)} kW',
            GridPower_kW: '${dataUTI.METER_Grid_Power_KW.toStringAsFixed(2)} kW',
          ),

          BatteryModel(
            name: 'BESS Unit 1',
            status: bessStatusText,
            soc: '${dataUTI.BESS_SOC.toStringAsFixed(2)} %',
            soh: '${dataUTI.BESS_SOH.toStringAsFixed(2)} %',
            voltage: '${dataUTI.BESS_V.toStringAsFixed(2)} V',
            current: '${dataUTI.BESS_I.toStringAsFixed(2)} A',
            kw: '${dataUTI.BESS_KW.toStringAsFixed(2)} kW',
            temperature: '${dataUTI.BESS_Temperature.toStringAsFixed(1)} °C',
            
            totalDischarge: '${dataUTI.BESS_Total_Discharge.toStringAsFixed(2)} kWh',
            totalCharge: '${dataUTI.BESS_Total_Charge.toStringAsFixed(2)} kWh',
            dailyDischarge: '${dataUTI.BESS_Daily_Discharge_Energy.toStringAsFixed(2)} kWh',
            dailyCharge: '${dataUTI.BESS_Daily_Charge_Energy.toStringAsFixed(2)} kWh',
            socMax: '${dataUTI.BESS_SOC_MAX.toStringAsFixed(2)} %',
            socMin: '${dataUTI.BESS_SOC_MIN.toStringAsFixed(2)} %',
            powerInvert: '${dataUTI.BESS_Power_KW_Invert.toStringAsFixed(2)} kW',
            manualSetpoint: '${dataUTI.BESS_Manual_Power_Setpoint.toStringAsFixed(2)} kW',

            pidCycleTime: dataUTI.BESS_PID_CycleTime.toStringAsFixed(0),
            pidTd: dataUTI.BESS_PID_Td.toStringAsFixed(2),
            pidTi: dataUTI.BESS_PID_Ti.toStringAsFixed(2),
            pidGain: dataUTI.BESS_PID_Gain.toStringAsFixed(2),
          ),

          SolarModel(
            name: 'Solar Panel Zone 1', 
            status: dataUTI.PV1_Active_Power_KW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV1_Active_Power_KW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar Panel Zone 2', 
            status: dataUTI.PV2_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV2_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar Panel Zone 3', 
            status: dataUTI.PV3_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV3_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar Panel Zone 4', 
            status: dataUTI.PV4_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV4_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
        ];
      } 
      else if (activePlant == 'TPI' && currentData is DashboardDataTPI) {
        DashboardDataTPI dataTPI = currentData as DashboardDataTPI;
        
        String bessStatusTextTPI;
        if (dataTPI.BESS_SCU_P < 0) {
          bessStatusTextTPI = 'Charging';
        } else if (dataTPI.BESS_SCU_P > 0) {
          bessStatusTextTPI = 'Discharging';
        } else {
          bessStatusTextTPI = 'Offline';
        }

        allDevices = [
          InverterModel(
            name: 'Inverter TPI',
            status: dataTPI.METER_I1 > 0 ? 'Active' : 'Offline',
            sn: 'TPI-INV-999', 
            inverterType: 'TPI Special Inverter',
            ratedPower: '50kW',
            systemTime: DateTime.now().toString().split('.')[0], 

            Export_KWH: '${dataTPI.METER_KWHNEG.toStringAsFixed(2)} kWh',
            Import_KWH: '${dataTPI.METER_KWHPOS.toStringAsFixed(2)} kWh',
            PF: '${dataTPI.METER_PF.toStringAsFixed(2)}',
            V1: '${dataTPI.METER_V1.toStringAsFixed(2)} V',
            V2: '${dataTPI.METER_V2.toStringAsFixed(2)} V',
            V3: '${dataTPI.METER_V3.toStringAsFixed(2)} V',
            I1: '${dataTPI.METER_I1.toStringAsFixed(2)} A',
            I2: '${dataTPI.METER_I2.toStringAsFixed(2)} A',
            I3: '${dataTPI.METER_I3.toStringAsFixed(2)} A',
            KW: '${dataTPI.METER_P.toStringAsFixed(2)} kW',
            KVAR: '${dataTPI.METER_Q.toStringAsFixed(2)} kVAR',
            // ตัวแปรไหนไม่มีใน TPI ก็ใส่ขีด - หรือค่าจำลองไว้ก่อน
            LoadPower_kW: '${dataTPI.EMS_PLOAD.abs().toStringAsFixed(2)} kW',
            GridPower_kW: '${dataTPI.METER_P.toStringAsFixed(2)} kW',
          ),

          BatteryModel(
            name: 'BESS Unit 1',
            status: bessStatusTextTPI,
            soc: '${dataTPI.BESS_RACKS[0]['SOC']?.toStringAsFixed(2) ?? '0.0'} %',
            soh: '${dataTPI.BESS_RACKS[0]['SOH']?.toStringAsFixed(2) ?? '0.0'} %',
            voltage: '${dataTPI.BESS_RACKS[0]['V']?.toStringAsFixed(2) ?? '0.0'} V',
            current: '${dataTPI.BESS_RACKS[0]['I']?.toStringAsFixed(2) ?? '0.0'} A',
            kw: '${dataTPI.BESS_RACKS[0]['P']?.toStringAsFixed(2) ?? '0.0'} kW',
            temperature: '${dataTPI.BESS_RACKS[0]['CELLTEMP']?.toStringAsFixed(1) ?? '0.0'} °C',
            totalDischarge: '${dataTPI.BESS_RACKS[0]['KWHDISCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh', 
            totalCharge: '${dataTPI.BESS_RACKS[0]['KWHCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyDischarge: '${dataTPI.BESS_RACKS[0]['KWHDISCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyCharge: '${dataTPI.BESS_RACKS[0]['KWHCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
          ),
          BatteryModel(
            name: 'BESS Unit 2',
            status: bessStatusTextTPI,
            soc: '${dataTPI.BESS_RACKS[1]['SOC']?.toStringAsFixed(2) ?? '0.0'} %',
            soh: '${dataTPI.BESS_RACKS[1]['SOH']?.toStringAsFixed(2) ?? '0.0'} %',
            voltage: '${dataTPI.BESS_RACKS[1]['V']?.toStringAsFixed(2) ?? '0.0'} V',
            current: '${dataTPI.BESS_RACKS[1]['I']?.toStringAsFixed(2) ?? '0.0'} A',
            kw: '${dataTPI.BESS_RACKS[1]['P']?.toStringAsFixed(2) ?? '0.0'} kW',
            temperature: '${dataTPI.BESS_RACKS[1]['CELLTEMP']?.toStringAsFixed(1) ?? '0.0'} °C',
            totalDischarge: '${dataTPI.BESS_RACKS[1]['KWHDISCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh', 
            totalCharge: '${dataTPI.BESS_RACKS[1]['KWHCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyDischarge: '${dataTPI.BESS_RACKS[1]['KWHDISCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyCharge: '${dataTPI.BESS_RACKS[1]['KWHCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
          ),
          BatteryModel(
            name: 'BESS Unit 3',
            status: bessStatusTextTPI,
            soc: '${dataTPI.BESS_RACKS[2]['SOC']?.toStringAsFixed(2) ?? '0.0'} %',
            soh: '${dataTPI.BESS_RACKS[2]['SOH']?.toStringAsFixed(2) ?? '0.0'} %',
            voltage: '${dataTPI.BESS_RACKS[2]['V']?.toStringAsFixed(2) ?? '0.0'} V',
            current: '${dataTPI.BESS_RACKS[2]['I']?.toStringAsFixed(2) ?? '0.0'} A',
            kw: '${dataTPI.BESS_RACKS[2]['P']?.toStringAsFixed(2) ?? '0.0'} kW',
            temperature: '${dataTPI.BESS_RACKS[2]['CELLTEMP']?.toStringAsFixed(1) ?? '0.0'} °C',
            totalDischarge: '${dataTPI.BESS_RACKS[2]['KWHDISCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh', 
            totalCharge: '${dataTPI.BESS_RACKS[2]['KWHCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyDischarge: '${dataTPI.BESS_RACKS[2]['KWHDISCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyCharge: '${dataTPI.BESS_RACKS[2]['KWHCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
          ),
          BatteryModel(
            name: 'BESS Unit 4',
            status: bessStatusTextTPI,
            soc: '${dataTPI.BESS_RACKS[3]['SOC']?.toStringAsFixed(2) ?? '0.0'} %',
            soh: '${dataTPI.BESS_RACKS[3]['SOH']?.toStringAsFixed(2) ?? '0.0'} %',
            voltage: '${dataTPI.BESS_RACKS[3]['V']?.toStringAsFixed(2) ?? '0.0'} V',
            current: '${dataTPI.BESS_RACKS[3]['I']?.toStringAsFixed(2) ?? '0.0'} A',
            kw: '${dataTPI.BESS_RACKS[3]['P']?.toStringAsFixed(2) ?? '0.0'} kW',
            temperature: '${dataTPI.BESS_RACKS[3]['CELLTEMP']?.toStringAsFixed(1) ?? '0.0'} °C',
            totalDischarge: '${dataTPI.BESS_RACKS[3]['KWHDISCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh', 
            totalCharge: '${dataTPI.BESS_RACKS[3]['KWHCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyDischarge: '${dataTPI.BESS_RACKS[3]['KWHDISCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyCharge: '${dataTPI.BESS_RACKS[3]['KWHCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
          ),
          BatteryModel(
            name: 'BESS Unit 5',
            status: bessStatusTextTPI,
            soc: '${dataTPI.BESS_RACKS[4]['SOC']?.toStringAsFixed(2) ?? '0.0'} %',
            soh: '${dataTPI.BESS_RACKS[4]['SOH']?.toStringAsFixed(2) ?? '0.0'} %',
            voltage: '${dataTPI.BESS_RACKS[4]['V']?.toStringAsFixed(2) ?? '0.0'} V',
            current: '${dataTPI.BESS_RACKS[4]['I']?.toStringAsFixed(2) ?? '0.0'} A',
            kw: '${dataTPI.BESS_RACKS[4]['P']?.toStringAsFixed(2) ?? '0.0'} kW',
            temperature: '${dataTPI.BESS_RACKS[4]['CELLTEMP']?.toStringAsFixed(1) ?? '0.0'} °C',
            totalDischarge: '${dataTPI.BESS_RACKS[4]['KWHDISCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh', 
            totalCharge: '${dataTPI.BESS_RACKS[4]['KWHCHARGETOTAL']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyDischarge: '${dataTPI.BESS_RACKS[4]['KWHDISCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
            dailyCharge: '${dataTPI.BESS_RACKS[4]['KWHCHARGEDAILY']?.toStringAsFixed(2) ?? '0.0'} kWh',
          ),

          SolarModel(
            name: 'Solar Panel Logger 1 (TPI)', 
            status: dataTPI.SOLAR_SOLAR1_LOGGER1_P > 0 ? 'Active' : 'Offline',
            currentPower: '${dataTPI.SOLAR_SOLAR1_LOGGER1_P.toStringAsFixed(2)} kW',
          ),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.only(left: 20),
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: const Color.fromRGBO(28, 134, 223, 1),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: [
                _DeviceCategoryTab(isSelected: _selectedIndex == 0, text: 'All'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 1, text: 'Inverter'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 2, text: 'BESS'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 3, text: 'Solar Panel'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DeviceListView(devices: allDevices),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.inverter).toList()),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.bess).toList()),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.solarPanel).toList()),
        ],
      ),
    );
  }
}

class _DeviceCategoryTab extends StatelessWidget {
  final bool isSelected;
  final String text;

  const _DeviceCategoryTab({
    required this.isSelected,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? const Color.fromRGBO(28, 134, 223, 1) : Colors.grey, 
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _DeviceListView extends StatelessWidget {
  final List<DeviceModel> devices;
  const _DeviceListView({required this.devices});

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) return const Center(child: Text('No devices found'));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        Color statusColor = _getStatusColor(device.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(_getIcon(device.type), color: Colors.blueGrey),
            title: Text(device.name),
            subtitle: Row(
              children: [
                const Text('Status: '), 
                Text(
                  device.status, 
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold,),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailPage(device: device),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Active' || status == 'Charging') {
      return Colors.green;
    } 
    else if (status == 'Discharging') {
      return Colors.red;
    } 
    else {
      return Colors.grey;
    }
  }

  IconData _getIcon(DeviceType type) {
    switch (type) {
      case DeviceType.inverter: return Icons.bolt;
      case DeviceType.bess: return Icons.battery_charging_full;
      case DeviceType.solarPanel: return Icons.wb_sunny;
    }
  }
}