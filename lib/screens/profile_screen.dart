import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? healthData;
  bool isLoading = true;

  Map<String, dynamic> calculateBMI() {
    if (healthData == null) return {};

    final weight = double.tryParse(healthData!['weight'] ?? '');
    final heightCm = double.tryParse(healthData!['height'] ?? '');

    if (weight == null || heightCm == null || heightCm == 0) return {};

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'ນໍ້າໜັກໜ້ອຍ';
      color = Colors.orange;
    } else if (bmi < 23) {
      category = 'ປົກກະຕີ';
      color = Colors.greenAccent;
    } else if (bmi < 25) {
      category = 'ເລີ່ມອ້ວນ';
      color = Colors.yellow;
    } else if (bmi < 30) {
      category = 'ອ້ວນລະດັນ 1';
      color = Colors.deepOrangeAccent;
    } else {
      category = 'ອ້ວນລະດັນ 2';
      color = Colors.redAccent;
    }

    return {
      'bmi': bmi.toStringAsFixed(1),
      'category': category,
      'color': color,
    };
  }

  String getBMISuggestion(double bmi) {
    if (bmi < 18.5) {
      return 'ຄວນເພີ່ມອາຫານ ແລະ ການອອກກຳລັງກາຍສ້າງກ້າມເນື້ອ';
    } else if (bmi < 23) {
      return 'ສຸຂະພາບດີ! ຮັກສາຕໍ່ໄປ 💪';
    } else if (bmi < 25) {
      return 'ເລີ່ມອ້ວນ ຄວນເພີ່ມອາຫານ ແລະ ການອອກກຳລັງກາຍ';
    } else if (bmi < 30) {
      return 'ອ້ວນລະດັນ 1 ຄວນຄວບຄຸມອາຫານ ແລະ ອອກກຳລັງກາຍຢ່າງສະໝໍ່າສະເໝີ';
    } else {
      return 'ອ້ວນລະດັນ 2 ຄວນປຶກສາສາທ່ານໝໍ ແລະ ດູແລສຸຂະພາບຢ່າງສະໝໍ່າສະເໝີ';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHealthData();
  }

  Future<void> fetchHealthData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      setState(() {
        healthData = snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
        isLoading = false;
      });
    } catch (e) {
      print('ເກີດຂໍ້ຜິດພາດ: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bmiData = calculateBMI();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ຂໍ້ມູນສ່ວນຕົວ'),
        backgroundColor: Colors.teal[800],
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.tealAccent,
                    child: const Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user?.email ?? 'ບໍ່ພົບບັນຊີ',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                _profileCard(),

                if (bmiData.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _bmiCard(bmiData),
                ],

                const SizedBox(height: 46),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/health_form');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('ແກ້ໄຂຂໍ້ມູນສຸຂະພາບ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('ອອກຈາກລະບົບ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _profileCard() {
    if (healthData == null) {
      return const Text('ຍັງບໍ່ມີຂໍ້ມູນສຸຂະພາບ', style: TextStyle(color: Colors.white70));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoRow('ນໍ້າໜັກ', '${healthData!['weight']} kg'),
          _infoRow('ຄວາມສູງ', '${healthData!['height']} cm'),
          _infoRow('ອາຍຸ', '${healthData!['age']} ปี'),
          _infoRow('ເພດ', healthData!['gender']),
          _infoRow('ກິດຈະກຳ', healthData!['activityLevel']),
        ],
      ),
    );
  }

  Widget _bmiCard(Map<String, dynamic> bmiData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmiData['color'], width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ຄ່າ BMI: ${bmiData['bmi']}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: bmiData['color'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ລະດັບ: ${bmiData['category']}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            getBMISuggestion(double.parse(bmiData['bmi'])),
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.tealAccent.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
