import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'password'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _email.text,
                  password: _password.text,
                );
                final user = FirebaseAuth.instance.currentUser;
                user?.sendEmailVerification();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(verifyRoute);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'week-password') {
                  await showErrorDialog(
                    context,
                    e.code,
                  );
                } else if (e.code == 'email-already-in-use') {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _email.text,
                      password: _password.text,
                    );
                  } on FirebaseAuthException catch (a) {
                    if (a.code == 'wrong-password') {
                      await showErrorDialog(
                        context,
                        a.code,
                      );
                    } else {}
                  }
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    if (user.emailVerified) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    } else {
                      final users = FirebaseAuth.instance.currentUser;
                      users?.sendEmailVerification();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).restorablePushNamedAndRemoveUntil(
                        verifyRoute,
                        (route) => false,
                      );
                    }
                  }
                } else if (e.code == 'invalid-email') {
                  await showErrorDialog(
                    context,
                    e.code,
                  );
                } else {
                  await showErrorDialog(
                    context,
                    e.code,
                  );
                }
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('go back to Login'))
        ],
      ),
    );
  }
}
