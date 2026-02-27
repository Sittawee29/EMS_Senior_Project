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
    // เชื่อมต่อกับ Stream ของ MqttService
    _mqttSubscription = MqttService().dataStream.listen((newData) {
      if (mounted) { // เช็คว่าหน้าจอยังเปิดอยู่ไหมก่อน setState
        setState(() {
          // รับค่าใหม่มาใส่ตัวแปร Data ในหน้านี้
          Data = newData; 
          
          // แล้วสั่งอัปเดตข้อมูลลง UI
          _updateDeviceData(); 
        });
      }
    });
  }

  void _updateDeviceData() {
    setState(() {
      if (currentDevice is InverterModel) {
        // ต้อง cast เป็น InverterModel ก่อนเพื่อดึงค่าเดิมบางตัวมาใช้
        InverterModel oldData = currentDevice as InverterModel;
        
        currentDevice = InverterModel(
          name: oldData.name,
          status: Data.METER_I_Total > 0 ? 'Active' : 'Offline',
          sn: oldData.sn,
          inverterType: oldData.inverterType,
          ratedPower: oldData.ratedPower,
          systemTime: DateTime.now().toString().split('.')[0], // เวลาปัจจุบัน

          // Map ข้อมูล Inverter จาก Data
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
          
          // ข้อมูล Version (ถ้าใน MQTT ไม่มี ก็ใช้ค่าเดิมไปก่อน)
          protocolVersion: oldData.protocolVersion,
          mainVersion: oldData.mainVersion,
          hmiVersion: oldData.hmiVersion,
          firmwareVersion: oldData.firmwareVersion,
        );
      }

      // 🔋 ส่วนของ Battery (ที่คุณทำไว้แล้ว)
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

      // ☀️ ส่วนของ Solar (เพิ่มใหม่)
      else if (currentDevice is SolarModel) {
        // เช็คชื่อเพื่อ map ข้อมูลให้ถูก Zone (PV1, PV2, PV3...)
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
            // --- Tab 1: Device Data ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildDeviceContent(currentDevice),
            ),

            // --- Tab 2: Architecture ---
            const Center(child: Text('Architecture View')),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceContent(DeviceModel device) {
    if (device is InverterModel) {
      return _buildInverterView(device);
    } else if (device is BatteryModel) {
      return _buildBatteryView(device);
    } else if (device is SolarModel) {
      return _buildSolarView(device);
    } else {
      return const Center(child: Text('Unknown Device Type'));
    }
  }

  // --- View Builders (เหมือนเดิม) ---

  Widget _buildInverterView(InverterModel data) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            _buildTextItem('SN', data.sn),
            _buildTextItem('Inverter Type', data.inverterType),
            _buildTextItem('Rated Power', data.ratedPower),
            _buildTextItem('System Time', data.systemTime),
          ]),

        const SizedBox(height: 16),
        const Divider(), // เส้นขีดคั่น
        const SizedBox(height: 16),

        _buildSectionHeader('Version Information'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,        // 2 คอลัมน์
          shrinkWrap: true,         // ขยายตามเนื้อหา
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 16,      // ปรับสัดส่วนให้บรรทัดไม่สูงเกินไป (ยิ่งเลขเยอะ บรรทัดยิ่งเตี้ย)
          crossAxisSpacing: 20,     // ระยะห่างแนวนอน
          mainAxisSpacing: 5,       // ระยะห่างแนวตั้ง
          children: [
          _buildTextItem('Protocol Version', data.protocolVersion),
          _buildTextItem('MAIN', data.mainVersion),
          _buildTextItem('HMI', data.hmiVersion),
          _buildTextItem('Arc Board Firmware', data.firmwareVersion), // Map ตามชื่อในรูป

        ]),

        const SizedBox(height: 16),
        const Divider(), // เส้นขีดคั่น
        const SizedBox(height: 16),

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
          _buildTextItem('Export', data.Export_KWH),
          _buildTextItem('Export', data.Export_KVARH),
          _buildTextItem('Import', data.Import_KWH),
          _buildTextItem('Import', data.Import_KVARH),
          _buildTextItem('Total', data.Total_KWH),
          _buildTextItem('Total', data.Total_KVARH),
          _buildTextItem('Frequency (Hz)', data.Hz),
          _buildTextItem('Power Factor (PF)', data.PF),
          _buildTextItem('Voltage V1', data.V1),
          _buildTextItem('Current I1', data.I1),
          _buildTextItem('Voltage V2', data.V2),
          _buildTextItem('Current I2', data.I2),
          _buildTextItem('Voltage V3', data.V3),
          _buildTextItem('Current I3', data.I3),
          _buildTextItem('Active Power (kW)', data.KW),
          _buildTextItem('Reactive Power (kVAR)', data.KVAR),
          _buildTextItem('Load Power (kW)', data.LoadPower_kW),
          _buildTextItem('Grid Power (kW)', data.GridPower_kW),
        ]),

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

  Widget _buildSolarView(SolarModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Solar Generation'),
        const SizedBox(height: 16),
        _buildTextItem('Power Output', data.currentPower),
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