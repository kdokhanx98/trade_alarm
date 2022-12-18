import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trade_alarm/pages/home.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const MyHomePage())));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/app_icon_nobg.png',
            width: 300,
            height: 300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Trade',
                style: TextStyle(color: Color(0xffF27C08), fontSize: 32),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Alarm',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ],
          )
        ],
      )),
    );
  }
}
