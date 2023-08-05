import 'package:flutter/material.dart';
import 'package:flutterapp/services/auth/auth_services.dart';
import 'package:flutterapp/utilities/dialog/cannot_share_empty_note_dialog.dart';
import 'package:flutterapp/utilities/generics/get_arguments.dart';
import 'package:flutterapp/services/cloud/cloud_note.dart';
import 'package:flutterapp/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> getOrCreateExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final currentNote = _note;
    if (currentNote != null) {
      return currentNote;
    }
    final user = AuthServices.firebase().currentUser!;
    final userId = user.id;
    final newNote = await _notesService.createNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpyt() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
          documentId: note.documentId, text: _textController.text);
    }
  }

  @override
  void dispose() {
    _saveNoteIfTextIsNotEmpyt();
    _deleteNoteIfEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
          backgroundColor: Colors.amber,
          actions: [
            IconButton(
              onPressed: () async {
                final text = _textController.text;
                if (_note == null && text.isEmpty) {
                  await cannotShareEmptyNoteDialog(context);
                } else {
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getOrCreateExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.done:
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      const InputDecoration(hintText: 'enter the note!'),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
