import 'package:flutter/material.dart';
import 'homepage.dart';
import 'api_service.dart';
import 'login2.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // Handle the login authentication logic
  // ==========================================
  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both your email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Capture the full Map response from handleAuth
    final Map<String, dynamic> response = await _apiService.handleAuth(emailController.text);

    setState(() => isLoading = false);

    if (response['status'] == 'success') {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );

      print("✅ Login Successful for: ${emailController.text}");
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Login failed. Check Server/IP"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _socialButton({required String label, required Widget iconWidget, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B0B3B), Color(0xFF3B1F6F)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 35, right: 35, bottom: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Image.network(
                        'https://i.postimg.cc/W3Szv9zw/logo.png',
                        width: 291,
                        height: 88,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 88,
                            child: Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white, size: 48),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // FIXED EMOJI HERE
                        border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
                      ),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Inter'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "email@domain.com",
                          hintStyle: TextStyle(color: Color(0xFF828282), fontSize: 14, fontFamily: 'Inter'),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // FIXED MISSING ARGUMENT HERE
                        border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Color(0xFF828282), fontSize: 14, fontFamily: 'Inter'),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF828282),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C3A96),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Log in", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text("or", style: TextStyle(color: Colors.white54, fontFamily: 'Inter', fontSize: 12))
                        ),
                        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        style: const TextStyle(fontSize: 11, fontFamily: 'Inter', height: 1.50),
                        children: [
                          const TextSpan(text: 'By clicking continue, you agree to our ', style: TextStyle(color: Color(0xFFBDBDBD))),
                          const TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFFAB7AFF))),
                          const TextSpan(text: '\nand ', style: TextStyle(color: Color(0xFFBDBDBD))),
                          const TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFFAB7AFF))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _socialButton(
                        label: "Continue with Google",
                        iconWidget: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', width: 22, height: 22),
                        onPressed: () {}
                    ),
                    const SizedBox(height: 12),
                    _socialButton(
                        label: "Continue with Apple",
                        iconWidget: const Icon(Icons.apple, size: 26, color: Colors.black),
                        onPressed: () {}
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 35,
            right: 35,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Login2())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3A96),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("Create an account", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}