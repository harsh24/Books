import 'package:fireauth/screens/auth_page.dart';
import 'package:fireauth/screens/book_detail_page.dart';
import 'package:fireauth/screens/book_finder_page.dart';
import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:fireauth/screens/favorites_page.dart';
import 'package:fireauth/service/responsive.dart';
import 'package:fireauth/service/google_books_provider.dart';
import 'package:fireauth/screens/search_results_page.dart';
import 'package:fireauth/service/profile_provider.dart';
import 'package:fireauth/screens/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //FirebaseFirestore.instance.useFirestoreEmulator('localhost', 9090);
  //FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  runApp(const AuthExampleApp());
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthExampleApp extends StatelessWidget {
  const AuthExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<GoogleBooksProvider>(
              create: (_) => GoogleBooksProvider('harry')),
          ChangeNotifierProvider<ProfileProvider>(
            create: (_) =>
                ProfileProvider(_auth.currentUser != null ? true : false),
          )
        ],
        child: MaterialApp(
          title: 'Firebase Example App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Palette.primaryColor,
                systemOverlayStyle: SystemUiOverlayStyle.dark),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Wrapper(user: _auth.currentUser != null ? true : false),
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
        ));
  }
}

Widget _buildRoute({
  required BuildContext context,
  required String? routeName,
  Object? arguments,
}) {
  switch (routeName) {
    case '/home':
      return ResponsiveWidget.isLargeScreen(context)
          ? const BookFinderPage()
          : const BottomNavScreen();

    case '/detail':
      final map = arguments as Map<String, dynamic>;
      final _book = map['book'];
      final _fav = map['fav'];

      return BookDetailsPage(book: _book, fav: _fav);

    case '/fav':
      return const FavoritesPage();

    case '/auth':
      final map = arguments as Map<String, dynamic>;
      final _type = map['type'];
      return AuthPage(type: _type);

    case '/results':
      final map = arguments as Map<String, dynamic>;
      final query = map['query'];

      return SearchResultsPage(query: query);

    default:
      return Container();
  }
}
