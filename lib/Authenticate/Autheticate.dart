import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/Screens/HomeScreen.dart';
import 'package:first/Authenticate/LoginScree.dart';
import 'package:first/homepage.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return HomePage();
    } else {
      return LoginScreen();
    }
  }
}
