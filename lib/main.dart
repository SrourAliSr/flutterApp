import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/Views/email_verification_view.dart';
import 'package:flutterapp/Views/login_view.dart';
import 'package:flutterapp/Views/notes/create_update_note_view.dart';
import 'package:flutterapp/Views/register_view.dart';
import 'package:flutterapp/constanst/routes.dart';
import 'package:flutterapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterapp/services/auth/bloc/auth_event.dart';
import 'package:flutterapp/services/auth/bloc/auth_state.dart';
import 'package:flutterapp/services/auth/firebase_auth_provider.dart';
import 'Views/notes/notes_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      loginRoute: (context) => const LoginView(),
      rigesterRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyRoute: (context) => const VerifyEmailView(),
      createUpdateNoteRout: (context) => const CreateUpdateNoteView(),
    }, //passing the viewed page
  ));
}

class HomePage extends StatelessWidget {
  //stateless is the widget that won't take changes and statefull is the opposite
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else {
        return Scaffold(
          body: Container(
              padding: const EdgeInsets.fromLTRB(250, 500, 0, 0),
              child: const CircularProgressIndicator()),
        );
      }
    });
  }
}
