import 'package:flutter/material.dart';
import 'package:flutterapp/services/auth/auth_services.dart';
import 'package:flutterapp/services/crud/notes_service.dart';
import '../../constanst/routes.dart';
import '../../enums/menu_action.dart';
import '../../utilities/show_error_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthServices.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  void deltedatabase() {
    _notesService.deleteAllNotes();
    _notesService.clearTable('note');
    _notesService.clearTable('user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your notes'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () => deltedatabase(),
            icon: const Icon(Icons.remove),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNewRout);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logOut = await showLogOutDialog(context);
                  if (logOut) {
                    await AuthServices.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
                  break;
                default:
                  await showErrorDialog(
                    context,
                    'Error occured!',
                  );
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DataBaseNote>;
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final notess = allNotes[index];
                            return ListTile(
                              title: Text(
                                notess.text,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              hoverColor: Colors.amber,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }

                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('sign out'),
        content: const Text('Are you sure you want to signout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Canel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('confirm'),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}
