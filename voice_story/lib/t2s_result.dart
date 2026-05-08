import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menubar.dart';
import 'profile_page.dart';
import 'api_service.dart';

class T2sResult extends StatefulWidget {
  final String language;
  final String text;
  final String audioUrl;

  const T2sResult({
    super.key,
    required this.language,
    required this.text,
    required this.audioUrl,
  });

  @override
  State<T2sResult> createState() => _T2sResultState();
}

class _T2sResultState extends State<T2sResult> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService.instance;

  bool _isPlaying = false;
  bool _isProcessing = false;
  final DateTime _now = DateTime.now();

  String _loggedInUser = "";

  String _selectedTone = 'Male Standard';
  final List<String> _tones = [
    'Male Standard',
    'Male Deep',
    'Female Standard',
    'Female Soft',
    'Female Bright',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);

    _loadUser();

    Future.delayed(const Duration(milliseconds: 500), () {
      _togglePlay();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _loggedInUser = prefs.getString('username') ?? "unknown_user";
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      // ==========================================
      // UPDATED: Safely builds the audio playback URL
      // ==========================================
      final String toneUrl = Uri.parse("${ApiService.baseUrl}/tts").replace(queryParameters: {
        "text": widget.text,
        "lang": _selectedTone,
        "target_lang_name": widget.language.toLowerCase(),
        "username": _loggedInUser,
      }).toString();

      _audioPlayer.play(UrlSource(toneUrl)).then((_) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isPlaying = true;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error loading audio. Check server."))
          );
        }
      });
    } catch (e) {
      debugPrint("❌ Playback Error: $e");
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _getFormattedDate() {
    List<String> weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return "${_now.day.toString().padLeft(2, '0')}.${_now.month.toString().padLeft(2, '0')}.${_now.year} (${weekdays[_now.weekday - 1]})";
  }

  String _getFormattedTime() {
    int hour = _now.hour == 0 ? 12 : (_now.hour > 12 ? _now.hour - 12 : _now.hour);
    return "$hour:${_now.minute.toString().padLeft(2, '0')} ${_now.hour >= 12 ? 'PM' : 'AM'}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomMenuBar(),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF210C48), Color(0xFF5C3A96)]))),
          Opacity(opacity: 0.4, child: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/image/background.jpeg"), fit: BoxFit.cover, alignment: Alignment.topCenter, colorFilter: ColorFilter.mode(Color(0xFF210C48), BlendMode.screen))))),
          SafeArea(
            child: Builder(builder: (context) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(onTap: () => Scaffold.of(context).openDrawer(), child: const Icon(Icons.menu, color: Colors.white, size: 28)),
                        Image.network("https://i.postimg.cc/W3Szv9zw/logo.png", width: 141, height: 40, fit: BoxFit.contain),
                        InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())), child: const Icon(Icons.person_outline, color: Colors.white, size: 28)),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 38.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(height: 40, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFF3B2A5E), borderRadius: BorderRadius.circular(5)), child: Center(child: Text(widget.language, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')))),
                              const SizedBox(height: 15),
                              Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)), child: Text(widget.text, style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Poppins'))),
                              const SizedBox(height: 25),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFF6A42AA), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(onTap: _togglePlay, child: Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4.5)), child: Center(child: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(_isPlaying ? Icons.stop : Icons.play_arrow, color: Colors.white, size: 28)))),
                                        const SizedBox(width: 12),
                                        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_waveBar(12), _waveBar(18), _waveBar(24), _waveBar(16), _waveBar(10), _waveBar(28), _waveBar(34), _waveBar(28), _waveBar(20), _waveBar(14), _waveBar(24), _waveBar(18)])),
                                        const SizedBox(width: 16),
                                        Text(_isPlaying ? "..." : "0:02", style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(children: [Text(_getFormattedDate(), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins')), const SizedBox(width: 16), Text(_getFormattedTime(), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins'))]),
                                        Expanded(
                                          child: PopupMenuButton<String>(
                                            onSelected: (String newValue) { setState(() { _selectedTone = newValue; _audioPlayer.stop(); _isPlaying = false; }); _togglePlay(); },
                                            color: const Color(0xFF4B277E), offset: const Offset(0, -200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min,
                                              children: [const Icon(Icons.person_outline, color: Colors.white, size: 14), const SizedBox(width: 4), Flexible(child: Text(_selectedTone, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', decoration: TextDecoration.underline, decorationColor: Colors.white)))],
                                            ),
                                            itemBuilder: (BuildContext context) { return _tones.map((String choice) { return PopupMenuItem<String>(value: choice, child: Text(choice, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'))); }).toList(); },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                children: [
                                  InkWell(onTap: () { Clipboard.setData(ClipboardData(text: widget.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard!"), backgroundColor: Color(0xFF773ECC))); }, child: const Icon(Icons.copy_outlined, color: Colors.white, size: 24)),
                                  const SizedBox(width: 20),

                                  InkWell(
                                    onTap: () async {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading audio...")));

                                      // ==========================================
                                      // UPDATED: Safely builds the download URL
                                      // ==========================================
                                      final String toneUrl = Uri.parse("${ApiService.baseUrl}/tts").replace(queryParameters: {
                                        "text": widget.text,
                                        "lang": _selectedTone,
                                        "target_lang_name": widget.language.toLowerCase(),
                                        "username": _loggedInUser,
                                      }).toString();

                                      String? path = await _apiService.downloadAudio(toneUrl);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(path != null ? "Audio saved to Downloads!" : "Failed to download audio."), backgroundColor: path != null ? Colors.green : Colors.red));
                                    },
                                    child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
                                  ),

                                  const SizedBox(width: 20),
                                  const Icon(Icons.share_outlined, color: Colors.white, size: 24),
                                  const Spacer(),
                                  ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B277E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Back", style: TextStyle(color: Colors.white))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _waveBar(double height) {
    return Container(width: 7.5, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)));
  }
}