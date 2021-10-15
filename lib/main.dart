import 'package:fireauth/screens/auth_page.dart';
import 'package:fireauth/screens/book_detail_page.dart';
import 'package:fireauth/screens/book_finder_page.dart';
import 'package:fireauth/extra/registerpage.dart';
import 'package:fireauth/extra/sign.dart';
import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:fireauth/screens/favorites_page.dart';
import 'package:fireauth/screens/search_results_page.dart';
import 'package:fireauth/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const AuthExampleApp());
}

class AuthExampleApp extends StatelessWidget {
  const AuthExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Example App',
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.dark(),
      home: const Wrapper(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return _buildRoute(
                context: context,
                routeName: settings.name,
                arguments: settings.arguments);
          },
          maintainState: true,
          fullscreenDialog: false,
        );
      },
    );
  }
}

Widget _buildRoute({
  required BuildContext? context,
  required String? routeName,
  Object? arguments,
}) {
  switch (routeName) {
    case '/home':
      return const BottomNavScreen();

    case '/detail':
      final map = arguments as Map<String, dynamic>;
      final _book = map['book'];
      final _fav = map['fav'];

      return BookDetailsPage(
        book: _book,
        fav: _fav,
      );

    case '/fav':
      return const FavoritesPage();

    case '/auth':
      return const AuthPage();

    case '/results':
      final map = arguments as Map<String, dynamic>;
      final results = map['results'];

      return SearchResultsPage(
        results: results,
      );

    default:
      return Container();
  }
}

/// Provides a UI to select a authentication type page
class AuthTypeSelector extends StatelessWidget {
  const AuthTypeSelector({Key? key}) : super(key: key);

  // Navigates to a new page
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Example App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SignInButtonBuilder(
              icon: Icons.person_add,
              backgroundColor: Colors.indigo,
              text: 'Registration',
              onPressed: () => _pushPage(context, const RegisterPage()),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SignInButtonBuilder(
              icon: Icons.verified_user,
              backgroundColor: Colors.orange,
              text: 'Sign In',
              onPressed: () => _pushPage(context, SignInPage()),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SignInButtonBuilder(
              backgroundColor: Colors.green,
              text: 'Home',
              onPressed: () => _pushPage(context, const BookFinderPage()),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SignInButtonBuilder(
              backgroundColor: Colors.green,
              text: 'Auth',
              onPressed: () => _pushPage(context, const AuthPage()),
            ),
          ),
        ],
      ),
    );
  }
}
