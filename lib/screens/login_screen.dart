import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../providers/auth_provider.dart';
import '../widgets/customButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                HeroLogo(),
                SizedBox(height: 50),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroLogo extends StatelessWidget {
  const HeroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Image.asset(
        'assets/images/logoBiru.png',
        width: 150,
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _passwordError;
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            EmailField(controller: _emailController),
            const SizedBox(height: 20),
            PasswordField(
              controller: _passwordController,
              obscureText: _obscureText,
              toggleObscureText: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              errorText: _passwordError,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implement forgot password functionality
                  Navigator.pushNamed(context, '/forgotPassword');
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
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF034B6C),
                  Color(0xFF033B59),
                  Color(0xFF012139),
                ],
              ),
              isLoading: _isLoading, // Pass loading state to the button
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                    _passwordError = null;
                  });

                  String email = _emailController.text;
                  String password = _passwordController.text;
                  try {
                    await authProvider.signInWithEmail(email, password);
                    if (authProvider.user != null) {
                      Navigator.pushNamed(context, '/main');
                    } else {
                      setState(() {
                        _passwordError = 'Kata sandi salah';
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _passwordError = 'Kata sandi salah';
                    });
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            const SignupPrompt(),
            const SizedBox(height: 20),
            const DividerWithText(text: 'Atau'),
            const SizedBox(height: 20),
            GoogleSignInButton(authProvider: authProvider),
          ],
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email tidak boleh kosong';
        }
        // Trim input value to remove extra spaces
        String trimmedValue = value.trim();
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedValue)) {
          return 'Masukkan format email yang valid';
        }

        return null;
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleObscureText;
  final String? errorText;

  const PasswordField({super.key, 
    required this.controller,
    required this.obscureText,
    required this.toggleObscureText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: 'Kata Sandi',
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.black.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleObscureText,
        ),
        errorText: errorText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kata sandi tidak boleh kosong';
        }
        return null;
      },
    );
  }
}

class SignupPrompt extends StatelessWidget {
  const SignupPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Belum Punya Akun? ',
        style: const TextStyle(color: Colors.black54),
        children: [
          TextSpan(
            text: 'Daftar disini',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/signup');
              },
          ),
        ],
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Colors.black45),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(text),
        ),
        const Expanded(
          child: Divider(color: Colors.black45),
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final AuthProvider authProvider;

  const GoogleSignInButton({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await authProvider.signInWithGoogle();
          if (authProvider.user != null) {
            Navigator.pushNamed(context, '/main');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login dengan Google gagal')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login dengan Google gagal: $e')),
          );
        }
      },
      icon: SvgPicture.asset('assets/svgs/google_icon.svg', width: 30),
      label: const Text('Masuk Dengan Google',
          style: TextStyle(fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
