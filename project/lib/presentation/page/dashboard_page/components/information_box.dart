part of '../page.dart';

class _InformationBox extends StatelessWidget {
  const _InformationBox({
    required this.icon,
    required this.backgroundColor,
    required this.number,
    required this.text,
    this.unit = '',
    this.showPercent = false,
  });

  final Widget icon;
  final Color backgroundColor;
  final double number;
  final bool showPercent;
  final String text;
  final String unit;

  String _formatNumber(double number) {
    String formatted;
    if (number.abs() >= 1000000000) {
      formatted = NumberFormat.compact().format(number);
    } else {
      //formatted = NumberFormat.decimalPattern().format(number).replaceAll(',', ' ');
      formatted = NumberFormat('#,##0.00').format(number);
    }
    if (unit.isNotEmpty) {
      formatted = '$formatted $unit';
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,//268
      height: 172,
      padding: const EdgeInsets.only(top: 22, bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: backgroundColor,
            child: icon,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                showPercent ? '$number%' : _formatNumber(number),
                style: TextStyles.myriadProSemiBold24Dark,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(text, style: TextStyles.myriadProRegular16DarkGrey),
        ],
      ),
    );
  }
}

class _CalendarBox extends StatefulWidget {
  const _CalendarBox({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.holidayDates = const [],     
    this.holidayDetails = const {},   
  }) : super(key: key);

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<String> holidayDates;
  final Map<String, String> holidayDetails;

  @override
  State<_CalendarBox> createState() => _CalendarBoxState();
}

class _CalendarBoxState extends State<_CalendarBox> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _startDailyCheckTimer();
  }

  void _startDailyCheckTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _selectedDate.day || now.month != _selectedDate.month || now.year != _selectedDate.year) {
        setState(() {
          _selectedDate = now;
          _viewMonth = DateTime(now.year, now.month, 1);
        }); 
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  bool _isRedDay(DateTime day) {
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return true;
    }
    String formatted = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return widget.holidayDates.contains(formatted);
  }

  @override
  Widget build(BuildContext context) {
    const List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    DateTime firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    DateTime lastDay = DateTime(_viewMonth.year, _viewMonth.month + 1, 0);
    int daysInMonth = lastDay.day;
    int firstWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    String viewMonthStr = "${_viewMonth.year}-${_viewMonth.month.toString().padLeft(2, '0')}";
    List<String> holidaysInThisMonth = widget.holidayDates.where((date) => date.startsWith(viewMonthStr)).toList();

    return Container(
      width: 606,  // กว้าง 606 ตามกำหนด
      height: 366, // สูง 366 ตามกำหนด
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getDayName(_selectedDate.weekday)} ${_selectedDate.day}",
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFFF44336) 
                  ),
                ),
                // แสดงเดือนและปีเล็กๆ ด้านล่าง
                Text(
                  "${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "วันหยุดในเดือนนี้:", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: holidaysInThisMonth.isEmpty
                      ? Text(
                          "- ไม่มีวันหยุดพิเศษ -", 
                          style: TextStyle(color: Colors.grey[400], fontSize: 14)
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: holidaysInThisMonth.length,
                          itemBuilder: (context, idx) {
                            String hDateStr = holidaysInThisMonth[idx];
                            int dNum = int.parse(hDateStr.split('-')[2]);
                            String hName = widget.holidayDetails[hDateStr] ?? 'วันหยุดพิเศษ';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6.0),
                                    child: Icon(Icons.circle, size: 6, color: Color(0xFFF44336)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "วันที่ $dNum: $hName",
                                      style: const TextStyle(fontSize: 14, color: Color(0xFFF44336)),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                      ),
                    ),
                    Text(
                      "${_getMonthName(_viewMonth.month)} ${_viewMonth.year}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekdays.map((w) => SizedBox(
                    width: 32,
                    child: Text(
                      w, 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: (w == 'Sun' || w == 'Sat') ? const Color(0xFFF44336) : Colors.grey[700]
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: daysInMonth + firstWeekday,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday) return const SizedBox();

                      int dayNum = index - firstWeekday + 1;
                      DateTime dayDate = DateTime(_viewMonth.year, _viewMonth.month, dayNum);

                      bool isRed = _isRedDay(dayDate);
                      bool isSelected = dayDate.year == _selectedDate.year &&
                                        dayDate.month == _selectedDate.month &&
                                        dayDate.day == _selectedDate.day;

                      return Container( // เปลี่ยนจาก InkWell เป็น Container
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0x809E9E9E) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$dayNum",
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isRed ? const Color(0xFFF44336) : Colors.grey[800]),
                            fontWeight: (isRed || isSelected) ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
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
    );
  }
}

// แปลงจาก StatelessWidget เป็น StatefulWidget
class _TodayStatusBox extends StatefulWidget {
  const _TodayStatusBox({
    Key? key,
    required this.currentDate,
    required this.holidayDates,
    required this.holidayDetails,
  }) : super(key: key);

  final DateTime currentDate;
  final List<String> holidayDates;
  final Map<String, String> holidayDetails;

  @override
  State<_TodayStatusBox> createState() => _TodayStatusBoxState();
}

class _TodayStatusBoxState extends State<_TodayStatusBox> {
  late DateTime _currentDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.currentDate;
    _startDailyCheckTimer();
  }

  void _startDailyCheckTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _currentDate.day || now.month != _currentDate.month || now.year != _currentDate.year) {
        setState(() {
          _currentDate = now; // อัพเดทค่า state ใหม่
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // เปลี่ยนมาใช้ _currentDate แทน widget.currentDate ตรงนี้
    String formattedDate = "${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}";

    bool isWeekend = _currentDate.weekday == DateTime.saturday || _currentDate.weekday == DateTime.sunday;
    bool isApiHoliday = widget.holidayDates.contains(formattedDate);

    String statusText;
    String detailText;
    Color iconColor;
    Color bgColor;
    IconData iconData;

    if (isApiHoliday) {
      statusText = 'Holiday';
      detailText = widget.holidayDetails[formattedDate] ?? 'วันหยุดพิเศษ';
      iconColor = const Color(0xFFF44336);
      bgColor = const Color(0xFFF44336).withOpacity(0.1);
      iconData = Icons.celebration;
    } else if (isWeekend) {
      statusText = 'Weekend';
      detailText = 'วันหยุดสุดสัปดาห์';
      iconColor = const Color(0xFFFF9800);
      bgColor = const Color(0xFFFF9800).withOpacity(0.1);
      iconData = Icons.weekend;
    } else {
      statusText = 'Workday';
      detailText = 'วันทำงานปกติ';
      iconColor = const Color(0xFF4CAF50);
      bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
      iconData = Icons.work;
    }

    // โค้ดส่วน Container ด้านล่างคงเดิม
    return Container(
      width: 292,
      height: 172,
      padding: const EdgeInsets.only(top: 22, bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: bgColor,
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                statusText,
                style: TextStyles.myriadProSemiBold24Dark,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Tooltip(
                  message: detailText, 
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    detailText, 
                    style: TextStyles.myriadProRegular16DarkGrey.copyWith(
                      fontSize: 13, 
                      height: 1.2,
                    ), 
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}