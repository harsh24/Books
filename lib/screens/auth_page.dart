import 'package:fireauth/handler/auth_exception_handler.dart';
import 'package:fireauth/screens/book_finder_page.dart';
import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:fireauth/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _auth = FirebaseAuth.instance;

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _type = true;
  int _success = 0;
  bool _passvisible = false;
  String _userEmail = '';
  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthResultStatus? _status;

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      setState(() {
        _success = 1;
        _userEmail = user!.email!;
      });
    } catch (e) {
      _status = AuthExceptionHandler.handleException(e);
      setState(() {
        _success = -1;
      });
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user!;
      setState(() {
        _success = 1;
        _userEmail = user!.email!;
      });
    } catch (e) {
      _status = AuthExceptionHandler.handleException(e);
      if (_status.toString() == 'AuthResultStatus.wrongPassword') {
        setState(() {
          _success = -2;
        });
      } else {
        setState(() {
          _success = -2;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
        ],
      );
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);
        final User user = (await _auth.signInWithCredential(credential)).user!;
        setState(() {
          _success = 1;
        });
      } else {
        print(result.status);
        print(result.message);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .25,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(64.0),
                    bottomRight: Radius.circular(64.0)),
                color: Colors.black,
              ),
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  Padding(
                    key: UniqueKey(),
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(
                      _type ? 'Sign up' : 'Sign in',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 32.0,
                      bottom: 16.0,
                    ),
                    child: Text(
                      _type ? 'Welcome to Books' : 'Welcome back',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 8.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _emailController,
                      validator: (String? value) {
                        if (!isEmail(value) || value!.isEmpty) {
                          return 'Please enter an email address.';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        errorText: _success == -1
                            ? AuthExceptionHandler.generateExceptionMessage(
                                _status)
                            : null,
                        labelText: 'Email address',
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 24.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _passvisible,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorText: _success == -2
                            ? AuthExceptionHandler.generateExceptionMessage(
                                _status)
                            : null,
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _passvisible = !_passvisible),
                            icon: Icon(
                              _passvisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            )),
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  isLoading
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xff171717)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                )),
                            child: Text(_type ? 'Create account' : 'Sign in'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = !isLoading;
                                });
                                _type
                                    ? await _register()
                                    : await _signInWithEmailAndPassword();
                                setState(() {
                                  isLoading = !isLoading;
                                });
                                if (_success == 1) {
                                  Navigator.of(context)
                                      .popAndPushNamed('/home');
                                }
                              }
                            },
                          ))
                      : const Center(child: CircularProgressIndicator()),
                  const Center(child: Text('Or')),
                  Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.facebook),
                        label: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 4.0),
                          child: Text('Continue with Facebook'),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF1877f2)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                //side: BorderSide(color: Colors.red),
                              ),
                            )),
                        onPressed: () async {
                          await _signInWithFacebook();

                          if (_success == 1) {
                            Navigator.of(context).popAndPushNamed('/home');
                            //_pushPage(context, const BottomNavScreen());
                          }
                        },
                      )),
                  Container(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        icon: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: const Image(
                            image: AssetImage('assets/images/google.png'),
                            height: 36.0,
                          ),
                        ),

                        label: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Text(
                            'Continue with Google',
                            style:
                                TextStyle(color: Color.fromRGBO(0, 0, 0, 0.54)),
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFFFFFFFF)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                //side: BorderSide(color: Colors.red),
                              ),
                            )),
                        // child: const Text('Create account'),
                        onPressed: () {},
                      )),
                  const SizedBox(height: 20.0),
                  Center(
                      child: GestureDetector(
                          onTap: () => setState(() {
                                _type = !_type;
                              }),
                          child: Text(_type
                              ? 'Already have an account? Log in.'
                              : 'Don\'t have an account? Create one.'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
