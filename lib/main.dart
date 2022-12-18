import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trade_alarm/pages/splash.dart';
import 'notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    NotificaitonService.setupFlutterNotifications();
  } catch (e) {
    log('error setupping flutter notification ${e.toString()}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trade Alarm',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashPage(),
    );
  }
}
