import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PcosGuideScreen extends StatefulWidget {
  const PcosGuideScreen({super.key});

  @override
  State<PcosGuideScreen> createState() => _PcosGuideScreenState();
}

class _PcosGuideScreenState extends State<PcosGuideScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientColor1;
  late Animation<Color?> _gradientColor2;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _gradientColor1 = ColorTween(
      begin: const Color(0xFF4C4177).withOpacity(0.8),
      end: const Color(0xFF2A5470).withOpacity(0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _gradientColor2 = ColorTween(
      begin: const Color(0xFFB06AB3).withOpacity(0.8),
      end: const Color(0xFF4568DC).withOpacity(0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          setState(() {
            _scrollOffset = scrollInfo.metrics.pixels;
          });
          return false;
        },
        child: Stack(
          children: [
            // Background image with parallax
            Positioned.fill(
              top: -_scrollOffset * 0.3,
              child: Hero(
                tag: "Guide to PCOS",
                child: Image.asset(
                  "assets/images/guide1.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Animated Gradient Overlay
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _gradientColor1.value ?? Colors.deepPurple,
                        _gradientColor2.value ?? Colors.purpleAccent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Scrollable content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  expandedHeight: 230,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "Guide to PCOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    titlePadding:
                    const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),

                // Body Content
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _animatedSection(
                          index: 0,
                          title: "What is PCOS?",
                          icon: FontAwesomeIcons.circleInfo,
                          content:
                          "Polycystic Ovary Syndrome (PCOS) is a common hormonal condition "
                              "affecting women of reproductive age. It causes irregular periods, "
                              "excess male hormones (androgens), and cysts in the ovaries. "
                              "PCOS can impact metabolism, fertility, skin, and mental well-being.",
                        ),

                        _animatedListSection(
                          index: 1,
                          title: "Symptoms",
                          icon: FontAwesomeIcons.exclamationTriangle,
                          items: [
                            "Irregular or missed menstrual cycles",
                            "Weight gain, especially around the belly",
                            "Excess hair growth (face, chest, back)",
                            "Acne and oily skin",
                            "Thinning hair or hair loss",
                            "Difficulty getting pregnant",
                            "Fatigue or mood swings",
                          ],
                        ),

                        _animatedSection(
                          index: 2,
                          title: "Causes",
                          icon: FontAwesomeIcons.dna,
                          content:
                          "The exact cause of PCOS is not fully known, but several factors "
                              "play a role:\n\n"
                              "• Genetic predisposition\n"
                              "• Insulin resistance leading to high insulin levels\n"
                              "• Inflammation in the body\n"
                              "• Hormonal imbalance (especially androgens)",
                        ),

                        _animatedSection(
                          index: 3,
                          title: "Diagnosis",
                          icon: FontAwesomeIcons.stethoscope,
                          content:
                          "Doctors usually diagnose PCOS using a combination of:\n\n"
                              "• Medical history and symptoms\n"
                              "• Physical examination\n"
                              "• Blood tests (to check hormones and insulin)\n"
                              "• Ultrasound scan of the ovaries",
                        ),

                        _animatedSection(
                          index: 4,
                          title: "Treatment & Management",
                          icon: FontAwesomeIcons.syringe,
                          content:
                          "While there’s no permanent cure for PCOS, it can be effectively managed with lifestyle and medical support. Common treatments include:\n\n"
                              "• **Lifestyle Changes:** Regular exercise, balanced diet, stress reduction.\n"
                              "• **Medications:** Birth control pills, Metformin (for insulin resistance), and fertility treatments.\n"
                              "• **Mental Health Support:** Therapy or support groups to manage anxiety or depression.",
                        ),

                        _animatedListSection(
                          index: 5,
                          title: "Diet & Lifestyle Tips",
                          icon: FontAwesomeIcons.utensils,
                          items: [
                            "Eat whole foods rich in fiber and lean protein.",
                            "Avoid processed sugar and refined carbs.",
                            "Include omega-3 fats (flaxseed, fish, walnuts).",
                            "Exercise 30–45 minutes daily.",
                            "Sleep 7–8 hours and manage stress.",
                          ],
                        ),

                        _animatedSection(
                          index: 6,
                          title: "Myths vs Facts",
                          icon: FontAwesomeIcons.balanceScale,
                          content:
                          "🚫 **Myth:** PCOS means you can’t get pregnant.\n"
                              "✅ **Fact:** Many women with PCOS conceive naturally with management.\n\n"
                              "🚫 **Myth:** PCOS only affects overweight women.\n"
                              "✅ **Fact:** It can occur in women of all body types.\n\n"
                              "🚫 **Myth:** You must have cysts to have PCOS.\n"
                              "✅ **Fact:** Not all women with PCOS have ovarian cysts.",
                        ),

                        _animatedSection(
                          index: 7,
                          title: "When to See a Doctor",
                          icon: FontAwesomeIcons.userDoctor,
                          content:
                          "If you experience missed periods for several months, sudden weight changes, "
                              "excess hair growth, or trouble conceiving — visit a gynecologist or endocrinologist. "
                              "Early diagnosis helps prevent long-term complications like diabetes or infertility.",
                        ),

                        _animatedSection(
                          index: 8,
                          title: "Final Note ❤️",
                          icon: FontAwesomeIcons.heart,
                          content:
                          "PCOS doesn’t define you — it’s a manageable condition. "
                              "With consistency, medical guidance, and self-care, you can live a healthy, balanced, and confident life.",
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Animated Section Builder
  Widget _animatedSection({
    required int index,
    required String title,
    required IconData icon,
    required String content,
  }) {
    final delay = index * 0.2;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50, end: 0),
      duration: Duration(milliseconds: 700 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value / 50).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(title, icon),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16.5,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedListSection({
    required int index,
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50, end: 0),
      duration: Duration(milliseconds: 700 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value / 50).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(title, icon),
            const SizedBox(height: 8),
            _iconList(items),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _iconList(List<String> items) {
    return Column(
      children: items
          .map(
            (text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}
