import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterapp/services/auth/bloc/auth_event.dart';
import 'package:flutterapp/services/auth/bloc/auth_state.dart';
import 'package:flutterapp/utilities/dialog/error_dialog.dart';
import 'package:flutterapp/utilities/dialog/password_email_reset_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(
              context,
              'something went wrong!, please make sure you are registered user!',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Password Reset'),
          backgroundColor: Colors.amber,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'If you forgot your password enter your email below and hit reset , an email verification will be sent to you!',
                style: TextStyle(color: Colors.redAccent),
              ),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                    helperText: 'Please enter the email here'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context.read<AuthBloc>().add(
                        AuthEventForgotPassword(email: email),
                      );
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('back to login page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
