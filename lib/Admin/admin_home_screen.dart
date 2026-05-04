import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_articles_screen.dart';
import 'manage_videos_screen.dart';
import 'manage_faqs_screen.dart';
import 'manage_stories_screen.dart';
import 'manage_tips_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _sections = [
    {'title': 'Articles', 'icon': Icons.article_outlined, 'color': Colors.indigo, 'screen': const ManageArticlesScreen()},
    {'title': 'Videos', 'icon': Icons.video_collection_outlined, 'color': Colors.pink, 'screen': const ManageVideosScreen()},
    {'title': 'FAQs', 'icon': Icons.help_outline, 'color': Colors.orange, 'screen': const ManageFaqsScreen()},
    {'title': 'Stories', 'icon': Icons.book_outlined, 'color': Colors.teal, 'screen': const ManageStoriesScreen()},
    {'title': 'Tips', 'icon': Icons.lightbulb_outline, 'color': Colors.purple, 'screen': const ManageTipsScreen()},
    {
      'title': 'Analytics',
      'icon': Icons.bar_chart_rounded,
      'color': Colors.green,
      'screen': const AnalyticsScreen(),   // <‑ new screen
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSectionCard(Map<String, dynamic> s) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => s['screen']));
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [(s['color'] as Color).withOpacity(0.8), s['color'] as Color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: (s['color'] as Color).withOpacity(0.4), blurRadius: 8, offset: const Offset(2, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'], size: 45, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                s['title'],
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Add • Edit • Remove",
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        title: Text("Admin Dashboard", style: GoogleFonts.montserrat(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: GridView.builder(
          itemCount: _sections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 1.0),
          itemBuilder: (context, index) => _buildSectionCard(_sections[index]),
        ),
      ),
    );
  }
}
