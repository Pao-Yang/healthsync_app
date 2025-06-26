import 'package:flutter/material.dart';
import 'package:healthsync_app/screens/target_progress_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HealthSync',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  _buildButton(
                    context,
                    icon: Icons.fitness_center,
                    label: 'ເລີ່ມອອກກຳລັງກາຍ',
                    onPressed: () => Navigator.pushNamed(context, '/workout'),
                    color: Colors.tealAccent.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    context,
                    icon: Icons.bar_chart,
                    label: 'ປະຫວັດການອອກກຳລັງກາຍ',
                    onPressed:
                        () => Navigator.pushNamed(context, '/statistics'),
                    color: Colors.tealAccent.shade400,
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    context,
                    icon: Icons.assignment,
                    label: 'ປ້ອນຂໍ້ມູນສຸຂະພາບ',
                    onPressed:
                        () => Navigator.pushNamed(context, '/health_form'),
                    color: Colors.tealAccent.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    context,
                    icon: Icons.monitor_weight,
                    label: 'ເບິ່ງກຣາຟ BMI',
                    onPressed: () => Navigator.pushNamed(context, '/bmi_chart'),
                    color: Colors.tealAccent.shade400,
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    context,
                    icon: Icons.flag,
                    label: 'ຕັ້ງນໍ້າໜັກເປົ້າໝາຍ',
                    onPressed: () => Navigator.pushNamed(context, '/set_goal'),
                    color: Colors.tealAccent.shade700,
                  ),
                  const SizedBox(height: 16),
                  const TargetProgressCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: Colors.tealAccent.withOpacity(0.6),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87, // สีตัวหนังสือปุ่มให้เข้ากับปุ่มสีสว่าง
        ),
      ),
    );
  }
}
