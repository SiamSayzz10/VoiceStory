import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'menubar.dart';
import 'profile_page.dart';
import 'api_service.dart';

class S2tResult extends StatefulWidget {
  final String language;
  final String text;

  const S2tResult({
    super.key,
    required this.language,
    required this.text,
  });

  @override
  State<S2tResult> createState() => _S2tResultState();
}

class _S2tResultState extends State<S2tResult> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // --- EMULATOR/MOBILE STABILITY CONFIG ---
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);

    // Auto-play the AI voice as soon as the screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _playVoice();
    });

    // Reset the play icon when the audio finishes
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- PLAYBACK LOGIC ---
  Future<void> _playVoice() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    try {
      if (mounted) setState(() => _isPlaying = true);

      // Map UI language string to the API code strictly
      String langCode = "en"; // Default
      if (widget.language.toLowerCase() == "bangla") langCode = "bn";
      else if (widget.language.toLowerCase() == "japanese") langCode = "ja";
      else if (widget.language.toLowerCase() == "arabic") langCode = "ar";
      else if (widget.language.toLowerCase() == "spanish") langCode = "es";

      // Fetch the audio URL from your Backend
      String? audioUrl = await _apiService.generateSpeech(widget.text, langCode);

      if (audioUrl != null) {
        await _audioPlayer.setSource(UrlSource(audioUrl));
        // Buffer delay for stability
        await Future.delayed(const Duration(milliseconds: 200));
        await _audioPlayer.resume();
      }
    } catch (e) {
      print("❌ Playback Error: $e");
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const CustomMenuBar(),
      body: Stack(
        children: [
          // 1. FIGMA: Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF210C48), Color(0xFF5C3A96)],
              ),
            ),
          ),

          // 2. FIGMA: Texture Background Image
          Opacity(
            opacity: 0.4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/image/background.jpeg"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    colorFilter: ColorFilter.mode(Color(0xFF210C48), BlendMode.screen)
                ),
              ),
            ),
          ),

          // 3. FIGMA: Bottom Ellipse Decor
          Positioned(
            bottom: -63,
            left: (screenWidth - 615) / 2,
            child: Container(
              width: 615, height: 346,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8147E5).withOpacity(0.3),
                    const Color(0xFF5C3A96).withOpacity(0.3)
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.elliptical(615, 346)),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 4. HEADER: Official Logo and Icons
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(Icons.menu, color: Colors.white, size: 28),
                        ),
                      ),
                      Image.network(
                        "https://i...content-available-to-author-only...g.cc/W3Szv9zw/logo.png",
                        width: 141, height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Text("VoiceStory AI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                        child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.3),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 38.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Translucent Language Label
                            Container(
                              width: 325, height: 32,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4B277E).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(widget.language, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                            ),

                            const SizedBox(height: 27),

                            // Result Text Box (Solid White)
                            Container(
                              width: 326,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.text,
                                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_isPlaying ? "AI is speaking..." : "Play Response",
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      IconButton(
                                        onPressed: _playVoice,
                                        icon: Icon(
                                            _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                                            color: const Color(0xFF4B277E),
                                            size: 32
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Action Buttons
                            SizedBox(
                              width: 326,
                              child: Row(
                                children: [
                                  const Icon(Icons.copy_outlined, color: Colors.white, size: 24),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.share_outlined, color: Colors.white, size: 24),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4B277E),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text("Back", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
