import 'package:flutter/material.dart';
import 'start_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //สร้างลิสต์ workout แต่ละประเภท เป็น Map ที่เก็บชื่อ, ไอคอน และสี
    final List<Map<String, dynamic>> workouts = [
      {
        'title': 'Cardio',
        'icon': Icons.directions_run,
        'color': Colors.redAccent,
      },
      {
        'title': 'Weight Training',
        'icon': Icons.fitness_center,
        'color': Colors.blueAccent,
      },
      {
        'title': 'Yoga',
        'icon': Icons.self_improvement,
        'color': Colors.greenAccent,
      },
      {
        'title': 'HIIT',
        'icon': Icons.flash_on,
        'color': Colors.orangeAccent,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(  //แถบด้านบนแบบโปร่งใส (ไม่มีพื้นหลัง)
        title: const Text(
          'ເລືອກປະເພດການອອກກຳລັງກາຍ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: GridView.builder(  //สร้าง GridView ที่แสดง 2 คอลัมน์
          itemCount: workouts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return GestureDetector( //ใช้ GestureDetector เพื่อคลิกแต่ละกล่อง
              onTap: () {
                Navigator.push( //เมื่อคลิก → นำไปยังหน้า StartWorkoutScreen และส่งค่า workoutTitle ไปด้วย
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StartWorkoutScreen(workoutTitle: workout['title']),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      workout['color'].withOpacity(0.25),
                      Colors.black,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: workout['color'].withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: workout['color'].withOpacity(0.6),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      workout['icon'],
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      workout['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
