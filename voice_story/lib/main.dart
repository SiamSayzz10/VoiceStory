import 'package:flutter/material.dart';

// If this still shows a red line, try: import 'package:voice_story/login.dart';

import 'login.dart';



void main() {

  runApp(const VoiceStoryApp());

}



class VoiceStoryApp extends StatelessWidget {

  const VoiceStoryApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'VoiceStory AI',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        brightness: Brightness.dark,

        primaryColor: const Color(0xFF1B0B3B),

        fontFamily: 'Poppins',

        scaffoldBackgroundColor: const Color(0xFF1B0B3B),

      ),

      home: const Start6(),

    );

  }

}



class Start6 extends StatelessWidget {

  const Start6({super.key});



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

// Background Gradient

          Container(

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [Color(0xFF1B0B3B), Color(0xFF3B1F6F)],

              ),

            ),

          ),



// Texture Overlay

          Opacity(

            opacity: 0.3,

            child: Container(

              decoration: const BoxDecoration(

                image: DecorationImage(

                  image: AssetImage("assets/image/background.jpeg"),

                  fit: BoxFit.cover,

                  colorFilter: ColorFilter.mode(Color(0xFF1B0B3B), BlendMode.screen),

                ),

              ),

            ),

          ),



          SafeArea(

            child: Center(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Image.asset(

                    "assets/image/logo.png",

                    width: 260,

                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) => const Icon(

                        Icons.settings_voice_outlined,

                        size: 100,

                        color: Colors.white

                    ),

                  ),

                  const SizedBox(height: 60),

                  const Text(

                    "Speak your story.\nWrite your world.",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      letterSpacing: 1.2,

                      fontWeight: FontWeight.w300,

                    ),

                  ),

                  const SizedBox(height: 120),

                  _buildStartButton(context),

                  const SizedBox(height: 25),

                  const Text(

                    "Next-generation AI voice technology",

                    style: TextStyle(

                        color: Colors.white54,

                        fontSize: 14,

                        fontFamily: 'Inter'

                    ),

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildStartButton(BuildContext context) {

    return Container(

      width: 180,

      height: 55,

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),

        gradient: const LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0xFF773ECC), Color(0xFF4B277E)],

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: 0.3),

            blurRadius: 10,

            offset: const Offset(0, 5),

          ),

        ],

      ),

      child: ElevatedButton(

        onPressed: () {

// Navigating to the Login class

          Navigator.push(

            context,

            MaterialPageRoute(builder: (context) => const Login()),

          );

        },

        style: ElevatedButton.styleFrom(

          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        ),

        child: const Text(

          "Start!",

          style: TextStyle(

              fontSize: 20,

              fontWeight: FontWeight.bold,

              color: Colors.white

          ),

        ),

      ),

    );

  }

}