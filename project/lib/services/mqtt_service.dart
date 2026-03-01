import 'dart:async';
import 'dart:convert'; // สำหรับ jsonDecode
import 'package:http/http.dart' as http;

// --- Model ข้อมูล (คงเดิม) ---
class DashboardDataUTI {
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
  double EMS_EnergyProducedFromPV_kWh;
  double EMS_EnergyFeedFromGrid_kWh;
  double EMS_EnergyConsumption_kWh;
  double EMS_EnergyFeedToGrid_Daily;
  double EMS_EnergyConsumption_Daily;
  double EMS_EnergyFeedFromGrid_Daily;
  double EMS_SolarPower_kW;
  double EMS_LoadPower_kW;
  double EMS_RenewRatioDaily;
  double EMS_RenewRatioLifetime;
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

  DashboardDataUTI({
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
    this.EMS_EnergyProducedFromPV_kWh = 0.0,
    this.EMS_EnergyFeedFromGrid_kWh = 0.0,
    this.EMS_EnergyConsumption_kWh = 0.0,
    this.EMS_EnergyFeedToGrid_Daily = 0.0,
    this.EMS_EnergyConsumption_Daily = 0.0,
    this.EMS_EnergyFeedFromGrid_Daily = 0.0,
    this.EMS_SolarPower_kW = 0.0,
    this.EMS_LoadPower_kW = 0.0,
    this.EMS_RenewRatioDaily = 0.0,
    this.EMS_RenewRatioLifetime = 0.0,
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

  factory DashboardDataUTI.fromJson(Map<String, dynamic> json) {
    return DashboardDataUTI(
      // --- EMS ---
      PV_Total_Energy: (json['EMS_EMS_PV_TOTAL_ENERGY'] ?? 0).toDouble(),
      PV_Daily_Energy: (json['EMS_EMS_PV_DAILY_ENERGY'] ?? 0).toDouble(),
      Load_Total_Energy: (json['EMS_EMS_LOAD_TOTAL_ENERGY'] ?? 0).toDouble(),
      Load_Daily_Energy: (json['EMS_EMS_LOAD_DAILY_ENERGY'] ?? 0).toDouble(),
      GRID_Total_Import_Energy: (json['EMS_EMS_GRID_TOTAL_IMPORT_ENERGY'] ?? 0).toDouble(),
      GRID_Daily_Import_Energy: (json['EMS_EMS_GRID_DAILY_IMPORT_ENERGY'] ?? 0).toDouble(),
      GRID_Total_Export_Energy: (json['EMS_EMS_GRID_TOTAL_EXPORT_ENERGY'] ?? 0).toDouble(),
      GRID_Daily_Export_Energy: (json['EMS_EMS_GRID_DAILY_EXPORT_ENERGY'] ?? 0).toDouble(),
      BESS_Daily_Charge_Energy: (json['EMS_EMS_BESS_DAILY_CHARGE_ENERGY'] ?? 0).toDouble(),
      BESS_Daily_Discharge_Energy: (json['EMS_EMS_BESS_DAILY_DISCHARGE_ENERGY'] ?? 0).toDouble(),
      EMS_CO2_Equivalent: (json['EMS_EMS_CO2_EQUIVALENT'] ?? 0).toDouble(),
      EMS_EnergyProducedFromPV_Daily: (json['EMS_EMS_ENERGYPRODUCEDFROMPV_DAILY'] ?? 0).toDouble(),
      EMS_EnergyProducedFromPV_kWh: (json['EMS_EMS_ENERGYPRODUCEDFROMPV_KWH'] ?? 0).toDouble(),
      EMS_EnergyFeedFromGrid_kWh: (json['EMS_EMS_ENERGYFEEDFROMGRID_KWH'] ?? 0).toDouble(),
      EMS_EnergyConsumption_kWh: (json['EMS_EMS_ENERGYCONSUMPTION_KWH'] ?? 0).toDouble(),
      EMS_EnergyFeedToGrid_Daily: (json['EMS_EMS_ENERGYFEEDTOGRID_DAILY'] ?? 0).toDouble(),
      EMS_EnergyConsumption_Daily: (json['EMS_EMS_ENERGYCONSUMPTION_DAILY'] ?? 0).toDouble(),
      EMS_EnergyFeedFromGrid_Daily: (json['EMS_EMS_ENERGYFEEDFROMGRID_DAILY'] ?? 0).toDouble(),
      EMS_SolarPower_kW: (json['EMS_EMS_SOLARPOWER_KW'] ?? 0).toDouble(),
      EMS_LoadPower_kW: (json['EMS_EMS_LOADPOWER_KW'] ?? 0).toDouble(),
      EMS_RenewRatioDaily: (json['EMS_EMS_RENEWRATIODAILY'] ?? 0).toDouble(),
      EMS_RenewRatioLifetime: (json['EMS_EMS_RENEWRATIOLIFETIME'] ?? 0).toDouble(),
      
      // --- BESS ---
      BESS_SOC: (json['BESS_SOC'] ?? 0).toDouble(),
      BESS_SOH: (json['BESS_SOH'] ?? 0).toDouble(),
      BESS_V: (json['BESS_V'] ?? 0).toDouble(),
      BESS_I: (json['BESS_I'] ?? 0).toDouble(),
      BESS_KW: (json['BESS_KW'] ?? 0).toDouble(),
      BESS_Temperature: (json['BESS_TEMPERATURE'] ?? 0).toDouble(),
      BESS_Total_Discharge: (json['BESS_TOTAL_DISCHARGE'] ?? 0).toDouble(),
      BESS_Total_Charge: (json['BESS_TOTAL_CHARGE'] ?? 0).toDouble(),
      BESS_SOC_MAX: (json['BESS_SOC_MAX'] ?? 0).toDouble(),
      BESS_SOC_MIN: (json['BESS_SOC_MIN'] ?? 0).toDouble(),
      BESS_Power_KW_Invert: (json['BESS_POWER_KW_INVERT'] ?? 0.0).toDouble(),
      BESS_Manual_Power_Setpoint: (json['BESS_MANUAL_POWER_SETPOINT'] ?? 0.0).toDouble(),
      BESS_PID_CycleTime: (json['BESS_PID_CYCLETIME'] ?? 0.0).toDouble(),
      BESS_PID_Td: (json['BESS_PID_TD'] ?? 0.0).toDouble(),
      BESS_PID_Ti: (json['BESS_PID_TI'] ?? 0.0).toDouble(),
      BESS_PID_Gain: (json['BESS_PID_GAIN'] ?? 0.0).toDouble(),
      BESS_Temp_Ambient: (json['BESS_BESS_TEMP_AMBIENT'] ?? 0.0).toDouble(),
      BESS_Alarm: (json['BESS_BESS_ALARM'] ?? 0.0).toDouble(),
      BESS_Fault: (json['BESS_BESS_FAULT'] ?? 0.0).toDouble(),
      BESS_Communication_Fault: (json['BESS_BESS_COMMUNICATION_FAULT'] ?? 0.0).toDouble(),
      
      // --- METER ---
      METER_Export_KVARH: (json['METER_EXPORT_KVARH'] ?? 0).toDouble(),
      METER_Export_KWH: (json['METER_EXPORT_KWH'] ?? 0).toDouble(),
      METER_Import_KVARH: (json['METER_IMPORT_KVARH'] ?? 0).toDouble(),
      METER_Import_KWH: (json['METER_IMPORT_KWH'] ?? 0).toDouble(),
      METER_Total_KVARH: (json['METER_TOTAL_KVARH'] ?? 0).toDouble(),
      METER_Total_KWH: (json['METER_TOTAL_KWH'] ?? 0).toDouble(),
      METER_Hz: (json['METER_HZ'] ?? 0).toDouble(),
      METER_PF: (json['METER_PF'] ?? 0).toDouble(),
      METER_V1: (json['METER_V1'] ?? 0).toDouble(),
      METER_V2: (json['METER_V2'] ?? 0).toDouble(),
      METER_V3: (json['METER_V3'] ?? 0).toDouble(),
      METER_I1: (json['METER_I1'] ?? 0).toDouble(),
      METER_I2: (json['METER_I2'] ?? 0).toDouble(),
      METER_I3: (json['METER_I3'] ?? 0).toDouble(),
      METER_I_Total: (json['METER_I_TOTAL'] ?? 0).toDouble(),
      METER_KW: (json['METER_KW'] ?? 0).toDouble(),
      METER_KVAR: (json['METER_KVAR'] ?? 0).toDouble(),
      METER_KW_Invert: (json['METER_KW_INVERT'] ?? 0).toDouble(),
      METER_Grid_Power_KW: (json['METER_GRID_POWER_KW'] ?? 0).toDouble(),
      
      // --- PV1 ---
      PV1_Grid_Power_KW: (json['PV1_PV1_GRID_POWER_KW'] ?? 0).toDouble(),
      PV1_Load_Power_KW: (json['PV1_PV1_LOAD_POWER_KW'] ?? 0).toDouble(),
      PV1_Daily_Energy_Power_KWh: (json['PV1_PV1_DAILY_ENERGY_POWER_KWH'] ?? 0).toDouble(),
      PV1_Total_Energy_Power_KWh: (json['PV1_PV1_TOTAL_ENERGY_POWER_KWH'] ?? 0).toDouble(),
      PV1_Power_Factor: (json['PV1_PV1_POWER_FACTOR'] ?? 0).toDouble(),
      PV1_Reactive_Power_KVar: (json['PV1_PV1_REACTIVE_POWER_KVAR'] ?? 0).toDouble(),
      PV1_Active_Power_KW: (json['PV1_PV1_ACTIVE_POWER_KW'] ?? 0).toDouble(),
      PV1_Fault: (json['PV1_PV1_FAULT'] ?? 0).toDouble(),
      PV1_Communication_Fault: (json['PV1_PV1_COMMUNICATION_FAULT'] ?? 0).toDouble(),
      
      // --- PV2 ---
      PV2_Energy_Daily_kW: (json['PV2_PV2_ENERGY_DAILY_KW'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction_kWh_Start: (json['PV2_PV2_LIFETIMEENERGYPRODUCTION_KWH_START'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction_kWh: (json['PV2_PV2_LIFETIMEENERGYPRODUCTION_KWH'] ?? 0).toDouble(),
      PV2_ReactivePower_kW: (json['PV2_PV2_REACTIVEPOWER_KW'] ?? 0).toDouble(),
      PV2_ApparentPower_kW: (json['PV2_PV2_APPARENTPOWER_KW'] ?? 0).toDouble(),
      PV2_Active_Power_kW: (json['PV2_PV2_POWER_KW'] ?? 0).toDouble(),
      PV2_LifeTimeEnergyProduction: (json['PV2_PV2_LIFETIMEENERGYPRODUCTION'] ?? 0).toDouble(),
      PV2_PowerFactor_Percen: (json['PV2_PV2_POWERFACTOR_PERCEN'] ?? 0).toDouble(),
      PV2_ReactivePower: (json['PV2_PV2_REACTIVEPOWER'] ?? 0).toDouble(),
      PV2_ApparentPower: (json['PV2_PV2_APPARENTPOWER'] ?? 0).toDouble(),
      PV2_Power: (json['PV2_PV2_POWER'] ?? 0).toDouble(),
      PV2_Communication_Fault: (json['PV2_PV2_COMMUNICATION_FAULT'] ?? 0).toDouble(),
      
      // --- PV3 ---
      PV3_Total_Power_Yields_Real: (json['PV3_PV3_TOTAL_POWER_YIELDS_REAL'] ?? 0).toDouble(),
      PV3_Total_Apparent_Power_kW: (json['PV3_PV3_TOTAL_APPARENT_POWER_KW'] ?? 0).toDouble(),
      PV3_Total_Reactive_Power_kW: (json['PV3_PV3_TOTAL_REACTIVE_POWER_KW'] ?? 0).toDouble(),
      PV3_Active_Power_kW: (json['PV3_PV3_TOTAL_ACTIVE_POWER_KW'] ?? 0).toDouble(),
      PV3_Total_Reactive_Power: (json['PV3_PV3_TOTAL_REACTIVE_POWER'] ?? 0).toDouble(),
      PV3_Total_Active_Power: (json['PV3_PV3_TOTAL_ACTIVE_POWER'] ?? 0).toDouble(),
      PV3_Total_Apparent_Power: (json['PV3_PV3_TOTAL_APPARENT_POWER'] ?? 0).toDouble(),
      PV3_Total_Power_Yields: (json['PV3_PV3_TOTAL_POWER_YIELDS'] ?? 0).toDouble(),
      PV3_Daily_Power_Yields: (json['PV3_PV3_DAILY_POWER_YIELDS'] ?? 0).toDouble(),
      PV3_Nominal_Active_Power: (json['PV3_PV3_NOMINAL_ACTIVE_POWER'] ?? 0).toDouble(),
      PV3_Communication_Fault: (json['PV3_PV3_COMMUNICATION_FAULT'] ?? 0).toDouble(),
      
      // --- PV4 ---
      PV4_Total_Power_Yields_Real: (json['PV4_PV4_TOTAL_POWER_YIELDS_REAL'] ?? 0).toDouble(),
      PV4_Total_Apparent_Power_kW: (json['PV4_PV4_TOTAL_APPARENT_POWER_KW'] ?? 0).toDouble(),
      PV4_Total_Reactive_Power_kW: (json['PV4_PV4_TOTAL_REACTIVE_POWER_KW'] ?? 0).toDouble(),
      PV4_Active_Power_kW: (json['PV4_PV4_TOTAL_ACTIVE_POWER_KW'] ?? 0).toDouble(),
      PV4_Total_Reactive_Power: (json['PV4_PV4_TOTAL_REACTIVE_POWER'] ?? 0).toDouble(),
      PV4_Total_Active_Power: (json['PV4_PV4_TOTAL_ACTIVE_POWER'] ?? 0).toDouble(),
      PV4_Total_Apparent_Power: (json['PV4_PV4_TOTAL_APPARENT_POWER'] ?? 0).toDouble(),
      PV4_Total_Power_Yields: (json['PV4_PV4_TOTAL_POWER_YIELDS'] ?? 0).toDouble(),
      PV4_Daily_Power_Yields: (json['PV4_PV4_DAILY_POWER_YIELDS'] ?? 0).toDouble(),
      PV4_Nominal_Active_Power: (json['PV4_PV4_NOMINAL_ACTIVE_POWER'] ?? 0).toDouble(),
      PV4_Communication_Fault: (json['PV4_PV4_COMMUNICATION_FAULT'] ?? 0).toDouble(),
    );
  }
}

class DashboardDataTPI {
  // ==========================================
  // --- EMS (Energy Management System) ---
  // ==========================================
  double EMS_PLOAD;
  double EMS_KWHLOADTOTAL;
  double EMS_KWHLOADDAILY;
  double EMS_CO2E;
  double EMS_RENEWRATIO;
  double EMS_RENEWRATIOLIFETIME;

  // ==========================================
  // --- METER (Main Power Meter) ---
  // ==========================================
  double METER_P; double METER_Q; double METER_S; double METER_PF;
  double METER_KWHTOTAL; double METER_KWHPOS; double METER_KWHNEG;
  double METER_KWHTOTALDAILY; double METER_KWHPOSDAILY; double METER_KWHNEGDAILY;
  double METER_V1; double METER_V2; double METER_V3;
  double METER_V12; double METER_V23; double METER_V31;
  double METER_I1; double METER_I2; double METER_I3;

  // ==========================================
  // --- SOLAR (Inverters & EMI) ---
  // ==========================================
  double SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL;
  double SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY;
  double SOLAR_SOLAR1_EMI1_TEMPAMBIENT;
  double SOLAR_SOLAR1_EMI1_TEMPPV;
  
  double SOLAR_SOLAR1_LOGGER1_P; double SOLAR_SOLAR1_LOGGER1_Q; double SOLAR_SOLAR1_LOGGER1_PF;
  double SOLAR_SOLAR1_LOGGER1_KWHTOTAL; double SOLAR_SOLAR1_LOGGER1_KWHDAILY; double SOLAR_SOLAR1_LOGGER1_IDC;
  double SOLAR_SOLAR1_LOGGER1_V12; double SOLAR_SOLAR1_LOGGER1_V23; double SOLAR_SOLAR1_LOGGER1_V31;
  double SOLAR_SOLAR1_LOGGER1_I1; double SOLAR_SOLAR1_LOGGER1_I2; double SOLAR_SOLAR1_LOGGER1_I3;

  double SOLAR_SOLAR1_METER2_P; double SOLAR_SOLAR1_METER2_Q; double SOLAR_SOLAR1_METER2_S; double SOLAR_SOLAR1_METER2_PF;
  double SOLAR_SOLAR1_METER2_KWHTOTAL; double SOLAR_SOLAR1_METER2_KWHPOS; double SOLAR_SOLAR1_METER2_KWHNEG;
  double SOLAR_SOLAR1_METER2_V1; double SOLAR_SOLAR1_METER2_V2; double SOLAR_SOLAR1_METER2_V3;
  double SOLAR_SOLAR1_METER2_V12; double SOLAR_SOLAR1_METER2_V23; double SOLAR_SOLAR1_METER2_V31;
  double SOLAR_SOLAR1_METER2_I1; double SOLAR_SOLAR1_METER2_I2; double SOLAR_SOLAR1_METER2_I3;

  double SOLAR_SOLAR1_METER3_P; double SOLAR_SOLAR1_METER3_Q; double SOLAR_SOLAR1_METER3_S; double SOLAR_SOLAR1_METER3_PF;
  double SOLAR_SOLAR1_METER3_KWHTOTAL; double SOLAR_SOLAR1_METER3_KWHPOS; double SOLAR_SOLAR1_METER3_KWHNEG;
  double SOLAR_SOLAR1_METER3_V1; double SOLAR_SOLAR1_METER3_V2; double SOLAR_SOLAR1_METER3_V3;
  double SOLAR_SOLAR1_METER3_V12; double SOLAR_SOLAR1_METER3_V23; double SOLAR_SOLAR1_METER3_V31;
  double SOLAR_SOLAR1_METER3_I1; double SOLAR_SOLAR1_METER3_I2; double SOLAR_SOLAR1_METER3_I3;

  double BESS_SCU_P; double BESS_SCU_I; double BESS_SCU_SOC; double BESS_SCU_SOH; double BESS_SCU_PINVERT;
  double BESS_SCU_KWHCHARGETOTAL; double BESS_SCU_KWHDISCHARGETOTAL;
  double BESS_SCU_KWHCHARGEDAILY; double BESS_SCU_KWHDISCHARGEDAILY;

  List<Map<String, dynamic>> BESS_RACKS;

  double WEATHER_Temp; double WEATHER_TempMin; double WEATHER_TempMax;
  double WEATHER_Humidity; double WEATHER_WindSpeed; double WEATHER_Sunrise;
  double WEATHER_Sunset; double WEATHER_FeelsLike; double WEATHER_Pressure;
  String WEATHER_Icon;

  DashboardDataTPI({
    this.EMS_PLOAD = 0.0, this.EMS_KWHLOADTOTAL = 0.0, this.EMS_KWHLOADDAILY = 0.0,
    this.EMS_CO2E = 0.0, this.EMS_RENEWRATIO = 0.0, this.EMS_RENEWRATIOLIFETIME = 0.0,

    this.METER_P = 0.0, this.METER_Q = 0.0, this.METER_S = 0.0, this.METER_PF = 0.0,
    this.METER_KWHTOTAL = 0.0, this.METER_KWHPOS = 0.0, this.METER_KWHNEG = 0.0,
    this.METER_KWHTOTALDAILY = 0.0, this.METER_KWHPOSDAILY = 0.0, this.METER_KWHNEGDAILY = 0.0,
    this.METER_V1 = 0.0, this.METER_V2 = 0.0, this.METER_V3 = 0.0,
    this.METER_V12 = 0.0, this.METER_V23 = 0.0, this.METER_V31 = 0.0,
    this.METER_I1 = 0.0, this.METER_I2 = 0.0, this.METER_I3 = 0.0,

    this.SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL = 0.0, this.SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY = 0.0,
    this.SOLAR_SOLAR1_EMI1_TEMPAMBIENT = 0.0, this.SOLAR_SOLAR1_EMI1_TEMPPV = 0.0,
    this.SOLAR_SOLAR1_LOGGER1_P = 0.0, this.SOLAR_SOLAR1_LOGGER1_Q = 0.0, this.SOLAR_SOLAR1_LOGGER1_PF = 0.0,
    this.SOLAR_SOLAR1_LOGGER1_KWHTOTAL = 0.0, this.SOLAR_SOLAR1_LOGGER1_KWHDAILY = 0.0, this.SOLAR_SOLAR1_LOGGER1_IDC = 0.0,
    this.SOLAR_SOLAR1_LOGGER1_V12 = 0.0, this.SOLAR_SOLAR1_LOGGER1_V23 = 0.0, this.SOLAR_SOLAR1_LOGGER1_V31 = 0.0,
    this.SOLAR_SOLAR1_LOGGER1_I1 = 0.0, this.SOLAR_SOLAR1_LOGGER1_I2 = 0.0, this.SOLAR_SOLAR1_LOGGER1_I3 = 0.0,
    
    this.SOLAR_SOLAR1_METER2_P = 0.0, this.SOLAR_SOLAR1_METER2_Q = 0.0, this.SOLAR_SOLAR1_METER2_S = 0.0, this.SOLAR_SOLAR1_METER2_PF = 0.0,
    this.SOLAR_SOLAR1_METER2_KWHTOTAL = 0.0, this.SOLAR_SOLAR1_METER2_KWHPOS = 0.0, this.SOLAR_SOLAR1_METER2_KWHNEG = 0.0,
    this.SOLAR_SOLAR1_METER2_V1 = 0.0, this.SOLAR_SOLAR1_METER2_V2 = 0.0, this.SOLAR_SOLAR1_METER2_V3 = 0.0,
    this.SOLAR_SOLAR1_METER2_V12 = 0.0, this.SOLAR_SOLAR1_METER2_V23 = 0.0, this.SOLAR_SOLAR1_METER2_V31 = 0.0,
    this.SOLAR_SOLAR1_METER2_I1 = 0.0, this.SOLAR_SOLAR1_METER2_I2 = 0.0, this.SOLAR_SOLAR1_METER2_I3 = 0.0,

    this.SOLAR_SOLAR1_METER3_P = 0.0, this.SOLAR_SOLAR1_METER3_Q = 0.0, this.SOLAR_SOLAR1_METER3_S = 0.0, this.SOLAR_SOLAR1_METER3_PF = 0.0,
    this.SOLAR_SOLAR1_METER3_KWHTOTAL = 0.0, this.SOLAR_SOLAR1_METER3_KWHPOS = 0.0, this.SOLAR_SOLAR1_METER3_KWHNEG = 0.0,
    this.SOLAR_SOLAR1_METER3_V1 = 0.0, this.SOLAR_SOLAR1_METER3_V2 = 0.0, this.SOLAR_SOLAR1_METER3_V3 = 0.0,
    this.SOLAR_SOLAR1_METER3_V12 = 0.0, this.SOLAR_SOLAR1_METER3_V23 = 0.0, this.SOLAR_SOLAR1_METER3_V31 = 0.0,
    this.SOLAR_SOLAR1_METER3_I1 = 0.0, this.SOLAR_SOLAR1_METER3_I2 = 0.0, this.SOLAR_SOLAR1_METER3_I3 = 0.0,

    this.BESS_SCU_P = 0.0, this.BESS_SCU_I = 0.0, this.BESS_SCU_SOC = 0.0, this.BESS_SCU_SOH = 0.0, this.BESS_SCU_PINVERT = 0.0,
    this.BESS_SCU_KWHCHARGETOTAL = 0.0, this.BESS_SCU_KWHDISCHARGETOTAL = 0.0,
    this.BESS_SCU_KWHCHARGEDAILY = 0.0, this.BESS_SCU_KWHDISCHARGEDAILY = 0.0,

    this.BESS_RACKS = const [],

    this.WEATHER_Temp = 0.0, this.WEATHER_TempMin = 0.0, this.WEATHER_TempMax = 0.0,
    this.WEATHER_Humidity = 0.0, this.WEATHER_WindSpeed = 0.0, this.WEATHER_Sunrise = 0.0,
    this.WEATHER_Sunset = 0.0, this.WEATHER_FeelsLike = 0.0, this.WEATHER_Pressure = 0.0,
    this.WEATHER_Icon = "",
  });

  factory DashboardDataTPI.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseRacks(Map<String, dynamic> source) {
      List<Map<String, dynamic>> racksList = [];
      for (int i = 1; i <= 5; i++) {
        racksList.add({
          "KWHCHARGETOTAL": (source['BESS_RACK${i}_KWHCHARGETOTAL'] ?? 0).toDouble(),
          "KWHDISCHARGETOTAL": (source['BESS_RACK${i}_KWHDISCHARGETOTAL'] ?? 0).toDouble(),
          "KWHCHARGEDAILY": (source['BESS_RACK${i}_KWHCHARGEDAILY'] ?? 0).toDouble(),
          "KWHDISCHARGEDAILY": (source['BESS_RACK${i}_KWHDISCHARGEDAILY'] ?? 0).toDouble(),
          "TIMECHARGE": (source['BESS_RACK${i}_TIMECHARGE'] ?? 0).toDouble(),
          "TIMEDISCHARGE": (source['BESS_RACK${i}_TIMEDISCHARGE'] ?? 0).toDouble(),
          
          "V": (source['BESS_RACK${i}_V'] ?? 0).toDouble(),
          "I": (source['BESS_RACK${i}_I'] ?? 0).toDouble(),
          "P": (source['BESS_RACK${i}_P'] ?? 0).toDouble(),
          "SOC": (source['BESS_RACK${i}_SOC'] ?? 0).toDouble(),
          "SOH": (source['BESS_RACK${i}_SOH'] ?? 0).toDouble(),
          "CELLV": (source['BESS_RACK${i}_CELLV'] ?? 0).toDouble(),
          "CELLTEMP": (source['BESS_RACK${i}_CELLTEMP'] ?? 0).toDouble(),

          "STATE": source['BESS_RACK${i}_STATE']?.toString() ?? "",
          "PCSALARM": source['BESS_RACK${i}_PCSALARM']?.toString() ?? "",
          "PCSCOMMFAULT": (source['BESS_RACK${i}_PCSCOMMFAULT'] ?? 0).toDouble(),
          "PCSFAULT": (source['BESS_RACK${i}_PCSFAULT'] ?? 0).toDouble(),
          "PCSDERATING": (source['BESS_RACK${i}_PCSDERATING'] ?? 0).toDouble(),
          "PCSBOOTING": (source['BESS_RACK${i}_PCSBOOTING'] ?? 0).toDouble(),
          "PCSGRIDTIED": (source['BESS_RACK${i}_PCSGRIDTIED'] ?? 0).toDouble(),
          "PCSOFFGRID": (source['BESS_RACK${i}_PCSOFFGRID'] ?? 0).toDouble(),
          "PCSFAIL": (source['BESS_RACK${i}_PCSFAIL'] ?? 0).toDouble(),
          "PCSONOFF": (source['BESS_RACK${i}_PCSONOFF'] ?? 0).toDouble(),
          "PCSSTANDBY": (source['BESS_RACK${i}_PCSSTANDBY'] ?? 0).toDouble(),
          "PCSCHARGING": (source['BESS_RACK${i}_PCSCHARGING'] ?? 0).toDouble(),
          "PCSDISCHARGING": (source['BESS_RACK${i}_PCSDISCHARGING'] ?? 0).toDouble(),
          "PCSFULLYCHARGE": (source['BESS_RACK${i}_PCSFULLYCHARGE'] ?? 0).toDouble(),
          "PCSTOTALLYDISCHARGE": (source['BESS_RACK${i}_PCSTOTALLYDISCHARGE'] ?? 0).toDouble(),
        });
      }
      return racksList;
    }

    return DashboardDataTPI(
      EMS_PLOAD: (json['EMS_PLOAD'] ?? 0).toDouble(),
      EMS_KWHLOADTOTAL: (json['EMS_KWHLOADTOTAL'] ?? 0).toDouble(),
      EMS_KWHLOADDAILY: (json['EMS_KWHLOADDAILY'] ?? 0).toDouble(),
      EMS_CO2E: (json['EMS_CO2E'] ?? 0).toDouble(),
      EMS_RENEWRATIO: (json['EMS_RENEWRATIO'] ?? 0).toDouble(),
      EMS_RENEWRATIOLIFETIME: (json['EMS_RENEWRATIOLIFETIME'] ?? 0).toDouble(),

      METER_P: (json['METER_P'] ?? 0).toDouble(),
      METER_Q: (json['METER_Q'] ?? 0).toDouble(),
      METER_S: (json['METER_S'] ?? 0).toDouble(),
      METER_PF: (json['METER_PF'] ?? 0).toDouble(),
      METER_KWHTOTAL: (json['METER_KWHTOTAL'] ?? 0).toDouble(),
      METER_KWHPOS: (json['METER_KWHPOS'] ?? 0).toDouble(),
      METER_KWHNEG: (json['METER_KWHNEG'] ?? 0).toDouble(),
      METER_KWHTOTALDAILY: (json['METER_KWHTOTALDAILY'] ?? 0).toDouble(),
      METER_KWHPOSDAILY: (json['METER_KWHPOSDAILY'] ?? 0).toDouble(),
      METER_KWHNEGDAILY: (json['METER_KWHNEGDAILY'] ?? 0).toDouble(),
      METER_V1: (json['METER_V1'] ?? 0).toDouble(),
      METER_V2: (json['METER_V2'] ?? 0).toDouble(),
      METER_V3: (json['METER_V3'] ?? 0).toDouble(),
      METER_V12: (json['METER_V12'] ?? 0).toDouble(),
      METER_V23: (json['METER_V23'] ?? 0).toDouble(),
      METER_V31: (json['METER_V31'] ?? 0).toDouble(),
      METER_I1: (json['METER_I1'] ?? 0).toDouble(),
      METER_I2: (json['METER_I2'] ?? 0).toDouble(),
      METER_I3: (json['METER_I3'] ?? 0).toDouble(),

      SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL: (json['SOLAR_SOLAR1_EMI1_IRRADIANCETOTAL'] ?? 0).toDouble(),
      SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY: (json['SOLAR_SOLAR1_EMI1_IRRADIANCEDAILY'] ?? 0).toDouble(),
      SOLAR_SOLAR1_EMI1_TEMPAMBIENT: (json['SOLAR_SOLAR1_EMI1_TEMPAMBIENT'] ?? 0).toDouble(),
      SOLAR_SOLAR1_EMI1_TEMPPV: (json['SOLAR_SOLAR1_EMI1_TEMPPV'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_P: (json['SOLAR_SOLAR1_LOGGER1_P'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_Q: (json['SOLAR_SOLAR1_LOGGER1_Q'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_PF: (json['SOLAR_SOLAR1_LOGGER1_PF'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_KWHTOTAL: (json['SOLAR_SOLAR1_LOGGER1_KWHTOTAL'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_KWHDAILY: (json['SOLAR_SOLAR1_LOGGER1_KWHDAILY'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_IDC: (json['SOLAR_SOLAR1_LOGGER1_IDC'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_V12: (json['SOLAR_SOLAR1_LOGGER1_V12'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_V23: (json['SOLAR_SOLAR1_LOGGER1_V23'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_V31: (json['SOLAR_SOLAR1_LOGGER1_V31'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_I1: (json['SOLAR_SOLAR1_LOGGER1_I1'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_I2: (json['SOLAR_SOLAR1_LOGGER1_I2'] ?? 0).toDouble(),
      SOLAR_SOLAR1_LOGGER1_I3: (json['SOLAR_SOLAR1_LOGGER1_I3'] ?? 0).toDouble(),

      SOLAR_SOLAR1_METER2_P: (json['SOLAR_SOLAR1_METER2_P'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_Q: (json['SOLAR_SOLAR1_METER2_Q'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_S: (json['SOLAR_SOLAR1_METER2_S'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_PF: (json['SOLAR_SOLAR1_METER2_PF'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_KWHTOTAL: (json['SOLAR_SOLAR1_METER2_KWHTOTAL'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_KWHPOS: (json['SOLAR_SOLAR1_METER2_KWHPOS'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_KWHNEG: (json['SOLAR_SOLAR1_METER2_KWHNEG'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V1: (json['SOLAR_SOLAR1_METER2_V1'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V2: (json['SOLAR_SOLAR1_METER2_V2'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V3: (json['SOLAR_SOLAR1_METER2_V3'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V12: (json['SOLAR_SOLAR1_METER2_V12'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V23: (json['SOLAR_SOLAR1_METER2_V23'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_V31: (json['SOLAR_SOLAR1_METER2_V31'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_I1: (json['SOLAR_SOLAR1_METER2_I1'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_I2: (json['SOLAR_SOLAR1_METER2_I2'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER2_I3: (json['SOLAR_SOLAR1_METER2_I3'] ?? 0).toDouble(),

      SOLAR_SOLAR1_METER3_P: (json['SOLAR_SOLAR1_METER3_P'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_Q: (json['SOLAR_SOLAR1_METER3_Q'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_S: (json['SOLAR_SOLAR1_METER3_S'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_PF: (json['SOLAR_SOLAR1_METER3_PF'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_KWHTOTAL: (json['SOLAR_SOLAR1_METER3_KWHTOTAL'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_KWHPOS: (json['SOLAR_SOLAR1_METER3_KWHPOS'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_KWHNEG: (json['SOLAR_SOLAR1_METER3_KWHNEG'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V1: (json['SOLAR_SOLAR1_METER3_V1'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V2: (json['SOLAR_SOLAR1_METER3_V2'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V3: (json['SOLAR_SOLAR1_METER3_V3'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V12: (json['SOLAR_SOLAR1_METER3_V12'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V23: (json['SOLAR_SOLAR1_METER3_V23'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_V31: (json['SOLAR_SOLAR1_METER3_V31'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_I1: (json['SOLAR_SOLAR1_METER3_I1'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_I2: (json['SOLAR_SOLAR1_METER3_I2'] ?? 0).toDouble(),
      SOLAR_SOLAR1_METER3_I3: (json['SOLAR_SOLAR1_METER3_I3'] ?? 0).toDouble(),

      BESS_SCU_P: (json['BESS_SCU_P'] ?? 0).toDouble(),
      BESS_SCU_I: (json['BESS_SCU_I'] ?? 0).toDouble(),
      BESS_SCU_SOC: (json['BESS_SCU_SOC'] ?? 0).toDouble(),
      BESS_SCU_SOH: (json['BESS_SCU_SOH'] ?? 0).toDouble(),
      BESS_SCU_PINVERT: (json['BESS_SCU_PINVERT'] ?? 0).toDouble(),
      BESS_SCU_KWHCHARGETOTAL: (json['BESS_SCU_KWHCHARGETOTAL'] ?? 0).toDouble(),
      BESS_SCU_KWHDISCHARGETOTAL: (json['BESS_SCU_KWHDISCHARGETOTAL'] ?? 0).toDouble(),
      BESS_SCU_KWHCHARGEDAILY: (json['BESS_SCU_KWHCHARGEDAILY'] ?? 0).toDouble(),
      BESS_SCU_KWHDISCHARGEDAILY: (json['BESS_SCU_KWHDISCHARGEDAILY'] ?? 0).toDouble(),

      // ดึง Rack ทั้ง 5 เข้าเป็น List อัตโนมัติ
      BESS_RACKS: parseRacks(json),

      WEATHER_Temp: (json['WEATHER_Temp'] ?? 0).toDouble(),
      WEATHER_TempMin: (json['WEATHER_TempMin'] ?? 0).toDouble(),
      WEATHER_TempMax: (json['WEATHER_TempMax'] ?? 0).toDouble(),
      WEATHER_Humidity: (json['WEATHER_Humidity'] ?? 0).toDouble(),
      WEATHER_WindSpeed: (json['WEATHER_WindSpeed'] ?? 0).toDouble(),
      WEATHER_Sunrise: (json['WEATHER_Sunrise'] ?? 0).toDouble(),
      WEATHER_Sunset: (json['WEATHER_Sunset'] ?? 0).toDouble(),
      WEATHER_FeelsLike: (json['WEATHER_FeelsLike'] ?? 0).toDouble(),
      WEATHER_Pressure: (json['WEATHER_Pressure'] ?? 0).toDouble(),
      WEATHER_Icon: json['WEATHER_Icon']?.toString() ?? "",
    );
  }
}

// --- ส่วนของ Service (เปลี่ยนไส้ในเป็น HTTP API) ---
class MqttService {
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();
  String selectedPlant = 'UTI';
  dynamic latestData;
  

  String get _apiUrl => "http://$serverIp:$serverPort/api/dashboard?plant=$selectedPlant";
  String get _historyApiUrl => "http://$serverIp:$serverPort/api/history/today?plant=$selectedPlant";

  void changePlant(String newPlant) {
    if (selectedPlant != newPlant) {
      selectedPlant = newPlant;
      _fetchData();
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistoryData() async {
    try {
      final response = await http.get(Uri.parse(_historyApiUrl));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.cast<Map<String, dynamic>>();
      } else {
        print("History API Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching History: $e");
      return [];
    }
  }
  
  DashboardDataTPI? currentDataTPI;
  DashboardDataUTI? currentData;
  final StreamController<dynamic> _dataController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get dataStream => _dataController.stream;
  Timer? _timer;

  void connect() {
    print("MqttService: Connecting via API Mock...");
    _fetchData();
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
      final String targetUrl = '$_apiUrl?plant=$selectedPlant';
      final response = await http.get(Uri.parse(targetUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("$selectedPlant JSON ที่รับมา: $jsonResponse");
        if (selectedPlant == 'UTI') {
          final currentDataUTI = DashboardDataUTI.fromJson(jsonResponse);
          _dataController.add(currentDataUTI);
        } else {
          final currentDataTPI = DashboardDataTPI.fromJson(jsonResponse);
          _dataController.add(currentDataTPI);
        }
        
      } else {
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching API: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchWithCustomPath(String endpoint) async {
    final String baseUrl = 'http://$serverIp:$serverPort';
    
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}