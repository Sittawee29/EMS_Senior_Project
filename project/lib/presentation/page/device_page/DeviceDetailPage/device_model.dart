enum DeviceType { solar, bess, meter, ems, logger, emi }

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
class MeterModel extends DeviceModel {
  final String Export_KWH;
  final String Import_KWH;
  final String Export_KVARH;
  final String Import_KVARH;
  final String Total_KWH;
  final String Total_KVARH;
  final String P;
  final String Q;
  final String S;
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
  final String kwhtotal;
  final String kwhpos;
  final String kwhneg;
  final String kwhtotaldaily;
  final String kwhposdaily;
  final String kwhnegdaily;
  final String LoadPower_kW;
  final String GridPower_kW;

  MeterModel({
    required super.name,
    required super.status,
    this.Export_KWH = '-',
    this.Import_KWH = '-',
    this.Export_KVARH = '-',
    this.Import_KVARH = '-',
    this.Total_KWH = '-',
    this.Total_KVARH = '-',
    this.P = '-',
    this.Q = '-',
    this.S = '-',
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
    this.kwhtotal = '-',
    this.kwhpos = '-',
    this.kwhneg = '-',
    this.kwhtotaldaily = '-',
    this.kwhposdaily = '-',
    this.kwhnegdaily = '-',
    this.LoadPower_kW = '-',
    this.GridPower_kW = '-',
  }) : super(type: DeviceType.meter);
}

class EMSModel extends DeviceModel {
  final String pload;
  final String kwhloadtotal;
  final String kwhloaddaily;
  final String renewratio;
  final String co2e;
  final String renewratiolifetime;

  EMSModel({
    required super.name,
    required super.status,
    this.pload = '-',
    this.kwhloadtotal = '-',
    this.kwhloaddaily = '-',
    this.renewratio = '-',
    this.co2e = '-',
    this.renewratiolifetime = '-',
  }) : super(type: DeviceType.ems);
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

class SolarModel extends DeviceModel {
  final String currentPower;
  SolarModel({
    required super.name,
    required super.status,
    this.currentPower = '0 kW',
  }) : super(type: DeviceType.solar);
}

class SolarLoggerModel extends DeviceModel {
  final String kwhtotal;
  final String kwhdaily;
  final String p;
  final String q;
  final String idc;
  final String pf;
  final String v12;
  final String v23;
  final String v31;
  final String i1;
  final String i2;
  final String i3;

  SolarLoggerModel({
    required super.name,
    required super.status,
    this.kwhtotal = '-',
    this.kwhdaily = '-',
    this.p = '-',
    this.q = '-',
    this.idc = '-',
    this.pf = '-',
    this.v12 = '-',
    this.v23 = '-',
    this.v31 = '-',
    this.i1 = '-',
    this.i2 = '-',
    this.i3 = '-',
  }) : super(type: DeviceType.logger);
}

class SolarMeterModel extends DeviceModel {
  final String kwhtotal;
  final String kwhpos;
  final String kwhneg;
  final String p;
  final String q;
  final String s;
  final String pf;
  final String v12;
  final String v23;
  final String v31;
  final String v1;
  final String v2;
  final String v3;
  final String i1;
  final String i2;
  final String i3;

  SolarMeterModel({
    required super.name,
    required super.status,
    this.kwhtotal = '-',
    this.kwhpos = '-',
    this.kwhneg = '-',
    this.p = '-',
    this.q = '-',
    this.s = '-',
    this.pf = '-',
    this.v12 = '-',
    this.v23 = '-',
    this.v31 = '-',
    this.v1 = '-',
    this.v2 = '-',
    this.v3 = '-',
    this.i1 = '-',
    this.i2 = '-',
    this.i3 = '-',
  }) : super(type: DeviceType.meter);
}

class SolarEMIModel extends DeviceModel {
  final String tempambient;
  final String irradiancetotal;
  final String irradiancedaily;
  final String temppv;

  SolarEMIModel({
    required super.name,
    required super.status,
    this.tempambient = '-',
    this.irradiancetotal = '-',
    this.irradiancedaily = '-',
    this.temppv = '-',
  }) : super(type: DeviceType.emi);
}