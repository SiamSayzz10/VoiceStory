import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // REQUIRED for copying text
import 'api_service.dart';
import 'menubar.dart';

class HistoryS2TPage extends StatefulWidget {
  const HistoryS2TPage({super.key});

  @override
  State<HistoryS2TPage> createState() => _HistoryS2TPageState();
}

class _HistoryS2TPageState extends State<HistoryS2TPage> {
  final ApiService _apiService = ApiService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isS2TMode = true;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _currentlyPlayingUrl;

  // Keep track of the currently selected date (defaults to today)
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _currentlyPlayingUrl = null);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      if (username == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = await _apiService.getHistory(username);

      setState(() {
        // FIX: Keep the full data here so BOTH STT and TTS tabs work!
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _playAudio(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) return;

    final url = "${ApiService.baseUrl}/$audioPath";

    if (_currentlyPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingUrl = null);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _currentlyPlayingUrl = url);
    }
  }

  // ==========================================
  // Date Picker Function
  // ==========================================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024), // Allows going back in time
      lastDate: DateTime.now(),  // Prevents picking future dates
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF773ECC), // VoiceStory Purple for the calendar
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _audioPlayer.stop(); // Stop audio if they change the date
        _currentlyPlayingUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomMenuBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF210C48), Color(0xFF3B1F6F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildPageTitleAndDate(),
              _buildToggleButtons(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )),
          Image.network("https://i.postimg.cc/W3Szv9zw/logo.png", width: 130),
          const Icon(Icons.person_pin, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  // ==========================================
  // Interactive Date Pill
  // ==========================================
  Widget _buildPageTitleAndDate() {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    String day = _selectedDate.day.toString();
    String month = months[_selectedDate.month - 1];
    String year = _selectedDate.year.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),

          // Wrapped the date container in an InkWell to make it clickable
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF773ECC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$day $month",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        year,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _toggleBtn("Text To Speech", !isS2TMode),
          _toggleBtn("Speech To Text", isS2TMode),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            isS2TMode = (label == "Speech To Text");
            _audioPlayer.stop();
            _currentlyPlayingUrl = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF773ECC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Filter by Mode AND Date
  // ==========================================
  Widget _buildList() {
    final filteredHistory = _history.where((item) {
      // 1. Check Mode (STT vs TTS)
      final itemType = item['type'] ?? 'stt';
      final matchesMode = isS2TMode ? itemType == 'stt' : itemType == 'tts';

      // 2. Check Date (Compare YYYY-MM-DD)
      String itemDateStr = "";
      if (item['created_at'] != null) {
        itemDateStr = item['created_at'].toString().split('T')[0];
      }
      // Format our _selectedDate to match the database string (YYYY-MM-DD)
      String selectedDateStr = _selectedDate.toIso8601String().split('T')[0];

      final matchesDate = itemDateStr == selectedDateStr;

      // Only show items that match both the current tab AND the selected date
      return matchesMode && matchesDate;
    }).toList();

    if (filteredHistory.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: const Color(0xFF773ECC),
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final item = filteredHistory[index];
          return isS2TMode ? _s2tCard(item) : _ttsCard(item);
        },
      ),
    );
  }

  Widget _s2tCard(dynamic item) {
    String displayDate = item['created_at'] != null ? item['created_at'].toString().split('T')[0] : "Unknown Date";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['original_text'] ?? "No text recorded", style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayDate, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Row(
                children: [
                  const Icon(Icons.share_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 15),
                  // NEW: Clickable Copy Button
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: item['original_text'] ?? ""));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Text copied to clipboard!"), backgroundColor: Color(0xFF773ECC)),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.copy_all, color: Colors.white70, size: 22),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _ttsCard(dynamic item) {
    final isPlaying = _currentlyPlayingUrl == "${ApiService.baseUrl}/${item['audio_path']}";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                color: Colors.white,
                size: 40
            ),
            onPressed: () => _playAudio(item['audio_path']),
          ),

          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.graphic_eq, color: Colors.white70, size: 30),
                  Text(
                      item['original_text'] ?? "Audio",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)
                  ),
                ],
              )
          ),

          // NEW: Clickable Download Button
          IconButton(
            icon: Icon(Icons.download_for_offline, color: Colors.white.withValues(alpha: 0.4)),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Downloading audio..."))
              );

              String? path = await _apiService.downloadAudio(item['audio_path']);

              if (path != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Audio saved to Downloads!"), backgroundColor: Colors.green)
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to download audio."), backgroundColor: Colors.red)
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Format the date nicely for the empty message
    String displayDate = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

    return Center(
        child: Text(
            "No ${isS2TMode ? 'transcriptions' : 'audio files'} found for $displayDate.",
            style: const TextStyle(color: Colors.white38, fontSize: 16)
        )
    );
  }
}