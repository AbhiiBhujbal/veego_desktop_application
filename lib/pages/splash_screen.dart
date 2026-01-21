import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veego_desktop_application/screen/home_main_screen.dart';

import '../constant/constant.dart';

class SplashScreen extends StatefulWidget{
  _SplashScreenState createState()=>_SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  String currentMessage = "Starting....";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoadingSequence();
    _navigateToHome();

  }

  void _startLoadingSequence() {
    _timer = Timer.periodic(Duration(seconds: 0), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeMainScreen()),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/veego-logo.png',
              height: 100,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            ),
            SizedBox(height: 20),
            Text(
              currentMessage,
              style: TextStyle(fontSize: 16, color: loaderColor),
            ),
          ],
        ),
      ),
    );
  }
}



