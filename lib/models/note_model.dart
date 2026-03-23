import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int color;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  String category;

  @HiveField(7)
  DateTime? reminder;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  bool isDeleted;

  @HiveField(10)
  String folder;

  @HiveField(11)
  String sound;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF,
    this.isPinned = false,
    this.category = 'General',
    this.reminder,
    this.isFavorite = false,
    this.isDeleted = false,
    this.folder = 'Main',
    this.sound = 'Standard',
  });
}
