import 'dart:async';
import 'package:flutter/material.dart';
import 'device_model.dart';
import '../../../../../services/mqtt_service.dart';

class DeviceDetailPage extends StatefulWidget {
  final DeviceModel device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late DeviceModel currentDevice;
  
  DashboardDataUTI Data = DashboardDataUTI(); 
  StreamSubscription? _mqttSubscription;

  @override
  void initState() {
    super.initState();
    currentDevice = widget.device;
    
    _initMqttListener();
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    super.dispose();
  }

  void _initMqttListener() {
    _mqttSubscription = MqttService().dataStream.listen((newData) {
      if (mounted) {
        setState(() {
          Data = newData; 
          _updateDeviceData(); 
        });
      }
    });
  }

  void _updateDeviceData() {
    setState(() {
      if (currentDevice is MeterModel) {
        MeterModel oldData = currentDevice as MeterModel;
        currentDevice = MeterModel(
          name: oldData.name,
          status: Data.METER_I_Total > 0 ? 'Active' : 'Offline',
          Export_KWH: '${Data.METER_Export_KWH.toStringAsFixed(2)} kWh',
          Import_KWH: '${Data.METER_Import_KWH.toStringAsFixed(2)} kWh',
          Export_KVARH: '${Data.METER_Export_KVARH.toStringAsFixed(2)} kVARh',
          Import_KVARH: '${Data.METER_Import_KVARH.toStringAsFixed(2)} kVARh',
          Total_KWH: '${Data.METER_Total_KWH.toStringAsFixed(2)} kWh',
          Total_KVARH: '${Data.METER_Total_KVARH.toStringAsFixed(2)} kVARh',
          Hz: '${Data.METER_Hz.toStringAsFixed(2)} Hz',
          PF: Data.METER_PF.toStringAsFixed(2),
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
        );
      }

      else if (currentDevice is EMSModel) {
        EMSModel oldData = currentDevice as EMSModel;
        currentDevice = EMSModel(
          name: oldData.name,
          status: Data.METER_I_Total > 0 ? 'Active' : 'Offline',
          pload: '${Data.EMS_LoadPower_kW.toStringAsFixed(2)} kW',
          kwhloadtotal: '${(Data.EMS_EnergyConsumption_kWh/1000).toStringAsFixed(2)} MWh',
          kwhloaddaily: '${Data.EMS_EnergyConsumption_Daily.toStringAsFixed(2)} kWh',
          renewratio: '${Data.EMS_RenewRatioDaily.toStringAsFixed(2)} %',
          co2e: '${Data.EMS_CO2_Equivalent.toStringAsFixed(2)} kgCO2e',
          renewratiolifetime: '${Data.EMS_RenewRatioLifetime.toStringAsFixed(2)} %',
        );
      }

      else if (currentDevice is BatteryModel) {
        currentDevice = BatteryModel(
          name: currentDevice.name,
          status: Data.BESS_KW > 0 ? 'Charging' : (Data.BESS_KW < 0 ? 'Discharging' : 'Standby'),
          
          soc: '${Data.BESS_SOC.toStringAsFixed(2)} %',
          soh: '${Data.BESS_SOH.toStringAsFixed(2)} %',
          voltage: '${Data.BESS_V.toStringAsFixed(2)} V',
          current: '${Data.BESS_I.toStringAsFixed(2)} A',
          kw: '${Data.BESS_KW.toStringAsFixed(2)} kW',
          temperature: '${Data.BESS_Temperature.toStringAsFixed(1)} °C',
          
          totalDischarge: '${Data.BESS_Total_Discharge.toStringAsFixed(2)} kWh',
          totalCharge: '${Data.BESS_Total_Charge.toStringAsFixed(2)} kWh',
          socMax: '${Data.BESS_SOC_MAX.toStringAsFixed(2)} %',
          socMin: '${Data.BESS_SOC_MIN.toStringAsFixed(2)} %',
          powerInvert: '${Data.BESS_Power_KW_Invert.toStringAsFixed(2)} kW',
          manualSetpoint: '${Data.BESS_Manual_Power_Setpoint.toStringAsFixed(2)} kW',

          pidCycleTime: Data.BESS_PID_CycleTime.toStringAsFixed(0),
          pidTd: Data.BESS_PID_Td.toStringAsFixed(2),
          pidTi: Data.BESS_PID_Ti.toStringAsFixed(2),
          pidGain: Data.BESS_PID_Gain.toStringAsFixed(2),
          
          dailyCharge: '${Data.BESS_Daily_Charge_Energy.toStringAsFixed(2)} kWh',
          dailyDischarge: '${Data.BESS_Daily_Discharge_Energy.toStringAsFixed(2)} kWh',
        );
      }

      else if (currentDevice is SolarModel) {
        double solarPower = 0.0;
        String name = currentDevice.name;

        if (name.contains('Zone 1')) solarPower = Data.PV1_Active_Power_KW;
        else if (name.contains('Zone 2')) solarPower = Data.PV2_Active_Power_kW;
        else if (name.contains('Zone 3')) solarPower = Data.PV3_Active_Power_kW;
        else if (name.contains('Zone 4')) solarPower = Data.PV4_Active_Power_kW;

        currentDevice = SolarModel(
          name: name,
          status: solarPower > 0 ? 'Active' : 'Offline',
          currentPower: '${solarPower.toStringAsFixed(2)} kW',
        );
      }

      else if (currentDevice is SolarLoggerModel) {
        SolarLoggerModel oldData = currentDevice as SolarLoggerModel;
        currentDevice = SolarLoggerModel(
          name: oldData.name,
          status: Data.PV1_Active_Power_KW > 0 ? 'Active' : 'Offline',
          p: '${Data.PV1_Active_Power_KW.toStringAsFixed(2)} kW',
          
        );
      }

      else if (currentDevice is SolarMeterModel) {
        SolarMeterModel oldData = currentDevice as SolarMeterModel;
        currentDevice = SolarMeterModel(
          name: oldData.name,
          status: Data.METER_I_Total > 0 ? 'Active' : 'Offline',
          p: '${Data.PV1_Active_Power_KW.toStringAsFixed(2)} kW',
        );
      }

      else if (currentDevice is SolarEMIModel) {
        SolarEMIModel oldData = currentDevice as SolarEMIModel;
        currentDevice = SolarEMIModel(
          name: oldData.name,
          status: 'Active',
          
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            currentDevice.name,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
              hoverColor: Colors.transparent,
            ),
          ],
          bottom: TabBar(
            labelColor: Color.fromRGBO(28, 134, 223, 1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color.fromRGBO(28, 134, 223, 1),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'Device Data'),
              Tab(text: 'Architecture'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildDeviceContent(currentDevice),
            ),
            const Center(child: Text('Architecture View')),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceContent(DeviceModel device) {
    if (device is MeterModel) {return _buildMeterView(device);}
    else if (device is EMSModel) {return _buildEMSView(device);}
    else if (device is BatteryModel) {return _buildBatteryView(device);}
    else if (device is SolarLoggerModel) {return _buildSolarLoggerView(device);}
    else if (device is SolarMeterModel) {return _buildSolarMeterView(device);}
    else if (device is SolarEMIModel) {return _buildSolarEMIView(device);}
    else {return const Center(child: Text('Unknown Device Type'));}
  }

  // --- View Builders (เหมือนเดิม) ---

  Widget _buildMeterView(MeterModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Power Information'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,        // 2 คอลัมน์
          shrinkWrap: true,         // ขยายตามเนื้อหา
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,      // ปรับสัดส่วนให้บรรทัดไม่สูงเกินไป (ยิ่งเลขเยอะ บรรทัดยิ่งเตี้ย)
          crossAxisSpacing: 20,     // ระยะห่างแนวนอน
          mainAxisSpacing: 5,       // ระยะห่างแนวตั้ง
          children: [
          _buildTextItem('Power', data.P),
          _buildTextItem('Reactive Power', data.Q),
          _buildTextItem('Apparent Power', data.S),
          _buildTextItem('Power Factor (PF)', data.PF),
          _buildTextItem('Voltage V1', data.V1),
          _buildTextItem('Current I1', data.I1),
          _buildTextItem('Voltage V2', data.V2),
          _buildTextItem('Current I2', data.I2),
          _buildTextItem('Voltage V3', data.V3),
          _buildTextItem('Current I3', data.I3),
          _buildTextItem('Power Total', data.kwhtotal),
          _buildTextItem('Power Total Daily', data.kwhtotaldaily),
          _buildTextItem('Power Positive', data.kwhpos),
          _buildTextItem('Power Positive Daily', data.kwhposdaily),
          _buildTextItem('Power Negative', data.kwhneg),
          _buildTextItem('Power Negative Daily', data.kwhnegdaily),
        ]),
      ],
    );
  }

  Widget _buildEMSView(EMSModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('EMS Information'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,        // 2 คอลัมน์
          shrinkWrap: true,         // ขยายตามเนื้อหา
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,      // ปรับสัดส่วนให้บรรทัดไม่สูงเกินไป (ยิ่งเลขเยอะ บรรทัดยิ่งเตี้ย)
          crossAxisSpacing: 20,     // ระยะห่างแนวนอน
          mainAxisSpacing: 5,       // ระยะห่างแนวตั้ง
          children: [
            _buildTextItem('Total Unit Consumption', data.kwhloadtotal),
            _buildTextItem('Daily Unit Consumption', data.kwhloaddaily),
            _buildTextItem('Power Consumption', data.pload),
            _buildTextItem('CO₂e Emissions', data.co2e),
            _buildTextItem('Lifetime Renewable Ratio', data.renewratiolifetime),
            _buildTextItem('Renewable Ratio', data.renewratio),
          ],
        ),

      ],
    );
  }

  Widget _buildBatteryView(BatteryModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Battery'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            _buildTextItem('Battery Status', data.status),
            _buildTextItem('Battery Power', data.kw),
            _buildTextItem('Battery Voltage', data.voltage),
            _buildTextItem('Battery Current', data.current),
            _buildTextItem('Total Charging Energy', data.totalCharge),
            _buildTextItem('Total Discharging Energy', data.totalDischarge),
            _buildTextItem('Daily Charging', data.dailyCharge),
            _buildTextItem('Daily Discharging', data.dailyDischarge),
            _buildTextItem('Battery Rated Capacity', '874Ah'),
            _buildTextItem('SoC', data.soc),
            _buildTextItem('SOH', data.soh),
            _buildTextItem('Temperature', data.temperature),
            _buildTextItem('Invert Power', data.powerInvert),
            _buildTextItem('Setpoint', data.manualSetpoint),
            _buildTextItem('PID Cycle', data.pidCycleTime),
            _buildTextItem('PID Gain', data.pidGain),
          ],
        ),
      ],
    );
  }

  Widget _buildSolarLoggerView(SolarLoggerModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Solar Logger'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            _buildTextItem('Total Unit PV', data.kwhtotal),
            _buildTextItem('Daily Unit PV', data.kwhdaily),
            _buildTextItem('Power PV', data.p),
            _buildTextItem('Reactive Power PV', data.q),
            _buildTextItem('DC Current', data.idc),
            _buildTextItem('Power Factor', data.pf),
            _buildTextItem('Line Voltage 1-2', data.v12),
            _buildTextItem('Phase Current 1', data.i1),
            _buildTextItem('Line Voltage 2-3', data.v23),
            _buildTextItem('Phase Current 2', data.i2),
            _buildTextItem('Line Voltage 3-1', data.v31),
            _buildTextItem('Phase Current 3', data.i3),
          ],
        ),
      ],
    );
  }

  Widget _buildSolarMeterView(SolarMeterModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Solar Meter'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            _buildTextItem('Total Unit PV', data.kwhtotal),
            _buildTextItem('Power PV', data.p),
            _buildTextItem('Positive Unit PV', data.kwhpos),
            _buildTextItem('Reactive Power PV', data.q),
            _buildTextItem('Negative Unit PV', data.kwhneg),
            _buildTextItem('Apparent Power PV', data.s),
            _buildTextItem('Power Factor', data.pf),
            _buildTextItem('Phase Current 1', data.i1),
            _buildTextItem('Phase Current 2', data.i2),
            _buildTextItem('Phase Current 3', data.i3),
            _buildTextItem('Line Voltage 1-2', data.v12),
            _buildTextItem('Voltage Phase 1', data.v1),
            _buildTextItem('Line Voltage 2-3', data.v23),
            _buildTextItem('Voltage Phase 2', data.v2),
            _buildTextItem('Line Voltage 3-1', data.v31),
            _buildTextItem('Voltage Phase 3', data.v3),
          ],
        ),
      ],
    );
  }

  Widget _buildSolarEMIView(SolarEMIModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Solar EMI'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            _buildTextItem('Ambient Temperature', data.tempambient),
            _buildTextItem('Temperature PV', data.temppv),
            _buildTextItem('Irradiance Total', data.irradiancetotal),
            _buildTextItem('Irradiance Daily', data.irradiancedaily),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$label: ",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}