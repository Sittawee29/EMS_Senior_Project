part of '../page.dart';

// ------------------------------------------------------------------
// 1. Model
// ------------------------------------------------------------------
class _WeatherData {
  final String cityName;
  final double temp;
  final double tempMin; 
  final double tempMax; 
  final double feelsLike;
  final String description; 
  final double humidity;
  final double windSpeed;
  final int pressure;
  final String iconCode; 
  final int sunrise; 
  final int sunset;  

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

  // [แก้ใหม่] รับค่า plant เข้ามาด้วยเพื่อเอาไปกำหนดชื่อเมือง
  factory _WeatherData.fromServer(Map<String, dynamic> json, String plant) {

    double getVal(String key) => (json[key] != null) ? (json[key] as num).toDouble() : 0.0;
    int getInt(String key) => (json[key] != null) ? (json[key] as num).toInt() : 0;
    
    String rawIconCode = (json['WEATHER_Icon'] != null && json['WEATHER_Icon'].toString().isNotEmpty) 
        ? json['WEATHER_Icon'].toString() 
        : '01d';
        
    int currentHour = DateTime.now().hour;
    bool isDaytime = currentHour >= 6 && currentHour <= 17;
    
    String finalIconCode = rawIconCode;
    
    if (!isDaytime && rawIconCode.endsWith('d')) {
      finalIconCode = rawIconCode.substring(0, rawIconCode.length - 1) + 'n';
    } else if (isDaytime && rawIconCode.endsWith('n')) {
      finalIconCode = rawIconCode.substring(0, rawIconCode.length - 1) + 'd';
    }

    String getDescription(String code) {
      switch (code) {
        case '01d': case '01n': return 'Clear';
        case '02d': case '02n': return 'Few Clouds';
        case '03d': case '03n': return 'Scattered Clouds';
        case '04d': case '04n': return 'Cloudy'; 
        case '09d': case '09n': return 'Drizzle'; 
        case '10d': case '10n': return 'Rain'; 
        case '11d': case '11n': return 'Thunderstorm'; 
        case '13d': case '13n': return 'Snow'; 
        case '50d': case '50n': return 'Mist'; 
        default: return 'Cloudy';
      }
    }

    // [แก้ใหม่] เช็กชื่อเมืองตาม Plant
    String serverCityName = (json['WEATHER_City'] != null && json['WEATHER_City'].toString().isNotEmpty)
        ? json['WEATHER_City'].toString()
        : 'Unknown';

    return _WeatherData(
      cityName: serverCityName,
      temp: getVal('WEATHER_Temp'),
      tempMin: getVal('WEATHER_TempMin'), 
      tempMax: getVal('WEATHER_TempMax'), 
      feelsLike: getVal('WEATHER_FeelsLike'), 
      description: getDescription(finalIconCode),
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
  final String plant; // [แก้ใหม่] รับค่า plant จากหน้าหลัก

  const _WeatherBox({required this.plant});

  @override
  State<_WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<_WeatherBox> {
  Future<_WeatherData>? _weatherFuture;
  Timer? _timer;
  
  // ตั้งค่า IP/Port ของ Server
  static const String serverIp = 'localhost'; // หรือ IP 127.0.0.1 ของคุณ
  static const String serverPort = '8000';

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

  // [เพิ่มใหม่] โค้ดนี้จะทำงานเมื่อมีการกดสลับ Tab โรงงาน (plant มีการเปลี่ยนแปลง)
  @override
  void didUpdateWidget(covariant _WeatherBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plant != widget.plant) {
      // ถ้า plant เปลี่ยน ให้ดึงข้อมูลอากาศใหม่ทันที
      setState(() {
        _weatherFuture = _fetchWeather();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<_WeatherData> _fetchWeather() async {
    try {
      // [แก้ใหม่] ต่อท้าย URL ด้วย ?plant=ชื่อโรงงาน
      final String serverUrl = 'http://$serverIp:$serverPort/api/dashboard?plant=${widget.plant}';
      final url = Uri.parse(serverUrl);
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // ส่ง widget.plant เข้าไปแปลงเป็นชื่อเมือง
        return _WeatherData.fromServer(data, widget.plant);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather from server');
    }
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return "--:--";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ลบ @override ออกเพราะ Method นี้สร้างใหม่ ไม่ได้สืบทอดมา
  Widget _getWeatherIcon(String code) {
    const double size = 30; 
    switch (code) {
      case '01d': return const Icon(Icons.wb_sunny, color: Colors.orange, size: size);
      case '01n': return const Icon(Icons.nightlight_round, color: Colors.blueGrey, size: size);
      case '02d': case '02n': 
      case '03d': case '03n': 
      case '04d': case '04n': return const Icon(Icons.cloud, color: Colors.grey, size: size);
      case '09d': case '09n': 
      case '10d': case '10n': return const Icon(Icons.water_drop, color: Colors.blue, size: size);
      case '11d': case '11n': return const Icon(Icons.flash_on, color: Colors.amber, size: size);
      case '13d': case '13n': return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: size);
      case '50d': case '50n': return const Icon(Icons.blur_on, color: Colors.grey, size: size);
      default: return const Icon(Icons.wb_cloudy, color: Colors.grey, size: size);
    }
  }

  @override
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
                const Text('Weather', style: TextStyles.myriadProSemiBold22DarkBlue),
                const SizedBox(height: 8),
                Text(
                  data.cityName,
                  style: TextStyles.myriadProRegular16DarkGrey.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DetailItem(icon: Icons.thermostat, label: 'Feels Like', value: '${data.feelsLike.round()}°', color: Palette.orange),
                          _DetailItem(icon: Icons.water_drop, label: 'Humidity', value: '${data.humidity.round()}%', color: Palette.lightBlue),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DetailItem(icon: Icons.air, label: 'Wind', value: '${data.windSpeed} m/s', color: Colors.grey),
                          _DetailItem(icon: Icons.speed, label: 'Pressure', value: '${data.pressure} hPa', color: Palette.purple),
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