import 'package:flutter/material.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/services/auth/auth_%20exception.dart';
import 'package:flutterapp/services/auth/auth_services.dart';
import '../utilities/dialog/error_dialog.dart';

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
        title: const Text('Log in'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
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
                await AuthServices.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthServices.firebase().currentUser;
                if (user != null) {
                  if (user.isEmailVerified) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyRoute,
                      (route) => false,
                    );
                  }
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'User not founded!.',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'The password is incorrect!.',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Authentication error!.',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  rigesterRoute,
                  (route) => false,
                );
              },
              child: const Text('Not registerd yet? register here!'))
        ],
      ),
    );
  }
}
