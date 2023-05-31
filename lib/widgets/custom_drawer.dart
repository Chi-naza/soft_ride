import 'package:flutter/material.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/intro/splash_screen.dart';

class MyDrawerWidget extends StatefulWidget {
  String? name;
  String? email;

  MyDrawerWidget({super.key, this.name, this.email});

  @override
  State<MyDrawerWidget> createState() => _MyDrawerWidgetState();
}

class _MyDrawerWidgetState extends State<MyDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  // Icon  - Person
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User's name
                      Text(
                        widget.name!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // User's email
                      Text(
                        widget.email!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const  SizedBox(height: 12.0),
          // History
          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(Icons.history, color: Colors.white54,),
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.white54
                ),
              ),
            ),
          ),
          // Visit Profile
          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.white54,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          ),
          // About
          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.white54,),
              title: Text(
                "About",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          ),
          // Sign Out
          GestureDetector(
            onTap: () {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.white54,),
              title: Text(
                "Sign Out",
                style: TextStyle(
                    color: Colors.white54
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}