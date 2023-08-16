import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/Views/email_verification_view.dart';
import 'package:flutterapp/Views/forgot_password_view.dart';
import 'package:flutterapp/Views/login_view.dart';
import 'package:flutterapp/Views/notes/create_update_note_view.dart';
import 'package:flutterapp/Views/register_view.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/helpers/loading/loading_screen.dart';
import 'package:flutterapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterapp/services/auth/bloc/auth_event.dart';
import 'package:flutterapp/services/auth/bloc/auth_state.dart';
import 'package:flutterapp/services/auth/firebase_auth_provider.dart';
import 'Views/notes/notes_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(255, 255, 255, 52),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              MaterialStatePropertyAll(Color.fromRGBO(152, 97, 220, 0.925)),
        ),
      ),
      primaryTextTheme: Typography.whiteCupertino,
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createUpdateNoteRout: (context) => const CreateUpdateNoteView(),
      '/login/': (context) => const LoginView(),
    }, //passing the viewed page
  ));
}

class HomePage extends StatelessWidget {
  //stateless is the widget that won't take changes and statefull is the opposite
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else {
        return Scaffold(
          body: Container(
              padding: const EdgeInsets.fromLTRB(250, 500, 0, 0),
              child: const CircularProgressIndicator()),
          backgroundColor: Colors.black,
        );
      }
    });
  }
}
