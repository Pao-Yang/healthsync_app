import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


//สร้าง StatefulWidget สำหรับจัดการอินพุตและสถานะโหลด
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

//_loading บอกว่ากำลังโหลดอยู่หรือไม่ (ใช้ปิดปุ่ม และแสดงวงกลมโหลด)
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _resetPassword() async {

    //ดึงอีเมลที่ผู้ใช้กรอก และลบช่องว่างหน้า/หลัง
    final email = _emailController.text.trim();
    if (email.isEmpty) {

      //ถ้าไม่ได้กรอกอีเมล → แจ้งเตือนให้กรอกก่อน
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ກະລຸນາປ້ອນອີເມລຂອງທ່ານ')));
      return;
    }

    setState(() => _loading = true);

    try {
      //ใช้ Firebase ส่งอีเมลสำหรับรีเซ็ตรหัสผ่าน
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      //แจ้งผู้ใช้ว่าได้ส่งอีเมลแล้ว และพากลับไปหน้า login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ສົ່ງລີ້ງປ່ຽນລະຫັດຜ່ານໄປຍັງອີເມລຮຽບຮ້ອຍແລ້ວ'),
        ),
      );
      Navigator.pop(context);

      //ถ้ามีข้อผิดพลาด (เช่น อีเมลไม่ถูกต้อง) แสดงข้อความ error
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );

      //กลับสถานะ _loading ให้เป็น false ไม่ว่าจะสำเร็จหรือไม่
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
          child: SingleChildScrollView( //ใช้ ScrollView เพื่อให้ฟอร์มเลื่อนได้บนหน้าจอเล็ก
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
                    'ລືມລະຫັດຜ່ານ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ປ້ອນອີເມລທີ່ໃຊ້ລົງທະບຽນເພື່ອຮັບລີ້ງປ່ຽນລະຫັດຜ່ານ',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  //ช่องกรอกอีเมล พร้อมตั้งค่าให้ใช้แป้นพิมพ์เฉพาะอีเมล
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ອີເມລ',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'ປ້ອນອີເມລຂອງທ່ານ',
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
                    child: ElevatedButton( //ถ้า _loading จะปิดปุ่มและแสดง วงกลมโหลด
                      onPressed: _loading ? null : _resetPassword,
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
                                'ສົ່ງລີ້ງປ່ຽນລະຫັດຜ່ານ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16), // เว้นระยะห่าง
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // ย้อนกลับไปหน้า Login
                      },
                      child: const Text(
                        'ກັບຄືນໜ້າເຂົ້າສູ່ລະບົບ',
                        style: TextStyle(color: Colors.white70),
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
