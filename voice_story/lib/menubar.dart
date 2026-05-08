import 'package:flutter/material.dart';
import 'api_service.dart';
import 'homepage.dart';
import 'profile_page.dart';
import 'history_s2t.dart'; // Ensure this matches your filename

class CustomMenuBar extends StatelessWidget {
  const CustomMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService.instance;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: const Color(0xFF4B277E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 16, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    "https://i.postimg.cc/W3Szv9zw/logo.png",
                    width: 141,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                        "VoiceStory AI",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),
            ),

            // --- Navigation Menu ---
            _drawerTile(
              icon: Icons.home_outlined,
              title: "Home",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),

            // ==========================================
            // UPDATED: Profile Navigation Logic
            // ==========================================
            _drawerTile(
              icon: Icons.person_outline,
              title: "Profile",
              onTap: () {
                Navigator.pop(context); // This gracefully closes the side menu first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),

            _drawerTile(
              icon: Icons.history_outlined,
              title: "History",
              onTap: () {
                Navigator.pop(context); // 1. Close the drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryS2TPage()),
                ); // 2. Push to history page
              },
            ),

            const Spacer(),

            // --- Logout Section ---
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _drawerTile(
                icon: Icons.logout,
                title: "Logout",
                onTap: () => api.logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8), // <--- FIXED HERE
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Poppins'),
      ),
      onTap: onTap,
    );
  }
}