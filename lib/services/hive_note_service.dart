import 'package:note_app/models/note_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveNoteService {
  static const String _boxName = 'notes_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    await Hive.openBox<Note>(_boxName);
  }

  Box<Note> get _box => Hive.box<Note>(_boxName);

  // 📝 Create or Update
  Future<void> saveNote(Note note) async {
    await _box.put(note.id, note);
  }

  // 🗑 Soft Delete (Move to Trash)
  Future<void> moveToTrash(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isDeleted = true;
      await note.save();
    }
  }

  // 🚮 Delete Permanently
  Future<void> deletePermanently(String id) async {
    await _box.delete(id);
  }

  // ♻ Restore from Trash
  Future<void> restoreFromTrash(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isDeleted = false;
      await note.save();
    }
  }

  // 🔔 Toggle Pin
  Future<void> togglePin(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await note.save();
    }
  }

  // ⭐ Toggle Favorite
  Future<void> toggleFavorite(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isFavorite = !note.isFavorite;
      await note.save();
    }
  }

  // 🔍 Stream of All Notes
  Stream<List<Note>> getNotesStream() {
    return _box.watch().map((_) => getAllNotes());
  }

  List<Note> _sortNotes(Iterable<Note> notes) {
    final list = notes.toList();
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<Note> getAllNotes({String? category, String? folder, bool showDeleted = false}) {
    Iterable<Note> notes = _box.values.where((n) => n.isDeleted == showDeleted);
    
    if (category != null && category != 'All') {
      notes = notes.where((n) => n.category == category);
    }
    
    if (folder != null) {
      notes = notes.where((n) => n.folder == folder);
    }
    
    return _sortNotes(notes);
  }

  // 🔍 Search
  List<Note> searchNotes(String query, {String? category, bool showDeleted = false}) {
    Iterable<Note> notes = _box.values.where((n) => n.isDeleted == showDeleted);
    
    if (category != null && category != 'All') {
      notes = notes.where((n) => n.category == category);
    }

    if (query.isNotEmpty) {
      notes = notes.where((note) =>
          note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase()));
    }
    
    return _sortNotes(notes);
  }
}
