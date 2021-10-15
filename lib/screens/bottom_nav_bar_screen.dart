import 'package:fireauth/screens/book_finder_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class BottomNavScreen extends HookWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _animationcontroller = useAnimationController(
      initialValue: 1.0,
      duration: const Duration(milliseconds: 200),
    );
    final _animation = CurvedAnimation(
      parent: _animationcontroller,
      curve: Curves.easeInCubic,
    );
    final List<Widget> _screens = [
      AnimatedBuilder(
        animation: _animation,
        child: const BookFinderPage(),
        builder: (context, child) => FadeTransition(
          opacity: _animation,
          child: child,
        ),
      ),
      AnimatedBuilder(
        animation: _animation,
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
              child: TextButton(
                  onPressed: () async {
                    await _auth.signOut();
                  },
                  child: const Text('Sign out'))),
        ),
        builder: (context, child) => FadeTransition(
          opacity: _animation,
          child: child,
        ),
      )
    ];
    final _currentIndex = useState(0);

    return Scaffold(
      body: IndexedStack(
        children: _screens,
        index: _currentIndex.value,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.value,
        onTap: (index) {
          _currentIndex.value = index;
          _animationcontroller.reset();
          _animationcontroller.forward();
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedFontSize: 0.0,
        selectedFontSize: 0.0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 0.0,
        items: [Icons.home, Icons.person]
            .asMap()
            .map((key, value) => MapEntry(
                  key,
                  BottomNavigationBarItem(
                    label: key.toString(),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _currentIndex.value == key
                            ? Palette.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Icon(value),
                    ),
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }
}

class Palette {
  static const Color primaryColor = Color(0xFF473F97);
}
