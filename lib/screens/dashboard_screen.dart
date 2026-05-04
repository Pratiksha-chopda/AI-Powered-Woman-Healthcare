import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// MODELS
import 'package:woman1/models/health_report_model.dart';

// SCREENS
import 'pcos_guide_screen.dart';
import 'pcos_what_screen.dart';
import 'pcos_tips_screen.dart';
import 'carb_screen.dart';
import 'energy_screen.dart';
import 'sleep_screen.dart';
import 'weight_screen.dart';
import 'hairloss_screen.dart';
import 'bmi_screen.dart';
import 'report_screen.dart';
import 'ArticleDetailScreen.dart';
import 'tips_screen.dart';
import 'stories_screen.dart';
import 'FaqScreen.dart';
import 'profile_screen.dart';

// CHATBOT
import 'chatbot_screen.dart';

class PcosTopic {
  final String title;
  final String image;
  final Widget page;

  PcosTopic({
    required this.title,
    required this.image,
    required this.page,
  });
}

class DiscoverItem {
  final String title;
  final String category;
  final String time;
  final String imageUrl;
  final String content;

  DiscoverItem({
    required this.title,
    required this.category,
    required this.time,
    required this.imageUrl,
    required this.content,
  });

  factory DiscoverItem.fromMap(Map<String, dynamic> map) {
    return DiscoverItem(
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      time: map['time'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      content: map['content'] ?? '',
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _greetingController;
  late Animation<Offset> _slideAnimation;

  String greetingMessage = "";
  bool isLoadingReport = true;

  HealthReportModel report = HealthReportModel(
    carbs: 0,
    energy: 0,
    sleep: 0,
    weight: 0,
    bmi: 0,
    hairLoss: 0,
  );

  List<DiscoverItem> discoverItems = [];
  String selectedCategory = 'Articles';
  bool isDiscoverLoading = true;

  @override
  void initState() {
    super.initState();

    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = "Good Morning";
    } else if (hour < 17) {
      greetingMessage = "Good Afternoon";
    } else {
      greetingMessage = "Good Evening";
    }

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _greetingController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _greetingController, curve: Curves.easeOutBack),
        );
    _greetingController.forward();

    _fetchLatestReport();
    fetchDiscoverItems();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestReport() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reports')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          report = HealthReportModel(
            carbs: (data['carbs'] ?? 0).toDouble(),
            energy: (data['energy'] ?? 0).toDouble(),
            sleep: (data['sleep'] ?? 0).toDouble(),
            weight: (data['weight'] ?? 0).toDouble(),
            bmi: (data['bmi'] ?? 0).toDouble(),
            hairLoss: (data['hairLoss'] ?? 0).toDouble(),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching report: $e");
    } finally {
      setState(() => isLoadingReport = false);
    }
  }

  Future<void> fetchDiscoverItems() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('discover').get();

      final allItems = snapshot.docs
          .map((doc) => DiscoverItem.fromMap(doc.data()))
          .toList();

      setState(() {
        discoverItems = allItems;
        isDiscoverLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading discover items: $e");
    }
  }

  final List<PcosTopic> topics = [
    PcosTopic(
      title: "Guide to PCOS",
      image: "assets/images/pcos1.png",
      page: const PcosGuideScreen(),
    ),
    PcosTopic(
      title: "What is PCOS?",
      image: "assets/images/pcos3.png",
      page: const PcosWhatScreen(),
    ),
    PcosTopic(
      title: "Tips for PCOS",
      image: "assets/images/pcos4.png",
      page: const PcosTipsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: SafeArea(
        child: isLoadingReport
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GREETING CARD
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9A8CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$greetingMessage, ${widget.username.split(' ').first}",
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMM d')
                                  .format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //  CHATBOT CARD — NOW WORKS
                GestureDetector(
                  onTap: () {
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid ?? "guest";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatBotScreen(userId: uid),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline,
                            size: 32, color: Colors.deepPurple),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Chat with us now… Get Emotional Care & Counseling",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // UNDERSTANDING PCOS
                const Text(
                  "Understanding PCOS",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: topics.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final t = topics[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              duration:
                              const Duration(milliseconds: 600),
                              child: t.page,
                            ),
                          );
                        },
                        child: Hero(
                          tag: t.title,
                          child: Container(
                            width: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: AssetImage(t.image),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.1),
                                  BlendMode.darken,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  t.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // TRACKERS
                const Text(
                  "Trackers",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _trackerCard(Icons.fastfood, "Carbs", Colors.orange),
                    _trackerCard(Icons.bolt, "Energy", Colors.blue),
                    _trackerCard(Icons.nightlight_round, "Sleep",
                        Colors.teal),
                    _trackerCard(Icons.monitor_weight, "Weight",
                        Colors.pink),
                    _trackerCard(Icons.scale, "BMI", Colors.indigo),
                    _trackerCard(Icons.face_retouching_natural,
                        "Hair Loss", Colors.purple),
                    _trackerCard(Icons.insert_chart, "Report",
                        Colors.green),
                  ],
                ),

                const SizedBox(height: 24),

                //  DISCOVER
                const Text(
                  "Discover",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final category
                      in ['Articles', 'Tips', 'Stories', 'FAQs'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (val) {
                              setState(
                                      () => selectedCategory = category);
                            },
                            selectedColor:
                            Colors.deepPurple.shade100,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                isDiscoverLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  children: discoverItems
                      .where((item) =>
                  item.category == selectedCategory)
                      .map((item) => _discoverCard(item))
                      .toList(),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Experts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _trackerCard(IconData icon, String title, Color color) {
    return GestureDetector(
      onTap: () {
        Widget page;
        switch (title) {
          case "Carbs":
            page = CarbScreen(report: report);
            break;
          case "Energy":
            page = EnergyScreen(report: report);
            break;
          case "Sleep":
            page = SleepScreen(report: report);
            break;
          case "Weight":
            page = WeightScreen(report: report);
            break;
          case "BMI":
            page = BMIScreen(report: report);
            break;
          case "Hair Loss":
            page = HairLossScreen(report: report);
            break;
          case "Report":
            page = ReportScreen();
            break;
          default:
            page = CarbScreen(report: report);
        }

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 600),
            child: page,
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discoverCard(DiscoverItem item) {
    return GestureDetector(
      onTap: () {
        switch (item.category) {
          case 'Tips':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TipsScreen(),
              ),
            );
            break;

          case 'Stories':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoriesScreen(),
              ),
            );
            break;

          case 'FAQs':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiscoverFaqSection(),
              ),
            );
            break;

          default:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(
                  title: item.title,
                  content: item.content,
                  imageUrl: item.imageUrl,
                ),
              ),
            );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                item.imageUrl,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image,
                      color: Colors.grey, size: 36),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          item.time,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}