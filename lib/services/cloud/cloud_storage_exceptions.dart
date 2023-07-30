class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

// C in crud
class CouldNotCraeteNoteException extends CloudStorageExceptions {}
// R in crud

class CouldNotGetAllNotesException extends CloudStorageExceptions {}
// U in crud

class CouldNotUpdateNotesException extends CloudStorageExceptions {}

// D in crud
class CouldNotDeleteNotesException extends CloudStorageExceptions {}
