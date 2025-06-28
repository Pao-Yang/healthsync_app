import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthFormScreen extends StatefulWidget {
  const HealthFormScreen({super.key});

  @override
  State<HealthFormScreen> createState() => _HealthFormScreenState();
}

class _HealthFormScreenState extends State<HealthFormScreen> {
  //ควบคุมค่าในช่องกรอกน้ำหนัก, ส่วนสูง, และอายุ
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

//selectedGenderIndex และ selectedActivityIndex คือค่าที่เลือกไว้ (โดย default)
  int selectedGenderIndex = 0;
  int selectedActivityIndex = 1;
//ตัวเลือกให้ผู้ใช้เลือกเพศและระดับกิจกรรม
  final List<String> genderOptions = ['ຊາຍ', 'ຍີງ', 'ອື່ນໆ'];
  final List<String> activityOptions = ['ບໍ່ຄ່ອຍອອກກຳລັງກາຍ', 'ປົກກະຕີ', 'ອອກກຳລັງກາຍສະໝໍ່າສະເໝີ'];
//ดึงค่าที่เลือกมาใช้งานแบบอ่านง่าย
  String get gender => genderOptions[selectedGenderIndex];
  String get activityLevel => activityOptions[selectedActivityIndex];

  void saveHealthData() async { //อ่านค่าจาก TextField  ตรวจสอบว่าผู้ใช้ล็อกอินหรือยัง ถ้าล็อกอินแล้ว บันทึกข้อมูลเข้า Firestore
    final weight = weightController.text.trim();
    final height = heightController.text.trim();
    final age = ageController.text.trim();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ ຍັງບໍ່ໄດ້ເຂົ້າສູ່ລະບົບ')),
      );
      return;
    }

    final uid = user.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('health_data')
          .add({
        'weight': weight,
        'height': height,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ບັນທຶກຂໍ້ມູນສຳເລັດ')),
      );

      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ເກີດຂໍ້ຜິດພາດ: $e')),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.tealAccent.shade400),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.tealAccent.shade400, width: 2),
      ),
    );
  }

  Widget _buildToggleButtons(String label, List<String> options, int selectedIndex, ValueChanged<int> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.tealAccent.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: List.generate(options.length, (index) {
            final bool isSelected = selectedIndex == index;
            return ChoiceChip(
              label: Text(
                options[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.tealAccent.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.tealAccent.shade400,
              backgroundColor: Colors.grey[850],
              shadowColor: isSelected ? Colors.tealAccent.shade400.withOpacity(0.5) : null,
              elevation: isSelected ? 6 : 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onSelected: (selected) {
                if (selected) onSelected(index);
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ປ້ອນຂໍ້ມູນສຸຂະພາບ'),
        backgroundColor: Colors.teal[800],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ນໍ້າໜັກ (kg)',
              style: TextStyle(
                color: Colors.tealAccent.shade400,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _inputDecoration('ເຊັ່ນ: 65', Icons.monitor_weight),
            ),
            const SizedBox(height: 24),

            Text(
              'ຄວາມສູງ (cm)',
              style: TextStyle(
                color: Colors.tealAccent.shade400,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _inputDecoration('ເຊັ່ນ: 170', Icons.height),
            ),
            const SizedBox(height: 24),

            Text(
              'ອາຍຸ',
              style: TextStyle(
                color: Colors.tealAccent.shade400,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _inputDecoration('ເຊັ່ນ: 25', Icons.cake),
            ),
            const SizedBox(height: 32),

            _buildToggleButtons('ເພດ', genderOptions, selectedGenderIndex, (idx) {
              setState(() {
                selectedGenderIndex = idx;
              });
            }),
            const SizedBox(height: 24),

            _buildToggleButtons('ລະດັບກິດຈະກຳ', activityOptions, selectedActivityIndex, (idx) {
              setState(() {
                selectedActivityIndex = idx;
              });
            }),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: saveHealthData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: Colors.tealAccent.shade200.withOpacity(0.6),
                ),
                child: const Text(
                  'ບັນທຶກ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
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
