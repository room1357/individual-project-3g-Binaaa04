import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/home_screen.dart';
import 'package:pemrograman_mobile/screens/login_screen.dart';
import 'package:pemrograman_mobile/services/auth.dart';
import 'package:pemrograman_mobile/services/database_service.dart';
import 'package:pemrograman_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          title: 'Track Your Cash, Master Your Life',
          theme: AppTheme.lightTheme,
          home: auth.isAuth
              ? HomeScreen(username: auth.currentUser!.username)
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                        backgroundColor: AppTheme.backgroundColor,
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
