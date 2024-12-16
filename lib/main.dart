import 'package:flutter/material.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/provider/navigator_provider.dart';
import 'package:nibret/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(ToastificationWrapper(
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0668FE), width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
