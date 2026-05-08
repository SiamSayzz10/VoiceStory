import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'menubar.dart';
import 'profile_page.dart';
import 't2s_convert.dart';
import 's2t_language.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

    @override
    HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
    final AudioPlayer _audioPlayer = AudioPlayer();
    final ApiService _apiService = ApiService();

    @override
    void dispose() {
        _audioPlayer.dispose();
        super.dispose();
    }

    void _playAiVoice(String text, String lang) async {
        if (text.isEmpty) return;
        String? audioUrl = await _apiService.generateSpeech(text, lang);
        if (audioUrl != null) {
            await _audioPlayer.play(UrlSource(audioUrl));
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                // The Drawer must be defined here for the Builder to find it
                drawer: const CustomMenuBar(),
                body: Stack(
                children: [
        // Background Gradient
        Container(
                decoration: const BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF210C48), Color(0xFF5C3A96)]
                  )
              )
          ),

        // Background Texture
        Opacity(
                opacity: 0.4,
                child: Container(
                decoration: const BoxDecoration(
                image: DecorationImage(
                image: AssetImage("assets/image/background.jpeg"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                colorFilter: ColorFilter.mode(Color(0xFF210C48), BlendMode.screen)
                      )
                  )
              )
          ),

        SafeArea(
                child: Stack(
                children: [
        // UNIVERSAL HEADER
        Align(
                alignment: Alignment.topCenter,
                child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

        // --- FIXED: CRITICAL BUILDER FIX FOR DRAWER ---
        Builder(
                builder: (context) => InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
            // This context is now inside the Scaffold's scope
            Scaffold.of(context).openDrawer();
        },
        child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/iMvG1QL8zN/0l68sk6w_expires_30_days.png",
                width: 24, height: 16,
                errorBuilder: (c, e, s) => const Icon(Icons.menu, color: Colors.white, size: 28)
                                )
                            ),
                          ),
                        ),

        // Official Logo Link
        Image.network(
                "https://i.postimg.cc/W3Szv9zw/logo.png",
                width: 141,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Text("VoiceStory AI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                        ),

        // Profile Icon
        InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
        child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/iMvG1QL8zN/9hxjyhx1_expires_30_days.png", width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.person_outline, color: Colors.white, size: 28))
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

        // CENTERED CONTENT
        Align(
                alignment: Alignment.center,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                      const Text(
                "Select Your Mode",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'Poppins')
                      ),
                      const SizedBox(height: 40),

        _modeButton(
                title: "Text To Speech",
                gradientColors: [const Color(0xFF773ECC), const Color(0xFF4B277E)],
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const T2sConvert()))
                      ),

                      const SizedBox(height: 😎,

        _modeButton(
                title: "Speech To Text",
                gradientColors: [const Color(0xFF4B277E), const Color(0xFF773ECC)],
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const S2tLanguage()))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    }

    Widget _modeButton({required String title, required List<Color> gradientColors, required VoidCallback onPressed}) {
        return InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(😎,
                child: Container(
                width: 360, height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(😎,
                gradient: LinearGradient(colors: gradientColors),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Center(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))
        ),
      ),
    );
    }
}