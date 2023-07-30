import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/constanst/crud.dart';
import 'package:flutterapp/services/cloud/cloud_note.dart';
import 'package:flutterapp/services/cloud/cloud_storage_constants.dart';
import 'package:flutterapp/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update(
        {textFieldName: text},
      );
    } catch (e) {
      throw CouldNotUpdateNotesException();
    }
  }

  Stream<Iterable<CloudNote>> getAllNotes({required String ownerUsereId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map((doc) => CloudNote.fromSnapshot(doc))
                .where((note) => note.ownerUserId == ownerUsereId),
          );

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieledName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map(
              (docs) {
                return CloudNote(
                  documentId: docs.id,
                  ownerUserId: docs.data()[ownerUserIdFieledName] as String,
                  text: docs.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNoteI({required String ownerUserId}) async {
    await notes.add(
      {
        ownerUserIdFieledName: userIdColumn,
        textFieldName: '',
      },
    );
  }
}
