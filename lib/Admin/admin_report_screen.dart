// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  double totalRevenue = 0;
  double totalProfit = 0;
  double totalLoss = 0;
  double totalRefunds = 0;
  List<FlSpot> revenueData = [];
  Map<String, int> bookingsCount = {};

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    QuerySnapshot bookingsSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();
    double revenue = 0;
    double refunds = 0;
    Map<String, int> boxBookings = {};
    List<FlSpot> revenuePoints = [];
    int index = 1;

    for (var doc in bookingsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      revenue += data['totalCost'] ?? 0;
      refunds += data['refundAmount'] ?? 0;

      String boxName = data['boxName'] ?? 'Unknown';
      boxBookings[boxName] = (boxBookings[boxName] ?? 0) + 1;

      revenuePoints.add(FlSpot(index.toDouble(), revenue));
      index++;
    }

    setState(() {
      totalRevenue = revenue;
      totalRefunds = refunds;
      totalProfit = revenue - refunds;
      totalLoss = refunds;
      bookingsCount = boxBookings;
      revenueData = revenuePoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Admin Report',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCard(
                    title: 'Revenue',
                    value: totalRevenue,
                    icon: Icons.attach_money,
                    color: Colors.green),
                SummaryCard(
                    title: 'Profit',
                    value: totalProfit,
                    icon: Icons.trending_up,
                    color: Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCard(
                    title: 'Refunds',
                    value: totalRefunds,
                    icon: Icons.money_off,
                    color: Colors.red),
                SummaryCard(
                    title: 'Loss',
                    value: totalLoss,
                    icon: Icons.trending_down,
                    color: Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Day ${value.toInt()}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: const FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenueData,
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.blue,
                      dotData: const FlDotData(show: true), // ✅ Shows data points
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        value: totalProfit,
                        title: 'Profit',
                        color: Colors.green,
                        radius: 50),
                    PieChartSectionData(
                        value: totalRefunds,
                        title: 'Refunds',
                        color: Colors.red,
                        radius: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const SummaryCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text('₹${value.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
