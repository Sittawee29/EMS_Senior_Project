part of '../../page.dart';

enum TimePeriod { daily, monthly, yearly }
enum GraphType { power, energy, voltage, current, SoC, co2 }

class HCurve extends StatefulWidget {
  const HCurve({super.key});

  @override
  State<HCurve> createState() => _HCurveState();
}

class _HCurveState extends State<HCurve> {
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  GraphType _selectedType = GraphType.power;
  TimePeriod _selectedPeriod = TimePeriod.daily;
  DateTime _currentDate = DateTime.now(); // วันที่ที่เลือกปัจจุบัน (Default: Today)
  DateTime? _minDataDate; // วันแรกที่มีข้อมูลใน DB
  DateTime? _maxDataDate; // วันสุดท้ายที่มีข้อมูลใน DB
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  // --- [ใหม่] ตัวแปรเก็บ index ที่ต้องการซ่อน ---
  final Set<int> _hiddenIndices = {};

  // --- 1. แก้ไข: เปลี่ยน _timeLabels จากตัวแปรคงที่ เป็น Getter ที่เปลี่ยนตาม Period ---
  List<String> get _currentLabels {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return List.generate(288, (index) {
          final int totalMinutes = index * 5;
          final int h = totalMinutes ~/ 60;
          final int m = totalMinutes % 60;
          return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        });
      case TimePeriod.monthly:
        // สร้างเลข 1 ถึง 31
        return List.generate(31, (index) => (index + 1).toString());
      case TimePeriod.yearly:
        // ชื่อเดือนย่อ
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDataRange(); // 1. หาขอบเขตข้อมูลก่อน
    _loadData();       // 2. โหลดข้อมูลกราฟ
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDataRange() async {
    try {
      // แก้ IP ให้ตรง server คุณ
      final response = await http.get(Uri.parse('http://$serverIp:$serverPort/api/data_range'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
             // แปลง String เป็น DateTime
             if (data['min_date'] != null) _minDataDate = DateTime.parse(data['min_date']);
             if (data['max_date'] != null) _maxDataDate = DateTime.parse(data['max_date']);
          });
        }
      }
    } catch (e) {
      print("Error fetching range: $e");
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String endpoint = '';
      String queryParams = '';

      // สร้าง URL ตามโหมดที่เลือก
      if (_selectedPeriod == TimePeriod.daily) {
        endpoint = '/api/history/daily';
        String dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
        queryParams = '?date=$dateStr';
        
      } else if (_selectedPeriod == TimePeriod.monthly) {
        endpoint = '/api/history/monthly';
        queryParams = '?year=${_currentDate.year}&month=${_currentDate.month}';
        
      } else if (_selectedPeriod == TimePeriod.yearly) {
        endpoint = '/api/history/yearly';
        queryParams = '?year=${_currentDate.year}';
      }

      final String baseUrl = 'http://$serverIp:$serverPort'; 
      final url = Uri.parse('$baseUrl$endpoint$queryParams');
      
      final response = await http.get(url);
      
      List<Map<String, dynamic>> data = [];
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        data = jsonList.cast<Map<String, dynamic>>();
      }

      if (mounted) {
        setState(() {
          _historyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- [ใหม่] ฟังก์ชันเปิดปฏิทิน (Calendar) ---
  Future<void> _showCalendar() async {
    // 1. ถ้าเป็น Monthly ให้ใช้ Dialog เลือกเดือนแบบพิเศษที่เราสร้าง
    if (_selectedPeriod == TimePeriod.monthly) {
      await _showMonthPicker(context);
      return;
    }

    // 2. ถ้าเป็น Daily หรือ Yearly ใช้ของเดิม
    final DateTime firstDate = _minDataDate ?? DateTime(2020);
    final DateTime lastDate = _maxDataDate ?? DateTime.now();

    DatePickerMode initialMode = DatePickerMode.day;
    if (_selectedPeriod == TimePeriod.yearly) {
       initialMode = DatePickerMode.year; 
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: initialMode,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Palette.lightBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentDate = picked;
      });
      _loadData();
    }
  }

  // --- [ใหม่] ฟังก์ชันเลือกเฉพาะ เดือน/ปี สำหรับโหมด Monthly ---
  Future<void> _showMonthPicker(BuildContext context) async {
    final DateTime firstDate = _minDataDate ?? DateTime(2020);
    final DateTime lastDate = _maxDataDate ?? DateTime.now();
    
    // ปีที่กำลังเลือกใน Dialog (เริ่มต้นที่ปีปัจจุบันที่เลือกอยู่)
    int displayYear = _currentDate.year;

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ปุ่มลดปี
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: displayYear > firstDate.year
                        ? () => setStateDialog(() => displayYear--)
                        : null,
                  ),
                  // แสดงปี
                  Text(
                    "$displayYear",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // ปุ่มเพิ่มปี
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: displayYear < lastDate.year
                        ? () => setStateDialog(() => displayYear++)
                        : null,
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                height: 300, // ความสูงของตารางเดือน
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 คอลัมน์
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final int month = index + 1;
                    // ตรวจสอบว่าเดือนนี้เลือกได้ไหม (ตาม min/max data)
                    bool isSelectable = true;
                    if (displayYear == firstDate.year && month < firstDate.month) isSelectable = false;
                    if (displayYear == lastDate.year && month > lastDate.month) isSelectable = false;

                    final bool isSelected = (displayYear == _currentDate.year && month == _currentDate.month);

                    return InkWell(
                      onTap: isSelectable
                          ? () {
                              // เมื่อเลือกเดือน ให้ส่งค่ากลับทันที
                              Navigator.pop(context, DateTime(displayYear, month));
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Palette.lightBlue : (isSelectable ? Colors.white : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Palette.lightBlue : Colors.grey.shade300,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM').format(DateTime(2022, month)), // ชื่อเดือนย่อ (Jan, Feb...)
                          style: TextStyle(
                            color: isSelectable ? (isSelected ? Colors.white : Colors.black) : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentDate = picked;
      });
      _loadData();
    }
  }

  // --- [ใหม่] Helper แสดงข้อความวันที่ที่เลือกอยู่ ---
  String _getDateLabel() {
    if (_selectedPeriod == TimePeriod.daily) {
      return DateFormat('dd MMM yyyy').format(_currentDate);
    } else if (_selectedPeriod == TimePeriod.monthly) {
      return DateFormat('MMMM yyyy').format(_currentDate);
    } else {
      return DateFormat('yyyy').format(_currentDate);
    }
  }

  void _onPeriodChanged(TimePeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
        
        _currentDate = DateTime.now(); 
        if (_selectedPeriod == TimePeriod.monthly || _selectedPeriod == TimePeriod.yearly) {
          _selectedType = GraphType.energy;
        }
      });
      _loadData();
    }
  }

  // --- [ใหม่] ฟังก์ชันสลับการแสดงผล ---
  void _toggleSeriesVisibility(int index) {
    setState(() {
      if (_hiddenIndices.contains(index)) {
        _hiddenIndices.remove(index); // เปิด
      } else {
        _hiddenIndices.add(index); // ปิด
      }
    });
  }
  
  String _getGraphTypeName(GraphType type) { /* ... (เหมือนเดิม) ... */ 
    switch (type) {
      case GraphType.power: return "Power (kW)";
      case GraphType.energy: return "Energy (kWh)";
      case GraphType.voltage: return "Voltage (V)";
      case GraphType.current: return "Current (A)";
      case GraphType.SoC: return "SoC (%)";
      case GraphType.co2: return "CO₂";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... (Header ส่วน Title และปุ่ม เลือก Period เหมือนเดิม) ...
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getGraphTypeName(_selectedType),
                 style: TextStyles.myriadProSemiBold22DarkBlue,
              ),
              Row(
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(width: 12),
                  Material( // ใช้ Material เพื่อให้เห็น Effect เวลาแตะ
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _showCalendar, // ย้ายคำสั่งกดมาไว้ตรงนี้ (ครอบทั้งปุ่ม)
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 8), // ระยะห่างภายใน
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Palette.lightBlue, size: 20),
                            const SizedBox(width: 8), // ระยะห่างระหว่างไอคอนกับตัวหนังสือ
                            Text(
                              _getDateLabel(), 
                              style: const TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildGraphTypeDropdown(),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        _isLoading
            ? const SizedBox(
                height: 300, 
                child: Center(child: CircularProgressIndicator())
              )
            : _LineChart(
                timeLabels: _currentLabels, // ส่ง Labels ที่เป็น Dynamic ไป
                historyData: _historyData,
                graphType: _selectedType,
                selectedPeriod: _selectedPeriod, // --- ส่ง period ไปด้วย ---
                hiddenIndices: _hiddenIndices,
              ),

        const SizedBox(height: 20),
        
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: _buildLegend(),
        ),
      ],
    );
  }

  // ... (Method _buildPeriodSelector, _periodBtn, _buildGraphTypeDropdown, _buildLegend เหมือนเดิม) ...
  Widget _buildPeriodSelector() {
     return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _periodBtn("Daily", TimePeriod.daily),
          _periodBtn("Monthly", TimePeriod.monthly),
          _periodBtn("Yearly", TimePeriod.yearly),
        ],
      ),
    );
  }

  Widget _periodBtn(String text, TimePeriod period) {
    final bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _onPeriodChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Palette.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGraphTypeDropdown() {
    // --- [ใหม่] กำหนดรายการที่จะแสดงใน Dropdown ตาม Period ---
    List<GraphType> availableTypes;
    if (_selectedPeriod == TimePeriod.monthly || _selectedPeriod == TimePeriod.yearly) {
      availableTypes = [GraphType.energy]; // แสดงแค่ Energy
    } else {
      availableTypes = GraphType.values;   // แสดงทั้งหมด (สำหรับ Daily)
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<GraphType>(
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGraphTypeName(_selectedType),
                style: const TextStyle(
                  color: Color.fromARGB(255, 22, 39, 128),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'MyriadPro',
                ),
              ),
              const SizedBox(width: 4),
              // ถ้ามีตัวเลือกเดียว (Monthly/Yearly) อาจจะซ่อนลูกศรก็ได้ แต่ใส่ไว้ตามเดิมเพื่อให้ UI เหมือนเดิม
              const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
            ],
          ),
        ),
        onSelected: (GraphType newValue) {
          setState(() {
            _selectedType = newValue;
          });
        },
        itemBuilder: (BuildContext context) {
          // --- [ใหม่] วนลูปสร้าง Item จาก availableTypes แทน GraphType.values ---
          return availableTypes.map((GraphType value) {
            final bool isSelected = value == _selectedType;
            return PopupMenuItem<GraphType>(
              value: value,
              height: 40,
              child: Row(
                children: [
                  if (isSelected)
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(color: Palette.lightBlue, shape: BoxShape.circle),
                    ),
                  Text(
                    _getGraphTypeName(value),
                    style: TextStyle(
                      color: isSelected ? Palette.lightBlue : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'MyriadPro',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildLegendItem({required int index, required Color color, required String text}) {
    final bool isHidden = _hiddenIndices.contains(index);
    final Color displayColor = isHidden ? Colors.grey : color; // สีจางลงเมื่อซ่อน

    return GestureDetector(
      onTap: () => _toggleSeriesVisibility(index), // คลิกเพื่อ Toggle
      child: Container(
        color: Colors.transparent, // ให้พื้นที่คลิกครอบคลุมง่ายขึ้น
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: displayColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isHidden ? Colors.grey : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    List<Widget> items = [];
    void addSpace() => items.add(const SizedBox(width: 20)); // Helper

    switch (_selectedType) {
      case GraphType.power:
        items.add(_buildLegendItem(index: 0, color: Palette.lightBlue, text: 'PV Production'));
        addSpace();
        items.add(_buildLegendItem(index: 1, color: Palette.orange, text: 'Load Consumption'));
        addSpace();
        items.add(_buildLegendItem(index: 2, color: Palette.red, text: 'Grid Power'));
        addSpace();
        items.add(_buildLegendItem(index: 3, color: Palette.green, text: 'BESS Power'));
        break;
      case GraphType.energy:
        items.add(_buildLegendItem(index: 0, color: Colors.blue, text: 'PV Production'));
        addSpace();
        items.add(_buildLegendItem(index: 1, color: Colors.red, text: 'Consumption'));
        addSpace();
        items.add(_buildLegendItem(index: 2, color: Colors.green, text: 'BESS Charge'));
        addSpace();
        items.add(_buildLegendItem(index: 3, color: Colors.orange, text: 'BESS Discharge'));
        break;
      case GraphType.voltage:
        items.add(_buildLegendItem(index: 0, color: Colors.red, text: 'Phase 1'));
        addSpace();
        items.add(_buildLegendItem(index: 1, color: Colors.yellow, text: 'Phase 2'));
        addSpace();
        items.add(_buildLegendItem(index: 2, color: Colors.blue, text: 'Phase 3'));
        break;
      case GraphType.current:
        items.add(_buildLegendItem(index: 0, color: Colors.red, text: 'Phase 1'));
        addSpace();
        items.add(_buildLegendItem(index: 1, color: Colors.yellow, text: 'Phase 2'));
        addSpace();
        items.add(_buildLegendItem(index: 2, color: Colors.blue, text: 'Phase 3'));
        break;
      case GraphType.SoC:
        items.add(_buildLegendItem(index: 0, color: Colors.green, text: 'SoC (%)'));
        break;
      case GraphType.co2:
        items.add(_buildLegendItem(index: 0, color: Colors.teal, text: 'CO₂ Saved'));
        break;
    }
    return Row(children: items);
  }
}

class _LineChart extends StatelessWidget {
  final List<String> timeLabels;
  final List<Map<String, dynamic>> historyData;
  final GraphType graphType;
  final TimePeriod selectedPeriod;
  final Set<int> hiddenIndices; // --- [ใหม่] รับค่า ---

  const _LineChart({
    required this.timeLabels,
    required this.historyData,
    required this.graphType,
    required this.selectedPeriod,
    required this.hiddenIndices, // --- [ใหม่] ---
  });

  String _getUnit() { /* ... (เหมือนเดิม) ... */ 
      switch (graphType) {
      case GraphType.power: return 'kW';
      case GraphType.energy: return 'kWh';
      case GraphType.voltage: return 'V';
      case GraphType.current: return 'A';
      case GraphType.co2: return 'CO₂e';
      default: return '';
    }
  }
  
  String _getSeriesName(int index) { /* ... (เหมือนเดิม) ... */ 
     switch (graphType) {
      case GraphType.power:
        switch (index) {
          case 0: return 'PV Production';
          case 1: return 'Load Consumption';
          case 2: return 'Grid Power';
          case 3: return 'BESS Power';
          default: return '';
        }
      case GraphType.energy:
        switch (index) {
          case 0: return 'PV Production';
          case 1: return 'Consumption';
          case 2: return 'BESS Charge';
          case 3: return 'BESS Discharge';
          default: return '';
        }
      case GraphType.voltage:
        switch (index) {
          case 0: return 'Phase 1';
          case 1: return 'Phase 2';
          case 2: return 'Phase 3';
          default: return '';
        }
      case GraphType.current:
        switch (index) {
          case 0: return 'Phase 1';
          case 1: return 'Phase 2';
          case 2: return 'Phase 3';
          default: return '';
        }
      case GraphType.SoC:
        return 'SoC (%)';

      case GraphType.co2:
        return 'CO₂ Saved';
        default: return '';
        
    }
  }
  
  double? _getValue(Map<String, dynamic> row, String key) { /* ... (เหมือนเดิม) ... */ 
      if (row[key] == null) return null;
    try {
      return double.parse(row[key].toString());
    } catch (e) {
      return null;
    }
  }

  // --- 2. แก้ไข: ปรับ Logic การ Map ข้อมูลลงกราฟ ตาม Period ---
  List<FlSpot> _getPoints(String key) {
    Map<int, double> map = {}; // เปลี่ยน Key เป็น int (Index ของแกน X)
    
    for (var r in historyData) {
      if (r['timestamp'] == null) continue;
      try {
        DateTime dt = DateTime.parse(r['timestamp'].toString());
        int xIndex = 0;
        
        if (selectedPeriod == TimePeriod.daily) {
          // Logic เดิม (แปลงเป็น index 5 นาที)
          int totalMinutes = dt.hour * 60 + dt.minute;
          int roundedTotalMinutes = (totalMinutes ~/ 5) * 5;
          xIndex = roundedTotalMinutes ~/ 5; // Index 0 - 287
        } else if (selectedPeriod == TimePeriod.monthly) {
          // ใช้ "วันที่" เป็น Index (เริ่ม 0 คือวันที่ 1)
          xIndex = dt.day - 1; 
        } else if (selectedPeriod == TimePeriod.yearly) {
          // ใช้ "เดือน" เป็น Index (เริ่ม 0 คือ Jan)
          xIndex = dt.month - 1;
        }

        double? v = _getValue(r, key);
        // ถ้าข้อมูลซ้ำใน Period เดียวกัน (เช่น Monthly แต่อ่านข้อมูลรายชม.) อาจจะต้องหา Avg หรือ Sum
        // แต่เบื้องต้นใช้ค่าล่าสุด หรือค่าแรกที่เจอไปก่อนตาม Logic เดิม
        if (v != null) map[xIndex] = v;
      } catch (e) {}
    }

    List<FlSpot> spots = [];
    // Loop ตามจำนวน Labels (288 หรือ 31 หรือ 12)
    for (int i = 0; i < timeLabels.length; i++) {
      if (map.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), map[i]!));
      }
    }
    return spots;
  }

  double _calculateNiceInterval(double range) { /* ... (เหมือนเดิม) ... */ 
      if (range == 0) return 10;
    double roughInterval = range / 5;
    double magnitude = pow(10, (log(roughInterval) / ln10).floor()).toDouble();
    double normalized = roughInterval / magnitude;
    if (normalized <= 1) return 1 * magnitude;
    if (normalized <= 2) return 2 * magnitude;
    if (normalized <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    List<LineChartBarData> lines = [];

    // --- [ใหม่] Helper function เพื่อเช็คการซ่อน ---
    void addLineIfVisible(int index, String key, Color color) {
      if (!hiddenIndices.contains(index)) {
         // *** สำคัญ: ต้องใส่ชื่อ Key ให้ตรงกับข้อมูลจริงของคุณ ***
        lines.add(_buildLine(_getPoints(key), color));
      }
    }
    // ... (การ add lines เหมือนเดิม) ...
    switch (graphType) {
      case GraphType.power:
        // เดิม: lines.add(_buildLine(_getPoints("EMS_SolarPower_kW"), Palette.lightBlue));
        // ใหม่:
        addLineIfVisible(0, "EMS_SolarPower_kW", Palette.lightBlue);
        addLineIfVisible(1, "EMS_LoadPower_kW", Palette.orange); 
        addLineIfVisible(2, "METER_KW", Palette.red); 
        addLineIfVisible(3, "EMS_BatteryPower_kW", Palette.green);
        break;

      case GraphType.energy:
        addLineIfVisible(0, "EMS_EnergyProducedFromPV_Daily", Colors.blue);
        addLineIfVisible(1, "EMS_EnergyConsumption_Daily", Colors.red);
        addLineIfVisible(2, "BESS_Daily_Charge_Energy", Colors.green);
        addLineIfVisible(3, "BESS_Daily_Discharge_Energy", Colors.orange);
        break;

      case GraphType.voltage:
        addLineIfVisible(0, "METER_V1", Colors.red);
        addLineIfVisible(1, "METER_V2", Colors.yellow);
        addLineIfVisible(2, "METER_V3", Colors.blue);
        break;

      case GraphType.current:
        addLineIfVisible(0, "METER_I1", Colors.red);
        addLineIfVisible(1, "METER_I2", Colors.yellow);
        addLineIfVisible(2, "METER_I3", Colors.blue);
        break;

      case GraphType.SoC:
        addLineIfVisible(0, "BESS_SOC", Colors.green);
        break;

      case GraphType.co2:
        addLineIfVisible(0, "EMS_CO2_Equivalent", Colors.teal);
        break;
    }

    double minY = 0;
    double maxY = 10;
    double interval = 5;
    List<FlSpot> allSpots = lines.expand((line) => line.spots).toList();

    if (allSpots.isNotEmpty) {
      double dataMin = allSpots.map((e) => e.y).reduce(min);
      double dataMax = allSpots.map((e) => e.y).reduce(max);
      if (dataMin > 0) dataMin = 0;
      double range = dataMax - dataMin;
      interval = _calculateNiceInterval(range);
      minY = (dataMin / interval).floor() * interval;
      maxY = (dataMax / interval).ceil() * interval;
      if (minY == maxY) maxY += interval;
    }

    // --- 3. แก้ไข: กำหนด maxX และ X-Interval ตาม Period ---
    double maxX;
    double xInterval;
    
    if (selectedPeriod == TimePeriod.daily) {
      maxX = 288;
      xInterval = 24; // ทุก 2 ชั่วโมง
    } else if (selectedPeriod == TimePeriod.monthly) {
      maxX = 30; // Index 0-30 (31 วัน)
      xInterval = 5; // ทุก 5 วัน
    } else {
      maxX = 11; // Index 0-11 (12 เดือน)
      xInterval = 1; // ทุก 1 เดือน
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 900),
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 10.0), 
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX, // ใช้ค่า Dynamic
            minY: minY,
            maxY: maxY,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    const FlLine(color: Colors.blueGrey, strokeWidth: 1, dashArray: [5, 5]),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: barData.color ?? Colors.blue,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.1),
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(12),
                maxContentWidth: 300,
                tooltipHorizontalOffset: 60, 
                fitInsideHorizontally: true, 
                fitInsideVertically: true,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  touchedBarSpots.sort((a, b) => a.barIndex.compareTo(b.barIndex));
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    final index = flSpot.x.toInt();
                    // ดึง Label ตาม Index
                    final time = (index >= 0 && index < timeLabels.length) ? timeLabels[index] : '';
                    
                    final isFirst = barSpot == touchedBarSpots.first;
                    final name = _getSeriesName(barSpot.barIndex);
                    final lineText = '$name: ${flSpot.y.toStringAsFixed(2)} ${_getUnit()}';

                    if (isFirst) {
                      return LineTooltipItem(
                        '$time\n', // แสดง Label (เวลา/วันที่/เดือน) ตรงหัว Tooltip
                        const TextStyle(
                          color: Color.fromARGB(255, 22, 39, 128),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: lineText,
                            style: TextStyle(color: barSpot.bar.color, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      );
                    } else {
                      return LineTooltipItem(
                        lineText, 
                        TextStyle(color: barSpot.bar.color, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    }
                  }).toList();
                },
            ),
          ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 0.5),
              getDrawingVerticalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 0.5),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50, 
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    if (value % interval != 0 && value != minY && value != maxY) return const SizedBox();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: xInterval, // ใช้ Interval Dynamic
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < timeLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          timeLabels[index],
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
            lineBarsData: lines,
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    final bool showCurved = selectedPeriod == TimePeriod.daily;

    return LineChartBarData(
      spots: spots,
      isCurved: showCurved,
      color: color,
      barWidth: 2,
      dotData: FlDotData(
        show: !showCurved,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3.0,
            color: color,
          );
        },
      ),
      // -------------------------------
      belowBarData: BarAreaData(
        show: true,
        cutOffY: 0,
        applyCutOffY: true,
        color: color.withOpacity(0.1),
      ),
      aboveBarData: BarAreaData(
        show: true,
        cutOffY: 0,
        applyCutOffY: true,
        color: color.withOpacity(0.1),
      ),
    );
  }
}