part of '../../page.dart';

// Enum สำหรับประเภทกราฟ
enum GraphType { power, energy, voltage, current, co2 }

class HCurve extends StatefulWidget {
  const HCurve({super.key});

  @override
  State<HCurve> createState() => _HCurveState();
}

class _HCurveState extends State<HCurve> {
  GraphType _selectedType = GraphType.power;
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  // สร้าง Time Slots 00:00 - 23:55 (288 ช่อง)
  final List<String> _timeLabels = List.generate(288, (index) {
    final int totalMinutes = index * 5;
    final int h = totalMinutes ~/ 60;
    final int m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  });

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh ทุก 5 นาที
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await MqttService().fetchHistoryData();
    
    // --- เพิ่มส่วน Debug ---
    print("Fetched History Data: ${data.length} rows");
    if (data.isNotEmpty) {
      print("First Row Keys: ${data.first.keys.toList()}"); // ดูว่ามี Key อะไรบ้าง
      print("First Row Sample: ${data.first}");
    }
    // ---------------------

    if (mounted) {
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันเปลี่ยน Tab
  void _onTypeChanged(GraphType type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 32.0, right: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Curve (24H)', style: TextStyles.myriadProSemiBold22DarkBlue),
              _buildTypeSelector(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 2. ตัวกราฟ
        _isLoading
            ? const SizedBox(
                height: 300, 
                child: Center(child: CircularProgressIndicator())
              )
            : _LineChart(
                timeLabels: _timeLabels,
                historyData: _historyData,
                graphType: _selectedType,
              ),

        const SizedBox(height: 20),
        
        // 3. Legend (คำอธิบายสี)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _typeBtn("Power (kW)", GraphType.power),
          _typeBtn("Energy (kWh)", GraphType.energy),
          _typeBtn("Voltage (V)", GraphType.voltage),
          _typeBtn("Current (I)", GraphType.current),
          _typeBtn("CO₂", GraphType.co2),
        ],
      ),
    );
  }

  Widget _typeBtn(String text, GraphType type) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Palette.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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

  Widget _buildLegend() {
    List<Widget> items = [];
    switch (_selectedType) {
      case GraphType.power:
        items = [
          const NameAndColorRow(color: Palette.lightBlue, text: 'PV Production'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Palette.orange, text: 'Load Consumption'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Palette.red, text: 'Grid Power'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Palette.green, text: 'BESS Power'),
        ];
        break;
      case GraphType.energy:
        items = [
          const NameAndColorRow(color: Colors.blue, text: 'PV Production'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.red, text: 'Consumption'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.green, text: 'BESS Charge'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.orange, text: 'BESS Discharge'),
        ];
        break;
      case GraphType.voltage:
        items = [
          const NameAndColorRow(color: Colors.red, text: 'Phase 1'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.yellow, text: 'Phase 2'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.blue, text: 'Phase 3'),
        ];
        break;
      case GraphType.current:
        items = [
          const NameAndColorRow(color: Colors.red, text: 'Phase 1'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.yellow, text: 'Phase 2'),
          const SizedBox(width: 20),
          const NameAndColorRow(color: Colors.blue, text: 'Phase 3'),
        ];
        break;
      case GraphType.co2:
        items = [
          const NameAndColorRow(color: Colors.teal, text: 'CO₂ Saved'),
        ];
        break;
    }
    return Row(children: items);
  }
}

class _LineChart extends StatelessWidget {
  final List<String> timeLabels;
  final List<Map<String, dynamic>> historyData;
  final GraphType graphType;

  String _getUnit() {
    switch (graphType) {
      case GraphType.power: return 'kW';
      case GraphType.energy: return 'kWh';
      case GraphType.voltage: return 'V';
      case GraphType.current: return 'A';
      case GraphType.co2: return 'CO₂e';
      default: return '';
    }
  }

  String _getSeriesName(int index) {
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
      case GraphType.co2:
        return 'CO₂ Saved';
      default:
        return '';
    }
  }

  const _LineChart({
    required this.timeLabels,
    required this.historyData,
    required this.graphType,
  });

  double? _getValue(Map<String, dynamic> row, String key) {
    if (row[key] == null) return null;
    try {
      return double.parse(row[key].toString());
    } catch (e) {
      return null;
    }
  }

  List<FlSpot> _getPoints(String key) {
    Map<String, double> map = {};
    for (var r in historyData) {
      if (r['timestamp'] == null) continue;
      try {
        DateTime dt = DateTime.parse(r['timestamp'].toString());
        int totalMinutes = dt.hour * 60 + dt.minute;
        int roundedTotalMinutes = (totalMinutes ~/ 5) * 5;
        int h = roundedTotalMinutes ~/ 60;
        int m = roundedTotalMinutes % 60;
        String timeKey = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        double? v = _getValue(r, key);
        if (v != null) map[timeKey] = v;
      } catch (e) {}
    }
    List<FlSpot> spots = [];
    for (int i = 0; i < timeLabels.length; i++) {
      if (map.containsKey(timeLabels[i])) {
        spots.add(FlSpot(i.toDouble(), map[timeLabels[i]]!));
      }
    }
    return spots;
  }

  double _calculateNiceInterval(double range) {
    if (range == 0) return 10; // กรณีไม่มีข้อมูล หรือค่าเท่ากันหมด
    
    // อยากได้เส้น Grid ประมาณ 5-6 เส้น
    double roughInterval = range / 5;
    
    // หา Magnitude (หลักหน่วย, สิบ, ร้อย...)
    double magnitude = pow(10, (log(roughInterval) / ln10).floor()).toDouble();
    double normalized = roughInterval / magnitude;

    // ปัดให้ลงล็อค 1, 2, 5, 10
    if (normalized <= 1) return 1 * magnitude;
    if (normalized <= 2) return 2 * magnitude;
    if (normalized <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    List<LineChartBarData> lines = [];

    // switch case คงเดิม
    switch (graphType) {
      case GraphType.power:
        lines.add(_buildLine(_getPoints("EMS_SolarPower_kW"), Palette.lightBlue));
        lines.add(_buildLine(_getPoints("EMS_LoadPower_kW"), Palette.orange)); 
        lines.add(_buildLine(_getPoints("METER_KW"), Palette.red)); 
        lines.add(_buildLine(_getPoints("EMS_BatteryPower_kW"), Palette.green));
        break;
      case GraphType.energy:
        lines.add(_buildLine(_getPoints("EMS_EnergyProducedFromPV_Daily"), Colors.blue));
        lines.add(_buildLine(_getPoints("EMS_EnergyConsumption_Daily"), Colors.red));
        lines.add(_buildLine(_getPoints("BESS_Daily_Charge_Energy"), Colors.green));
        lines.add(_buildLine(_getPoints("BESS_Daily_Discharge_Energy"), Colors.orange));
        break;
      case GraphType.voltage:
        lines.add(_buildLine(_getPoints("METER_V1"), Colors.red));
        lines.add(_buildLine(_getPoints("METER_V2"), Colors.yellow));
        lines.add(_buildLine(_getPoints("METER_V3"), Colors.blue));
        break;
      case GraphType.current:
        lines.add(_buildLine(_getPoints("METER_I1"), Colors.red));
        lines.add(_buildLine(_getPoints("METER_I2"), Colors.yellow));
        lines.add(_buildLine(_getPoints("METER_I3"), Colors.blue));
        break;
      case GraphType.co2:
        lines.add(_buildLine(_getPoints("EMS_CO2_Equivalent"), Colors.teal));
        break;
    }

    double minY = 0;
    double maxY = 10; // Default
    double interval = 5;
    List<FlSpot> allSpots = lines.expand((line) => line.spots).toList();

    if (allSpots.isNotEmpty) {
      double dataMin = allSpots.map((e) => e.y).reduce(min);
      double dataMax = allSpots.map((e) => e.y).reduce(max);

      // ถ้าค่าต่ำสุดมากกว่า 0 ให้เริ่มที่ 0 เสมอ (เพื่อความสวยงามของกราฟ Power)
      // แต่ถ้ามีค่าติดลบ (เช่น BESS Charge) ก็ให้ใช้ค่าจริง
      if (dataMin > 0) dataMin = 0;

      // เผื่อระยะหัวท้ายเล็กน้อย (Padding)
      double range = dataMax - dataMin;
      interval = _calculateNiceInterval(range); // หา interval ที่ลงตัว

      // ปรับ Min/Max ให้ลงล็อคกับ Interval
      minY = (dataMin / interval).floor() * interval;
      maxY = (dataMax / interval).ceil() * interval;
      
      // กรณีค่า Min กับ Max เท่ากัน (เช่นกราฟเส้นตรง) ให้ถ่างออก
      if (minY == maxY) {
        maxY += interval;
      }
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 900),
      // --- จุดแก้ไขสำคัญ ---
      child: Padding(
        // เปลี่ยนจาก 10 เป็น 32 (เพื่อให้ตรงกับ Header และมีที่เหลือเฟือ)
        // และเพิ่ม padding ขวา 32 ด้วยเพื่อความสมดุล
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 10.0), 
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 288,
            minY: minY,  // <--- ใส่ตรงนี้
            maxY: maxY,  // <--- ใส่ตรงนี้
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
                    final time = (index >= 0 && index < timeLabels.length) ? timeLabels[index] : '';
                    final isFirst = barSpot == touchedBarSpots.first;
                    
                    final name = _getSeriesName(barSpot.barIndex);
                    final lineText = '$name: ${flSpot.y.toStringAsFixed(2)} ${_getUnit()}';

                    if (isFirst) {
                      return LineTooltipItem(
                        '$time\n',
                        const TextStyle(
                          color: Color.fromARGB(255, 22, 39, 128),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: lineText,
                            style: TextStyle(
                              color: barSpot.bar.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return LineTooltipItem(
                        lineText, 
                        TextStyle(
                          color: barSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                    if (value % interval != 0 && value != minY && value != maxY) {
                        return const SizedBox();
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4, // ลดช่องว่างระหว่างตัวเลขกับเส้นกราฟลงนิดนึง
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                        ),
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
                  interval: 24,
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
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
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