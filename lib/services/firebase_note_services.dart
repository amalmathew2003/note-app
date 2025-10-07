import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNote(String content) async {
    await _firestore.collection('notes').add({
      'title': content.split(' ').take(3).join(' '),
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> getNotes() {
    return _firestore
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> addNoteWithTitle(String title, String content) async {
    await _firestore.collection('notes').add({
      'title': title.isEmpty ? content.split(' ').take(3).join(' ') : title,
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  // 🗑️ DELETE note by ID
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      print("Error deleting note: $e");
      rethrow; // optional: propagate error to UI if needed
    }
  }
}
