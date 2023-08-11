import 'package:flutter/material.dart';
import 'package:flutterapp/services/cloud/cloud_note.dart';
import 'package:share_plus/share_plus.dart';
import '../../utilities/dialog/delete_dialog.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.notes.length,
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      itemBuilder: (context, index) {
        final note = widget.notes.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Dismissible(
              background: Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Icon(
                  Icons.share,
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete),
              ),
              key: ValueKey<CloudNote>(widget.notes.elementAt(index)),
              onDismissed: (DismissDirection direction) async {
                setState(() {});

                switch (direction) {
                  case DismissDirection.startToEnd:
                    Share.share(widget.notes.elementAt(index).toString());
                    break;
                  case DismissDirection.endToStart:
                    bool check = await showDeleteDialog(context);
                    if (check == true) {
                      widget.onDeleteNote(note);
                    }
                    break;
                  default:
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                onTap: () {
                  widget.onTap(note);
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      width: 3, color: Color.fromARGB(255, 233, 189, 56)),
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
