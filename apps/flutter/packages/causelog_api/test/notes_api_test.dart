import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for NotesApi
void main() {
  final instance = Openapi().getNotesApi();

  group(NotesApi, () {
    // Quick capture (note, observation, or decision draft)
    //
    //Future<CaptureResponse> capture(CaptureRequest captureRequest, { String idempotencyKey }) async
    test('test capture', () async {
      // TODO
    });

    // Compare two note revisions (Markdown diff)
    //
    //Future<RevisionComparison> compareNoteRevisions(String noteId, String from, String to) async
    test('test compareNoteRevisions', () async {
      // TODO
    });

    // Create a note (appends initial revision)
    //
    //Future<Note> createNote(String projectId, NoteCreateRequest noteCreateRequest, { String idempotencyKey }) async
    test('test createNote', () async {
      // TODO
    });

    // Delete a note
    //
    //Future deleteNote(String noteId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteNote', () async {
      // TODO
    });

    // Get a note
    //
    //Future<Note> getNote(String noteId) async
    test('test getNote', () async {
      // TODO
    });

    // List note revisions (newest first)
    //
    //Future<RevisionPage> listNoteRevisions(String noteId) async
    test('test listNoteRevisions', () async {
      // TODO
    });

    // List notes
    //
    //Future<NotePage> listNotes(String projectId, { int page, int perPage }) async
    test('test listNotes', () async {
      // TODO
    });

    // Update a note (appends revision)
    //
    //Future<Note> updateNote(String noteId, NoteUpdateRequest noteUpdateRequest, { String idempotencyKey }) async
    test('test updateNote', () async {
      // TODO
    });

  });
}
