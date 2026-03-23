import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/hive_note_service.dart';
import 'package:note_app/Screen/home_screen.dart';
import 'package:note_app/Screen/language_selection_screen.dart';
import 'package:note_app/Screen/note_detail_screen.dart';
import 'package:note_app/utils/app_colors.dart';
import 'package:note_app/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final HiveNoteService _hiveService = HiveNoteService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _currentFolder = 'Main';
  bool _isGridView = true;
  bool _showDeleted = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Ideas', 'Work', 'Personal', 'General', 'Tasks'];
  List<String> _userFolders = ['Main', 'Drafts', 'Archive'];

  @override
  void initState() {
    super.initState();
    _loadUserFolders();
  }

  Future<void> _loadUserFolders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userFolders = prefs.getStringList('user_folders') ?? ['Main', 'Drafts', 'Archive'];
    });
  }

  Future<void> _addFolder() async {
    final controller = TextEditingController();
    String? folderName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("New Folder", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: "Folder Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("CREATE")),
        ],
      ),
    );
    if (folderName != null && folderName.isNotEmpty) {
      setState(() {
        if (!_userFolders.contains(folderName)) _userFolders.add(folderName);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_folders', _userFolders);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      drawer: _buildDrawer(isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [AppColors.bgDark, AppColors.bgDark.withBlue(40)]
              : [AppColors.bgLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              _buildSearchBar(isDark),
              _buildCategoryTabs(isDark),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<Note>('notes_box').listenable(),
                  builder: (context, Box<Note> box, _) {
                    final notes = _hiveService.searchNotes(
                      _searchQuery, 
                      category: _selectedCategory,
                      showDeleted: _showDeleted
                    ).where((n) => _showDeleted || n.folder == _currentFolder).toList();
                    
                    if (notes.isEmpty) {
                      return _buildEmptyState(isDark);
                    }

                    return PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim1, anim2) => FadeThroughTransition(animation: anim1, secondaryAnimation: anim2, child: child),
                      child: _isGridView 
                        ? _buildGridView(notes, isDark, key: ValueKey('grid_$_selectedCategory$_currentFolder$_showDeleted')) 
                        : _buildListView(notes, isDark, key: ValueKey('list_$_selectedCategory$_currentFolder$_showDeleted')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showDeleted ? null : _buildFAB(isDark),
    );
  }

  Widget _buildFAB(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen(initialFolder: _currentFolder))),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text("NEW NOTE", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(builder: (c) => IconButton(icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white70 : Colors.black87), onPressed: () => Scaffold.of(c).openDrawer())),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_showDeleted ? "Trash Bin" : _currentFolder, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                  Text("Voice Notes", style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded), onPressed: _toggleTheme),
              IconButton(icon: Icon(Icons.language_rounded, color: isDark ? Colors.white : Colors.black87), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()))),
              IconButton(icon: Icon(_isGridView ? Icons.view_agenda_rounded : Icons.grid_view_rounded), onPressed: () => setState(() => _isGridView = !_isGridView)),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleTheme() async {
    final mode = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    setState(() {});
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Search notes...",
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLightLight,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54), fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<Note> notes, bool isDark, {required Key key}) {
    return MasonryGridView.count(key: key, padding: const EdgeInsets.all(16), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, itemCount: notes.length, itemBuilder: (context, index) => _NoteCard(note: notes[index], isDark: isDark));
  }

  Widget _buildListView(List<Note> notes, bool isDark, {required Key key}) {
    return ListView.builder(key: key, padding: const EdgeInsets.all(16), itemCount: notes.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _NoteCard(note: notes[index], isDark: isDark, isList: true)));
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      child: Column(
        children: [
          _buildDrawerHeader(isDark),
          _drawerTile(isDark, Icons.note_rounded, "All Notes", !_showDeleted && _currentFolder == 'Main', () => setState(() { _showDeleted = false; _currentFolder = 'Main'; Navigator.pop(context); })),
          _drawerTile(isDark, Icons.delete_outline_rounded, "Trash Bin", _showDeleted, () => setState(() { _showDeleted = true; Navigator.pop(context); })),
          _drawerTile(isDark, Icons.language_rounded, "Language Settings", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()))),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("FOLDERS", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              IconButton(icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary), onPressed: _addFolder),
            ]),
          ),
          Expanded(child: ListView.builder(
            itemCount: _userFolders.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => _drawerTile(isDark, Icons.folder_rounded, _userFolders[index], !_showDeleted && _currentFolder == _userFolders[index], () => setState(() { _showDeleted = false; _currentFolder = _userFolders[index]; Navigator.pop(context); })),
          )),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      color: AppColors.primary,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 30)),
        const SizedBox(height: 16),
        Text("Voice Notes", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _drawerTile(bool isDark, IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54)),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black87))),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(_showDeleted ? Icons.delete_sweep_rounded : Icons.auto_awesome_rounded, size: 64, color: AppColors.primary.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text(_showDeleted ? "No trash found" : "Empty in $_currentFolder", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white30 : Colors.black12)),
    ]));
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isList, isDark;
  const _NoteCard({required this.note, required this.isDark, this.isList = false});

  @override
  Widget build(BuildContext context) {
    final hiveService = HiveNoteService();
    final Color cardColor = isDark ? (note.color == 0xFFFFFFFF || note.color == 0xFF1E293B ? AppColors.surfaceDark : Color(note.color).withOpacity(0.4)) : (note.color == 0xFFFFFFFF ? Colors.white : Color(note.color).withOpacity(0.2));

    return GestureDetector(
      onLongPress: () => _showActions(context, hiveService),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(note.category.toUpperCase(), style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary)),
            if (note.isPinned) const Icon(Icons.push_pin_rounded, size: 12, color: AppColors.primary),
          ]),
          const SizedBox(height: 8),
          Text(note.title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(note.content, style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54, height: 1.4), maxLines: isList ? 3 : 6, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  void _showActions(BuildContext context, HiveNoteService hiveService) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 20),
        if (!note.isDeleted) ...[
          _actionTile(Icons.edit_note_rounded, Colors.blue, "Edit", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen(note: note))); }),
          _actionTile(note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, Colors.amber, note.isPinned ? "Unpin" : "Pin", () { hiveService.togglePin(note.id); Navigator.pop(context); }),
          _actionTile(Icons.delete_rounded, Colors.red, "Move to Trash", () { hiveService.moveToTrash(note.id); Navigator.pop(context); }),
        ] else ...[
          _actionTile(Icons.restore_rounded, AppColors.primary, "Restore", () { hiveService.restoreFromTrash(note.id); Navigator.pop(context); }),
          _actionTile(Icons.delete_forever_rounded, Colors.red, "Delete Permanently", () { hiveService.deletePermanently(note.id); Navigator.pop(context); }),
        ],
        const SizedBox(height: 20),
      ]),
    ));
  }

  Widget _actionTile(IconData icon, Color color, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color), title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)), onTap: onTap);
  }
}
