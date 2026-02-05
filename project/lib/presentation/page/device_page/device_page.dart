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

  DashboardData Data = DashboardData();
  StreamSubscription? _mqttSubscription;
  
  // ✅ 1. สร้าง List เริ่มต้นด้วย Class ลูกที่ถูกต้อง
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
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.animation!.value == _tabController.index.toDouble()) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    _initMqtt();
  }

  void _initMqtt() {
    MqttService().connect();
    _mqttSubscription = MqttService().dataStream.listen((newData) {
      setState(() {
        Data = newData;
        _updateDeviceListStatus();
      });
    });
  }

  // ✅ 2. ฟังก์ชันอัปเดตสถานะและข้อมูล Real-time
  void _updateDeviceListStatus() {
    String bessStatusText;
    double bessKW = Data.BESS_KW;

    if (bessKW > 0) {
      bessStatusText = 'Charging';
    } else if (bessKW < 0) {
      bessStatusText = 'Discharging';
    } else {
      bessStatusText = 'Offline';
    }

    setState(() {
      allDevices = [
        // อัปเดต Inverter
        InverterModel(
          name: 'Inverter', 
          status: Data.METER_I_Total > 0 ? 'Active' : 'Offline',
          sn: '2408214212', 
          inverterType: 'Three phase LV Hybrid',
          ratedPower: '20kW',
          systemTime: DateTime.now().toString().split('.')[0], // อัปเดตเวลาจริง

          Export_KWH: '${Data.METER_Export_KWH.toStringAsFixed(2)} kWh',
          Import_KWH: '${Data.METER_Import_KWH.toStringAsFixed(2)} kWh',
          Export_KVARH: '${Data.METER_Export_KVARH.toStringAsFixed(2)} kVARh',
          Import_KVARH: '${Data.METER_Import_KVARH.toStringAsFixed(2)} kVARh',
          Total_KWH: '${Data.METER_Total_KWH.toStringAsFixed(2)} kWh',
          Total_KVARH: '${Data.METER_Total_KVARH.toStringAsFixed(2)} kVARh',
          Hz: '${Data.METER_Hz.toStringAsFixed(2)} Hz',
          PF: '${Data.METER_PF.toStringAsFixed(2)}',
          V1: '${Data.METER_V1.toStringAsFixed(2)} V',
          V2: '${Data.METER_V2.toStringAsFixed(2)} V',
          V3: '${Data.METER_V3.toStringAsFixed(2)} V',
          I1: '${Data.METER_I1.toStringAsFixed(2)} A',
          I2: '${Data.METER_I2.toStringAsFixed(2)} A',
          I3: '${Data.METER_I3.toStringAsFixed(2)} A',
          KW: '${Data.METER_KW.toStringAsFixed(2)} kW',
          KVAR: '${Data.METER_KVAR.toStringAsFixed(2)} kVAR',
          LoadPower_kW: '${Data.METER_KW_Invert.abs().toStringAsFixed(2)} kW',
          GridPower_kW: '${Data.METER_Grid_Power_KW.toStringAsFixed(2)} kW',
        ),

        // อัปเดต Battery (ใส่ค่า Real-time)
        BatteryModel(
          name: 'BESS Unit 1',
          status: bessStatusText,
          // กลุ่มข้อมูลหลัก
          soc: '${Data.BESS_SOC.toStringAsFixed(2)} %',
          soh: '${Data.BESS_SOH.toStringAsFixed(2)} %',
          voltage: '${Data.BESS_V.toStringAsFixed(2)} V',
          current: '${Data.BESS_I.toStringAsFixed(2)} A',
          kw: '${Data.BESS_KW.toStringAsFixed(2)} kW',
          temperature: '${Data.BESS_Temperature.toStringAsFixed(1)} °C',
          
          // กลุ่ม Energy & Limits
          totalDischarge: '${Data.BESS_Total_Discharge.toStringAsFixed(2)} kWh',
          totalCharge: '${Data.BESS_Total_Charge.toStringAsFixed(2)} kWh',
          dailyDischarge: '${Data.BESS_Daily_Discharge_Energy.toStringAsFixed(2)} kWh',
          dailyCharge: '${Data.BESS_Daily_Charge_Energy.toStringAsFixed(2)} kWh',
          socMax: '${Data.BESS_SOC_MAX.toStringAsFixed(2)} %',
          socMin: '${Data.BESS_SOC_MIN.toStringAsFixed(2)} %',
          powerInvert: '${Data.BESS_Power_KW_Invert.toStringAsFixed(2)} kW',
          manualSetpoint: '${Data.BESS_Manual_Power_Setpoint.toStringAsFixed(2)} kW',

          // กลุ่ม PID
          pidCycleTime: Data.BESS_PID_CycleTime.toStringAsFixed(0),
          pidTd: Data.BESS_PID_Td.toStringAsFixed(2),
          pidTi: Data.BESS_PID_Ti.toStringAsFixed(2),
          pidGain: Data.BESS_PID_Gain.toStringAsFixed(2),
        ),

        // อัปเดต Solar Panels
        SolarModel(
          name: 'Solar Panel Zone 1', 
          status: Data.PV1_Active_Power_KW > 0 ? 'Active' : 'Offline',
          currentPower: '${Data.PV1_Active_Power_KW.toStringAsFixed(2)} kW',
        ),
        SolarModel(
          name: 'Solar Panel Zone 2', 
          status: Data.PV2_Active_Power_kW > 0 ? 'Active' : 'Offline',
          currentPower: '${Data.PV2_Active_Power_kW.toStringAsFixed(2)} kW',
        ),
        SolarModel(
          name: 'Solar Panel Zone 3', 
          status: Data.PV3_Active_Power_kW > 0 ? 'Active' : 'Offline',
          currentPower: '${Data.PV3_Active_Power_kW.toStringAsFixed(2)} kW',
        ),
        SolarModel(
          name: 'Solar Panel Zone 4', 
          status: Data.PV4_Active_Power_kW > 0 ? 'Active' : 'Offline',
          currentPower: '${Data.PV4_Active_Power_kW.toStringAsFixed(2)} kW',
        ),
      ];
    });
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
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