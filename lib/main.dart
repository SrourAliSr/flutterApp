import 'package:flutter/material.dart';
import 'package:flutterapp/Views/email_verification_view.dart';
import 'package:flutterapp/Views/login_view.dart';
import 'package:flutterapp/Views/notes/new_note_view.dart';
import 'package:flutterapp/Views/register_view.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/services/auth/auth_services.dart';
import 'Views/notes/notes_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      rigesterRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyRoute: (context) => const VerifyEmailView(),
      newNewRout: (context) => const NewNoteView(),
    }, //passing the viewed page
  ));
}

class HomePage extends StatelessWidget {
  //stateless is the widget that won't take changes and statefull is the opposite
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthServices.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const LoginView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const Scaffold(
              body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
        }
      },
    );
  }
}
