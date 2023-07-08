import 'package:flutter/material.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/services/auth/auth_services.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email verification'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 200, 0, 10),
        child: Center(
          child: Column(
            children: [
              const Text(
                  'we\'ve sent an email verification please verify your email adress'),
              TextButton(
                  onPressed: () async {
                    final user = AuthServices.firebase().currentUser;
                    await AuthServices.firebase().sendEmailVerification();
                    if (user != null) {
                      if (user.isEmailVerified) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute,
                          (route) => false,
                        );
                      }
                    }
                  },
                  child: const Text('Haven\'t recived the email? click here!')),
              TextButton(
                onPressed: () async {
                  await AuthServices.firebase().logOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    rigesterRoute,
                    (route) => false,
                  );
                },
                child: const Text('Restart'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
