import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_saver/file_saver.dart';

@RoutePage()
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  // --- Theme Colors ---
  final Color primaryColor = Colors.indigo;
  final Color secondaryColor = Colors.indigo.shade50;
  
  // --- Global Data Constraints ---
  DateTime? minGlobalDate;
  DateTime? maxGlobalDate;
  bool isLoading = true;

  // --- Selected State ---
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  int startHour = 0;
  int startMinute = 0;
  int endHour = 23;
  int endMinute = 55;

  // --- Standard Options ---
  final List<int> allHours = List.generate(24, (index) => index);
  final List<int> allMinutes = List.generate(12, (index) => index * 5);

  String selectedStep = '5 mins';
  final List<String> steps = [
    '5 mins', '10 mins', '15 mins', '30 mins',
    '1 hour', '2 hours', '4 hours', '6 hours', '1 day'
  ];

  String selectedFormat = 'Excel';
  final List<String> formats = ['Excel', 'PDF'];

  // --- Variable Selection State ---
  final List<String> _masterVariables = const [
    "METER_V1", "METER_V2", "METER_V3",
    "METER_I1", "METER_I2", "METER_I3",
    "METER_KW", "METER_Total_KWH",
    "METER_Export_KVARH", "METER_Export_KWH", "METER_Import_KVARH", "METER_Import_KWH",
    "METER_Total_KVARH", "METER_Hz", "METER_PF",
    "METER_I_Total", "METER_KVAR", "METER_KW_Invert", "METER_Grid_Power_KW",
    "PV_Total_Energy", "PV_Daily_Energy", "Load_Total_Energy", "Load_Daily_Energy",
    "GRID_Total_Import_Energy", "GRID_Daily_Import_Energy", "GRID_Total_Export_Energy", "GRID_Daily_Export_Energy",
    "BESS_Daily_Charge_Energy", "BESS_Daily_Discharge_Energy", "EMS_CO2_Equivalent",
    "EMS_EnergyProducedFromPV_Daily", "EMS_EnergyFeedToGrid_Daily", "EMS_EnergyConsumption_Daily",
    "EMS_EnergyFeedFromGrid_Daily", "EMS_SolarPower_kW", "EMS_LoadPower_kW","EMS_BatteryPower_kW",
    "EMS_EnergyProducedFromPV_kWh", "EMS_EnergyFeedFromGrid_kWh", "EMS_EnergyConsumption_kWh",
    "BESS_SOC", "BESS_SOH", "BESS_V", "BESS_I", "BESS_KW", "BESS_Temperature",
    "BESS_Total_Discharge", "BESS_Total_Charge", "BESS_SOC_MAX", "BESS_SOC_MIN",
    "BESS_Power_KW_Invert", "BESS_Manual_Power_Setpoint", "BESS_PID_CycleTime",
    "BESS_PID_Td", "BESS_PID_Ti", "BESS_PID_Gain", "BESS_Temp_Ambient",
    "BESS_Alarm", "BESS_Fault", "BESS_Communication_Fault",
    "PV1_Grid_Power_KW", "PV1_Load_Power_KW", "PV1_Daily_Energy_Power_KWh", "PV1_Total_Energy_Power_KWh",
    "PV1_Power_Factor", "PV1_Reactive_Power_KVar", "PV1_Active_Power_KW", "PV1_Fault", "PV1_Communication_Fault",
    "PV2_Energy_Daily_kW", "PV2_LifeTimeEnergyProduction_kWh_Start", "PV2_LifeTimeEnergyProduction_kWh",
    "PV2_ReactivePower_kW", "PV2_ApparentPower_kW", "PV2_Power_kW", "PV2_LifeTimeEnergyProduction",
    "PV2_PowerFactor_Percen", "PV2_ReactivePower", "PV2_ApparentPower", "PV2_Power", "PV2_Communication_Fault",
    "PV3_Total_Power_Yields_Real", "PV3_Total_Apparent_Power_kW", "PV3_Total_Reactive_Power_kW", "PV3_Total_Active_Power_kW",
    "PV3_Total_Reactive_Power", "PV3_Total_Active_Power", "PV3_Total_Apparent_Power", "PV3_Total_Power_Yields",
    "PV3_Daily_Power_Yields", "PV3_Nominal_Active_Power", "PV3_Communication_Fault",
    "PV4_Total_Power_Yields_Real", "PV4_Total_Apparent_Power_kW", "PV4_Total_Reactive_Power_kW", "PV4_Total_Active_Power_kW",
    "PV4_Total_Reactive_Power", "PV4_Total_Active_Power", "PV4_Total_Apparent_Power", "PV4_Total_Power_Yields",
    "PV4_Daily_Power_Yields", "PV4_Nominal_Active_Power", "PV4_Communication_Fault",
    "WEATHER_Temp","WEATHER_TempMin", "WEATHER_TempMax", "WEATHER_Sunrise", "WEATHER_Sunset",
    "WEATHER_FeelsLike", "WEATHER_Humidity", "WEATHER_Pressure", "WEATHER_WindSpeed",
    "WEATHER_Cloudiness","WEATHER_Icon"
  ];

  late List<String> availableVariables;
  List<String> selectedVariables = [];
  String? _tempSelectedVariable;
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  final String baseUrl = "http://$serverIp:$serverPort";

  @override
  void initState() {
    super.initState();
    availableVariables = List.from(_masterVariables);
    _fetchDataRange();
  }

  Future<void> _fetchDataRange() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/data_range'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        DateTime minD = DateTime.parse(data['min_date']);
        DateTime maxD = DateTime.parse(data['max_date']);

        setState(() {
          minGlobalDate = minD;
          maxGlobalDate = maxD;
          startDate = minD;
          startHour = minD.hour;
          startMinute = _snapToNearest5(minD.minute);
          endDate = maxD;
          endHour = maxD.hour;
          endMinute = _snapToNearest5(maxD.minute);
          isLoading = false;
        });
      } else {
        _handleError("Failed to load data range");
      }
    } catch (e) {
      _handleError("Connection error: $e");
    }
  }

  int _snapToNearest5(int minute) {
    return (minute / 5).floor() * 5;
  }

  void _handleError(String message) {
    setState(() {
      isLoading = false;
      minGlobalDate = DateTime.now().subtract(const Duration(days: 1));
      maxGlobalDate = DateTime.now();
      startDate = minGlobalDate!;
      endDate = maxGlobalDate!;
    });
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Export Data Manager"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Time Configuration Section
            _buildSectionHeader("Time Configuration", Icons.access_time_filled),
            const SizedBox(height: 8), 
            _buildControlPanel(),

            const SizedBox(height: 20), 

            // 2. Variable Selection Section
            _buildSectionHeader("Variable Selection", Icons.list_alt),
            const SizedBox(height: 8), 
            
            // Dual List Box Container
            SizedBox(
              height: 320, 
              child: Row(
                children: [
                  // Left Box
                  Expanded(
                    child: _buildListBox(
                      title: "Available Variables",
                      items: availableVariables,
                      selectedItem: _tempSelectedVariable,
                      onTap: (val) => setState(() => _tempSelectedVariable = val),
                      isSource: true,
                    ),
                  ),
                  
                  // Center Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTransferButton(
                        icon: Icons.arrow_forward_rounded,
                        // ถ้าครบ 10 แล้ว และตัวแปรที่เลือกอยู่ไม่ได้อยู่ในลิสต์ขวา (ป้องกันการกดซ้ำ)
                        // หรือจะปล่อยให้กดแล้วไปติด SnackBar แจ้งเตือนข้างบนก็ได้ครับ
                        onPressed: _moveToRight, 
                        color: selectedVariables.length >= 10 ? Colors.grey : primaryColor, // เปลี่ยนสีปุ่มเป็นสีเทาถ้าเต็ม
                      ),
                        const SizedBox(height: 12),
                        _buildTransferButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: _moveToLeft,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),

                  // Right Box
                  Expanded(
                    child: _buildListBox(
                      title: "To Export",
                      items: selectedVariables,
                      selectedItem: null,
                      onTap: (val) {},
                      isOrdered: true,
                      isSource: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. Export Action
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                // -------------------------------------------------------------
                // [MODIFIED] Check if selectedVariables is empty. 
                // If empty -> null (Disabled/Grey), else -> _handleExport (Enabled)
                // -------------------------------------------------------------
                onPressed: selectedVariables.isEmpty ? null : _handleExport,
                
                icon: const Icon(Icons.cloud_download_rounded, size: 24),
                label: const Text("Generate & Download", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  // กำหนดสีตอน Disabled ให้เป็นสีเทาชัดเจน (Optional: Flutter ทำให้อัตโนมัติอยู่แล้วถ้า onPressed เป็น null)
                  disabledBackgroundColor: Colors.grey[300], 
                  disabledForegroundColor: Colors.grey[500],
                  foregroundColor: Colors.white,
                  elevation: selectedVariables.isEmpty ? 0 : 3, // เอาเงาออกถ้ากดไม่ได้
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferButton({required IconData icon, required VoidCallback onPressed, required Color color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row: Start & End Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDateTimeRow(
                    label: "Start Time",
                    date: startDate,
                    hour: startHour,
                    minute: startMinute,
                    firstDate: minGlobalDate!,
                    lastDate: endDate,
                    validHours: _getValidHours(currentDate: startDate, limitDate: endDate, isStartType: true),
                    validMinutes: _getValidMinutes(currentDate: startDate, currentHour: startHour, limitDate: endDate, limitHour: endHour, isStartType: true),
                    onDateChanged: (d) => setState(() => startDate = d),
                    onHourChanged: (h) => setState(() => startHour = h!),
                    onMinuteChanged: (m) => setState(() => startMinute = m!),
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeRow(
                    label: "End Time",
                    date: endDate,
                    hour: endHour,
                    minute: endMinute,
                    firstDate: startDate,
                    lastDate: maxGlobalDate!,
                    validHours: _getValidHours(currentDate: endDate, limitDate: startDate, isStartType: false),
                    validMinutes: _getValidMinutes(currentDate: endDate, currentHour: endHour, limitDate: startDate, limitHour: startHour, isStartType: false),
                    onDateChanged: (d) => setState(() => endDate = d),
                    onHourChanged: (h) => setState(() => endHour = h!),
                    onMinuteChanged: (m) => setState(() => endMinute = m!),
                    icon: Icons.event_available_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(thickness: 1, height: 1),
            const SizedBox(height: 12),
            
            // Row: Step & Format
            Row(
              children: [
                Expanded(
                  child: _buildModernDropdown(
                    label: "Step Interval",
                    value: selectedStep,
                    items: steps,
                    icon: Icons.timer_outlined,
                    onChanged: (val) => setState(() => selectedStep = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernDropdown(
                    label: "File Format",
                    value: selectedFormat,
                    items: formats,
                    icon: Icons.file_present_rounded,
                    onChanged: (val) => setState(() => selectedFormat = val!),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime date,
    required int hour,
    required int minute,
    required DateTime firstDate,
    required DateTime lastDate,
    required List<int> validHours,
    required List<int> validMinutes,
    required ValueChanged<DateTime> onDateChanged,
    required ValueChanged<int?> onHourChanged,
    required ValueChanged<int?> onMinuteChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Date Button
            Expanded(
              flex: 4, 
              child: Material(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: primaryColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) onDateChanged(picked);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Icon(Icons.calendar_month, color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yy').format(date),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            
            // Hour
            Expanded(
              flex: 2,
              child: _buildCompactDropdown(
                value: validHours.contains(hour) ? hour : null,
                items: validHours,
                onChanged: onHourChanged,
                hint: "Hr",
              ),
            ),
            const Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            // Minute
            Expanded(
              flex: 2,
              child: _buildCompactDropdown(
                value: validMinutes.contains(minute) ? minute : null,
                items: validMinutes,
                onChanged: onMinuteChanged,
                hint: "Mn",
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Modern Dropdown (Step & Format) ---
  Widget _buildModernDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          elevation: 4,
          icon: Icon(Icons.arrow_drop_down, color: primaryColor, size: 20),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((T item) {
              return Row(
                children: [
                  Icon(icon, color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    item.toString(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((e) {
            final bool isSelected = e == value;
            return DropdownMenuItem(
              value: e, 
              child: Row(
                children: [
                  if (isSelected)
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    ),
                  Text(
                    e.toString(), 
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'MyriadPro',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- Compact Dropdown (Hour/Min) ---
  Widget _buildCompactDropdown<T>({required T? value, required List<T> items, required ValueChanged<T?> onChanged, required String hint}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          elevation: 4,
          hint: Center(child: Text(hint, style: const TextStyle(fontSize: 10))),
          icon: const SizedBox(), 
          style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
          alignment: Alignment.center,
          
          selectedItemBuilder: (BuildContext context) {
             return items.map<Widget>((T item) {
              return Center(
                child: Text(
                  item.toString(),
                  style: const TextStyle(
                    color: Colors.black87, 
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MyriadPro'
                  ),
                ),
              );
            }).toList();
          },

          items: items.isEmpty ? [] : items.map((e) {
            final bool isSelected = e == value;
            return DropdownMenuItem(
              value: e, 
              child: Row(
                children: [
                  if (isSelected)
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    ),
                  Text(
                    e.toString(),
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'MyriadPro',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildListBox({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onTap,
    bool isOrdered = false,
    bool isSource = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSource ? Colors.grey[100] : primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSource ? Colors.grey[700] : primaryColor, fontSize: 13)),
                Text("${items.length}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSource ? Colors.black54 : primaryColor)),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty 
              ? Center(child: Text("No items", style: TextStyle(color: Colors.grey[400], fontSize: 12)))
              : ListView.builder(
                padding: const EdgeInsets.all(6),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? primaryColor.withOpacity(0.1) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected ? Border.all(color: primaryColor.withOpacity(0.5)) : null,
                    ),
                    child: InkWell(
                      onTap: () => onTap(item),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            if(isOrdered)
                              Container(
                                width: 18, height: 18,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                child: Center(child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                              )
                            else if(isSource)
                              const Icon(Icons.add_circle_outline, size: 16, color: Colors.grey)
                            else 
                              const SizedBox.shrink(),
                              
                            if(isSource && !isOrdered) const SizedBox(width: 6),
                            
                            Expanded(child: Text(item, style: TextStyle(fontSize: 12, color: isSelected ? primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    );
  }

  // --- Logic Methods (Unchanged Logic) ---

  void _moveToRight() {
    if (_tempSelectedVariable != null && _tempSelectedVariable!.isNotEmpty) {
      // --- เพิ่มเงื่อนไขเช็คจำนวนที่นี่ ---
      if (selectedVariables.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can select a maximum of 10 variables"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return; // หยุดการทำงาน ไม่เพิ่มตัวแปรที่ 11
      }
      // ----------------------------

      setState(() {
        selectedVariables.add(_tempSelectedVariable!);
        availableVariables.remove(_tempSelectedVariable!);
        _tempSelectedVariable = null;
      });
    }
  }

  void _moveToLeft() {
    if (selectedVariables.isNotEmpty) {
      setState(() {
        final last = selectedVariables.removeLast();
        availableVariables.add(last);
        availableVariables.sort((a, b) => 
            _masterVariables.indexOf(a).compareTo(_masterVariables.indexOf(b)));
      });
    }
  }

  List<int> _getValidHours({required DateTime currentDate, required DateTime limitDate, required bool isStartType}) {
    List<int> valid = List.from(allHours);
    if (isDateSameDay(currentDate, minGlobalDate!)) valid.removeWhere((h) => h < minGlobalDate!.hour);
    if (isDateSameDay(currentDate, maxGlobalDate!)) valid.removeWhere((h) => h > maxGlobalDate!.hour);
    if (isDateSameDay(currentDate, limitDate)) {
      if (isStartType) valid.removeWhere((h) => h > endHour);
      else valid.removeWhere((h) => h < startHour);
    }
    return valid;
  }

  List<int> _getValidMinutes({required DateTime currentDate, required int currentHour, required DateTime limitDate, required int limitHour, required bool isStartType}) {
    List<int> valid = List.from(allMinutes);
    if (isDateSameDay(currentDate, minGlobalDate!) && currentHour == minGlobalDate!.hour) valid.removeWhere((m) => m < minGlobalDate!.minute);
    if (isDateSameDay(currentDate, maxGlobalDate!) && currentHour == maxGlobalDate!.hour) valid.removeWhere((m) => m > maxGlobalDate!.minute);
    if (isDateSameDay(currentDate, limitDate) && currentHour == limitHour) {
      if (isStartType) valid.removeWhere((m) => m > endMinute);
      else valid.removeWhere((m) => m < startMinute);
    }
    return valid;
  }

  bool isDateSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _handleExport() async {
    // สร้าง DateTime
    final startDT = DateTime(startDate.year, startDate.month, startDate.day, startHour, startMinute);
    final endDT = DateTime(endDate.year, endDate.month, endDate.day, endHour, endMinute);

    // ตรวจสอบความถูกต้องของเวลา
    if (startDT.isAfter(endDT)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Start time must be before End time"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

  try {
    final body = jsonEncode({
      "start_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(startDT),
      "end_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(endDT),
      "step": selectedStep,
      "file_format": selectedFormat,
      "variables": selectedVariables
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/export_custom'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    // --- จุดที่แก้ไข: เช็คว่า Server ส่งอะไรกลับมา ---
    
    if (response.statusCode == 200) {
      // เช็ค Header ว่าใช่ไฟล์ Excel/PDF หรือไม่?
      final contentType = response.headers['content-type'] ?? '';
      
      // กรณี 1: ถ้า Server ส่งกลับมาเป็น JSON (แปลว่ามี Error แจ้งกลับมา เช่น ไม่มีข้อมูล)
      if (contentType.contains('application/json')) {
         final jsonResponse = jsonDecode(response.body);
         String serverMessage = jsonResponse['error'] ?? 'Unknown Error';
         
         // แสดง Dialog แจ้งเตือนผู้ใช้
         if (mounted) {
           showDialog(
             context: context, 
             builder: (c) => AlertDialog(
               title: const Text("Export Failed"),
               content: Text(serverMessage), // เช่น "No data found..."
               actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
             )
           );
         }
      } 
      // กรณี 2: ถ้าเป็นไฟล์ (Excel/PDF) ให้ Save ตามปกติ
      else {
        String ext = selectedFormat == 'Excel' ? 'xlsx' : 'pdf';
        MimeType mimeType = selectedFormat == 'Excel' ? MimeType.microsoftExcel : MimeType.pdf;
         
         // ตั้งชื่อ Default ไว้ก่อน
        String fileName = "UTI_Factory_Report"; 
        print("ALL HEADERS: ${response.headers}"); 
        print("Check Key: ${response.headers['content-disposition']}");
         
        String? contentDisposition = response.headers['content-disposition'];
         
        if (contentDisposition != null) {
            // [แก้ไข] ใช้ r'''...''' (Triple quotes) เพื่อให้ใส่ ' และ " ได้โดยไม่ Error
          RegExp regex = RegExp(r'''filename[^;=\n]*=((['"]).*?\2|[^;\n]*)''');
          var match = regex.firstMatch(contentDisposition);
            
          if (match != null && match.group(1) != null) {
               // ลบ Quote และ Space
            String rawName = match.group(1)!
            .replaceAll('"', '')
            .replaceAll("'", '')
            .trim(); 
               
               // ตัดนามสกุลออก (ป้องกันการซ้ำซ้อน เช่น Report.xlsx.xlsx)
            if (rawName.toLowerCase().endsWith('.$ext')) {
              fileName = rawName.substring(0, rawName.length - (ext.length + 1));
            } else {
              fileName = rawName;
            }
          }
        }

         await FileSaver.instance.saveFile(
            name: fileName,
            bytes: response.bodyBytes,
            ext: ext,
            mimeType: mimeType,
         );
         
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Downloaded $fileName.$ext successfully!"), backgroundColor: Colors.green),
            );
         }
      }
    } else {
      // กรณี Server Error (500, 404)
      print("Server Error Log: ${response.body}"); // ดู log นี้ใน Debug Console ของ Flutter
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
         );
      }
    }
  } catch (e) {
    print("Connection Error: $e");
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
       );
    }
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}
}