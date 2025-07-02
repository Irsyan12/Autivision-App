import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_config.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forgotPassword_screen.dart';
import 'screens/onBoarding_screen.dart';
import 'screens/example_screen.dart';
import 'screens/detail_history.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'services/history_service.dart';
import 'providers/auth_provider.dart' as my_auth_provider;
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: getFirebaseOptions());
  await initializeDateFormatting('id', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth_provider.AuthProvider()),
        Provider<HistoryService>(create: (_) => HistoryService()),
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
        '/signup': (context) => const SignupScreen(),
        '/main': (context) =>
            MainScreen(user: FirebaseAuth.instance.currentUser),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/onBoarding': (context) => const OnBoardingScreen(),
        '/example': (context) => const ExampleScreen(),
        '/detail': (context) => const DetailHistoryScreen(historyItem: {}),
        '/history': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user != null ? const HistoryScreen() : const LoginScreen();
        },
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
