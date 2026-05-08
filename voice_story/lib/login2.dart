import 'package:flutter/material.dart';
import 'api_service.dart';

class Login2 extends StatefulWidget {
  const Login2({super.key});

  @override
  State<Login2> createState() => _Login2State();
}

class _Login2State extends State<Login2> {
  final ApiService _apiService = ApiService();
  bool isLoading = false;

  // Controllers for the text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // State to toggle password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================
  // STRICT REGISTRATION LOGIC
  // ==========================================
  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text.trim();

    // 1. Validation
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (password != confirmPasswordController.text.trim()) {
      _showError("Passwords do not match!");
      return;
    }

    // 2. Start Loading
    setState(() => isLoading = true);

    // 3. Call dedicated Register endpoint
    final result = await _apiService.registerUser(email);

    if (!mounted) return;
    setState(() => isLoading = false);

    // 4. Handle Response
    if (result['status'] == 'success') {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created! Please log in."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // BACK TO LOGIN: Force them to log in with the new account
      Navigator.pop(context);
    } else {
      // Show the specific error (e.g., "Account already exists")
      _showError(result['message'] ?? "Registration failed");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method for stylized TextFields
  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // <--- FIXED HERE
        border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText ?? false,
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Inter'),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF828282), fontSize: 14, fontFamily: 'Inter'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF828282),
              size: 20,
            ),
            onPressed: onToggleVisibility,
          )
              : null,
        ),
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

          // 2. Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hosted Logo
                    Center(
                      child: Image.network(
                        'https://i.postimg.cc/W3Szv9zw/logo.png',
                        width: 250,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.settings_voice_outlined, color: Colors.white, size: 60),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      "Create an account",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(hintText: "Full Name", controller: nameController),
                    const SizedBox(height: 12),
                    _buildTextField(hintText: "email@domain.com", controller: emailController),
                    const SizedBox(height: 12),
                    _buildTextField(
                      hintText: "Create password",
                      controller: passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      hintText: "Confirm password",
                      controller: confirmPasswordController,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    const SizedBox(height: 24),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C3A96),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Log in", style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}