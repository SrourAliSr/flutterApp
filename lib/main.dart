import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/Views/email_verification_view.dart';
import 'package:flutterapp/Views/login_view.dart';
import 'package:flutterapp/Views/notes/create_update_note_view.dart';
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
      createUpdateNoteRout: (context) => const CreateUpdateNoteView(),
    }, //passing the viewed page
  ));
}

// class HomePage extends StatelessWidget {
//   //stateless is the widget that won't take changes and statefull is the opposite
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthServices.firebase().initialize(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthServices.firebase().currentUser;

//             if (user != null) {
//               if (user.isEmailVerified) {
//                 return const NotesView();
//               } else {
//                 return const LoginView();
//               }
//             } else {
//               return const LoginView();
//             }
//           default:
//             return const Scaffold(
//               body: SizedBox(
//                 width: double.infinity,
//                 height: double.infinity,
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//             );
//         }
//       },
//     );
//   }
// }
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('bloc counter'),
          backgroundColor: Colors.amber,
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          builder: (context, state) {
            final invalidValue =
                (state is CounterSatateInvalid ? state.invalidValue : '',);
            return Column(
              children: [
                Text('current value => ${state.value}'),
                Visibility(
                  visible: state is CounterSatateInvalid,
                  child: Text('invalid inpute $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter number',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_controller.text.isEmpty) {
                          _controller.text = 1.toString();
                        }
                        context.read<CounterBloc>().add(
                              DecrementEvent(_controller.text),
                            );
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_controller.text.isEmpty) {
                          _controller.text = 1.toString();
                        }
                        context.read<CounterBloc>().add(
                              IncrementEvent(_controller.text),
                            );
                      },
                      child: const Text('+'),
                    ),
                  ],
                )
              ],
            );
          },
          listener: (context, state) {
            _controller.clear();
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;

  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(super.value);
}

class CounterSatateInvalid extends CounterState {
  final String invalidValue;

  const CounterSatateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;

  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(super.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(
            CounterSatateInvalid(
              invalidValue: event.value,
              previousValue: state.value,
            ),
          );
        } else {
          emit(
            CounterStateValid(state.value + integer),
          );
        }
      },
    );
    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(
            CounterSatateInvalid(
              invalidValue: event.value,
              previousValue: state.value,
            ),
          );
        } else {
          emit(
            CounterStateValid(state.value - integer),
          );
        }
      },
    );
  }
}
