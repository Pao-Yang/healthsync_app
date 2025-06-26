import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/health_form_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/bmi_chart_screen.dart';
import 'screens/set_target_weight_screen.dart';
import 'screens/forgot_password_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    
  );

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Kanit', // ถ้าคุณใช้ภาษาไทย
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(), // แทน Placeholder ด้วย LoginScreen
        '/register': (context) => const RegisterScreen(), // เพิ่มเส้นทางสมัคร
        '/dashboard': (context) => const DashboardScreen(), // ✅ เพิ่มตรงนี้
        '/workout': (context) => const WorkoutScreen(), // ✅ เพิ่มตรงนี้
        '/statistics': (context) => const StatisticsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/health_form': (context) => const HealthFormScreen(), // ✅ เพิ่มตรงนี้
        '/bmi_chart': (context) => const BMIChartScreen(),
        '/set_goal': (context) => const SetTargetWeightScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        


      },
    );
  }
}
