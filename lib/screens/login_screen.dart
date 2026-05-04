import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart';
import 'dashboard_screen.dart';
//import 'forgot_password_screen.dart';
import '../Admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // Admin credentials
  final String adminEmail = "admin@gmail.com";
  final String adminPassword = "Admin@123";

  late AnimationController _gradientController;
  late AnimationController _fadeController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<double> _logoFade, _subtitleFade, _fieldsFade, _buttonFade, _bottomTextFade;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

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

    _logoFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.25));
    _subtitleFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.15, 0.35));
    _fieldsFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.3, 0.6));
    _buttonFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.55, 0.8));
    _bottomTextFade =
        CurvedAnimation(parent: _fadeController, curve: const Interval(0.75, 1.0));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ⭐ FIXED LOGIN FUNCTION
  Future<void> _loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter both email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ⭐ Admin Check First
      if (email == adminEmail && password == adminPassword) {
        _showSnackBar("Welcome Admin 👑");

        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
        return;
      }

      // ⭐ NORMAL USER LOGIN
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user profile
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String firstName = "User";
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        firstName = data['firstName'] ?? "User";
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(username: firstName),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // 🔥 FIXED MESSAGE HANDLING
      String message = "";
      if (e.code == 'user-not-found') {
        message = "No account found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else {
        message = "Login failed. Please try again.";
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Something went wrong. Try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
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
              Image.asset('assets/images/background1.jpg', fit: BoxFit.cover),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _color1.value!.withOpacity(0.55),
                      _color2.value!.withOpacity(0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              Container(color: Colors.black.withOpacity(0.15)),

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _logoFade,
                              child: Text(
                                "Ovacare",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            FadeTransition(
                              opacity: _subtitleFade,
                              child: Text(
                                "Your health partner",
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            const SizedBox(height: 35),

                            FadeTransition(
                              opacity: _fieldsFade,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: emailController,
                                    style: const TextStyle(color: Colors.black87),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.email_outlined,
                                          color: Colors.black54),
                                      hintText: "Email Address",
                                      hintStyle:
                                      const TextStyle(color: Colors.black45),
                                      filled: true,
                                      fillColor:
                                      Colors.white.withOpacity(0.7),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.black87),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          color: Colors.black54),
                                      hintText: "Password",
                                      hintStyle:
                                      const TextStyle(color: Colors.black45),
                                      filled: true,
                                      fillColor:
                                      Colors.white.withOpacity(0.7),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            FadeTransition(
                              opacity: _buttonFade,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C4E80),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onPressed:
                                  _isLoading ? null : _loginUser,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                      color: Colors.white)
                                      : Text(
                                    "Log In",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            FadeTransition(
                              opacity: _bottomTextFade,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "New here? ",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Create Account",
                                      style: GoogleFonts.montserrat(
                                        color: const Color(0xFF1C4E80),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
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
}
