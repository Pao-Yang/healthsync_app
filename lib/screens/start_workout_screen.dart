import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartWorkoutScreen extends StatefulWidget {//ใช้ StatefulWidget เพราะ state (seconds, isRunning) เปลี่ยนตลอดเวลา
  //รับ workoutTitle จากหน้าก่อนหน้า เพื่อรู้ว่าผู้ใช้กำลังออกกำลังกายประเภทไหน
  final String workoutTitle;

  const StartWorkoutScreen({super.key, required this.workoutTitle});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  int seconds = 0;   //จำนวนวินาทีที่จับได้
  Timer? timer;    //ตัวจับเวลา (dart:async)
  bool isRunning = false;   // ควบคุมปุ่มและสถานะว่ากำลังนับอยู่ไหม

  Future<void> saveWorkoutData() async {
    await FirebaseFirestore.instance.collection('workouts').add({
      'title': widget.workoutTitle,  //เก็บ title ของ workout
      'duration': seconds,     //เก็บระยะเวลา (seconds)
      'timestamp': FieldValue.serverTimestamp(),  //ใช้ serverTimestamp() เพื่อระบุเวลาบนเซิร์ฟเวอร์
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
    setState(() {
      isRunning = true;
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      isRunning = false;
    });
  }

  String formatTime(int totalSeconds) {
    //แปลงวินาทีเป็น "นาที:วินาที"
    //ใช้ padLeft เพื่อเติมเลข 0 ด้านหน้าให้ครบ 2 หลัก
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.workoutTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ໄລຍະເວລາອອກກຳລັງກາຍ',
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            Text(
              formatTime(seconds),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? stopTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.redAccent : Colors.green,
                  ),
                  child: Text(
                    isRunning ? 'ຢຸດ' : 'ເລີ່ມ',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                  ),
                  child: const Text(
                    'ເລີ່ມໃໝ່',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () {
                saveWorkoutData(); // บันทึกเวลา
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('ສຳເລັດ', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
