import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // อย่าลืม import fl_chart

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardPage(),
  ));
}

// --- Model ข้อมูลจำลอง ---
class StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatData(this.title, this.value, this.icon, this.color);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ข้อมูลตัวอย่าง (ในโปรเจกต์จริงอาจจะมาจาก API)
  final List<StatData> stats = [
    StatData("Total Sales", "\$45,231", Icons.monetization_on, Colors.blue),
    StatData("New Users", "1,205", Icons.people, Colors.orange),
    StatData("Orders", "323", Icons.shopping_cart, Colors.green),
    StatData("Pending", "12", Icons.pending_actions, Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dynamic Dashboard', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.grey), onPressed: () {}),
          const CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150"), radius: 18),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // ใช้ LayoutBuilder เพื่อเช็คขนาดหน้าจอ
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ถ้าหน้าจอกว้างกว่า 800px ให้เป็น Desktop (แสดง 4 คอลัมน์)
            // ถ้าเล็กกว่าให้เป็น Mobile (แสดง 2 คอลัมน์)
            int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
            
            // ถ้ามือถือเล็กมาก (น้อยกว่า 500px) ให้เหลือ 1 คอลัมน์ในบางส่วน
            bool isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 1. ส่วน Stat Cards (Grid)
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (context, index) => _buildStatCard(stats[index]),
                  ),

                  const SizedBox(height: 24),

                  // 2. ส่วน Chart และ Recent List (จัด Layout ตามขนาดจอ)
                  isMobile 
                    ? Column(children: [_buildChartSection(), const SizedBox(height: 24), _buildRecentList()])
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildChartSection()),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _buildRecentList()),
                        ],
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget: สร้างการ์ดสถิติ
  Widget _buildStatCard(StatData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(data.icon, color: data.color, size: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: data.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("+12%", style: TextStyle(color: data.color, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(data.title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  // Widget: ส่วนกราฟ (ใช้ fl_chart หรือ Placeholder)
  Widget _buildChartSection() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Revenue Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            // ตัวอย่างกราฟเส้น (ถ้าไม่มี fl_chart ให้ใช้ Container สีแทนได้)
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3), const FlSpot(2, 2), const FlSpot(4, 5),
                      const FlSpot(6, 3.1), const FlSpot(8, 4), const FlSpot(10, 3), const FlSpot(12, 6),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: รายการล่าสุด
  Widget _buildRecentList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.black54),
                ),
                title: Text("User #$index"),
                subtitle: const Text("Purchased Item A"),
                trailing: const Text("+\$50", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              );
            },
          ),
        ],
      ),
    );
  }
}