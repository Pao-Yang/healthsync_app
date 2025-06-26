import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TargetProgressCard extends StatefulWidget {
  const TargetProgressCard({super.key});

  @override
  State<TargetProgressCard> createState() => _TargetProgressCardState();
}

class _TargetProgressCardState extends State<TargetProgressCard> {
  String? _targetWeight;
  double? _latestWeight;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final goalSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goal')
        .doc('main')
        .get();

    if (goalSnapshot.exists) {
      _targetWeight = goalSnapshot['targetWeight'].toString();
    }

    final latestSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (latestSnapshot.docs.isNotEmpty) {
      _latestWeight =
          double.tryParse(latestSnapshot.docs.first['weight'].toString());
    }

    setState(() {});
  }

  double? _calculateProgress() {
    if (_latestWeight == null || _targetWeight == null) return null;
    final target = double.tryParse(_targetWeight!);
    if (target == null) return null;

    final diff = (_latestWeight! - target).abs();
    if (diff == 0) return 1.0;

    return (1 - (diff / _latestWeight!)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    if (progress == null) {
      return const SizedBox(); // ยังโหลดไม่เสร็จหรือข้อมูลไม่พอ
    }

    final statusMessage = (_latestWeight! > double.parse(_targetWeight!))
        ? 'ເຈົ້າກຳລັງລົດນໍ້າໜັກ 💪'
        : (_latestWeight! < double.parse(_targetWeight!))
            ? 'ເຈົ້າກຳລັງເພີ່ມນໍ້າໜັກ 🍚'
            : 'ເຈົ້າເຖິງເປົ້າໝາຍແລ້ວ 🎯';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'ຄວາມຄືບຫນ້າໃນການ${_latestWeight! < double.parse(_targetWeight!) ? 'ເພີ່ມ' : 'ລົດ'}ນໍ້າໜັກ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: progress,
            animation: true,
            animationDuration: 800,
            center: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
            progressColor: Colors.tealAccent,
            backgroundColor: Colors.tealAccent.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Text(
            statusMessage,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
