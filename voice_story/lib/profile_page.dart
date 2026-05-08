import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'menubar.dart';
import 'homepage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService.instance;

  // 1. State Variables & Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  String currentUser = "";
  File? profileImage;
  String? networkImageUrl;
  bool _isLoading = true;

  // NEW: State to toggle password visibility
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // 2. Load Data from Backend
  // ==========================================
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString('username') ?? "";

    if (mounted) {
      setState(() {
        _emailController.text = currentUser; // Auto-fill email UI
      });
    }

    final data = await _apiService.getProfile(currentUser);
    if (data != null && mounted) {
      setState(() {
        _nameController.text = data['name'] ?? "";
        _passwordController.text = data['password'] ?? ""; // Fetches actual password

        if (data['gender'] != null && data['gender'].toString().isNotEmpty) {
          _selectedGender = data['gender'];
        }

        if (data['photo_path'] != null && data['photo_path'].toString().isNotEmpty) {
          networkImageUrl = "${ApiService.baseUrl}/${data['photo_path']}";
        }
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 3. Pick Image from Gallery
  // ==========================================
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // ==========================================
  // 4. Save Profile to Backend
  // ==========================================
  Future<void> saveProfile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saving changes..."), duration: Duration(seconds: 1)),
    );

    final success = await _apiService.updateProfile(
      currentUser,
      _nameController.text,
      _passwordController.text, // Sends the exact same password back
      _selectedGender ?? "",
      profileImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomMenuBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF210C48), Color(0xFF5C3A96)],
              ),
            ),
          ),
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
          SafeArea(
            child: Builder(
                builder: (context) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),

                          // Profile Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Scaffold.of(context).openDrawer(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.menu, color: Colors.white, size: 28),
                                ),
                              ),
                              const Text(
                                "Edit Profile",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.home_outlined, color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          // Profile Avatar
                          Center(
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: profileImage != null
                                          ? FileImage(profileImage!) as ImageProvider
                                          : (networkImageUrl != null
                                          ? NetworkImage(networkImageUrl!)
                                          : const NetworkImage("https://v...content-available-to-author-only...r.com/150")),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF773ECC),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Input Fields
                          _buildInputField("Name", "Enter your name", _nameController),
                          const SizedBox(height: 16),

                          _buildDropdownField("Gender"),
                          const SizedBox(height: 16),

                          // UPDATED: Email is strictly read-only
                          _buildInputField("Email", "email@gmail.com", _emailController, readOnly: true),
                          const SizedBox(height: 16),

                          // UPDATED: Password is strictly read-only, has an eye icon, and toggles visibility
                          _buildInputField(
                            "Password",
                            "********",
                            _passwordController,
                            isPassword: !_isPasswordVisible, // Toggles based on state
                            readOnly: true, // Prevents editing
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Save Changes Button
                          InkWell(
                            onTap: saveProfile,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF773ECC), Color(0xFF4B277E)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save Changes",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Added suffixIcon parameter for the eye toggle
  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false, bool readOnly = false, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
        ),
        Container(
          height: 52,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5A3392), Color(0xFF4B277E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            readOnly: readOnly,
            style: TextStyle(color: readOnly ? Colors.white70 : Colors.white, fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
              suffixIcon: suffixIcon, // Inserts the eye icon if provided
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5A3392), Color(0xFF4B277E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              hint: Text("Select your gender", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontFamily: 'Poppins')),
              dropdownColor: const Color(0xFF4B277E),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              isExpanded: true,
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins')),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
