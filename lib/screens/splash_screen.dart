import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _bgController;
  late AnimationController _textController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  String _displayedText = "";
  final String _fullText = "Ovacare"; // ✅ Changed from "I fee" to "Ovacare"
  bool _showShimmer = false;

  @override
  void initState() {
    super.initState();

    // Heartbeat + glow animation
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(
          parent: _heartbeatController,
          curve: Curves.easeInOut,
        ));

    _glowAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
          parent: _heartbeatController,
          curve: Curves.easeInOut,
        ));

    // Background pastel gradient
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Text pop-in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _startTextAnimation();

    // Navigate after splash
    Future.delayed(const Duration(seconds: 5), () {
      bool isLoggedIn = false; // TODO: Replace with real login logic
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(username: "User")),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  Future<void> _startTextAnimation() async {
    for (int i = 0; i <= _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        _displayedText = _fullText.substring(0, i);
      });
    }
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showShimmer = true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _bgController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final angle = _bgController.value * 2 * math.pi;
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(angle / 8),
                colors: [
                  Color.lerp(const Color(0xFFFFF5F8), const Color(0xFFFDECFB),
                      (math.sin(angle) + 1) / 2)!,
                  Color.lerp(const Color(0xFFF9EFFF), const Color(0xFFFFF9F4),
                      (math.cos(angle) + 1) / 2)!,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth glowing + heartbeat heart
                  AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(
                                    0.5 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 90,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // Pop-in text + shimmer
                  ScaleTransition(
                    scale: _textScaleAnimation,
                    child: FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            _displayedText,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (_showShimmer)
                            AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                final shimmerX =
                                    _shimmerController.value * 300 - 150;
                                return ClipRect(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0),
                                          Colors.white.withOpacity(0.7),
                                          Colors.white.withOpacity(0),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                        begin: Alignment(-1.0, 0),
                                        end: Alignment(1.0, 0),
                                        transform:
                                        GradientRotation(math.pi / 10),
                                      ).createShader(Rect.fromLTWH(
                                          shimmerX,
                                          0,
                                          bounds.width,
                                          bounds.height));
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Text(
                                      _displayedText,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Your female health assistant",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
