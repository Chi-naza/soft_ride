import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/auth/sign_in_screen.dart';
import 'package:soft_ride/constants/image_bank.dart';
import 'package:soft_ride/mainScreens/main_screen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  // splash screen implementation
  void startTimer(){
    Timer(const Duration(seconds: 5), () async{ 
      if(await fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }else {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> SignInScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(splashScreenImage),
              const SizedBox(height: 10),
              const Text(
                'Soft Ride',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}