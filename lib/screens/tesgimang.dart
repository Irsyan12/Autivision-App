import 'package:flutter/material.dart';
import '../widgets/customButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText =
      true; // State untuk mengatur apakah teks kata sandi disembunyikan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoBiru.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nama Pengguna',
                          labelStyle: TextStyle(
                            fontSize: 12, // Ukuran font label
                            color: Colors.black
                                .withOpacity(0.5), // Warna dengan opacity
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          labelStyle: TextStyle(
                            fontSize: 12, // Ukuran font label
                            color: Colors.black
                                .withOpacity(0.5), // Warna dengan opacity
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Implement forgot password functionality
                          },
                          child: const Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Masuk',
                        width: double.infinity,
                        gradient: const RadialGradient(
                          center: Alignment(0.7, -0.6),
                          radius: 2.2,
                          colors: [
                            Color(0xFF033B59),
                            Color(0xFF034B6C),
                            Color(0xFF012139),
                          ],
                          stops: [0.3, 0.7, 1.0],
                        ),
                        onPressed: () {
                          // Implement login functionality
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text.rich(
                        TextSpan(
                          text: 'Belum Punya Akun? ',
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Daftar disini',
                              style: TextStyle(color: Colors.blue),
                              // Implement navigation to the registration screen
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.black45),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('Atau'),
                          ),
                          Expanded(
                            child: Divider(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Implement login with Google functionality
                        },
                        icon: Image.asset(
                          'assets/images/google_icon.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Masuk Dengan Google'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
