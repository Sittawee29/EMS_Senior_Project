// 1. Enum สำหรับระบุประเภท
enum DeviceType { inverter, bess, solarPanel }

// 2. Class แม่ (Abstract) - ห้ามแก้
abstract class DeviceModel {
  final String name;
  final DeviceType type;
  final String status;

  DeviceModel({
    required this.name,
    required this.type,
    required this.status,
  });
}

// 3. Class ลูก: Inverter (มี SN, Version)
class InverterModel extends DeviceModel {
  final String sn;
  final String inverterType;
  final String ratedPower;
  final String systemTime;
  
  // Version Info
  final String protocolVersion;
  final String mainVersion;
  final String hmiVersion;
  final String firmwareVersion;

  final String Export_KWH;
  final String Import_KWH;
  final String Export_KVARH;
  final String Import_KVARH;
  final String Total_KWH;
  final String Total_KVARH;
  final String Hz;
  final String PF;
  final String V1;
  final String V2;
  final String V3;
  final String I1;
  final String I2;
  final String I3;
  final String KW;
  final String KVAR;
  final String LoadPower_kW;
  final String GridPower_kW;

  InverterModel({
    required super.name,
    required super.status,
    this.sn = '-',
    this.inverterType = '-',
    this.ratedPower = '-',
    this.systemTime = '-',
    this.protocolVersion = '-',
    this.mainVersion = '-',
    this.hmiVersion = '-',
    this.firmwareVersion = '-',
    this.Export_KWH = '-',
    this.Import_KWH = '-',
    this.Export_KVARH = '-',
    this.Import_KVARH = '-',
    this.Total_KWH = '-',
    this.Total_KVARH = '-',
    this.Hz = '-',
    this.PF = '-',
    this.V1 = '-',
    this.V2 = '-',
    this.V3 = '-',
    this.I1 = '-',
    this.I2 = '-',
    this.I3 = '-',
    this.KW = '-',
    this.KVAR = '-',
    this.LoadPower_kW = '-',
    this.GridPower_kW = '-',
  }) : super(type: DeviceType.inverter);
}

// 4. Class ลูก: Battery (มี Voltage, SoC, Energy)
class BatteryModel extends DeviceModel {
  final String soc;
  final String soh;
  final String voltage;
  final String current;
  final String kw;
  final String temperature;
  final String totalDischarge;
  final String totalCharge;
  final String dailyCharge;
  final String dailyDischarge;
  final String socMax;
  final String socMin;
  final String powerInvert;
  final String manualSetpoint;
  final String pidCycleTime;
  final String pidTd;
  final String pidTi;
  final String pidGain;

  BatteryModel({
    required super.name,
    required super.status,
    this.soc = '-',
    this.soh = '-',
    this.voltage = '-',
    this.current = '-',
    this.kw = '-',
    this.temperature = '-',
    this.totalDischarge = '-',
    this.totalCharge = '-',
    this.dailyCharge = '-',
    this.dailyDischarge = '-',
    this.socMax = '-',
    this.socMin = '-',
    this.powerInvert = '-',
    this.manualSetpoint = '-',
    this.pidCycleTime = '-',
    this.pidTd = '-',
    this.pidTi = '-',
    this.pidGain = '-',
  }) : super(type: DeviceType.bess);
}

// 5. Class ลูก: Solar (มี Current Power)
class SolarModel extends DeviceModel {
  final String currentPower;

  SolarModel({
    required super.name,
    required super.status,
    this.currentPower = '0 kW',
  }) : super(type: DeviceType.solarPanel);
}