import 'package:flutter/material.dart';
import 'package:nibret/screens/layout_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  void _navigateToMain() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove SafeArea since it's not needed here
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Image.asset('assets/Logo.png', height: 99, width: 120),
        ),
      ),
    );
  }
}
