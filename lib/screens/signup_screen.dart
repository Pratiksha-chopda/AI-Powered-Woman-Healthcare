import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/secure_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  late AnimationController _gradientController;
  late AnimationController _fadeController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<double> _titleFade, _fieldsFade, _buttonFade, _bottomTextFade;

  @override
  void initState() {
    super.initState();

    // Background gradient animations
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFFA8E6CF),
      end: const Color(0xFF84C9D9),
    ).animate(_gradientController);

    _color2 = ColorTween(
      begin: const Color(0xFF56BFBF),
      end: const Color(0xFFC3F0CA),
    ).animate(_gradientController);

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    _titleFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3));
    _fieldsFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.3, 0.6));
    _buttonFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.55, 0.8));
    _bottomTextFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.75, 1.0));

    _fadeController.forward();
  }

  Future<void> _registerUser() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String age = ageController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔹 Create user using Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'age': int.parse(age),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ⭐ SAVE HUGGINGFACE TOKEN (ONLY ONE TIME)
      await SecureStorage.saveToken(
          const String.fromEnvironment('HF_TOKEN', defaultValue: 'YOUR_HUGGINGFACE_TOKEN_HERE'));

      if (!mounted) return;

      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardScreen(username: firstName)),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email already in use';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Weak password';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _fadeController.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/signup_background.jpg',
                  fit: BoxFit.cover),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _color1.value!.withOpacity(0.4),
                      _color2.value!.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              Container(color: Colors.white.withOpacity(0.08)),

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6), width: 1.5),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _titleFade,
                              child: Column(
                                children: [
                                  Text("Ovacare",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 34,
                                          color: Colors.black87)),
                                  const SizedBox(height: 6),
                                  Text(
                                      "Your female health assistant",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 20),
                                  Text("Create Your Account",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            FadeTransition(
                              opacity: _fieldsFade,
                              child: Column(
                                children: [
                                  _buildInputField(firstNameController,
                                      "First Name", Icons.person_outline),
                                  const SizedBox(height: 14),
                                  _buildInputField(lastNameController,
                                      "Last Name", Icons.person_outline),
                                  const SizedBox(height: 14),
                                  _buildInputField(emailController,
                                      "Email Address", Icons.email_outlined),
                                  const SizedBox(height: 14),
                                  _buildInputField(passwordController,
                                      "Password", Icons.lock_outline,
                                      obscure: true),
                                  const SizedBox(height: 14),
                                  _buildInputField(ageController, "Age",
                                      Icons.calendar_today_outlined,
                                      inputType: TextInputType.number),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            FadeTransition(
                              opacity: _buttonFade,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C4E80),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(30)),
                                    elevation: 8,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onPressed:
                                  isLoading ? null : _registerUser,
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                      color: Colors.white)
                                      : Text("Register",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            FadeTransition(
                              opacity: _bottomTextFade,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Already have an account? ",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const LoginScreen()),
                                      );
                                    },
                                    child: Text("Login",
                                        style: GoogleFonts.montserrat(
                                            color: const Color(0xFF1C4E80),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      IconData icon,
      {bool obscure = false,
        TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
