import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _navigateAfterDelay(BuildContext context) async {
      final stopwatch = Stopwatch()..start();
      bool isLoggedIn = await _checkLoginStatus();
      await Future.delayed(const Duration(seconds: 2));
      print("Navigating after ${stopwatch.elapsedMilliseconds}ms");
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? '/main' : '/onBoarding',
        );
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigateAfterDelay(context);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFF033B59), Color(0xFF002038)],
          ),
        ),
        child: Center(
          child: Hero(
            tag: 'logo',
            child: Image.asset('assets/images/logoPutih.png',
                width: 200, height: 200),
          ),
        ),
      ),
    );
  }
}
