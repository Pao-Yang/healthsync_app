import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "เริ่มต้น",
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
