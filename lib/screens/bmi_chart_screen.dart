import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BMIChartScreen extends StatefulWidget {
  const BMIChartScreen({super.key});

  @override
  State<BMIChartScreen> createState() => _BMIChartScreenState();
}

class _BMIChartScreenState extends State<BMIChartScreen> {
  List<_BMIDataPoint> _bmiData = [];
  double? _targetBMI;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBMIData();
  }

  Future<void> _fetchBMIData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final goalSnapshot = await userRef.collection('goal').limit(1).get();
    if (goalSnapshot.docs.isNotEmpty) {
      final targetWeight = double.tryParse(goalSnapshot.docs.first['targetWeight'].toString());
      final heightSnapshot = await userRef.collection('health_data').orderBy('timestamp', descending: true).limit(1).get();
      if (targetWeight != null && heightSnapshot.docs.isNotEmpty) {
        final heightCm = double.tryParse(heightSnapshot.docs.first['height'].toString());
        if (heightCm != null && heightCm > 0) {
          final heightM = heightCm / 100;
          _targetBMI = targetWeight / (heightM * heightM);
        }
      }
    }

    final snapshot = await userRef.collection('health_data').orderBy('timestamp').get();

    final List<_BMIDataPoint> data = [];

    for (final doc in snapshot.docs) {
      final weight = double.tryParse(doc['weight'].toString());
      final heightCm = double.tryParse(doc['height'].toString());
      final timestamp = doc['timestamp']?.toDate();

      if (weight == null || heightCm == null || timestamp == null) continue;

      final heightM = heightCm / 100;
      final bmi = weight / (heightM * heightM);

      data.add(_BMIDataPoint(timestamp, bmi));
    }

    setState(() {
      _bmiData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ກຣາຟ BMI ລາຍເດືອນ'),
        backgroundColor: Colors.teal[800],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            )
          : _bmiData.isEmpty
              ? const Center(
                  child: Text(
                    'ຍັງບໍ່ມີຂໍ້ມູນ BMI',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ຄ່າ (BMI)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: LineChart(
                            LineChartData(
                              backgroundColor: Colors.transparent,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.white24,
                                  strokeWidth: 0.5,
                                ),
                                getDrawingVerticalLine: (value) => FlLine(
                                  color: Colors.white24,
                                  strokeWidth: 0.5,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 2,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= _bmiData.length) return const SizedBox.shrink();
                                      final date = _bmiData[index].timestamp;
                                      return Text(
                                        DateFormat.MMM().format(date),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: Colors.tealAccent,
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.tealAccent.withOpacity(0.1),
                                  ),
                                  spots: _bmiData
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value.bmi))
                                      .toList(),
                                ),
                                if (_targetBMI != null)
                                  LineChartBarData(
                                    isCurved: false,
                                    color: Colors.grey,
                                    barWidth: 2,
                                    dashArray: [6, 4],
                                    dotData: FlDotData(show: false),
                                    spots: [
                                      FlSpot(0, _targetBMI!),
                                      FlSpot((_bmiData.length - 1).toDouble(), _targetBMI!),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _BMIDataPoint {
  final DateTime timestamp;
  final double bmi;

  _BMIDataPoint(this.timestamp, this.bmi);
}
