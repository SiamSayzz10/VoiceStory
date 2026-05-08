import 'package:flutter/material.dart';
import 'homepage.dart'; // Ensure this is imported for successful login navigation

class Login3 extends StatelessWidget {
  const Login3({super.key});

  // Custom built tile to match Figma's exact tight spacing
  Widget _buildAccountTile({
    required BuildContext context,
    required String name,
    required String email,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE0E0E0), // Solid light-grey circle
                  radius: 12,
                ),
                const SizedBox(width: 16), // Exact horizontal gap
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2), // Tight gap between name and email
                    Text(
                      email,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
        ],
      ),
    );
  }

  // Custom built "Use another account" tile
  Widget _buildAddAccountTile({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
                const SizedBox(width: 14),
                const Text(
                  "Use another account",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B0B3B), Color(0xFF3B1F6F)],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 35, right: 35, bottom: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns content strictly to the left padding
                  children: [

                    // VoiceStory Logo (Explicitly Centered in a 291x88 box)
                    Center(
                      child: SizedBox(
                        width: 291,
                        height: 88,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // FIXED: Removed the const keyword here because it conflicts with the dynamic Column
                              Icon(Icons.settings_voice_outlined, color: Colors.white, size: 48),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "VoiceStory Ai",
                                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                  ),
                                  Text(
                                    "Where Every Voice is a Story",
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Exact Figma code for the Header
                    const SizedBox(
                      width: 277,
                      child: Text(
                        "Choose an account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: const TextSpan(
                        text: "to continue to ",
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter'),
                        children: [
                          TextSpan(
                            text: "VoiceStory Ai",
                            style: TextStyle(color: Color(0xFFB084E9), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Account List
                    _buildAccountTile(
                      context: context,
                      name: "Kanij Fatima Kotha",
                      email: "kanijfatimakotha11@gmail.com",
                      onTap: () {
                        // Example: Automatically log in this user and go to HomePage
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logging in as Kanij...")));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                      },
                    ),
                    _buildAccountTile(
                      context: context,
                      name: "Kotha Ahmed",
                      email: "kothaahmed011@gmail.com",
                      onTap: () {
                        // Example: Automatically log in this user and go to HomePage
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logging in as Kotha...")));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                      },
                    ),
                    _buildAddAccountTile(
                      onTap: () {
                        // Navigates back to your main Login screen so they can type a new email
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 40),

                    // Terms & Privacy Text
                    const SizedBox(
                      width: 328,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            height: 1.50,
                          ),
                          children: [
                            TextSpan(
                              text: 'By clicking email, you agree to our ',
                              style: TextStyle(color: Color(0xFFBDBDBD), fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: Color(0xFFAB7AFF), fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: ' and\n',
                              style: TextStyle(color: Color(0xFFBDBDBD), fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Color(0xFFAB7AFF), fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button in Top Left
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}