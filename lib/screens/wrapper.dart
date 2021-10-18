import 'package:fireauth/repository/db.dart';
import 'package:fireauth/screens/book_finder_page.dart';
import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:fireauth/screens/landing_page.dart';
import 'package:fireauth/service/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key, required this.user}) : super(key: key);

  final bool user;

  @override
  Widget build(BuildContext context) {
    if (user) {
      Database.userUid = _auth.currentUser!.uid;
    }
    return user
        ? ResponsiveWidget.isLargeScreen(context)
            ? const BookFinderPage()
            : const BottomNavScreen()
        : const LandingPage();
  }
}
