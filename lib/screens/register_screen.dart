import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthsync_app/screens/dashboard_screen.dart';

//เป็น StatefulWidget เพราะมีการเปลี่ยนสถานะ _loading และใช้ TextEditingController
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //_loading ใช้สำหรับแสดง CircularProgressIndicator ระหว่างรอระบบสมัคร
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  Future<void> register() async {
    //อ่านค่าที่ผู้ใช้พิมพ์ และลบช่องว่าง
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    //ถ้ามีช่องว่าง แสดง SnackBar เตือนผู้ใช้
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນຂອງທ່ານໃຫ້ຄົບຖ້ວນ')),
      );
      return;
    }

    //เปลี่ยนสถานะให้แสดงปุ่มโหลด
    setState(() => _loading = true);

    try {
      //ใช้ Firebase สร้างบัญชีผู้ใช้ใหม่
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      //บันทึกข้อมูลผู้ใช้ลงใน Firestore (collection users)
      //ใช้ serverTimestamp() เพื่อระบุเวลาที่สมัคร
      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      //หลังสมัครเสร็จ นำผู้ใช้ไปหน้า Dashboard และเคลียร์ stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );

      //กรณี Firebase ส่ง error: แจ้งข้อความให้เหมาะสม เช่น อีเมลซ้ำ, รหัสสั้นเกิน
    } on FirebaseAuthException catch (e) {
      String message = 'ເກີດຂໍ້ຜິດພາດໃນການລົງທະບຽນ';
      if (e.code == 'email-already-in-use') {
        message = 'ອີເມວນີ້ຖືກໃຊ້ໄປແລ້ວ';
      } else if (e.code == 'weak-password') {
        message = 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {    //กรณีอื่น ๆ ที่ไม่ใช่ Firebase Exception
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //ตั้งพื้นหลังไล่สีดำ → เขียว
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          //กล่องโปร่งแสงสำหรับใส่ฟอร์มสมัครสมาชิก
          child: SingleChildScrollView(   
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ລົງທະບຽນ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'ຊື່ ແລະ ນາມສະກຸນ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ຊື່ ແລະ ນາມສະກຸນ',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('ອີເມລ', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'ກະລຸນາປ້ອນອີເມລ',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'ລະຫັດຜ່ານ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '********',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'ລົງທະບຽນ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'ມີບັນຊີແລ້ວ? ເຂົ້າສູ່ລະບົບ',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          // decoration: TextDecoration.underline, // ลบขีดใต้
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
