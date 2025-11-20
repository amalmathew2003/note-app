import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 👇 Each user's notes collection
  CollectionReference<Map<String, dynamic>> _userNotesCollection() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  // 📝 Add note with auto title
  Future<void> addNote(String content) async {
    final title = content.split(' ').take(3).join(' ');

    await _userNotesCollection().add({
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  // 🆕 Add note with custom title
  Future<void> addNoteWithTitle(String title, String content) async {
    await _userNotesCollection().add({
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  // 🔁 Fetch only this user's notes
  Stream<List<Map<String, dynamic>>> getNotes() {
    return _userNotesCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // 🗑 Delete a note
  Future<void> deleteNote(String noteId) async {
    await _userNotesCollection().doc(noteId).delete();
  }
}
