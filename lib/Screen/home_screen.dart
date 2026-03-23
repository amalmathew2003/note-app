import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/hive_note_service.dart';
import 'package:note_app/services/speech_services.dart';
import 'package:note_app/services/ai_service.dart';
import 'package:note_app/services/notification_service.dart';
import 'package:note_app/utils/app_colors.dart';
import 'package:note_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final Note? note;
  final String? initialFolder;
  const HomeScreen({super.key, this.note, this.initialFolder});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final HiveNoteService _hiveService = HiveNoteService();
  final AiService _aiService = AiService();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  String _language = 'en';
  List<String> _userLanguages = [];
  bool _isRecording = false;
  bool _isAiGenerating = false;
  late int _selectedColor; 
  String _selectedCategory = 'General';
  String _selectedFolder = 'Main';
  String _selectedSound = 'Standard';
  DateTime? _reminderDate;
  
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    bool isDark = themeNotifier.value == ThemeMode.dark;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? (isDark ? AppColors.surfaceDark.value : AppColors.surfaceLight.value);
    _selectedCategory = widget.note?.category ?? 'General';
    _selectedFolder = widget.note?.folder ?? widget.initialFolder ?? 'Main';
    _selectedSound = widget.note?.sound ?? 'Standard';
    _reminderDate = widget.note?.reminder;

    _speechService.initSpeech();
    _loadUserLanguages();
    
    _waveController = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeInOut));
    _particleController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _userLanguages = prefs.getStringList('preferred_languages') ?? ['en']; });
  }

  void _recordSpeech() async {
    _createParticles();
    setState(() => _isRecording = true);
    _particleController.forward(from: 0);
    bool available = await _speechService.initSpeech();
    if (!available) { if (mounted) setState(() => _isRecording = false); return; }
    final localeMap = {'en': 'en-US', 'ml': 'ml-IN', 'kn': 'kn-IN', 'hi': 'hi-IN', 'ta': 'ta-IN', 'te': 'te-IN'};
    String result = await _speechService.listen(localeId: localeMap[_language] ?? 'en-US');
    if (mounted) { setState(() { _contentController.text = "${_contentController.text} $result".trim(); _isRecording = false; }); }
  }

  void _generateWithAi() async {
    if (_titleController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please type a keyword in the Title first!"))); return; }
    setState(() => _isAiGenerating = true);
    final content = await _aiService.generateNote(_titleController.text);
    if (mounted) { setState(() { _contentController.text = content; _isAiGenerating = false; }); }
  }

  void _createParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) { _particles.add(Particle()); }
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) { Navigator.pop(context); return; }
    final String noteId = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final note = Note(
      id: noteId,
      title: _titleController.text.isEmpty ? "Untitled Note" : _titleController.text,
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      color: _selectedColor,
      category: _selectedCategory,
      folder: _selectedFolder,
      sound: _selectedSound,
      reminder: _reminderDate,
      isPinned: widget.note?.isPinned ?? false,
      isFavorite: widget.note?.isFavorite ?? false,
    );
    await _hiveService.saveNote(note);
    if (_reminderDate != null) {
      try {
        final scheduler = NotificationService();
        await scheduler.scheduleNotification(
          id: noteId.hashCode.abs() % 1000000, 
          title: "Reminder: ${note.title}",
          body: note.content.length > 50 ? "${note.content.substring(0, 50)}..." : note.content,
          scheduledDate: _reminderDate!,
          sound: _selectedSound,
        );
        // FORCE an immediate notification to prove the engine is working
        await scheduler.showImmediateConfirmation(
          DateFormat('h:mm a').format(_reminderDate!)
        );
      } catch (e) {
        print("NOTIFICATION ERROR: $e");
      }
    }
    if (mounted) Navigator.pop(context);
  }

  void _deleteNote() async {
    if (widget.note != null) {
      bool? confirm = await showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: themeNotifier.value == ThemeMode.dark ? AppColors.surfaceDark : Colors.white, title: Text("Delete Note?", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)), content: Text("Moved to trash bin.", style: GoogleFonts.outfit(fontSize: 14)), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text("CANCEL", style: GoogleFonts.outfit(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(context, true), child: Text("MOVE TO TRASH", style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w800)))],));
      if (confirm == true) { await _hiveService.moveToTrash(widget.note!.id); if (mounted) Navigator.pop(context); }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    return Scaffold(backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight, appBar: _buildAppBar(isDark), body: Stack(children: [_buildContent(isDark), _buildBottomActionPanel(isDark), if (_isRecording || _isAiGenerating) _buildOverlayAnimation(isDark), ..._buildParticles(),],),);
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black87), onPressed: () => Navigator.pop(context)), title: Text(widget.note == null ? "NEW THOUGHT" : "EDIT THOUGHT", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: isDark ? Colors.white70 : Colors.black54)), centerTitle: true, actions: [if (widget.note != null) IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent), onPressed: _deleteNote), Padding(padding: const EdgeInsets.only(right: 8), child: TextButton(onPressed: _saveNote, child: Text("SAVE", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1)))),],);
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 10, 24, 200), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildCategorySelector(isDark), const SizedBox(height: 32), Row(children: [Expanded(child: TextField(controller: _titleController, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, height: 1.2), decoration: InputDecoration(hintText: 'Idea title...', hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26), border: InputBorder.none),)), IconButton(icon: Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28), onPressed: _generateWithAi, tooltip: "Magic Generate"),],), const SizedBox(height: 8), Row(children: [Icon(Icons.access_time_rounded, size: 12, color: isDark ? Colors.white30 : Colors.black38), const SizedBox(width: 6), Text(DateFormat('MMMM d • h:mm a').format(widget.note?.createdAt ?? DateTime.now()), style: GoogleFonts.outfit(color: isDark ? Colors.white30 : Colors.black38, fontSize: 12, fontWeight: FontWeight.w500)),]), const SizedBox(height: 32), TextField(controller: _contentController, maxLines: null, style: GoogleFonts.outfit(fontSize: 18, height: 1.6, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontWeight: FontWeight.w400), decoration: InputDecoration(hintText: 'Start recording...', hintStyle: TextStyle(color: isDark ? Colors.white12 : Colors.black12), border: InputBorder.none),),],),);
  }

  Widget _buildCategorySelector(bool isDark) {
    final cats = ['Ideas', 'Work', 'Personal', 'General', 'Tasks'];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: cats.map((cat) { final isSelected = _selectedCategory == cat; return Padding(padding: const EdgeInsets.only(right: 12), child: GestureDetector(onTap: () => setState(() => _selectedCategory = cat), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent)), child: Text(cat, style: GoogleFonts.outfit(color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54), fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500))))); }).toList()),);
  }

  Widget _buildBottomActionPanel(bool isDark) {
    return Positioned(bottom: 24, left: 24, right: 24, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark.withOpacity(0.95) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)]), child: Column(mainAxisSize: MainAxisSize.min, children: [_buildLanguageBar(isDark), const Divider(color: Colors.white10, height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildActionIcon(Icons.notifications_active_rounded, "Remind", _reminderDate != null, _selectReminder, isDark), _buildActionIcon(Icons.music_note_rounded, _selectedSound, false, _showSoundPicker, isDark), _buildMicButtonLarge(), _buildActionIcon(Icons.folder_rounded, _selectedFolder, false, _showFolderPicker, isDark), _buildActionIcon(Icons.palette_rounded, "Color", false, _showColorPicker, isDark),]),]),),);
  }

  Widget _buildLanguageBar(bool isDark) {
    if (_userLanguages.isEmpty) return const SizedBox();
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _userLanguages.map((code) => GestureDetector(onTap: () => setState(() => _language = code), child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _language == code ? AppColors.primary.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(_getLanguageLabel(code), style: GoogleFonts.outfit(color: _language == code ? AppColors.primary : (isDark ? Colors.white30 : Colors.black38), fontSize: 12, fontWeight: _language == code ? FontWeight.w800 : FontWeight.w500))))).toList()));
  }

  Widget _buildActionIcon(IconData icon, String label, bool active, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Column(children: [Icon(icon, color: active ? AppColors.primary : (isDark ? Colors.white30 : Colors.black38), size: 24), const SizedBox(height: 4), Text(label, style: GoogleFonts.outfit(color: isDark ? Colors.white10 : Colors.black12, fontSize: 10))]));
  }

  Widget _buildMicButtonLarge() {
    return GestureDetector(onTap: _recordSpeech, child: Container(height: 64, width: 64, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient), child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32)),);
  }

  void _showSoundPicker() {
    final sounds = ['Gentle', 'Standard', 'Urgent'];
    bool isDark = themeNotifier.value == ThemeMode.dark;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))), child: Column(mainAxisSize: MainAxisSize.min, children: sounds.map((s) => ListTile(leading: Icon(Icons.audiotrack_rounded, color: _selectedSound == s ? AppColors.primary : Colors.grey), title: Text(s, style: GoogleFonts.outfit(fontWeight: _selectedSound == s ? FontWeight.w800 : FontWeight.w500)), onTap: () { setState(() => _selectedSound = s); Navigator.pop(context); })).toList())));
  }

  void _showFolderPicker() async {
    final prefs = await SharedPreferences.getInstance();
    final folders = prefs.getStringList('user_folders') ?? ['Main', 'Drafts', 'Archive'];
    bool isDark = themeNotifier.value == ThemeMode.dark;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))), child: ListView.builder(shrinkWrap: true, itemCount: folders.length, itemBuilder: (context, index) => ListTile(leading: Icon(Icons.folder_rounded, color: _selectedFolder == folders[index] ? AppColors.primary : Colors.grey), title: Text(folders[index], style: GoogleFonts.outfit(fontWeight: _selectedFolder == folders[index] ? FontWeight.w800 : FontWeight.w500)), onTap: () { setState(() => _selectedFolder = folders[index]); Navigator.pop(context); }))));
  }

  Future<void> _selectReminder() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _reminderDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null) { final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now())); if (time != null) setState(() => _reminderDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute)); }
  }

  void _showColorPicker() {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    final colors = isDark ? AppColors.cardColorsDark : AppColors.cardColors;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))), child: Wrap(spacing: 16, runSpacing: 16, children: colors.map((c) => GestureDetector(onTap: () { setState(() => _selectedColor = c.value); Navigator.pop(context); }, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _selectedColor == c.value ? AppColors.primary : Colors.transparent, width: 3)), child: _selectedColor == c.value ? const Icon(Icons.check, color: Colors.white, size: 20) : null))).toList())));
  }

  Widget _buildOverlayAnimation(bool isDark) {
    return Container(color: Colors.black87, child: Center(child: AnimatedBuilder(animation: _waveController, builder: (context, child) => Transform.scale(scale: _waveAnimation.value, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05), child: CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(_isAiGenerating ? Icons.auto_awesome_rounded : Icons.mic_rounded, size: 40, color: AppColors.primary))), const SizedBox(height: 24), Text(_isAiGenerating ? "MAGIC GENERATING..." : "LISTENING...", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4)),],),),),),);
  }

  List<Widget> _buildParticles() {
    return _particles.map((p) => AnimatedBuilder(animation: _particleController, builder: (context, child) { p.update(_particleController.value); return Positioned(left: p.x * MediaQuery.of(context).size.width, top: p.y * MediaQuery.of(context).size.height, child: Opacity(opacity: p.opacity, child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: p.color)))); })).toList();
  }

  String _getLanguageLabel(String code) {
    final labels = {'en': 'English', 'ml': 'Malayalam', 'kn': 'Kannada', 'hi': 'Hindi', 'ta': 'Tamil', 'te': 'Telugu'};
    return labels[code] ?? code.toUpperCase();
  }
}

class Particle {
  late double x, y, dx, dy, opacity;
  late Color color;
  Particle() { x = 0.5; y = 0.5; dx = (math.Random().nextDouble() - 0.5) * 2; dy = (math.Random().nextDouble() - 0.5) * 2; opacity = 1.0; color = AppColors.primary; }
  void update(double progress) { x += dx * progress * 0.05; y += dy * progress * 0.05; opacity = 1.0 - progress; }
}