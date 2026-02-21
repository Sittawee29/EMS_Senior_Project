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
  // 1. ฟังก์ชันเช็คว่า "มีข้อมูลให้เลือกหรือไม่"
  bool _hasData(DateTime day) {
    // สมมติว่าตอนนี้เช็คจาก _minDataDate และ _maxDataDate
    // (ถ้าในอนาคตคุณมี List วันที่ที่มีข้อมูลจาก Database สามารถนำมาเช็คตรงนี้ได้เลย)
    if (_minDataDate == null || _maxDataDate == null) return true;
    
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    DateTime minOnly = DateTime(_minDataDate!.year, _minDataDate!.month, _minDataDate!.day);
    DateTime maxOnly = DateTime(_maxDataDate!.year, _maxDataDate!.month, _maxDataDate!.day);
    
    return dateOnly.compareTo(minOnly) >= 0 && dateOnly.compareTo(maxOnly) <= 0;
  }

  // 2. ฟังก์ชันแปลชื่อเดือนเป็นภาษาไทย/อังกฤษ ให้ดูสวยงาม
  String _getMonthName(int month) {
    const months = ["", "January", "February", "March", "April", "May", "June", 
                    "July", "August", "September", "October", "November", "December"];
    return months[month];
  }

  // 3. ฟังก์ชันสร้าง Custom Calendar ตัวใหม่
  Future<void> _showCustomCalendar() async {
    // ใช้ viewMonth เพื่อให้เลื่อนดูเดือนอื่นได้โดยที่กราฟยังไม่เปลี่ยน
    DateTime viewMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    const List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // คำนวณวันในเดือน
            DateTime firstDay = DateTime(viewMonth.year, viewMonth.month, 1);
            DateTime lastDay = DateTime(viewMonth.year, viewMonth.month + 1, 0);
            int daysInMonth = lastDay.day;
            int firstWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday; // ให้ Sunday = 0

            // ดึงรายการวันหยุดเฉพาะของเดือนที่กำลังดูอยู่
            String viewMonthStr = "${viewMonth.year}-${viewMonth.month.toString().padLeft(2, '0')}";
            List<String> holidaysInThisMonth = _holidayDates.where((date) => date.startsWith(viewMonthStr)).toList();

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ให้กล่องยืดตามเนื้อหา
                  children: [
                    // --- ส่วนหัว (เลือกเดือน/ปี) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() {
                              viewMonth = DateTime(viewMonth.year, viewMonth.month - 1, 1);
                            });
                            // สามารถเรียก API วันหยุดล่วงหน้าได้ถ้าข้ามปี
                          },
                        ),
                        Text(
                          "${_getMonthName(viewMonth.month)} ${viewMonth.year}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setDialogState(() {
                              viewMonth = DateTime(viewMonth.year, viewMonth.month + 1, 1);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- ส่วนหัวตารางวัน (Su, Mo, Tu...) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekdays.map((w) => SizedBox(
                        width: 30,
                        child: Text(w, textAlign: TextAlign.center, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: (w == 'Sun' || w == 'Sat') ? Colors.red : Colors.grey[700]
                          )),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),

                    // --- ส่วนตารางวันที่ ---
                    GridView.builder(
                      shrinkWrap: true, // สำคัญ! เพื่อไม่ให้ GridView ทะลุ Dialog
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: daysInMonth + firstWeekday,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday) return const SizedBox();

                        int dayNum = index - firstWeekday + 1;
                        DateTime dayDate = DateTime(viewMonth.year, viewMonth.month, dayNum);
                        
                        bool isRed = _isRedDay(dayDate);
                        bool hasData = _hasData(dayDate); // มีข้อมูลให้เลือกไหม?
                        bool isSelected = dayDate.year == _currentDate.year && 
                                          dayDate.month == _currentDate.month && 
                                          dayDate.day == _currentDate.day;

                        Color textColor;
                        if (isSelected) {
                          textColor = Colors.white; // สีขาวถ้าถูกเลือกอยู่
                        } else if (isRed) {
                          // วันหยุด: ถ้ามีข้อมูลเป็นแดงเข้ม ถ้าไม่มีเป็นแดงอ่อน
                          textColor = hasData ? Colors.red : Colors.red.shade300; 
                        } else {
                          // วันปกติ: ถ้ามีข้อมูลเป็นดำ ถ้าไม่มีเป็นเทาอ่อน
                          textColor = hasData ? Colors.black : Colors.grey.shade700;
                        }

                        return InkWell(
                          onTap: hasData ? () {
                            setState(() { _currentDate = dayDate; });
                            _loadData();
                            Navigator.pop(context);
                          } : null,
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : null,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected ? null : Border.all(color: Colors.transparent),
                            ),
                            child: Text(
                              "$dayNum",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: (isRed || isSelected) ? FontWeight.bold : FontWeight.normal,
                                // เอาเส้นขีดฆ่าออกแล้ว
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Divider(height: 20, thickness: 1),

                    // --- ส่วน List แสดงวันหยุดด้านล่าง ---
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("วันหยุดในเดือนนี้:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 5),
                          holidaysInThisMonth.isEmpty 
                            ? const Text("- ไม่มีวันหยุดพิเศษ -", style: TextStyle(color: Colors.grey, fontSize: 12))
                            : ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 100), // จำกัดความสูงของ List
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: holidaysInThisMonth.length,
                                  itemBuilder: (context, idx) {
                                    String hDateStr = holidaysInThisMonth[idx];
                                    int dNum = int.parse(hDateStr.split('-')[2]);
                                    
                                    // --- ดึงชื่อวันหยุดจาก Map ที่เราเตรียมไว้ ---
                                    String hName = _holidayDetails[hDateStr] ?? 'วันหยุดพิเศษ';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start, // ดันไอคอนให้อยู่บรรทัดบนสุดเผื่อชื่อยาว
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5.0),
                                            child: Icon(Icons.circle, size: 6, color: Colors.red),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "วันที่ $dNum: $hName", // แสดงรูปแบบ "วันที่ 13: วันสงกรานต์"
                                              style: const TextStyle(fontSize: 13, color: Colors.red)
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
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
        int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
        
        return List.generate(daysInMonth, (index) => (index + 1).toString());
      case TimePeriod.yearly:
        // ชื่อเดือนย่อ
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
  }
  List<String> _holidayDates = [];
  Map<String, String> _holidayDetails = {};
  @override
  void initState() {
    super.initState();
    _fetchDataRange(); // 1. หาขอบเขตข้อมูลก่อน
    _loadData();       // 2. โหลดข้อมูลกราฟ
    _fetchHolidays();
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

  Future<void> _showMonthPicker(BuildContext context) async {
    final DateTime firstDate = _minDataDate ?? DateTime(2020);
    final DateTime lastDate = _maxDataDate ?? DateTime.now();
    

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
      bool isYearChanged = _currentDate.year != picked.year;

      setState(() {
        _currentDate = picked;
      });
      
      _loadData();
      
      if (isYearChanged) {
        _fetchHolidays();
      }
    }
  }

  Future<void> _fetchHolidays() async {
    final year = _currentDate.year.toString();
    final url = Uri.parse('http://$serverIp:$serverPort/api/holidays/$year');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _holidayDates = List<String>.from(data['holidays']);
            if (data['holiday_details'] != null) {
              _holidayDetails = Map<String, String>.from(data['holiday_details']);
            }
          });
          print("Holidays loaded: $_holidayDates");
        }
      }
    } catch (e) {
      print("Error fetching holidays: $e");
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
                      onTap: _showCustomCalendar, // ย้ายคำสั่งกดมาไว้ตรงนี้ (ครอบทั้งปุ่ม)
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
            : _ChartDisplay( // <--- เปลี่ยนจาก _LineChart เป็น _ChartDisplay
                timeLabels: _currentLabels,
                historyData: _historyData,
                graphType: _selectedType,
                selectedPeriod: _selectedPeriod,
                hiddenIndices: _hiddenIndices,
                holidayDates: _holidayDates,
                currentDate: _currentDate,
                
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

  bool _isRedDay(DateTime day) {
  // 1. เช็ควันเสาร์-อาทิตย์ (6 = Saturday, 7 = Sunday)
  if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
    return true;
  }
  // 2. เช็คจากรายการวันหยุด API (รูปแบบ YYYY-MM-DD)
  String formatted = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
  return _holidayDates.contains(formatted);
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

class _ChartDisplay extends StatefulWidget {
  final List<String> timeLabels;
  final List<Map<String, dynamic>> historyData;
  final GraphType graphType;
  final TimePeriod selectedPeriod;
  final Set<int> hiddenIndices;
  final List<String> holidayDates;
  final DateTime currentDate;

  const _ChartDisplay({
    required this.timeLabels,
    required this.historyData,
    required this.graphType,
    required this.selectedPeriod,
    required this.hiddenIndices,
    required this.holidayDates,
    required this.currentDate,
  });

  @override
  State<_ChartDisplay> createState() => _ChartDisplayState();
}

class _ChartDisplayState extends State<_ChartDisplay> {
  int _touchedIndex = -1; // เก็บตำแหน่งที่แตะสำหรับกราฟแท่ง

  // --- Helpers ---
  String _getUnit() {
    switch (widget.graphType) {
      case GraphType.power: return 'kW';
      case GraphType.energy: return 'kWh';
      case GraphType.voltage: return 'V';
      case GraphType.current: return 'A';
      case GraphType.co2: return 'CO₂e';
      default: return '';
    }
  }

  String _getSeriesName(int index) {
    switch (widget.graphType) {
      case GraphType.power:
        return ['PV Production', 'Load Consumption', 'Grid Power', 'BESS Power'][index];
      case GraphType.energy:
        return ['PV Production', 'Consumption', 'BESS Charge', 'BESS Discharge'][index];
      case GraphType.voltage:
        return ['Phase 1', 'Phase 2', 'Phase 3'][index];
      case GraphType.current:
        return ['Phase 1', 'Phase 2', 'Phase 3'][index];
      case GraphType.SoC: return 'SoC (%)';
      case GraphType.co2: return 'CO₂ Saved';
      default: return '';
    }
  }

  List<_SeriesSpec> _getSeriesSpecs() {
    List<_SeriesSpec> specs = [];
    void add(int idx, String key, Color color) {
      if (!widget.hiddenIndices.contains(idx)) {
        specs.add(_SeriesSpec(idx, key, color));
      }
    }

    switch (widget.graphType) {
      case GraphType.power:
        add(0, "EMS_SolarPower_kW", Palette.lightBlue);
        add(1, "EMS_LoadPower_kW", Palette.orange);
        add(2, "METER_KW", Palette.red);
        add(3, "EMS_BatteryPower_kW", Palette.green);
        break;
      case GraphType.energy:
        add(0, "EMS_EnergyProducedFromPV_Daily", Colors.blue);
        add(1, "EMS_EnergyConsumption_Daily", Colors.red);
        add(2, "BESS_Daily_Charge_Energy", Colors.green);
        add(3, "BESS_Daily_Discharge_Energy", Colors.orange);
        break;
      case GraphType.voltage:
        add(0, "METER_V1", Colors.red);
        add(1, "METER_V2", Colors.yellow);
        add(2, "METER_V3", Colors.blue);
        break;
      case GraphType.current:
        add(0, "METER_I1", Colors.red);
        add(1, "METER_I2", Colors.yellow);
        add(2, "METER_I3", Colors.blue);
        break;
      case GraphType.SoC:
        add(0, "BESS_SOC", Colors.green);
        break;
      case GraphType.co2:
        add(0, "EMS_CO2_Equivalent", Colors.teal);
        break;
    }
    return specs;
  }

  double? _getValue(Map<String, dynamic> row, String key) {
    if (row[key] == null) return null;
    try { return double.parse(row[key].toString()); } catch (e) { return null; }
  }

  List<FlSpot> _getPoints(String key) {
    Map<int, double> map = {};
    for (var r in widget.historyData) {
      if (r['timestamp'] == null) continue;
      try {
        DateTime dt = DateTime.parse(r['timestamp'].toString());
        int xIndex = 0;
        if (widget.selectedPeriod == TimePeriod.daily) {
          int totalMinutes = dt.hour * 60 + dt.minute;
          xIndex = totalMinutes ~/ 5;
        } else if (widget.selectedPeriod == TimePeriod.monthly) {
          xIndex = dt.day - 1;
        } else {
          xIndex = dt.month - 1;
        }
        double? v = _getValue(r, key);
        if (v != null) map[xIndex] = v;
      } catch (e) {}
    }

    List<FlSpot> spots = [];
    int maxPoints = widget.selectedPeriod == TimePeriod.daily ? 288 : (widget.selectedPeriod == TimePeriod.monthly ? 31 : 12);
    for (int i = 0; i < maxPoints; i++) {
      if (map.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), map[i]!));
      } else if (widget.selectedPeriod != TimePeriod.daily) {
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }
    return spots;
  }

  double _calculateNiceInterval(double range) {
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
    List<_SeriesSpec> specs = _getSeriesSpecs();
    
    // คำนวณ Scale
    List<FlSpot> allPoints = [];
    Map<int, List<FlSpot>> seriesDataMap = {};
    for (var s in specs) {
      var points = _getPoints(s.key);
      seriesDataMap[s.index] = points;
      allPoints.addAll(points);
    }

    double minY = 0;
    double maxY = 10;
    double interval = 5;
    if (allPoints.isNotEmpty) {
      double dataMin = allPoints.map((e) => e.y).reduce(min);
      double dataMax = allPoints.map((e) => e.y).reduce(max);
      
      double minBound = (dataMin < 0) ? dataMin : 0;
      double range = dataMax - minBound;
      interval = _calculateNiceInterval(range);
      
      minY = (minBound / interval).floor() * interval;
      maxY = (dataMax / interval).ceil() * interval;
      if (minY == maxY) maxY += interval;
    }

    double maxX;
    double xInterval;
    if (widget.selectedPeriod == TimePeriod.daily) {
      maxX = 288;
      xInterval = 24;
    } else if (widget.selectedPeriod == TimePeriod.monthly) {
      maxX = 31;
      xInterval = 5;
    } else {
      maxX = 12;
      xInterval = 1;
    }

    if (widget.selectedPeriod == TimePeriod.daily) {
      return _buildLineChart(specs, seriesDataMap, minY, maxY, interval, maxX, xInterval);
    } else {
      return _buildBarChart(specs, seriesDataMap, minY, maxY, interval, maxX, xInterval);
    }
  }

  // --- 1. กราฟเส้น (Daily) ---
  Widget _buildLineChart(
    List<_SeriesSpec> specs,
    Map<int, List<FlSpot>> seriesDataMap,
    double minY, double maxY, double interval,
    double maxX, double xInterval
  ) {
    List<LineChartBarData> lines = specs.map((s) {
      return LineChartBarData(
        spots: seriesDataMap[s.index] ?? [],
        isCurved: true,
        color: s.color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, cutOffY: 0, applyCutOffY: true, color: s.color.withOpacity(0.1)),
        aboveBarData: BarAreaData(show: true, cutOffY: 0, applyCutOffY: true, color: s.color.withOpacity(0.1)),
      );
    }).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 900),
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 10.0),
        child: LineChart(
          LineChartData(
            minX: 0, maxX: (widget.timeLabels.length - 1).toDouble(),
            clipData: const FlClipData.all(),
            minY: minY, maxY: maxY,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    const FlLine(color: Colors.blueGrey, strokeWidth: 1, dashArray: [5, 5]),
                    FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: barData.color ?? Colors.blue)),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.1),
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(12),
                maxContentWidth: 300,
                tooltipHorizontalOffset: 60,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (touchedSpots) {
                  touchedSpots.sort((a, b) => a.barIndex.compareTo(b.barIndex));
                  return touchedSpots.map((barSpot) {
                    final flSpot = barSpot;
                    final spec = specs.firstWhere((s) => s.color == barSpot.bar.color, orElse: () => specs[0]);
                    final index = flSpot.x.toInt();
                    final time = (index >= 0 && index < widget.timeLabels.length) ? widget.timeLabels[index] : '';
                    final lineText = '${_getSeriesName(spec.index)}: ${flSpot.y.toStringAsFixed(2)} ${_getUnit()}';
                    
                    if (barSpot == touchedSpots.first) {
                      return LineTooltipItem(
                        '$time\n',
                        const TextStyle(color: Color.fromARGB(255, 22, 39, 128), fontWeight: FontWeight.bold, fontSize: 14),
                        children: [TextSpan(text: lineText, style: TextStyle(color: spec.color, fontWeight: FontWeight.bold, fontSize: 12))],
                      );
                    }
                    return LineTooltipItem(lineText, TextStyle(color: spec.color, fontWeight: FontWeight.bold, fontSize: 12));
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true, horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 0.5),
              getDrawingVerticalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 0.5),
            ),
            titlesData: _buildTitles(interval, xInterval),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
            lineBarsData: lines,
          ),
        ),
      ),
    );
  }

  // --- 2. กราฟแท่ง (Monthly/Yearly) ---
  Widget _buildBarChart(
    List<_SeriesSpec> specs,
    Map<int, List<FlSpot>> seriesDataMap,
    double minY, double maxY, double interval,
    double maxX, double xInterval
  ) {
    List<BarChartGroupData> barGroups = [];
    int xCount = widget.selectedPeriod == TimePeriod.monthly ? 31 : 12;
    double barWidth = 12.0 / (specs.isEmpty ? 1 : specs.length);
    if (barWidth > 16) barWidth = 16;

    for (int x = 0; x < xCount; x++) {
      List<BarChartRodData> rods = [];
      for (var spec in specs) {
        final spots = seriesDataMap[spec.index] ?? [];
        final spot = spots.firstWhere((element) => element.x.toInt() == x, orElse: () => FlSpot(x.toDouble(), 0));
        rods.add(
          BarChartRodData(
            toY: spot.y, color: spec.color, width: barWidth,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          ),
        );
      }
      barGroups.add(BarChartGroupData(x: x, barRods: rods, barsSpace: 4));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 900),
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 10.0),
        child: BarChart(
          BarChartData(
            maxY: maxY, minY: minY,
            // [คงเดิม] เส้นประแนวตั้งเหมือน LineChart
            extraLinesData: ExtraLinesData(
              verticalLines: [
                if (_touchedIndex != -1)
                  VerticalLine(
                    x: _touchedIndex.toDouble(),
                    color: Colors.blueGrey,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
              ],
            ),
            barTouchData: BarTouchData(
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                });
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.blueGrey.withOpacity(0.1),
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(12),
                maxContentWidth: 300,
                tooltipMargin: 8,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final spec = specs[rodIndex];
                  final timeLabel = (group.x >= 0 && group.x < widget.timeLabels.length) ? widget.timeLabels[group.x] : '';
                  
                  // [แก้ไขใหม่] แสดง Header (วันที่/เดือน) ใน *ทุกค่า* (ทุก Rod)
                  // โดยไม่ต้องเช็ค if (rodIndex == 0) แล้ว
                  return BarTooltipItem(
                    '$timeLabel\n',
                    const TextStyle(color: Color.fromARGB(255, 22, 39, 128), fontWeight: FontWeight.bold, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${_getSeriesName(spec.index)}: ${rod.toY.toStringAsFixed(2)} ${_getUnit()}',
                        style: TextStyle(color: spec.color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: _buildTitles(interval, xInterval),
            gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => const FlLine(color: Palette.mediumGrey40, strokeWidth: 0.5),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  FlTitlesData _buildTitles(double yInterval, double xInterval) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, reservedSize: 50, interval: yInterval,
          getTitlesWidget: (value, meta) {
             if (value % yInterval != 0 && value != 0) return const SizedBox();
             return SideTitleWidget(
               axisSide: meta.axisSide, space: 4,
               child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
             );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, reservedSize: 32, interval: xInterval,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < widget.timeLabels.length) {
              String currentLabel = widget.timeLabels[index];
              bool isHoliday = false;

              // --- แปลงป้ายกำกับเป็นวันที่ YYYY-MM-DD เพื่อไปเช็คกับวันหยุด ---
              if (widget.selectedPeriod == TimePeriod.monthly) {
                int dayInt = int.tryParse(currentLabel) ?? 0;
                if (dayInt > 0) {
                  DateTime dayDate = DateTime(widget.currentDate.year, widget.currentDate.month, dayInt);
                  
                  // เช็คทั้งวันหยุดจาก API และ เสาร์-อาทิตย์
                  bool isWeekend = dayDate.weekday == DateTime.saturday || dayDate.weekday == DateTime.sunday;
                  String fullStr = "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
                  
                  isHoliday = isWeekend || widget.holidayDates.contains(fullStr);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  currentLabel, 
                  style: TextStyle(
                    fontSize: 10, 
                    // ถ้าเป็นวันหยุดให้แดง ถ้าไม่ใช่ให้เทา
                    color: isHoliday ? Colors.red : Colors.grey,
                    fontWeight: isHoliday ? FontWeight.bold : FontWeight.normal,
                  )
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}

class _SeriesSpec {
  final int index;
  final String key;
  final Color color;
  _SeriesSpec(this.index, this.key, this.color);
}