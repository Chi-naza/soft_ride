import 'package:flutter/material.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/auth/sign_in_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(child: Text('Main Screen'), onTap: (){
          fAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => SignInScreen()));
          print('Signing out . . .');
        },),
      ),
    );
  }
}