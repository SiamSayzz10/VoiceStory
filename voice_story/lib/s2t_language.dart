import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW: Required for user tracking
import 'api_service.dart';
import 'menubar.dart';
import 's2t_result.dart';
import 'profile_page.dart'; // Optional: If you want the profile icon to work

class S2tLanguage extends StatefulWidget {
  const S2tLanguage({super.key});
  @override
  State<S2tLanguage> createState() => _S2tLanguageState();
}

class _S2tLanguageState extends State<S2tLanguage> {
  final AudioRecorder _recorder = AudioRecorder();
  final ApiService _apiService = ApiService.instance;

  String _selectedLanguage = 'English';
  final List<String> _languages = ['Bangla', 'English', 'Japanese', 'Arabic', 'Spanish'];

  bool isRecording = false;

  // NEW: Add a tracker to measure how long you hold the button
  DateTime? _recordingStartTime;

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';

        setState(() => isRecording = true);
        _recordingStartTime = DateTime.now(); // Start the timer

        // FIX: Force true WAV encoding so Python doesn't crash
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
      }
    } catch (e) {
      debugPrint("❌ Start Recording Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;
    try {
      final path = await _recorder.stop();
      setState(() => isRecording = false);

      if (path != null) {
        // FIX: Block accidental quick taps (Must hold for at least 1 second)
        if (_recordingStartTime != null && DateTime.now().difference(_recordingStartTime!).inSeconds < 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please hold the button down longer to speak!"), backgroundColor: Colors.orange),
          );
          return; // Exit early, do not send to server
        }

        final prefs = await SharedPreferences.getInstance();
        final currentUser = prefs.getString('username') ?? "unknown_user@gmail.com";

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transcribing to $_selectedLanguage..."))
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
        );

        String? resultText = await _apiService.transcribeAudio(
            currentUser,
            path,
            _selectedLanguage
        );

        if (!mounted) return;
        Navigator.pop(context);

        Navigator.push(context, MaterialPageRoute(
          builder: (context) => S2tResult(
            language: _selectedLanguage,
            // Added a helpful debugging message if it still fails
            text: resultText ?? "Sorry, I couldn't hear that clearly. (Check Python terminal for errors)",
          ),
        ));
      }
    } catch (e) {
      debugPrint("❌ Stop Error: $e");
      setState(() => isRecording = false);
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const CustomMenuBar(),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF210C48), Color(0xFF5C3A96)],
              ),
            ),
          ),
          // Texture Overlay
          Opacity(
            opacity: 0.4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/background.jpeg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(Color(0xFF210C48), BlendMode.screen),
                ),
              ),
            ),
          ),
          // Bottom Ellipse Decor
          Positioned(
            bottom: -63,
            left: (screenWidth - 615) / 2,
            child: Container(
              width: 615, height: 346,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isRecording
                      ? [const Color(0xFF8147E5), const Color(0xFF5C3A96)]
                      : [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 28)
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Dropdown and Status Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Column(
                    children: [
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                            items: _languages.map((String lang) {
                              return DropdownMenuItem<String>(
                                value: lang,
                                child: Text(lang, style: const TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Poppins')),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedLanguage = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 76, width: double.infinity, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isRecording ? Colors.white : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          isRecording ? "Listening..." : "converting into text..",
                          style: TextStyle(
                            color: isRecording ? const Color(0xFF5C3A96) : Colors.white.withOpacity(0.54),
                            fontSize: 14, fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),

          // 3. RECORDING TRIGGER (MIC)
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isRecording ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Opacity(
                      opacity: isRecording ? 1.0 : 0.6,
                      child: Image.network(
                        "https://s...content-available-to-author-only...s.com/tagjs-prod.appspot.com/v1/IRSv6C0IwJ/rz137xtr_expires_30_days.png",
                        width: 60, height: 62,
                        color: isRecording ? Colors.redAccent : null,
                        colorBlendMode: isRecording ? BlendMode.srcIn : null,
                        errorBuilder: (c, e, s) => Icon(
                            isRecording ? Icons.mic : Icons.mic_none,
                            color: isRecording ? Colors.redAccent : Colors.white,
                            size: 60
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRecording ? "Release to stop" : "Hold to record",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
