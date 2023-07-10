import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterapp/services/auth/auth_%20exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

//Exceptions classes
class DataBaseAlreadyOpenException implements Exception {}

class UnableToGetDocmunetsDirectory implements Exception {}

class DataBaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFoundUser implements Exception {}

class CouldNotDeleteNote implements Exception {}

class CouldNotFoundNotes implements Exception {}

class DidNotUpdateTheNote implements Exception {}

// Notes Database query /create /delete /read /open db /close db
class NotesService {
  Database? _db;

  Future<DataBaseNote> updateNote({
    required DataBaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw DidNotUpdateTheNote();
    } else {
      await getNote(id: note.id);
    }
  }

  Future<Iterable<DataBaseNote>> getAllNotes() async {
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
      return DataBaseNote.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DataBaseNote> createNote({required DataBaseUser owner}) async {
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
      return note;
    }
  }

  Future<DataBaseUser> getUser({required String email}) async {
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

  Future<void> createUser({required String email}) async {
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
      DataBaseUser(
        id: userId,
        email: email,
      );
    }
  }

  Future<void> deleteUser({required String email}) async {
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
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocmunetsDirectory();
      }
    }
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
