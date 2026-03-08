import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../services/mqtt_service.dart';

@RoutePage()
class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<dynamic>(
        stream: MqttService().dataStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? MqttService().currentData;
          if (data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final currentPlant = MqttService().selectedPlant;
          List<Map<String, dynamic>> alarmList = [];
          try {
            if (currentPlant == 'UTI') {
              alarmList = [
                {
                  "name": "Solar System 1",
                  "detail": "Solar System 1 Fault",
                  "value": data.PV1_Fault
                },
                {
                  "name": "Solar System 1",
                  "detail": "Communication Link Failure",
                  "value": data.PV1_Communication_Fault
                },
                {
                  "name": "Solar System 2",
                  "detail": "Communication Link Failure",
                  "value": data.PV2_Communication_Fault
                },
                {
                  "name": "Solar System 3",
                  "detail": "Communication Link Failure",
                  "value": data.PV3_Communication_Fault
                },
                {
                  "name": "Solar System 4",
                  "detail": "Communication Link Failure",
                  "value": data.PV4_Communication_Fault
                },
                {
                  "name": "BESS System 1",
                  "detail": "BESS System 1 Fault",
                  "value": data.BESS_Fault 
                },
                {
                  "name": "BESS System 1",
                  "detail": "Communication Link Failure",
                  "value": data.BESS_Communication_Fault
                },
              ];
            } else if (currentPlant == 'TPI') {
              final racks = data.BESS_RACKS;
              if (racks == null || racks.length < 5) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              alarmList = [
                //BESS System 1
                {
                  "name": "BESS System 1",
                  "detail": "BESS System 1 Fault",
                  "value": data.BESS_RACKS[0]['PSCFAULT']
                },
                {
                  "name": "BESS System 1",
                  "detail": "BESS System 1 Communication Fault",
                  "value": data.BESS_RACKS[0]['PSCCOMMFAULT']
                },
                {
                  "name": "BESS System 1",
                  "detail": "BESS System 1 Alarm",
                  "value": data.BESS_RACKS[0]['PSCALARM']
                },
                //BESS System 2
                {
                  "name": "BESS System 2",
                  "detail": "BESS System 2 Fault",
                  "value": data.BESS_RACKS[1]['PSCFAULT']
                },
                {
                  "name": "BESS System 2",
                  "detail": "BESS System 2 Communication Fault",
                  "value": data.BESS_RACKS[1]['PSCCOMMFAULT']
                },
                {
                  "name": "BESS System 2",
                  "detail": "BESS System 2 Alarm",
                  "value": data.BESS_RACKS[1]['PSCALARM']
                },
                //BESS System 3
                {
                  "name": "BESS System 3",
                  "detail": "BESS System 3 Fault",
                  "value": data.BESS_RACKS[2]['PSCFAULT']
                },
                {
                  "name": "BESS System 3",
                  "detail": "BESS System 3 Communication Fault",
                  "value": data.BESS_RACKS[2]['PSCCOMMFAULT']
                },
                {
                  "name": "BESS System 3",
                  "detail": "BESS System 3 Alarm",
                  "value": data.BESS_RACKS[2]['PSCALARM']
                },
                //BESS System 4
                {
                  "name": "BESS System 4",
                  "detail": "BESS System 4 Fault",
                  "value": data.BESS_RACKS[3]['PSCFAULT']
                },
                {
                  "name": "BESS System 4",
                  "detail": "BESS System 4 Communication Fault",
                  "value": data.BESS_RACKS[3]['PSCCOMMFAULT']
                },
                {
                  "name": "BESS System 4",
                  "detail": "BESS System 4 Alarm",
                  "value": data.BESS_RACKS[3]['PSCALARM']
                },
                //BESS System 5
                {
                  "name": "BESS System 5",
                  "detail": "BESS System 5 Fault",
                  "value": data.BESS_RACKS[4]['PSCFAULT']
                },
                {
                  "name": "BESS System 5",
                  "detail": "BESS System 5 Communication Fault",
                  "value": data.BESS_RACKS[4]['PSCCOMMFAULT']
                },
                {
                  "name": "BESS System 5",
                  "detail": "BESS System 5 Alarm",
                  "value": data.BESS_RACKS[4]['PSCALARM']
                },
              ];
            }
          }
          catch (e) {
            return Center(
              child: Text("Data Error: $e", style: const TextStyle(color: Colors.red)),
            );
          }

          int activeFaults = alarmList.where((e) {
            final val = e['value'];
            return val != null && (val as double) == 1.0;
          }).length;
          
          bool isSystemNormal = activeFaults == 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSystemNormal ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isSystemNormal ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isSystemNormal ? "SYSTEM NORMAL - $currentPlant" : "SYSTEM CRITICAL - $currentPlant",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      isSystemNormal 
                          ? "All systems in $currentPlant are operating normally." 
                          : "$activeFaults Active Alarm(s) Detected in $currentPlant!",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alarmList.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = alarmList[index];
                    final bool isFault = item['value'] != null && (item['value'] as double) == 1.0;
                    
                    return BlinkingAlarmCard(
                      name: item['name'],
                      detail: item['detail'],
                      isFault: isFault,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BlinkingAlarmCard extends StatefulWidget {
  final String name;
  final String detail;
  final bool isFault;

  const BlinkingAlarmCard({
    super.key,
    required this.name,
    required this.detail,
    required this.isFault,
  });
  @override
  State<BlinkingAlarmCard> createState() => _BlinkingAlarmCardState();
}

class _BlinkingAlarmCardState extends State<BlinkingAlarmCard>
  with SingleTickerProviderStateMixin { 
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.white, 
      end: const Color(0xFFFFCDD2), 
    ).animate(_controller);

    if (widget.isFault) {
      _controller.repeat(reverse: true); 
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingAlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFault != oldWidget.isFault) {
      if (widget.isFault) {
        _controller.repeat(reverse: true); 
      } else {
        _controller.stop(); 
        _controller.reset(); 
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = widget.isFault ? Colors.red : Colors.green;
    final String statusText = widget.isFault ? "FAULT" : "NORMAL";
    final IconData icon = widget.isFault ? Icons.error_outline : Icons.check_circle;

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: widget.isFault ? _colorAnimation.value : Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(icon, color: statusColor),
              ),
              title: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                widget.detail,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}