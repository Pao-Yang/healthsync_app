import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SetTargetWeightScreen extends StatefulWidget {
  const SetTargetWeightScreen({super.key});

  @override
  State<SetTargetWeightScreen> createState() => _SetTargetWeightScreenState();
}

class _SetTargetWeightScreenState extends State<SetTargetWeightScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _currentTarget;
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

    final goalSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('goal')
            .doc('main')
            .get();

    if (goalSnapshot.exists) {
      final weight = goalSnapshot['targetWeight'].toString();
      setState(() {
        _currentTarget = weight;
        _controller.text = weight;
      });
    }

    final latestSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('health_data')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (latestSnapshot.docs.isNotEmpty) {
      final latest = double.tryParse(
        latestSnapshot.docs.first['weight'].toString(),
      );
      setState(() => _latestWeight = latest);
    }
  }

  Future<void> _saveTargetWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final targetWeight = double.tryParse(_controller.text);
    if (targetWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນນໍ້າໜັກເປົ້າໝາຍໃຫ້ຖືກຕ້ອງ')),
      );
      return;
    }

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('goal')
        .doc('main')
        .set({
          'targetWeight': targetWeight,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    setState(() {
      _loading = false;
      _currentTarget = _controller.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ບັນທຶກເປົ້າໝາຍສຳເລັດແລ້ວ')),
    );
  }

  double? _calculateProgress() {
    if (_latestWeight == null || _currentTarget == null) return null;
    final target = double.tryParse(_currentTarget!);
    if (target == null) return null;

    final diff = (_latestWeight! - target).abs();
    if (diff == 0) return 1.0;

    final progress = 1 - (diff / _latestWeight!);
    return progress.clamp(0.0, 1.0);
  }

  String getStatusMessage() {
    if (_latestWeight == null || _currentTarget == null) return '';
    final target = double.tryParse(_currentTarget!);
    if (target == null) return '';

    if (_latestWeight! > target) {
      return 'ເຈົ້າກຳລັງລົດນໍ້າໜັກ 💪';
    } else if (_latestWeight! < target) {
      return 'ເຈົ້າກຳລັງເພີ່ມນໍ້າໜັກ 🍚';
    } else {
      return 'ເຈົ້າເຖິງເປົ້າໝາຍແລ້ວ 🎯';
    }
  }

  String? getSuggestion(double progress) {
    if (progress < 0.5) {
      return 'ຍັງຫ່າງຈາກເປົ້າໝາຍຫຼາຍ ລອງປັບອາຫານ ແລະ ອອກກຳລັງກາຍເພີ່ມເຕີມ!';
    } else if (progress >= 1.0) {
      return 'ຍີນດີ! ເຈົ້າເຖິງເປົ້າໝາຍແລ້ວ 🎉 ຮັກສາໄວ້ໃຫ້ໄດ້';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final statusMessage = getStatusMessage();
    final suggestion = progress != null ? getSuggestion(progress) : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ຕັ້ງເປົ້າໝາຍ'),
        backgroundColor: Colors.teal[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ຕັ້ງນໍ້າໜັກເປົ້າໝາຍ (kg):',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ເຊັ່ນ: 60.0',
                  hintStyle: TextStyle(
                    color: Colors.tealAccent.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveTargetWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'ບັນທຶກ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // <-- เพิ่มตรงนี้
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 32),
              if (_currentTarget != null)
                Text(
                  'ເປົ້າໝາຍຂອງເຈົ້າຄື $_currentTarget kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.tealAccent,
                  ),
                ),
              if (_latestWeight != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'ນໍ້າໜັກລ່າສຸດຂອງເຈົ້າຄື $_latestWeight kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              if (progress != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ຄວາມຄືບຫນ້າໃນການ${_latestWeight! < double.parse(_currentTarget!) ? 'ເພີ່ມນໍ້າໜັກ' : 'ລົດນໍ້າໜັກ'}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: CircularPercentIndicator(
                        radius: 90,
                        lineWidth: 14,
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
                    ),
                    const SizedBox(height: 20),
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (suggestion != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
