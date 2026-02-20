part of '../page.dart';

// ------------------------------------------------------------------
// 1. Model: เหมือนเดิม ไม่ต้องแก้
// ------------------------------------------------------------------
class _WeatherData {
  final String cityName;
  final double temp;
  final double tempMin; // Server ไม่ได้เก็บ ใช้ค่า temp แทน
  final double tempMax; // Server ไม่ได้เก็บ ใช้ค่า temp แทน
  final double feelsLike;
  final String description; // Server ไม่ได้เก็บ (สมมติเอา)
  final double humidity;
  final double windSpeed;
  final int pressure;
  final String iconCode; // คำนวณจาก Cloudiness แทน
  final int sunrise; // Server ไม่ได้เก็บ
  final int sunset;  // Server ไม่ได้เก็บ

  _WeatherData({
    required this.cityName,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
  });

  factory _WeatherData.fromServer(Map<String, dynamic> json) {

    double getVal(String key) => (json[key] != null) ? (json[key] as num).toDouble() : 0.0;
    
    int getInt(String key) => (json[key] != null) ? (json[key] as num).toInt() : 0;
    
    String rawIconCode = (json['WEATHER_Icon'] != null) ? json['WEATHER_Icon'].toString() : '01d';
    int currentHour = DateTime.now().hour;
    bool isDaytime = currentHour >= 6 && currentHour <= 17;
    
    String finalIconCode = rawIconCode;
    
    // ถ้าเป็นกลางคืน แต่โค้ดลงท้ายด้วย 'd' (Day) ให้เปลี่ยนเป็น 'n' (Night)
    if (!isDaytime && rawIconCode.endsWith('d')) {
      finalIconCode = rawIconCode.substring(0, rawIconCode.length - 1) + 'n';
    } 
    // ถ้าเป็นกลางวัน แต่โค้ดลงท้ายด้วย 'n' (Night) ให้เปลี่ยนเป็น 'd' (Day)
    else if (isDaytime && rawIconCode.endsWith('n')) {
      finalIconCode = rawIconCode.substring(0, rawIconCode.length - 1) + 'd';
    }

    return _WeatherData(
      cityName: 'Bangkok',
      temp: getVal('WEATHER_Temp'),
      
      tempMin: getVal('WEATHER_TempMin'), 
      tempMax: getVal('WEATHER_TempMax'), 
      feelsLike: getVal('WEATHER_FeelsLike'), 
      
      description: 'Clear',
      humidity: getVal('WEATHER_Humidity'),
      windSpeed: getVal('WEATHER_WindSpeed'),
      pressure: getInt('WEATHER_Pressure'), 
      iconCode: finalIconCode,
      sunrise: getInt('WEATHER_Sunrise'), 
      sunset: getInt('WEATHER_Sunset'),
    );
  }
}

// ------------------------------------------------------------------
// 2. WeatherBox
// ------------------------------------------------------------------
class _WeatherBox extends StatefulWidget {
  const _WeatherBox();

  @override
  State<_WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<_WeatherBox> {
  Future<_WeatherData>? _weatherFuture;
  Timer? _timer;
  static const String serverIp = 'localhost'; 
  static const String serverPort = '8000';
  final String _serverUrl = 'http://$serverIp:$serverPort/api/dashboard';

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
    
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) { 
        setState(() {
          _weatherFuture = _fetchWeather();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<_WeatherData> _fetchWeather() async {
  try {
    final url = Uri.parse(_serverUrl);
    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // [สำคัญ] ใช้ .fromServer ที่เราสร้างใหม่เพื่อแปลงข้อมูล
      return _WeatherData.fromServer(data);
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  } 
  catch (e) {
      // ถ้าดึงไม่ได้ ให้ throw error หรือจะ return ข้อมูลว่างๆ ก็ได้
      throw Exception('Failed to load weather from server');
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget _getWeatherIcon(String code) {
    const double size = 30; 
    switch (code) {
      case '01d': // ฟ้าโปร่ง กลางวัน
        return const Icon(Icons.wb_sunny, color: Colors.orange, size: size);
      case '01n': // ฟ้าโปร่ง กลางคืน
        return const Icon(Icons.nightlight_round, color: Colors.blueGrey, size: size);
      case '02d': case '02n': // เมฆเล็กน้อย
      case '03d': case '03n': // เมฆกระจัดกระจาย
      case '04d': case '04n': // เมฆมาก
        return const Icon(Icons.cloud, color: Colors.grey, size: size);
      case '09d': case '09n': // ฝนปรอยๆ
      case '10d': case '10n': // ฝนตก
        return const Icon(Icons.water_drop, color: Colors.blue, size: size);
      case '11d': case '11n': // พายุ
        return const Icon(Icons.flash_on, color: Colors.amber, size: size);
      case '13d': case '13n': // หิมะ
        return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: size);
      case '50d': case '50n': // หมอก
        return const Icon(Icons.blur_on, color: Colors.grey, size: size);
      default:
        return const Icon(Icons.wb_cloudy, color: Colors.grey, size: size);
    }
  }

  Widget build(BuildContext context) {
    return Container(
      width: 292, 
      height: 530, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: FutureBuilder<_WeatherData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 10),
                  // แสดงข้อความ Error (เช่น City not found)
                  Text(
                    '${snapshot.error}'.replaceAll('Exception:', ''), 
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() => _weatherFuture = _fetchWeather()),
                  )
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                const Text('Weather', style: TextStyles.myriadProSemiBold22DarkBlue),
                const SizedBox(height: 8),
                Text(
                  data.cityName, // ชื่อเมืองที่ API ตอบกลับมา (อาจมี Country code ต่อท้ายถ้า API ส่งมา)
                  style: TextStyles.myriadProRegular16DarkGrey.copyWith(fontSize: 16),
                ),

                const SizedBox(height: 20),

                // --- Main Temp ---
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${data.temp.round()}°C',
                        style: TextStyles.myriadProSemiBold32DarkBlue.copyWith(fontSize: 48),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getWeatherIcon(data.iconCode),
                          const SizedBox(width: 5),
                          Text(
                            data.description,
                            style: TextStyles.myriadProRegular16DarkGrey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${data.tempMax.toStringAsFixed(1)}/${data.tempMin.toStringAsFixed(1)}°C',
                            style: TextStyles.myriadProSemiBold16DarkBlue,
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Sun Schedule ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sunrise: ${_formatTime(data.sunrise)}', style: TextStyles.myriadProRegular13DarkGrey),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomPaint(painter: _DottedLinePainter()), 
                      ),
                    ),
                    Text('Sunset: ${_formatTime(data.sunset)}', style: TextStyles.myriadProRegular13DarkGrey),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 20),

                // --- 4. Details Grid ---
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DetailItem(
                            icon: Icons.thermostat,
                            label: 'Feels Like',
                            value: '${data.feelsLike.round()}°',
                            color: Palette.orange,
                          ),
                          _DetailItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '${data.humidity.round()}%',
                            color: Palette.lightBlue,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DetailItem(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '${data.windSpeed} m/s',
                            color: Colors.grey,
                          ),
                          _DetailItem(
                            icon: Icons.speed,
                            label: 'Pressure',
                            value: '${data.pressure} hPa',
                            color: Palette.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Widget ย่อยต่างๆ คงเดิม
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyles.myriadProRegular13DarkGrey.copyWith(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 22), 
            child: Text(value, style: TextStyles.myriadProSemiBold13Dark.copyWith(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 3;
    const double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}