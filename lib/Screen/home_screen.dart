import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aitesting/services/firebase_note_services.dart';
import 'package:aitesting/services/speech_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final FirebaseNoteService _firebaseService = FirebaseNoteService();

  String _title = '';
  String _text = '';
  String _language = 'en';
  List<String> _userLanguages = [];
  bool _isRecording = false;
  
  // Animation controllers
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _speechService.initSpeech();
    _loadUserLanguages();
    
    // Initialize wave animation controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

  void _recordSpeech() async {
    // Create particles for animation
    _createParticles();
    
    setState(() => _isRecording = true);
    
    // Start particle animation
    _particleController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 150));

    if (_userLanguages.isEmpty) return;

    bool available = await _speechService.initSpeech();
    if (!available) return;

    final localeMap = {
      'en': 'en-US',
      'ml': 'ml-IN',
      'kn': 'kn-IN',
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
    };

    final localeId = localeMap[_language] ?? 'en-US';

    String result = await _speechService.listen(localeId: localeId);

    setState(() {
      _text = result;
      _isRecording = false;
    });
  }

  void _createParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle());
    }
  }

  void _saveNote() async {
    if (_title.isEmpty || _text.isEmpty) return;

    await _firebaseService.addNoteWithTitle(_title, _text);

    setState(() {
      _text = '';
      _title = '';
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Add New Note"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: TextEditingController(text: _title),
                        maxLines: 1,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter note title...',
                        ),
                        onChanged: (val) => _title = val,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: TextEditingController(text: _text),
                        maxLines: 6,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Speak or type your note here...',
                        ),
                        onChanged: (val) => _text = val,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMicButton(),
                    _buildGradientButton(
                      icon: Icons.save,
                      text: "Save",
                      onTap: _saveNote,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (_userLanguages.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: _userLanguages.map((code) {
                      final label = _getLanguageLabel(code);
                      final selected = _language == code;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        selectedColor: Colors.deepPurple,
                        backgroundColor: Colors.grey.shade300,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _language = code),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // Particle Animation
          ..._particles.map((particle) {
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final animationValue = _particleController.value;
                particle.update(animationValue);
                
                return Positioned(
                  left: particle.x * MediaQuery.of(context).size.width,
                  top: particle.y * MediaQuery.of(context).size.height,
                  child: Transform.scale(
                    scale: particle.size,
                    child: Opacity(
                      opacity: particle.opacity,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: particle.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          // Mic animation overlay
          if (_isRecording) _buildMicAnimation(),
        ],
      ),
    );
  }

  Widget _buildMicAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Transform.scale(
            scale: _waveAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.4),
                        Colors.deepPurple.withOpacity(0.2),
                        Colors.deepPurple.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.indigo,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isRecording ? 1.0 : 0.0,
                  child: Text(
                    "Listening...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.deepPurple.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMicButton() {
    return InkWell(
      onTap: _recordSpeech,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isRecording ? 1.15 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.deepPurple.withOpacity(0.3),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.mic, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Speak",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return "English";
      case 'ml':
        return "Malayalam";
      case 'kn':
        return "Kannada";
      case 'hi':
        return "Hindi";
      case 'ta':
        return "Tamil";
      case 'te':
        return "Telugu";
      default:
        return code.toUpperCase();
    }
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.deepPurple.withOpacity(0.3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle class for animation
class Particle {
  late double x, y;
  late double dx, dy;
  late double size;
  late double opacity;
  late Color color;
  
  Particle() {
    reset();
  }
  
  void reset() {
    x = 0.5; // Start from center horizontally
    y = 0.5; // Start from center vertically
    dx = (Random.nextDouble() - 0.5) * 2;
    dy = (Random.nextDouble() - 0.5) * 2;
    size = Random.nextDouble() * 10 + 5;
    opacity = Random.nextDouble() * 0.5 + 0.5;
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.purple,
      Colors.deepPurpleAccent,
    ];
    color = colors[Random.nextInt(colors.length)];
  }
  
  void update(double progress) {
    x += dx * progress * 0.02;
    y += dy * progress * 0.02;
    opacity = 1.0 - progress;
    size = size * (1 - progress * 0.5);
  }
}

// Helper Random class
class Random {
  static final _random = math.Random();
  
  static double nextDouble() => _random.nextDouble();
  static int nextInt(int max) => _random.nextInt(max);
}