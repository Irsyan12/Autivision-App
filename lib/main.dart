import 'package:autivision_v2/screens/detail_history.dart';
import 'package:autivision_v2/screens/forgotPassword_screen.dart';
import 'package:autivision_v2/services/history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onBoarding_screen.dart';
import 'screens/example_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/auth_provider.dart' as MyAuthProvider;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inisialisasi data lokal
  await initializeDateFormatting('id', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAuthProvider.AuthProvider()),
        Provider<HistoryService>(create: (_) => HistoryService()),
        // Add other providers if necessary
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutiVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) =>
            MainScreen(user: FirebaseAuth.instance.currentUser),
        '/signup': (context) => const SignupScreen(),
        '/onBoarding': (context) => const OnBoardingScreen(),
        '/example': (context) => const ExampleScreen(),
        '/detail': (context) => const DetailHistoryScreen(
              historyItem: {},
            ),
        '/history': (context) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return const HistoryScreen();
          } else {
            return const LoginScreen();
          }
        },
        '/profile': (context) => const ProfileScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
