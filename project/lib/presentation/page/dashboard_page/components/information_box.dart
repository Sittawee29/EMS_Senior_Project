part of '../page.dart';

class _InformationBox extends StatelessWidget {
  const _InformationBox({
    required this.icon,
    required this.backgroundColor,
    required this.number,
    required this.text,
    this.unit = '',
    // ignore: unused_element_parameter
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

// ==========================================
// คลาสปฏิทิน (อัปเดต UI ให้ตรงกับรูปภาพ)
// ==========================================
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  String _getMonthName(int month) {
    const months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }

  // --- เพิ่มฟังก์ชันหาชื่อวันในสัปดาห์ ---
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
      // --- เปลี่ยนเป็น Row เพื่อแบ่ง 2 คอลัมน์ ซ้าย-ขวา ---
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ==========================================
          // คอลัมน์ที่ 1 (ซ้าย) : โชว์วันที่เลือก และ วันหยุด
          // ==========================================
          Expanded(
            flex: 4, // อัตราส่วนพื้นที่ฝั่งซ้าย
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงชื่อวันและวันที่ (เช่น Monday 23)
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
                
                // รายการวันหยุด
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

                // --- ตารางวันที่ ---
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

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = dayDate;
                          });
                          widget.onDateSelected(dayDate);
                        },
                        child: Container(
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