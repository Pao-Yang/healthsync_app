import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthsync_app/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາປ້ອນອີເມລ ແລະ ລະຫັດຜ່ານໃຫ້ຄົບຖ້ວນ')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'ເກີດຂໍ້ຜິດພາດໃນການເຂົ້າສູ່ລະບົບ';
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
                  // เพิ่มตรงนี้ใน build method หลังปุ่มเข้าสู่ระบบและก่อน "ยังไม่มีบัญชี? สมัครสมาชิก"
                  const SizedBox(height: 12),
                  Center(
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
