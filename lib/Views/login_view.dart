// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.fromLTRB(100, 400, 100, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            print(userCredential);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              print('User Not Found!');
                            } else if (e.code == 'wrong-password') {
                              print('Wrong Password!');
                            }
                          }
                        },
                        child: const Text('Login'))
                  ],
                ),
              );
            default:
              return const Text('loading');
          }
        },
      ),
    );
  }
}
