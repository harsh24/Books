import 'package:fireauth/repository/db.dart';
import 'package:fireauth/screens/book_finder_page.dart';
import 'package:fireauth/main.dart';
import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  @override
  void initState() {
    super.initState();
    //Listen to Auth State changes
    FirebaseAuth.instance
        .authStateChanges()
        .listen((event) => updateUserState(event));
  }

  //Updates state when user state changes in the app
  updateUserState(event) {
    setState(() {
      user = event;
      Database.userUid = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    //return const AuthTypeSelector();

    if (user == null) {
      return const AuthTypeSelector();
    } else {
      return const BottomNavScreen();
    }
  }
}
