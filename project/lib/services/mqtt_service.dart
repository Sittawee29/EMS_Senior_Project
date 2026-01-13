import 'dart:async';
import 'dart:convert'; // สำหรับ jsonDecode
import 'package:http/http.dart' as http;

// --- Model ข้อมูล (คงเดิม) ---
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
  double BESS_Temp_Ambient;
  double BESS_Alarm;
  double BESS_Fault;
  double BESS_Communication_Fault;

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
  double PV1_Fault;
  double PV1_Communication_Fault;
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
  double PV2_Communication_Fault;
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
  double PV3_Communication_Fault;
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
  double PV4_Communication_Fault;

  DashboardData({
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
    this.BESS_Temp_Ambient = 0.0,
    this.BESS_Alarm = 0.0,
    this.BESS_Fault = 0.0,
    this.BESS_Communication_Fault = 0.0,
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
    this.PV1_Grid_Power_KW = 0.0,
    this.PV1_Load_Power_KW = 0.0,
    this.PV1_Daily_Energy_Power_KWh = 0.0,
    this.PV1_Total_Energy_Power_KWh = 0.0,
    this.PV1_Power_Factor = 0.0,
    this.PV1_Reactive_Power_KVar = 0.0,
    this.PV1_Active_Power_KW = 0.0,
    this.PV1_Fault = 0.0,
    this.PV1_Communication_Fault = 0.0,
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
    this.PV2_Communication_Fault = 0.0,
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
    this.PV3_Communication_Fault = 0.0,
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
    this.PV4_Communication_Fault = 0.0,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      PV_Total_Energy: (json['PV_Total_Energy'] ?? 0).toDouble(),
      PV_Daily_Energy: (json['PV_Daily_Energy'] ?? 0).toDouble(),
      Load_Total_Energy: (json['Load_Total_Energy'] ?? 0).toDouble(),
      Load_Daily_Energy: (json['Load_Daily_Energy'] ?? 0).toDouble(),
      GRID_Total_Import_Energy: (json['GRID_Total_Import_Energy'] ?? 0).toDouble(),
      GRID_Daily_Import_Energy: (json['GRID_Daily_Import_Energy'] ?? 0).toDouble(),
      GRID_Total_Export_Energy: (json['GRID_Total_Export_Energy'] ?? 0).toDouble(),
      GRID_Daily_Export_Energy: (json['GRID_Daily_Export_Energy'] ?? 0).toDouble(),
      BESS_Daily_Charge_Energy: (json['BESS_Daily_Charge_Energy'] ?? 0).toDouble(),
      BESS_Daily_Discharge_Energy: (json['BESS_Daily_Discharge_Energy'] ?? 0).toDouble(),
      EMS_CO2_Equivalent: (json['EMS_CO2_Equivalent'] ?? 0).toDouble(),
      EMS_EnergyProducedFromPV_Daily: (json['EMS_EnergyProducedFromPV_Daily'] ?? 0).toDouble(),
      EMS_EnergyFeedToGrid_Daily: (json['EMS_EnergyFeedToGrid_Daily'] ?? 0).toDouble(),
      EMS_EnergyConsumption_Daily: (json['EMS_EnergyConsumption_Daily'] ?? 0).toDouble(),
      EMS_EnergyFeedFromGrid_Daily: (json['EMS_EnergyFeedFromGrid_Daily'] ?? 0).toDouble(),
      EMS_SolarPower_kW: (json['EMS_SolarPower_kW'] ?? 0).toDouble(),
      EMS_LoadPower_kW: (json['EMS_LoadPower_kW'] ?? 0).toDouble(),
      BESS_SOC: (json['BESS_SOC'] ?? 0).toDouble(),
      BESS_SOH: (json['BESS_SOH'] ?? 0).toDouble(),
      BESS_V: (json['BESS_V'] ?? 0).toDouble(),
      BESS_I: (json['BESS_I'] ?? 0).toDouble(),
      BESS_KW: (json['BESS_KW'] ?? 0).toDouble(),
      BESS_Temperature: (json['BESS_Temperature'] ?? 0).toDouble(),
      BESS_Total_Discharge: (json['BESS_Total_Discharge'] ?? 0).toDouble(),
      BESS_Total_Charge: (json['BESS_Total_Charge'] ?? 0).toDouble(),
      BESS_SOC_MAX: (json['BESS_SOC_MAX'] ?? 0).toDouble(),
      BESS_SOC_MIN: (json['BESS_SOC_MIN'] ?? 0).toDouble(),
      BESS_Power_KW_Invert: (json['BESS_Power_KW_Invert'] ?? 0.0).toDouble(),
      BESS_Manual_Power_Setpoint: (json['BESS_Manual_Power_Setpoint'] ?? 0.0).toDouble(),
      BESS_PID_CycleTime: (json['BESS_PID_CycleTime'] ?? 0.0).toDouble(),
      BESS_PID_Td: (json['BESS_PID_Td'] ?? 0.0).toDouble(),
      BESS_PID_Ti: (json['BESS_PID_Ti'] ?? 0.0).toDouble(),
      BESS_PID_Gain: (json['BESS_PID_Gain'] ?? 0.0).toDouble(),
      BESS_Temp_Ambient: (json['BESS_Temp_Ambient'] ?? 0.0).toDouble(),
      BESS_Alarm: (json['BESS_Alarm'] ?? 0.0).toDouble(),
      BESS_Fault: (json['BESS_Fault'] ?? 0.0).toDouble(),
      BESS_Communication_Fault: (json['BESS_Communication_Fault'] ?? 0.0).toDouble(),
      METER_Export_KVARH: (json['METER_Export_KVARH'] ?? 0).toDouble(),
      METER_Export_KWH: (json['METER_Export_KWH'] ?? 0).toDouble(),
      METER_Import_KVARH: (json['METER_Import_KVARH'] ?? 0).toDouble(),
      METER_Import_KWH: (json['METER_Import_KWH'] ?? 0).toDouble(),
      METER_Total_KVARH: (json['METER_Total_KVARH'] ?? 0).toDouble(),
      METER_Total_KWH: (json['METER_Total_KWH'] ?? 0).toDouble(),
      METER_Hz: (json['METER_Hz'] ?? 0).toDouble(),
      METER_PF: (json['METER_PF'] ?? 0).toDouble(),
      METER_V1: (json['METER_V1'] ?? 0).toDouble(),
      METER_V2: (json['METER_V2'] ?? 0).toDouble(),
      METER_V3: (json['METER_V3'] ?? 0).toDouble(),
      METER_I1: (json['METER_I1'] ?? 0).toDouble(),
      METER_I2: (json['METER_I2'] ?? 0).toDouble(),
      METER_I3: (json['METER_I3'] ?? 0).toDouble(),
      METER_I_Total: (json['METER_I_Total'] ?? 0).toDouble(),
      METER_KW: (json['METER_KW'] ?? 0).toDouble(),
      METER_KVAR: (json['METER_KVAR'] ?? 0).toDouble(),
      METER_KW_Invert: (json['METER_KW_Invert'] ?? 0).toDouble(),
      METER_Grid_Power_KW: (json['METER_Grid_Power_KW'] ?? 0).toDouble(),
      PV1_Grid_Power_KW: (json['PV1_Grid_Power_KW'] ?? 0).toDouble(),
      PV1_Load_Power_KW: (json['PV1_Load_Power_KW'] ?? 0).toDouble(),
      PV1_Daily_Energy_Power_KWh: (json['PV1_Daily_Energy_Power_KWh'] ?? 0).toDouble(),
      PV1_Total_Energy_Power_KWh: (json['PV1_Total_Energy_Power_KWh'] ?? 0).toDouble(),
      PV1_Power_Factor: (json['PV1_Power_Factor'] ?? 0).toDouble(),
      PV1_Reactive_Power_KVar: (json['PV1_Reactive_Power_KVar'] ?? 0).toDouble(),
      PV1_Active_Power_KW: (json['PV1_Active_Power_KW'] ?? 0).toDouble(),
      PV1_Fault: (json['PV1_Fault'] ?? 0).toDouble(),
      PV1_Communication_Fault: (json['PV1_Communication_Fault'] ?? 0).toDouble(),
      PV2_Energy_Daily_kW: (json['PV2_Energy_Daily_kW'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction_kWh_Start: (json['PV2_LifeTimeEnergyProduction_kWh_Start'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction_kWh: (json['PV2_LifeTimeEnergyProduction_kWh'] ?? 0).toDouble(),
      PV2_ReactivePower_kW: (json['PV2_ReactivePower_kW'] ?? 0).toDouble(),
      PV2_ApparentPower_kW: (json['PV2_ApparentPower_kW'] ?? 0).toDouble(),
      PV2_Active_Power_kW: (json['PV2_Power_kW'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction: (json['PV2_LifeTimeEnergyProduction'] ?? 0).toDouble(),
      PV2_PowerFactor_Percen: (json['PV2_PowerFactor_Percen'] ?? 0).toDouble(),
      PV2_ReactivePower: (json['PV2_ReactivePower'] ?? 0).toDouble(),
      PV2_ApparentPower: (json['PV2_ApparentPower'] ?? 0).toDouble(),
      PV2_Power: (json['PV2_Power'] ?? 0).toDouble(),
      PV2_Communication_Fault: (json['PV2_Communication_Fault'] ?? 0).toDouble(),
      PV3_Total_Power_Yields_Real: (json['PV3_Total_Power_Yields_Real'] ?? 0).toDouble(),
      PV3_Total_Apparent_Power_kW: (json['PV3_Total_Apparent_Power_kW'] ?? 0).toDouble(),
      PV3_Total_Reactive_Power_kW: (json['PV3_Total_Reactive_Power_kW'] ?? 0).toDouble(),
      PV3_Active_Power_kW: (json['PV3_Total_Active_Power_kW'] ?? 0).toDouble(),
      PV3_Total_Reactive_Power: (json['PV3_Total_Reactive_Power'] ?? 0).toDouble(),
      PV3_Total_Active_Power: (json['PV3_Total_Active_Power'] ?? 0).toDouble(),
      PV3_Total_Apparent_Power: (json['PV3_Total_Apparent_Power'] ?? 0).toDouble(),
      PV3_Total_Power_Yields: (json['PV3_Total_Power_Yields'] ?? 0).toDouble(),
      PV3_Daily_Power_Yields: (json['PV3_Daily_Power_Yields'] ?? 0).toDouble(),
      PV3_Nominal_Active_Power: (json['PV3_Nominal_Active_Power'] ?? 0).toDouble(),
      PV3_Communication_Fault: (json['PV3_Communication_Fault'] ?? 0).toDouble(),
      PV4_Total_Power_Yields_Real: (json['PV4_Total_Power_Yields_Real'] ?? 0).toDouble(),
      PV4_Total_Apparent_Power_kW: (json['PV4_Total_Apparent_Power_kW'] ?? 0).toDouble(),
      PV4_Total_Reactive_Power_kW: (json['PV4_Total_Reactive_Power_kW'] ?? 0).toDouble(),
      PV4_Active_Power_kW: (json['PV4_Total_Active_Power_kW'] ?? 0).toDouble(),
      PV4_Total_Reactive_Power: (json['PV4_Total_Reactive_Power'] ?? 0).toDouble(),
      PV4_Total_Active_Power: (json['PV4_Total_Active_Power'] ?? 0).toDouble(),
      PV4_Total_Apparent_Power: (json['PV4_Total_Apparent_Power'] ?? 0).toDouble(),
      PV4_Total_Power_Yields: (json['PV4_Total_Power_Yields'] ?? 0).toDouble(),
      PV4_Daily_Power_Yields: (json['PV4_Daily_Power_Yields'] ?? 0).toDouble(),
      PV4_Nominal_Active_Power: (json['PV4_Nominal_Active_Power'] ?? 0).toDouble(),
      PV4_Communication_Fault: (json['PV4_Communication_Fault'] ?? 0).toDouble(),
    );
  }
}

// --- ส่วนของ Service (เปลี่ยนไส้ในเป็น HTTP API) ---
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // ตรวจสอบ IP ให้ถูกต้อง (ถ้าเทสบน Web ใช้ localhost ได้เลย ถ้า Python รันอยู่เครื่องเดียวกัน)
  final String _apiUrl = "http://localhost:8000/api/dashboard";
  // หรือถ้าคุณใช้ IP วงแลน: "http://172.20.2.158:8000/api/dashboard";

  final _dataController = StreamController<DashboardData>.broadcast();
  Stream<DashboardData> get dataStream => _dataController.stream;

  DashboardData currentData = DashboardData();
  Timer? _timer;

  // *** สำคัญ: ต้องใช้ชื่อ function ว่า connect เท่านั้น ***
  void connect() {
    print("MqttService: Connecting via API Mock...");
    
    // ดึงข้อมูลครั้งแรก
    _fetchData();
    
    // ตั้งเวลาดึงข้อมูลใหม่ทุก 2 วินาที (Polling)
    _timer?.cancel(); 
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchData();
    });
  }

  void disconnect() {
    _timer?.cancel();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // แปลง JSON เป็น Object ทีเดียวจบ ครบทุกตัวแปร
        currentData = DashboardData.fromJson(jsonResponse);

        // ส่งข้อมูลเข้า Stream
        _dataController.add(currentData);
        // print("API Updated");
      } else {
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching API: $e");
    }
  }
}