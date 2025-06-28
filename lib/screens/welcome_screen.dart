import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key}); //super.key คือการส่ง key ไปยังคลาสแม่

  @override
  Widget build(BuildContext context) {
    //Scaffold เป็น widget ที่ให้โครงสร้างหน้าจอพื้นฐาน เช่น app bar, body, drawer เป็นต้น
    return Scaffold( 
      // Stack คือ widget ที่ใช้ซ้อน widget หลาย ๆ ตัวบนหน้าจอ (เหมือนชั้น ๆ)
      body: Stack(
        children: [
          // รูปพื้นหลังเต็มจอ
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.png',  // ใช้ภาพนี้เป็น background
              fit: BoxFit.cover,          // ให้เต็มหน้าจอแบบ cover
            ),
          ),

          // Overlay สีดำโปร่งแสงเพื่อให้อ่านข้อความง่ายขึ้น
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // เนื้อหาด้านหน้า
          //SafeArea ป้องกันไม่ให้ widget ชิดขอบหน้าจอเกินไป (กันชนตรง notch, status bar, etc.)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ลบรูปโลโก้ออกไปเพราะใช้เป็น background แล้ว
                    const SizedBox(height: 100), // ถ้าต้องการเว้นที่ว่าง

                    const Text(
                      "HealthSync",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 400),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal.shade800,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "ເລີ່ມຕົ້ນ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
