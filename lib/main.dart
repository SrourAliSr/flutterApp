import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(), //passing the viewed page
  ));
}

class HomePage extends StatelessWidget {
  //stateless is the widget that won't take changes and statefull is the opposite
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              final emailVerified = user?.emailVerified ?? false;

              if (emailVerified) {
                print('The the email adress is verified');
              } else {
                print('The email adress you are using is not verified!');
              }
              return const Text('Done');
            default:
              return const Text('loading');
          }
        },
      ),
    );
  }
}
