import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthsync_app/screens/dashboard_screen.dart';

//ใช้ StatefulWidget เพราะต้องเก็บสถานะ เช่น loading และข้อมูลจาก TextField
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //สร้าง controller สำหรับรับข้อมูลจาก TextField
  //ตัวแปร _loading ใช้สำหรับแสดง CircularProgressIndicator ระหว่างโหลด
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  Future<void> login() async {
    //ดึงค่า email และ password ที่ผู้ใช้กรอกมา แล้ว trim() เพื่อลบช่องว่าง
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    //ถ้าช่องว่าง แสดง SnackBar แจ้งเตือน
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ກະລຸນາປ້ອນອີເມລ ແລະ ລະຫັດຜ່ານໃຫ້ຄົບຖ້ວນ'),
        ),
      );
      return;
    }
    //_loading = true เพื่อแสดง indicator ว่ากำลังโหลด
    setState(() => _loading = true);

    //ใช้ Firebase Auth เข้าสู่ระบบด้วยอีเมลและรหัสผ่าน
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //หากสำเร็จ พาไปหน้า DashboardScreen และล้าง navigation stack ไม่ให้ย้อนกลับได้
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );

      //ดักจับ error จาก Firebase เช่น ไม่มีผู้ใช้, รหัสผ่านผิด
    } on FirebaseAuthException catch (e) {
      String message = 'ເກີດຂໍ້ຜິດພາດໃນການເຂົ້າສູ່ລະບົບ';

      //ตรวจรหัส error จาก Firebase แล้วเปลี่ยนข้อความแสดงผลตามกรณี
      if (e.code == 'user-not-found') {
        message = 'ບໍ່ພົບບັນຊີຂອງທ່ານ';
      } else if (e.code == 'wrong-password') {
        message = 'ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        //กล่องโปร่งแสง ขอบโค้ง ใช้สำหรับวางฟอร์ม login
        padding: const EdgeInsets.all(24),
        child: Center(
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
                    'ເຂົ້າສູ່ລະບົບ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 28),
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
                  const SizedBox(height: 20),
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
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // เปลี่ยนเป็นสีขาว
                        foregroundColor:
                            Colors.black, // สีข้อความและไอคอนเป็นดำ
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login),

                      //ถ้า _loading = true แสดงวงกลมโหลดแทนข้อความ
                      label:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                              : const Text(
                                'ເຂົ້າສູ່ລະບົບ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    //ใช้ GestureDetector เพื่อให้คลิกได้ → นำไปหน้า /forgot_password และ /register
                    child: GestureDetector(
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/forgot_password',
                          ), // สมมติคุณตั้ง route ไว้แบบนี้
                      child: const Text(
                        'ລືມລະຫັດຜ່ານ?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'ຍັງບໍ່ມີບັນຊີ? ລົງທະບຽນ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          // ลบ decoration ออก
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
