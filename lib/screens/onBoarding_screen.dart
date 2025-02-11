import 'package:flutter/material.dart';
import '../widgets/customButton.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Optional padding
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang Di\nAplikasi AutiVision',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Solusi Inovatif Untuk Deteksi Awal Autism\nSpectrum Disorder (ASD).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 80),
              SvgPicture.asset('assets/svgs/boardingPict.svg', width: 300),
              const SizedBox(height: 80),
              const Text(
                'Aplikasi Terbaik untuk Deteksi ASD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/logoBiru.png',
                width: 150,
              ),
              const SizedBox(height: 50),
              CustomButton(
                text: 'Lanjutkan',
                width: 350,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF034B6C),
                    Color(0xFF033B59),
                    Color(0xFF012139),
                  ],
                ),
                onPressed: () {
                  print('navigate to login');
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
