import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkoutsFromFirestore();
  }

  Future<void> loadWorkoutsFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('workouts')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      workouts =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // เพิ่ม docId
            return data;
          }).toList();
    });
  }

  Future<void> deleteWorkout(String docId) async {
    await FirebaseFirestore.instance.collection('workouts').doc(docId).delete();
    loadWorkoutsFromFirestore();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("ລົບຂໍ້ມູນສຳເລັດ")));
    // รีโหลดหลังลบ
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'ບໍ່ຮູ້ເວລາ';
    final dt = timestamp.toDate();
    return DateFormat('dd MMM yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ປະຫວັດການອອກກຳລັງກາຍ'),
        backgroundColor: Colors.teal[800],
        elevation: 0,
        centerTitle: true,
      ),
      body:
          workouts.isEmpty
              ? const Center(
                child: Text(
                  'ຍັງບໍ່ມີຂໍ້ມູນການອອກກຳລັງກາຍ',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade900, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade900.withOpacity(0.6),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.tealAccent.shade400,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.shade400.withOpacity(
                                  0.6,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.black87,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout['title'] ?? 'ບໍ່ລະບຸຂໍ້ມູນ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ໄລຍະເວລາ: ${workout['duration']} ວຶນາທີ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'ເມື່ອ: ${formatDate(workout['timestamp'])}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
