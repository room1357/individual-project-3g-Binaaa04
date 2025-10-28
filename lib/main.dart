import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/home_screen.dart';
import 'package:pemrograman_mobile/screens/login_screen.dart';
import 'package:pemrograman_mobile/services/auth.dart';
import 'package:pemrograman_mobile/services/database_service.dart';
import 'package:pemrograman_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize default categories via API
  final db = AppDb();
  await db.initializeDefaultCategories();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Track Your Money',
          theme: AppTheme.lightTheme,
          home: auth.isAuth
              ? HomeScreen(username: auth.currentUser!.username)
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _SplashScreen();
                    } else {
                      return const LoginScreen();
                    }
                  },
                ),
        );
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // Background biru
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dengan ukuran yang cukup besar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 60,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator dengan persentase
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
