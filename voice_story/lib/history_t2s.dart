import 'package:flutter/material.dart';
import 'menubar.dart';
import 'profile_page.dart';
import 'history_s2t.dart';

class HistoryT2SPage extends StatefulWidget {
  const HistoryT2SPage({super.key});

  @override
  State<HistoryT2SPage> createState() => _HistoryT2SPageState();
}

class _HistoryT2SPageState extends State<HistoryT2SPage> {
  @override
  Widget build(BuildContext context) {
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
                      colors: [Color(0xFF210C48), Color(0xFF5C3A96)]
                  )
              )
          ),

          // Background Texture Overlay
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
            child: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      const SizedBox(height: 15),

                      // ==========================================
                      // UNIVERSAL HEADER
                      // ==========================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => Scaffold.of(context).openDrawer(),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network("https://s...content-available-to-author-only...s.com/tagjs-prod.appspot.com/v1/iMvG1QL8zN/0l68sk6w_expires_30_days.png", width: 24, height: 16, errorBuilder: (c, e, s) => const Icon(Icons.menu, color: Colors.white, size: 28))
                                )
                            ),
                            Image.network(
                                "https://s...content-available-to-author-only...s.com/tagjs-prod.appspot.com/v1/iMvG1QL8zN/uuezh4f5_expires_30_days.png",
                                width: 141,
                                height: 40,
                                errorBuilder: (c, e, s) => const Text("VoiceStory AI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                            ),
                            InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network("https://s...content-available-to-author-only...s.com/tagjs-prod.appspot.com/v1/iMvG1QL8zN/9hxjyhx1_expires_30_days.png", width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.person_outline, color: Colors.white, size: 28))
                                )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ==========================================
                      // HISTORY TITLE & DATE FILTER BUTTON
                      // ==========================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("History", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins')),

                            // [FIXED]: Exact Figma specifications (Color: 604093, W: 140.08, H: 47, Radius: 4.61)
                            Container(
                                width: 140.08, // Hardcoded width from Figma
                                height: 47.0, // Hardcoded height from Figma
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF604093),
                                    borderRadius: BorderRadius.circular(4.61) // Hardcoded radius from Figma
                                ),
                                child: Row(
                                    children: [
                                      const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("3 Feb", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.1, fontFamily: 'Poppins')),
                                          Text("2026", style: TextStyle(color: Colors.white, fontSize: 11, height: 1.1, fontFamily: 'Poppins')),
                                        ],
                                      ),
                                      const Spacer(), // Pushes icon to the far right inside the fixed width box
                                      Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5)
                                          ),
                                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16)
                                      )
                                    ]
                                )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ==========================================
                      // NAVIGATION TAB BUTTONS
                      // ==========================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            // Active Tab (Text To Speech)
                            Expanded(
                              child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(color: const Color(0xFF773ECC), borderRadius: BorderRadius.circular(8)),
                                  child: const Center(child: Text("Text To Speech", style: TextStyle(color: Colors.white, fontFamily: 'Poppins')))
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Inactive Tab (Speech To Text)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryS2TPage()));
                                },
                                child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(color: const Color(0xFF4B277E), borderRadius: BorderRadius.circular(8)),
                                    child: const Center(child: Text("Speech To Text", style: TextStyle(color: Colors.white, fontFamily: 'Poppins')))
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ==========================================
                      // T2S LIST (AUDIO CARDS)
                      // ==========================================
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF6A42AA), // Matches S2T cards
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                children: [
                                  // TOP ROW: Play Icon + Waveform + Duration
                                  Row(
                                    children: [
                                      // Custom Extra Bold Play Button
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 4.5), // Extra bold circle border
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.play_arrow, color: Colors.white, size: 28), // Solid triangle icon
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Waveform Bars
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _waveBar(12), _waveBar(18), _waveBar(24), _waveBar(16), _waveBar(10),
                                            _waveBar(28), _waveBar(34), _waveBar(28), _waveBar(20), _waveBar(14),
                                            _waveBar(24), _waveBar(18), _waveBar(12), _waveBar(16), _waveBar(10),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Audio Duration
                                      const Text("0:48", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // BOTTOM ROW: Date + Time + Download Icon
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text("03.02.2026 (tuesday)", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontFamily: 'Poppins')),
                                          const SizedBox(width: 16),
                                          Text("11:58 AM", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontFamily: 'Poppins')),
                                        ],
                                      ),
                                      const Icon(Icons.file_download_outlined, color: Colors.white, size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to generate individual waveform bars
  Widget _waveBar(double height) {
    return Container(
        width: 7.5, // Bold look
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4)
        )
    );
  }
}