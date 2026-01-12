import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../services/mqtt_service.dart'; // ตรวจสอบ path ให้ถูกต้อง

@RoutePage()
class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<DashboardData>(
        stream: MqttService().dataStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? MqttService().currentData;

          // 1. Mapping ข้อมูล
          final List<Map<String, dynamic>> alarmList = [
            {
              "name": "BESS System",
              "detail": "Battery Energy Storage Fault",
              "value": data.BESS_Fault
            },
            {
              "name": "BESS Communication",
              "detail": "Comms Link Failure",
              "value": data.BESS_Communication_Fault
            },
            {
              "name": "PV1 System",
              "detail": "Inverter/Panel Fault",
              "value": data.PV1_Fault
            },
            {
              "name": "PV1 Communication",
              "detail": "Comms Link Failure",
              "value": data.PV1_Communication_Fault
            },
            {
              "name": "PV2 Communication",
              "detail": "Comms Link Failure",
              "value": data.PV2_Communication_Fault
            },
            {
              "name": "PV3 Communication",
              "detail": "Comms Link Failure",
              "value": data.PV3_Communication_Fault
            },
            {
              "name": "PV4 Communication",
              "detail": "Comms Link Failure",
              "value": data.PV4_Communication_Fault
            },
          ];

          // 2. เช็ค Fault รวม
          int activeFaults = alarmList.where((e) => (e['value'] as double) == 1.0).length;
          bool isSystemNormal = activeFaults == 0;

          return Column(
            children: [
              // --- Header Summary ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ถ้าจะให้ Header กระพริบด้วย ต้องทำแยกอีก Widget
                  // ในที่นี้เอาแค่เปลี่ยนสีตามปกติ
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
                      isSystemNormal ? "SYSTEM NORMAL" : "SYSTEM CRITICAL",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      isSystemNormal 
                          ? "All systems are operating normally." 
                          : "$activeFaults Active Alarm(s) Detected!",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // --- Alarm List ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alarmList.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = alarmList[index];
                    final bool isFault = (item['value'] as double) == 1.0;
                    
                    // ใช้ Widget ใหม่ที่สร้างขึ้นด้านล่างแทน
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

// -------------------------------------------------------------
// สร้าง Widget ใหม่แยกออกมาเพื่อจัดการ Animation (การกระพริบ)
// -------------------------------------------------------------
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
    with SingleTickerProviderStateMixin { // Mixin นี้จำเป็นสำหรับ AnimationController
  
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // ตั้งค่าตัวควบคุม Animation (ระยะเวลา 1 รอบ = 500ms)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // กำหนดสีที่จะกระพริบสลับกัน (ขาว <-> แดงอ่อน)
    // ใช้แดงอ่อน (red[100]) เพื่อให้ยังอ่านตัวหนังสือสีดำออก
    _colorAnimation = ColorTween(
      begin: Colors.white, 
      end: const Color(0xFFFFCDD2), // สีแดงอ่อน (Red 100)
    ).animate(_controller);

    // ถ้าเข้ามาแล้วเป็น Fault เลย ให้เริ่มกระพริบทันที
    if (widget.isFault) {
      _controller.repeat(reverse: true); // เล่นวนไป-กลับ
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingAlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // เช็คว่าสถานะ Fault เปลี่ยนไปหรือไม่
    if (widget.isFault != oldWidget.isFault) {
      if (widget.isFault) {
        _controller.repeat(reverse: true); // เริ่มกระพริบ
      } else {
        _controller.stop(); // หยุดกระพริบ
        _controller.reset(); // กลับไปเป็นสีขาว
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // คืน Memory เมื่อหน้านี้ปิดลง
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ธีมสีของ icon และ text
    final Color statusColor = widget.isFault ? Colors.red : Colors.green;
    final String statusText = widget.isFault ? "FAULT" : "NORMAL";
    final IconData icon = widget.isFault ? Icons.error_outline : Icons.check_circle;

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // ใช้สีจาก Animation ถ้าเป็น Fault, ถ้าไม่ใช้สีขาว
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