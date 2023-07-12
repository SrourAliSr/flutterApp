import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

// Notes Database query /create /delete /read /open db /close db
class NotesService {
  Database? _db;
  List<DataBaseNote> _notes = [];
  final _notesStreamController =
      StreamController<List<DataBaseNote>>.broadcast();

  Stream<List<DataBaseNote>> get allNotes => _notesStreamController.stream;

  static final NotesService _shared = NotesService._sharedInstace();
  NotesService._sharedInstace();
  factory NotesService() => _shared;

  Future<DataBaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFoundUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DataBaseNote> updateNote({
    required DataBaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw DidNotUpdateTheNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DataBaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final result = notes.map((noteRow) => DataBaseNote.fromRow(noteRow));

    return result;
  }

  Future<DataBaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFoundNotes();
    } else {
      final note = DataBaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DataBaseNote> createNote({required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(
      email: owner.email,
    );
    if (dbUser != owner) {
      throw CouldNotFoundUser();
    } else {
      const text = '';
      final noteId = await db.insert(
        noteTable,
        {
          idColumn: owner.id,
          textColumn: text,
          isSyncedWithCloudColumn: 1,
        },
      );
      final note = DataBaseNote(
        id: noteId,
        userId: owner.id,
        text: text,
        isSyncedWithCloud: true,
      );
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<DataBaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFoundUser();
    } else {
      return DataBaseUser.fromRow(results.first);
    }
  }

  Future<DataBaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: ' email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final userId =
          await db.insert(userTable, {emailColumn: email.toLowerCase()});

      return DataBaseUser(
        id: userId,
        email: email,
      );
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpenException();
    } else {
      try {
        final docsPath = await getApplicationDocumentsDirectory();
        final dbPath = join(docsPath.path, dbName);
        final db = await openDatabase(dbPath);
        _db = db;

        //created a constant user table with the constants down below
        await db.execute(creatUserTable);

        //created a constant note table with the constants down below
        await db.execute(creatNoteTable);
        await _cachedNotes();
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocmunetsDirectory();
      }
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DataBaseAlreadyOpenException {}
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Persons id : $id , Persons email : $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DataBaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DataBaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'id is : $id , user id is : $userId, is synced with cloud : $isSyncedWithCloud';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const creatNoteTable = '''CREATE TABLE IF NOT EXISTS "Note" (
                  "id"	INTEGER NOT NULL,
                  "User_id"	INTEGER NOT NULL,
                  "text"	TEXT,
                  "is_synced_with_cloud"	INTEGER DEFAULT 0,
                  PRIMARY KEY("id" AUTOINCREMENT),
                  FOREIGN KEY("User_id") REFERENCES "User"("id")
                   ); ''';

const creatUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
                  "id"	INTEGER NOT NULL,
                  "email"	TEXT NOT NULL UNIQUE,
                  PRIMARY KEY("id" AUTOINCREMENT)
                  );''';
