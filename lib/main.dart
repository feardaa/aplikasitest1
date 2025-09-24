// main.dart
import 'package:aplikasitest1/view/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/order_controller.dart';
import 'services/auth_service.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderController(),
        ),
      ],
      child: MaterialApp(
        title: 'LaundryCuy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        routes: {
          '/admin': (context) => const AdminPanel(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
