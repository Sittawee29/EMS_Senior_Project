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
    SolarModel(name: 'Solar System 1', status: 'Waiting...'),
    SolarModel(name: 'Solar System 2', status: 'Waiting...'),
    SolarModel(name: 'Solar System 3', status: 'Waiting...'),
    SolarModel(name: 'Solar System 4', status: 'Waiting...'),
    BatteryModel(name: 'BESS Systems 1',status: 'Waiting...',),
    MeterModel(name: 'Solar System 1',status: 'Waiting...'),
  ];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 5, vsync: this);
    activePlant = _mqttService.selectedPlant;
    currentData = _mqttService.latestData;
    _updateDeviceStatusBasedOnPlant();
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      if (mounted) {
        currentData = data;
        activePlant = _mqttService.selectedPlant;
        _updateDeviceStatusBasedOnPlant();
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
          SolarModel(
            name: 'Solar System 1', 
            status: dataUTI.PV1_Active_Power_KW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV1_Active_Power_KW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar System 2', 
            status: dataUTI.PV2_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV2_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar System 3', 
            status: dataUTI.PV3_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV3_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
          SolarModel(
            name: 'Solar System 4', 
            status: dataUTI.PV4_Active_Power_kW > 0 ? 'Active' : 'Offline',
            currentPower: '${dataUTI.PV4_Active_Power_kW.toStringAsFixed(2)} kW',
          ),
          MeterModel(
            name: 'Meter UTI', 
            status: dataUTI.METER_I_Total > 0 ? 'Active' : 'Offline',
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
            name: 'BESS System 1',
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
          SolarModel(
            name: 'Solar System 1', 
            status: dataTPI.SOLAR_SOLAR1_LOGGER1_P > 0 ? 'Active' : 'Offline',
            currentPower: '${dataTPI.SOLAR_SOLAR1_LOGGER1_P.toStringAsFixed(2)} kW',
          ),
          BatteryModel(
            name: 'BESS System 1',
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
            name: 'BESS System 2',
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
            name: 'BESS System 3',
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
            name: 'BESS System 4',
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
            name: 'BESS System 5',
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
          MeterModel(
            name: 'Meter TPI',
            status: dataTPI.METER_I1 > 0 ? 'Active' : 'Offline',
            P: '${dataTPI.METER_P.toStringAsFixed(2)} kW',
            Q: '${dataTPI.METER_Q.toStringAsFixed(2)} kVAR',
            PF: '${dataTPI.METER_PF.toStringAsFixed(2)}',
            S: '${dataTPI.METER_S.toStringAsFixed(2)} kVA',
            V1: '${dataTPI.METER_V1.toStringAsFixed(2)} V',
            V2: '${dataTPI.METER_V2.toStringAsFixed(2)} V',
            V3: '${dataTPI.METER_V3.toStringAsFixed(2)} V',
            I1: '${dataTPI.METER_I1.toStringAsFixed(2)} A',
            I2: '${dataTPI.METER_I2.toStringAsFixed(2)} A',
            I3: '${dataTPI.METER_I3.toStringAsFixed(2)} A',
            kwhtotal: '${(dataTPI.METER_KWHTOTAL/1000).toStringAsFixed(2)} MWh',
            kwhpos: '${(dataTPI.METER_KWHPOS/1000).toStringAsFixed(2)} MWh',
            kwhneg: '${(dataTPI.METER_KWHNEG/1000).toStringAsFixed(2)} MWh',
            kwhtotaldaily: '${dataTPI.METER_KWHTOTALDAILY.toStringAsFixed(2)} kWh',
            kwhposdaily: '${dataTPI.METER_KWHPOSDAILY.toStringAsFixed(2)} kWh',
            kwhnegdaily: '${dataTPI.METER_KWHNEGDAILY.toStringAsFixed(2)} kWh',
          ),
          EMSModel(
            name: 'EMS System TPI',
            status: dataTPI.METER_I1 > 0 ? 'Active' : 'Offline',
            
            kwhloadtotal: '${(dataTPI.EMS_KWHLOADTOTAL/1000).toStringAsFixed(2)} MWh',
            kwhloaddaily: '${dataTPI.EMS_KWHLOADDAILY.toStringAsFixed(2)} kWh',
            pload: '${dataTPI.EMS_PLOAD.abs().toStringAsFixed(2)} kW',
            co2e: '${dataTPI.EMS_CO2E.toStringAsFixed(2)} CO₂e',
            renewratiolifetime: '${(dataTPI.EMS_RENEWRATIOLIFETIME*100).toStringAsFixed(2)} %',
            renewratio: '${(dataTPI.EMS_RENEWRATIO*100).toStringAsFixed(2)} %',
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
                _DeviceCategoryTab(isSelected: _selectedIndex == 1, text: 'Solar Systems'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 2, text: 'BESS Systems'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 3, text: 'Meters'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 4, text: 'EMS Systems'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DeviceListView(devices: allDevices),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.solar).toList()),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.bess).toList()),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.meter).toList()),
          _DeviceListView(devices: allDevices.where((d) => d.type == DeviceType.ems).toList()),
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
              if (device.type == DeviceType.solar) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolarSubDevicePage(solarDevice: device as SolarModel),
                  ),
                );
              } else {
                // ไปหน้า Detail เดิม
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailPage(device: device),
                  ),
                );
              }
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
      case DeviceType.solar: return Icons.bolt;
      case DeviceType.bess: return Icons.battery_charging_full;
      case DeviceType.meter: return Icons.electric_meter;
      case DeviceType.ems: return Icons.settings_applications;
      case DeviceType.logger: return Icons.storage;
      case DeviceType.emi: return Icons.solar_power_rounded;
    }
  }
}

class SolarSubDevicePage extends StatefulWidget {
  final SolarModel solarDevice;
  const SolarSubDevicePage({Key? key, required this.solarDevice}) : super(key: key);

  @override
  State<SolarSubDevicePage> createState() => _SolarSubDevicePageState();
}

class _SolarSubDevicePageState extends State<SolarSubDevicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  List<DeviceModel> subDevices = [];
  final MqttService _mqttService = MqttService();
  StreamSubscription? _mqttSubscription;
  dynamic currentData;
  String activePlant = 'UTI';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    _initDefaultSubDevices();
    activePlant = _mqttService.selectedPlant;
    currentData = _mqttService.latestData;
    _updateSubDevicesBasedOnPlant();
    _mqttSubscription = _mqttService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          currentData = data;
          activePlant = _mqttService.selectedPlant;
          _updateSubDevicesBasedOnPlant();
        });
      }
    });
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _initDefaultSubDevices() {
    subDevices = [
      SolarLoggerModel(name: 'Logger 1', status: 'Waiting...'),
      SolarMeterModel(name: 'Meter 1', status: 'Waiting...'),
      SolarMeterModel(name: 'Meter 2', status: 'Waiting...'),
      SolarEMIModel(name: 'EMI 1', status: 'Waiting...'),
    ];
  }

  void _updateSubDevicesBasedOnPlant() {
    if (currentData == null) return;

    setState(() {
      try {
        dynamic data = currentData;
        double v(String key, double Function() getObjVal) {
          try {
            if (data is Map) return double.parse((data[key] ?? 0).toString());
            return double.parse((getObjVal() ?? 0).toString());
          } catch (e) {
            return 0.0;
          }
        }

        if (activePlant == 'UTI') {
          subDevices = [
            SolarLoggerModel(
              name: 'Solar Logger 1',
              status: v('METER_I1', () => data.METER_I1) > 0 ? 'Active' : 'Offline',
            ),
            SolarMeterModel(
              name: 'Meter of ${widget.solarDevice.name}', 
              status: v('METER_I_Total', () => data.METER_I_Total) > 0 ? 'Active' : 'Offline',
            ),
            SolarEMIModel(
              name: 'EMI 1', 
              status: 'Active',
            ),
          ];

        } else if (activePlant == 'TPI') {
          subDevices = [
            SolarLoggerModel(
              name: 'Solar Logger 1',
              status: v('SOLAR_SOLAR1_LOGGER1_P', () => data.SOLAR_SOLAR1_LOGGER1_P) > 0 ? 'Active' : 'Offline',
              kwhtotal: '${(v('SOLAR_SOLAR1_LOGGER1_KWHTOTAL', () => data.SOLAR_SOLAR1_LOGGER1_KWHTOTAL) / 1000).toStringAsFixed(2)} MWh',
              kwhdaily: '${v('SOLAR_SOLAR1_LOGGER1_KWHDAILY', () => data.SOLAR_SOLAR1_LOGGER1_KWHDAILY).toStringAsFixed(2)} kWh',
              p: '${v('SOLAR_SOLAR1_LOGGER1_P', () => data.SOLAR_SOLAR1_LOGGER1_P).toStringAsFixed(2)} kW',
              q: '${v('SOLAR_SOLAR1_LOGGER1_Q', () => data.SOLAR_SOLAR1_LOGGER1_Q).toStringAsFixed(2)} kVAR',
              idc: '${v('SOLAR_SOLAR1_LOGGER1_IDC', () => data.SOLAR_SOLAR1_LOGGER1_IDC).toStringAsFixed(2)} A',
              pf: '${v('SOLAR_SOLAR1_LOGGER1_PF', () => data.SOLAR_SOLAR1_LOGGER1_PF).toStringAsFixed(2)}',
              v12: '${v('SOLAR_SOLAR1_LOGGER1_V12', () => data.SOLAR_SOLAR1_LOGGER1_V12).toStringAsFixed(2)} V',
              i1: '${v('SOLAR_SOLAR1_LOGGER1_I1', () => data.SOLAR_SOLAR1_LOGGER1_I1).toStringAsFixed(2)} A',
              v23: '${v('SOLAR_SOLAR1_LOGGER1_V23', () => data.SOLAR_SOLAR1_LOGGER1_V23).toStringAsFixed(2)} V',
              i2: '${v('SOLAR_SOLAR1_LOGGER1_I2', () => data.SOLAR_SOLAR1_LOGGER1_I2).toStringAsFixed(2)} A',
              v31: '${v('SOLAR_SOLAR1_LOGGER1_V31', () => data.SOLAR_SOLAR1_LOGGER1_V31).toStringAsFixed(2)} V',
              i3: '${v('SOLAR_SOLAR1_LOGGER1_I3', () => data.SOLAR_SOLAR1_LOGGER1_I3).toStringAsFixed(2)} A',
            ),
            SolarMeterModel(
              name: 'Meter 2', 
              status: v('SOLAR_SOLAR1_METER2_P', () => data.SOLAR_SOLAR1_METER2_P) > 0 ? 'Active' : 'Offline',
              kwhtotal: '${(v('SOLAR_SOLAR1_METER2_KWHTOTAL', () => data.SOLAR_SOLAR1_METER2_KWHTOTAL) / 1000).toStringAsFixed(2)} MWh',
              kwhpos: '${(v('SOLAR_SOLAR1_METER2_KWHPOS', () => data.SOLAR_SOLAR1_METER2_KWHPOS) / 1000).toStringAsFixed(2)} MWh',
              kwhneg: '${(v('SOLAR_SOLAR1_METER2_KWHNEG', () => data.SOLAR_SOLAR1_METER2_KWHNEG) / 1000).toStringAsFixed(2)} MWh',
              p: '${v('SOLAR_SOLAR1_METER2_P', () => data.SOLAR_SOLAR1_METER2_P).toStringAsFixed(2)} kW',
              q: '${v('SOLAR_SOLAR1_METER2_Q', () => data.SOLAR_SOLAR1_METER2_Q).toStringAsFixed(2)} kVAR',
              pf: '${v('SOLAR_SOLAR1_METER2_PF', () => data.SOLAR_SOLAR1_METER2_PF).toStringAsFixed(2)}',
              s: '${v('SOLAR_SOLAR1_METER2_S', () => data.SOLAR_SOLAR1_METER2_S).toStringAsFixed(2)} kVA',
              v1: '${v('SOLAR_SOLAR1_METER2_V1', () => data.SOLAR_SOLAR1_METER2_V1).toStringAsFixed(2)} V',
              i1: '${v('SOLAR_SOLAR1_METER2_I1', () => data.SOLAR_SOLAR1_METER2_I1).toStringAsFixed(2)} A',
              v2: '${v('SOLAR_SOLAR1_METER2_V2', () => data.SOLAR_SOLAR1_METER2_V2).toStringAsFixed(2)} V',
              i2: '${v('SOLAR_SOLAR1_METER2_I2', () => data.SOLAR_SOLAR1_METER2_I2).toStringAsFixed(2)} A',
              v3: '${v('SOLAR_SOLAR1_METER2_V3', () => data.SOLAR_SOLAR1_METER2_V3).toStringAsFixed(2)} V',
              i3: '${v('SOLAR_SOLAR1_METER2_I3', () => data.SOLAR_SOLAR1_METER2_I3).toStringAsFixed(2)} A',
              v12: '${v('SOLAR_SOLAR1_METER2_V12', () => data.SOLAR_SOLAR1_METER2_V12).toStringAsFixed(2)} V',
              v23: '${v('SOLAR_SOLAR1_METER2_V23', () => data.SOLAR_SOLAR1_METER2_V23).toStringAsFixed(2)} V',
              v31: '${v('SOLAR_SOLAR1_METER2_V31', () => data.SOLAR_SOLAR1_METER2_V31).toStringAsFixed(2)} V', 
            ),
            SolarMeterModel(
              name: 'Meter 3', 
              status: v('SOLAR_SOLAR1_METER3_P', () => data.SOLAR_SOLAR1_METER3_P) > 0 ? 'Active' : 'Offline',
              kwhtotal: '${(v('SOLAR_SOLAR1_METER3_KWHTOTAL', () => data.SOLAR_SOLAR1_METER3_KWHTOTAL) / 1000).toStringAsFixed(2)} MWh',
              kwhpos: '${(v('SOLAR_SOLAR1_METER3_KWHPOS', () => data.SOLAR_SOLAR1_METER3_KWHPOS) / 1000).toStringAsFixed(2)} MWh',
              kwhneg: '${(v('SOLAR_SOLAR1_METER3_KWHNEG', () => data.SOLAR_SOLAR1_METER3_KWHNEG) / 1000).toStringAsFixed(2)} MWh',
              p: '${v('SOLAR_SOLAR1_METER3_P', () => data.SOLAR_SOLAR1_METER3_P).toStringAsFixed(2)} kW',
              q: '${v('SOLAR_SOLAR1_METER3_Q', () => data.SOLAR_SOLAR1_METER3_Q).toStringAsFixed(2)} kVAR',
              pf: '${v('SOLAR_SOLAR1_METER3_PF', () => data.SOLAR_SOLAR1_METER3_PF).toStringAsFixed(2)}',
              s: '${v('SOLAR_SOLAR1_METER3_S', () => data.SOLAR_SOLAR1_METER3_S).toStringAsFixed(2)} kVA',
              v1: '${v('SOLAR_SOLAR1_METER3_V1', () => data.SOLAR_SOLAR1_METER3_V1).toStringAsFixed(2)} V',
              i1: '${v('SOLAR_SOLAR1_METER3_I1', () => data.SOLAR_SOLAR1_METER3_I1).toStringAsFixed(2)} A',
              v2: '${v('SOLAR_SOLAR1_METER3_V2', () => data.SOLAR_SOLAR1_METER3_V2).toStringAsFixed(2)} V',
              i2: '${v('SOLAR_SOLAR1_METER3_I2', () => data.SOLAR_SOLAR1_METER3_I2).toStringAsFixed(2)} A',
              v3: '${v('SOLAR_SOLAR1_METER3_V3', () => data.SOLAR_SOLAR1_METER3_V3).toStringAsFixed(2)} V',
              i3: '${v('SOLAR_SOLAR1_METER3_I3', () => data.SOLAR_SOLAR1_METER3_I3).toStringAsFixed(2)} A',
              v12: '${v('SOLAR_SOLAR1_METER3_V12', () => data.SOLAR_SOLAR1_METER3_V12).toStringAsFixed(2)} V',
              v23: '${v('SOLAR_SOLAR1_METER3_V23', () => data.SOLAR_SOLAR1_METER3_V23).toStringAsFixed(2)} V',
              v31: '${v('SOLAR_SOLAR1_METER3_V31', () => data.SOLAR_SOLAR1_METER3_V31).toStringAsFixed(2)} V', 
            ),
            SolarEMIModel(
              name: 'EMI 1',
              status: v('SOLAR_SOLAR1_EMI1_TEMPAMBIENT', () => data.SOLAR_SOLAR1_EMI1_TEMPAMBIENT) > 0 ? 'Active' : 'Offline',
              tempambient: '${v('SOLAR_SOLAR1_EMI1_TEMPAMBIENT', () => data.SOLAR_SOLAR1_EMI1_TEMPAMBIENT).toStringAsFixed(1)} °C',
              irradiancetotal: '${v('SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL', () => data.SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL).toStringAsFixed(2)} W/m²',
              irradiancedaily: '${v('SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY', () => data.SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY).toStringAsFixed(2)} kWh/m²',
              temppv: '${v('SOLAR_SOLAR1_EMI1_TEMPPV', () => data.SOLAR_SOLAR1_EMI1_TEMPPV).toStringAsFixed(1)} °C',
            ),
          ];
        }
      } catch (e) {
        debugPrint('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.solarDevice.name),
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
                _DeviceCategoryTab(isSelected: _selectedIndex == 1, text: 'Loggers'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 2, text: 'Meters'),
                _DeviceCategoryTab(isSelected: _selectedIndex == 3, text: 'EMIs'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DeviceListView(devices: subDevices),
          _DeviceListView(devices: subDevices.where((d) => d.type == DeviceType.logger).toList()),
          _DeviceListView(devices: subDevices.where((d) => d.type == DeviceType.meter).toList()),
          _DeviceListView(devices: subDevices.where((d) => d.type == DeviceType.emi).toList()),
        ],
      ),
    );
  }
}