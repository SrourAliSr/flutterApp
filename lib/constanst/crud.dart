const dbName = 'note.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'User_id';
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
