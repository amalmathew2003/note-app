import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A reference to the 'notes' collection
  CollectionReference get notesCollection => _firestore.collection('notes');

  // 📝 Add note (auto-generates title from first few words)
  Future<void> addNote(String content) async {
    await notesCollection.add({
      'title': content.split(' ').take(3).join(' '),
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  // 🆕 Add note with user-defined title
  Future<void> addNoteWithTitle(String title, String content) async {
    await notesCollection.add({
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  // 🔁 Stream all notes (latest first)
  Stream<List<Map<String, dynamic>>> getNotes() {
    return notesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  // 🗑️ Delete note by ID
  Future<void> deleteNote(String noteId) async {
    try {
      await notesCollection.doc(noteId).delete();
    } catch (e) {
      print("Error deleting note: $e");
      rethrow;
    }
  }
}
