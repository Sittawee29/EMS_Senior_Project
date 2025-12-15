import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart'; // ใช้ Browser Client สำหรับ Web

// Model ข้อมูล
class DashboardData {
  //EMS
  double PV_Total_Energy;
  double PV_Daily_Energy;
  double Load_Daily_Energy;
  double Load_Total_Energy;
  double GRID_Total_Import_Energy;
  double GRID_Daily_Import_Energy;
  double GRID_Total_Export_Energy;
  double GRID_Daily_Export_Energy;
  double BESS_Daily_Charge_Energy;
  double BESS_Daily_Discharge_Energy;
  double EMS_CO2_Equivalent;
  double EMS_EnergyProducedFromPV_Daily;
  double EMS_EnergyFeedToGrid_Daily;
  double EMS_EnergyConsumption_Daily;
  double EMS_EnergyFeedFromGrid_Daily;
  double EMS_SolarPower_kW;
  double EMS_LoadPower_kW;
  //BESS
  double BESS_SOC;
  double BESS_SOH;
  double BESS_V;
  double BESS_I;
  double BESS_KW;
  double BESS_Temperature;
  double BESS_Total_Discharge;
  double BESS_Total_Charge;
  double BESS_SOC_MAX;
  double BESS_SOC_MIN;
  double BESS_Power_KW_Invert;
  double BESS_Manual_Power_Setpoint;
  double BESS_PID_CycleTime;
  double BESS_PID_Td;
  double BESS_PID_Ti;
  double BESS_PID_Gain;
  //METER
  double METER_Export_KVARH;
  double METER_Export_KWH;
  double METER_Import_KVARH;
  double METER_Import_KWH;
  double METER_Total_KVARH;
  double METER_Total_KWH;
  double METER_Hz;
  double METER_PF;
  double METER_V1;
  double METER_V2;
  double METER_V3;
  double METER_I1;
  double METER_I2;
  double METER_I3;
  double METER_I_Total;
  double METER_KW;
  double METER_KVAR;
  double METER_KW_Invert;
  double METER_Grid_Power_KW;
  //PV1
  double PV1_Grid_Power_KW;
  double PV1_Load_Power_KW;
  double PV1_Daily_Energy_Power_KWh;
  double PV1_Total_Energy_Power_KWh;
  double PV1_Power_Factor;
  double PV1_Reactive_Power_KVar;
  double PV1_Active_Power_KW;
  //PV2
  double PV2_Energy_Daily_kW;
  double PV2_LifeTimeEnergyProduction_kWh_Start;
  double PV2_LifeTimeEnergyProduction_kWh;
  double PV2_ReactivePower_kW;
  double PV2_ApparentPower_kW;
  double PV2_Active_Power_kW;
  double PV2_LifeTimeEnergyProduction;
  double PV2_PowerFactor_Percen;
  double PV2_ReactivePower;
  double PV2_ApparentPower;
  double PV2_Power;
  //PV3
  double PV3_Total_Power_Yields_Real;
  double PV3_Total_Apparent_Power_kW;
  double PV3_Total_Reactive_Power_kW;
  double PV3_Active_Power_kW;
  double PV3_Total_Reactive_Power;
  double PV3_Total_Active_Power;
  double PV3_Total_Apparent_Power;
  double PV3_Total_Power_Yields;
  double PV3_Daily_Power_Yields;
  double PV3_Nominal_Active_Power;
  //PV4
  double PV4_Total_Power_Yields_Real;
  double PV4_Total_Apparent_Power_kW;
  double PV4_Total_Reactive_Power_kW;
  double PV4_Active_Power_kW;
  double PV4_Total_Reactive_Power;
  double PV4_Total_Active_Power;
  double PV4_Total_Apparent_Power;
  double PV4_Total_Power_Yields;
  double PV4_Daily_Power_Yields;
  double PV4_Nominal_Active_Power;

  DashboardData({
    //EMS
    this.PV_Total_Energy = 0.0,
    this.PV_Daily_Energy = 0.0,
    this.Load_Total_Energy = 0.0,
    this.Load_Daily_Energy = 0.0,
    this.GRID_Total_Import_Energy = 0.0,
    this.GRID_Daily_Import_Energy = 0.0,
    this.GRID_Total_Export_Energy = 0.0,
    this.GRID_Daily_Export_Energy = 0.0,
    this.BESS_Daily_Charge_Energy = 0.0,
    this.BESS_Daily_Discharge_Energy = 0.0,
    this.EMS_CO2_Equivalent = 0.0,
    this.EMS_EnergyProducedFromPV_Daily = 0.0,
    this.EMS_EnergyFeedToGrid_Daily = 0.0,
    this.EMS_EnergyConsumption_Daily = 0.0,
    this.EMS_EnergyFeedFromGrid_Daily = 0.0,
    this.EMS_SolarPower_kW = 0.0,
    this.EMS_LoadPower_kW = 0.0,
    //BESS
    this.BESS_SOC = 0.0,
    this.BESS_SOH = 0.0,
    this.BESS_V = 0.0,
    this.BESS_I = 0.0,
    this.BESS_KW = 0.0,
    this.BESS_Temperature = 0.0,
    this.BESS_Total_Discharge = 0.0,
    this.BESS_Total_Charge = 0.0,
    this.BESS_SOC_MAX = 0.0,
    this.BESS_SOC_MIN = 0.0,
    this.BESS_Power_KW_Invert = 0.0,
    this.BESS_Manual_Power_Setpoint = 0.0,
    this.BESS_PID_CycleTime = 0.0,
    this.BESS_PID_Td = 0.0,
    this.BESS_PID_Ti = 0.0,
    this.BESS_PID_Gain = 0.0,
    //METER
    this.METER_Export_KVARH = 0.0,
    this.METER_Export_KWH = 0.0,
    this.METER_Import_KVARH = 0.0,
    this.METER_Import_KWH = 0.0,
    this.METER_Total_KVARH = 0.0,
    this.METER_Total_KWH = 0.0,
    this.METER_Hz = 0.0,
    this.METER_PF = 0.0,
    this.METER_V1 = 0.0,
    this.METER_V2 = 0.0,
    this.METER_V3 = 0.0,
    this.METER_I1 = 0.0,
    this.METER_I2 = 0.0,
    this.METER_I3 = 0.0,
    this.METER_I_Total = 0.0,
    this.METER_KW = 0.0,
    this.METER_KVAR = 0.0,
    this.METER_KW_Invert = 0.0,
    this.METER_Grid_Power_KW = 0.0,
    //PV1
    this.PV1_Grid_Power_KW = 0.0,
    this.PV1_Load_Power_KW = 0.0,
    this.PV1_Daily_Energy_Power_KWh = 0.0,
    this.PV1_Total_Energy_Power_KWh = 0.0,
    this.PV1_Power_Factor = 0.0,
    this.PV1_Reactive_Power_KVar = 0.0,
    this.PV1_Active_Power_KW = 0.0,
    //PV2
    this.PV2_Energy_Daily_kW = 0.0,
    this.PV2_LifeTimeEnergyProduction_kWh_Start = 0.0,
    this.PV2_LifeTimeEnergyProduction_kWh = 0.0,
    this.PV2_ReactivePower_kW = 0.0,
    this.PV2_ApparentPower_kW = 0.0,
    this.PV2_Active_Power_kW = 0.0,
    this.PV2_LifeTimeEnergyProduction = 0.0,
    this.PV2_PowerFactor_Percen = 0.0,
    this.PV2_ReactivePower = 0.0,
    this.PV2_ApparentPower = 0.0,
    this.PV2_Power = 0.0,
    //PV3
    this.PV3_Total_Power_Yields_Real = 0.0,
    this.PV3_Total_Apparent_Power_kW = 0.0,
    this.PV3_Total_Reactive_Power_kW = 0.0,
    this.PV3_Active_Power_kW = 0.0,
    this.PV3_Total_Reactive_Power = 0.0,
    this.PV3_Total_Active_Power = 0.0,
    this.PV3_Total_Apparent_Power = 0.0,
    this.PV3_Total_Power_Yields = 0.0,
    this.PV3_Daily_Power_Yields = 0.0,
    this.PV3_Nominal_Active_Power = 0.0,
    //PV4
    this.PV4_Total_Power_Yields_Real = 0.0,
    this.PV4_Total_Apparent_Power_kW = 0.0,
    this.PV4_Total_Reactive_Power_kW = 0.0,
    this.PV4_Active_Power_kW = 0.0,
    this.PV4_Total_Reactive_Power = 0.0,
    this.PV4_Total_Active_Power = 0.0,
    this.PV4_Total_Apparent_Power = 0.0,
    this.PV4_Total_Power_Yields = 0.0,
    this.PV4_Daily_Power_Yields = 0.0,
    this.PV4_Nominal_Active_Power = 0.0,
  });
}

class MqttService {
  // Singleton Pattern
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttBrowserClient client;
  
  // Stream สำหรับส่งข้อมูลไปหน้า UI
  final _dataController = StreamController<DashboardData>.broadcast();
  Stream<DashboardData> get dataStream => _dataController.stream;

  // ตัวแปรเก็บค่าปัจจุบัน
  DashboardData currentData = DashboardData();

  Future<void> connect() async {
    String clientIdentifier = 'flutter_web_' + DateTime.now().millisecondsSinceEpoch.toString();

    client = MqttBrowserClient('ws://127.0.0.1', clientIdentifier);
    client.port = 8083;
    
    // -----------------------------------------------------------
    // [จุดที่ต้องเพิ่ม] สั่งปิดการระบุ Protocol เพื่อให้คุยกับ Websockify รู้เรื่อง
    client.websocketProtocols = []; 
    // -----------------------------------------------------------

    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    
    client.connectionMessage = connMess;

    try {
      print('Connecting via Local Proxy (No Protocol Header)...');
      await client.connect("mqtt_user", "ADMINktt5120@"); 
    } catch (e) {
      print('Exception during connection: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    print('MQTT Connected via WebSocket!');
    _subscribeToTopics();

    // ดักจับข้อมูลที่ส่งเข้ามา
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String topic = c[0].topic;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // เรียกฟังก์ชันอัปเดตข้อมูล
      _updateData(topic, payload);
    });
  }

  void onDisconnected() {
    print('MQTT Disconnected');
  }

  void _subscribeToTopics() {
    print('Subscribing to topics...');
    //EMS
    client.subscribe("EMS/PV_Total_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/PV_Daily_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/Load_Total_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/Load_Daily_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/GRID_Total_Import_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/GRID_Daily_Import_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/GRID_Total_Export_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/GRID_Daily_Export_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/BESS_Daily_Charge_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/BESS_Daily_Discharge_Energy", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_CO2_Equivalent", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_EnergyProducedFromPV_Daily", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_EnergyFeedToGrid_Daily", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_EnergyConsumption_Daily", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_EnergyFeedFromGrid_Daily", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_SolarPower_kW", MqttQos.atMostOnce);
    client.subscribe("EMS/EMS_LoadPower_kW", MqttQos.atMostOnce);
    //BESS
    client.subscribe("BESS/SOC", MqttQos.atMostOnce);
    client.subscribe("BESS/SOH", MqttQos.atMostOnce);
    client.subscribe("BESS/V", MqttQos.atMostOnce);
    client.subscribe("BESS/I", MqttQos.atMostOnce);
    client.subscribe("BESS/KW", MqttQos.atMostOnce);
    client.subscribe("BESS/Temperature", MqttQos.atMostOnce);
    client.subscribe("BESS/Total_Discharge", MqttQos.atMostOnce);
    client.subscribe("BESS/Total_Charge", MqttQos.atMostOnce);
    client.subscribe("BESS/SOC_MAX", MqttQos.atMostOnce);
    client.subscribe("BESS/SOC_MIN", MqttQos.atMostOnce);
    client.subscribe("BESS/Power_KW_Invert", MqttQos.atMostOnce);
    client.subscribe("BESS/Manual_Power_Setpoint", MqttQos.atMostOnce);
    client.subscribe("BESS/PID_CycleTime", MqttQos.atMostOnce);
    client.subscribe("BESS/PID_Td", MqttQos.atMostOnce);
    client.subscribe("BESS/PID_Ti", MqttQos.atMostOnce);
    client.subscribe("BESS/PID_Gain", MqttQos.atMostOnce);
    //METER
    client.subscribe("METER/Export_KVARH", MqttQos.atMostOnce);
    client.subscribe("METER/Export_KWH", MqttQos.atMostOnce);
    client.subscribe("METER/Import_KVARH", MqttQos.atMostOnce);
    client.subscribe("METER/Import_KWH", MqttQos.atMostOnce);
    client.subscribe("METER/Total_KVARH", MqttQos.atMostOnce);
    client.subscribe("METER/Total_KWH", MqttQos.atMostOnce);
    client.subscribe("METER/Hz", MqttQos.atMostOnce);
    client.subscribe("METER/PF", MqttQos.atMostOnce);
    client.subscribe("METER/V1", MqttQos.atMostOnce);
    client.subscribe("METER/V2", MqttQos.atMostOnce);
    client.subscribe("METER/V3", MqttQos.atMostOnce);
    client.subscribe("METER/I1", MqttQos.atMostOnce);
    client.subscribe("METER/I2", MqttQos.atMostOnce);
    client.subscribe("METER/I3", MqttQos.atMostOnce);
    client.subscribe("METER/I_Total", MqttQos.atMostOnce);
    client.subscribe("METER/KW", MqttQos.atMostOnce);
    client.subscribe("METER/Grid_Power_KW", MqttQos.atMostOnce);
    client.subscribe("METER/KW_Invert", MqttQos.atMostOnce);
    //PV1
    client.subscribe("PV1/PV1_Grid_Power_KW", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Load_Power_KW", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Daily_Energy_Power_KWh", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Total_Energy_Power_KWh", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Power_Factor", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Reactive_Power_KVar", MqttQos.atMostOnce);
    client.subscribe("PV1/PV1_Active_Power_KW", MqttQos.atMostOnce);
    //PV2
    client.subscribe("PV2/PV2_Energy_Daily_kW", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_LifeTimeEnergyProduction_kWh_Start", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_LifeTimeEnergyProduction_kWh", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_ReactivePower_kW", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_ApparentPower_kW", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_LifeTimeEnergyProduction", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_PowerFactor_Percen", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_ReactivePower", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_ApparentPower", MqttQos.atMostOnce);
    client.subscribe("PV2/PV2_Power", MqttQos.atMostOnce);
    //PV3
    client.subscribe("PV3/PV3_Total_Power_Yields_Real", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Apparent_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Reactive_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Active_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Reactive_Power", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Active_Power", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Apparent_Power", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Total_Power_Yields", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Daily_Power_Yields", MqttQos.atMostOnce);
    client.subscribe("PV3/PV3_Nominal_Active_Power", MqttQos.atMostOnce);
    //PV4
    client.subscribe("PV4/PV4_Total_Power_Yields_Real", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Apparent_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Reactive_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Active_Power_kW", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Reactive_Power", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Active_Power", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Apparent_Power", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Total_Power_Yields", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Daily_Power_Yields", MqttQos.atMostOnce);
    client.subscribe("PV4/PV4_Nominal_Active_Power", MqttQos.atMostOnce);
  }

  void _updateData(String topic, String payload) {
    // print('DEBUG: Topic -> $topic, Payload -> $payload'); // เปิดบรรทัดนี้ถ้าอยากเห็นทุกค่าที่เข้ามา
    try {
      double value = double.tryParse(payload) ?? 0.0;
      
      switch (topic) {
      //EMS
        case "EMS/PV_Total_Energy":
          currentData.PV_Total_Energy = value;
          break;
        case "EMS/PV_Daily_Energy":
          currentData.PV_Daily_Energy = value;
          break;
        case "EMS/Load_Total_Energy":
          currentData.Load_Total_Energy = value;
          break;
        case "EMS/Load_Daily_Energy":
          currentData.Load_Daily_Energy = value;
          break;
        case "EMS/GRID_Total_Import_Energy":
          currentData.GRID_Total_Import_Energy = value;
          break;
        case "EMS/GRID_Daily_Import_Energy":
          currentData.GRID_Daily_Import_Energy = value;
          break;
        case "EMS/GRID_Total_Export_Energy":
          currentData.GRID_Total_Export_Energy = value;
          break;
        case "EMS/GRID_Daily_Export_Energy":
          currentData.GRID_Daily_Export_Energy = value;
          break;
        case "EMS/BESS_Daily_Charge_Energy":
          currentData.BESS_Daily_Charge_Energy = value;
          break;
        case "EMS/BESS_Daily_Discharge_Energy":
          currentData.BESS_Daily_Discharge_Energy = value;
          break;
        case "EMS/EMS_CO2_Equivalent":
          currentData.EMS_CO2_Equivalent = value;
          break;
        case "EMS/EMS_EnergyProducedFromPV_Daily":
          currentData.EMS_EnergyProducedFromPV_Daily = value;
          break;
        case "EMS/EMS_EnergyFeedToGrid_Daily":
          currentData.EMS_EnergyFeedToGrid_Daily = value;
          break;
        case "EMS/EMS_EnergyConsumption_Daily":
          currentData.EMS_EnergyConsumption_Daily = value;
          break;
        case "EMS/EMS_EnergyFeedFromGrid_Daily":
          currentData.EMS_EnergyFeedFromGrid_Daily = value;
          break;
        case "EMS/EMS_SolarPower_kW":
          currentData.EMS_SolarPower_kW = value;
          break;
        case "EMS/EMS_LoadPower_kW":
          currentData.EMS_LoadPower_kW = value;
          break;
      //BESS
        case "BESS/SOC":
          currentData.BESS_SOC = value;
          break;
        case "BESS/SOH":
          currentData.BESS_SOH = value;
          break;
        case "BESS/V":
          currentData.BESS_V = value;
          break;
        case "BESS/I":
          currentData.BESS_I = value;
          break;
        case "BESS/KW":
          currentData.BESS_KW = value;
          break;
        case "BESS/Temperature":
          currentData.BESS_Temperature = value;
          break;
        case "BESS/Total_Discharge":
          currentData.BESS_Total_Discharge = value;
          break;
        case "BESS/Total_Charge":
          currentData.BESS_Total_Charge = value;
          break;
        case "BESS/SOC_MAX":
          currentData.BESS_SOC_MAX = value;
          break;
        case "BESS/SOC_MIN":
          currentData.BESS_SOC_MIN = value;
          break;
        case "BESS/Power_KW_Invert":
          currentData.BESS_Power_KW_Invert = value;
          break;
        case "BESS/Manual_Power_Setpoint":
          currentData.BESS_Manual_Power_Setpoint = value;
          break;
        case "BESS/PID_CycleTime":
          currentData.BESS_PID_CycleTime = value;
          break;
        case "BESS/PID_Td":
          currentData.BESS_PID_Td = value;
          break;
        case "BESS/PID_Ti":
          currentData.BESS_PID_Ti = value;
          break;
        case "BESS/PID_Gain":
          currentData.BESS_PID_Gain = value;
          break;
      //METER
        case "METER/Export_KVARH":
          currentData.METER_Export_KVARH = value;
          break;
        case "METER/Export_KWH":
          currentData.METER_Export_KWH = value;
          break;
        case "METER/Import_KVARH":
          currentData.METER_Import_KVARH = value;
          break;
        case "METER/Import_KWH":
          currentData.METER_Import_KWH = value;
          break;
        case "METER/Total_KVARH":
          currentData.METER_Total_KVARH = value;
          break;
        case "METER/Total_KWH":
          currentData.METER_Total_KWH = value;
          break;
        case "METER/Hz":
          currentData.METER_Hz = value;
          break;
        case "METER/PF":
          currentData.METER_PF = value;
          break;
        case "METER/V1":
          currentData.METER_V1 = value;
          break;
        case "METER/V2":
          currentData.METER_V2 = value;
          break;
        case "METER/V3":
          currentData.METER_V3 = value;
          break;
        case "METER/I1":
          currentData.METER_I1 = value;
          break;
        case "METER/I2":
          currentData.METER_I2 = value;
          break;
        case "METER/I3":
          currentData.METER_I3 = value;
          break;
        case "METER/I_Total":
          currentData.METER_I_Total = value;
          break;
        case "METER/KW":
          currentData.METER_KW = value;
          break;
        case "METER/KVAR":
          currentData.METER_KVAR = value;
          break;
        case "METER/KW_Invert":
          currentData.METER_KW_Invert = value;
          break;
        case "METER/Grid_Power_KW":
          currentData.METER_Grid_Power_KW = value;
          break;
      //PV1
        case "PV1/PV1_Grid_Power_KW":
          currentData.PV1_Grid_Power_KW = value;
          break;
        case "PV1/PV1_Load_Power_KW":
          currentData.PV1_Load_Power_KW = value;
          break;
        case "PV1/PV1_Daily_Energy_Power_KWh":
          currentData.PV1_Daily_Energy_Power_KWh = value;
          break;
        case "PV1/PV1_Total_Energy_Power_KWh":
          currentData.PV1_Total_Energy_Power_KWh = value;
          break;
        case "PV1/PV1_Power_Factor":
          currentData.PV1_Power_Factor = value;
          break;
        case "PV1/PV1_Reactive_Power_KVar":
          currentData.PV1_Reactive_Power_KVar = value;
          break;
        case "PV1/PV1_Active_Power_KW":
          currentData.PV1_Active_Power_KW = value;
          break;
      //PV2
        case "PV2/PV2_Energy_Daily_kW":
          currentData.PV2_Energy_Daily_kW = value;
          break;
        case "PV2/PV2_LifeTimeEnergyProduction_kWh_Start":
          currentData.PV2_LifeTimeEnergyProduction_kWh_Start = value;
          break;
        case "PV2/PV2_LifeTimeEnergyProduction_kWh":
          currentData.PV2_LifeTimeEnergyProduction_kWh = value;
          break;
        case "PV2/PV2_ReactivePower_kW":
          currentData.PV2_ReactivePower_kW = value;
          break;
        case "PV2/PV2_ApparentPower_kW":
          currentData.PV2_ApparentPower_kW = value;
          break;
        case "PV2/PV2_Power_kW":
          currentData.PV2_Active_Power_kW = value;
          break;
        case "PV2/PV2_LifeTimeEnergyProduction":
          currentData.PV2_LifeTimeEnergyProduction = value;
          break;
        case "PV2/PV2_PowerFactor_Percen":
          currentData.PV2_PowerFactor_Percen = value;
          break;
        case "PV2/PV2_ReactivePower":
          currentData.PV2_ReactivePower = value;
          break;
        case "PV2/PV2_ApparentPower":
          currentData.PV2_ApparentPower = value;
          break;
        case "PV2/PV2_Power":
          currentData.PV2_Power = value;
          break;
      //PV3
        case "PV3/PV3_Total_Power_Yields_Real":
          currentData.PV3_Total_Power_Yields_Real = value;
          break;
        case "PV3/PV3_Total_Apparent_Power_kW":
          currentData.PV3_Total_Apparent_Power_kW = value;
          break;
        case "PV3/PV3_Total_Reactive_Power_kW":
          currentData.PV3_Total_Reactive_Power_kW = value;
          break;
        case "PV3/PV3_Total_Active_Power_kW":
          currentData.PV3_Active_Power_kW = value;
          break;
        case "PV3/PV3_Total_Reactive_Power":
          currentData.PV3_Total_Reactive_Power = value;
          break;
        case "PV3/PV3_Total_Active_Power":
          currentData.PV3_Total_Active_Power = value;
          break;
        case "PV3/PV3_Total_Apparent_Power":
          currentData.PV3_Total_Apparent_Power = value;
          break;
        case "PV3/PV3_Total_Power_Yields":
          currentData.PV3_Total_Power_Yields = value;
          break;
        case "PV3/PV3_Daily_Power_Yields":
          currentData.PV3_Daily_Power_Yields = value;
          break;
        case "PV3/PV3_Nominal_Active_Power":
          currentData.PV3_Nominal_Active_Power = value;
          break;
      //PV4
        case "PV4/PV4_Total_Power_Yields_Real":
          currentData.PV4_Total_Power_Yields_Real = value;
          break;
        case "PV4/PV4_Total_Apparent_Power_kW":
          currentData.PV4_Total_Apparent_Power_kW = value;
          break;
        case "PV4/PV4_Total_Reactive_Power_kW":
          currentData.PV4_Total_Reactive_Power_kW = value;
          break;
        case "PV4/PV4_Total_Active_Power_kW":
          currentData.PV4_Active_Power_kW = value;
          break;
        case "PV4/PV4_Total_Reactive_Power":
          currentData.PV4_Total_Reactive_Power = value;
          break;
        case "PV4/PV4_Total_Active_Power":
          currentData.PV4_Total_Active_Power = value;
          break;
        case "PV4/PV4_Total_Apparent_Power":
          currentData.PV4_Total_Apparent_Power = value;
          break;
        case "PV4/PV4_Total_Power_Yields":
          currentData.PV4_Total_Power_Yields = value;
          break;
        case "PV4/PV4_Daily_Power_Yields":
          currentData.PV4_Daily_Power_Yields = value;
          break;
        case "PV4/PV4_Nominal_Active_Power":
          currentData.PV4_Nominal_Active_Power = value;
          break;
      }
      // ส่งข้อมูลล่าสุดไปให้หน้าจอ UI
      _dataController.add(currentData);
      
    } catch (e) {
      print("Error parsing data: $e");
    }
  }
}