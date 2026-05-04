import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PcosWhatScreen extends StatefulWidget {
  const PcosWhatScreen({super.key});

  @override
  State<PcosWhatScreen> createState() => _PcosWhatScreenState();
}

class _PcosWhatScreenState extends State<PcosWhatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _c1;
  late Animation<Color?> _c2;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _c1 = ColorTween(
      begin: const Color(0xFFFF758C).withOpacity(0.6),
      end: const Color(0xFFFDA085).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _c2 = ColorTween(
      begin: const Color(0xFFFF9A9E).withOpacity(0.6),
      end: const Color(0xFFFECFEF).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          setState(() => _scrollOffset = scroll.metrics.pixels);
          return false;
        },
        child: Stack(
          children: [
            // Parallax Background
            Positioned.fill(
              top: -_scrollOffset * 0.25,
              child: Hero(
                tag: "What is PCOS?",
                child: Image.asset(
                  "assets/images/guide2.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Animated Gradient Overlay
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_c1.value!, _c2.value!],
                  ),
                ),
              ),
            ),

            // Scroll Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon:
                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  expandedHeight: 230,
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text(
                      "What is PCOS?",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _quote(
                            "“Your hormones don’t define you — your strength does.”"),

                        _animatedSection(
                          index: 0,
                          title: "Understanding PCOS",
                          icon: FontAwesomeIcons.venus,
                          content:
                          "Polycystic Ovary Syndrome (PCOS) is a complex hormonal disorder that affects how a woman’s ovaries work. "
                              "It is one of the most common causes of infertility and can influence not only the reproductive system but also metabolism, skin, and mood.\n\n"
                              "The name ‘polycystic’ refers to the many small fluid-filled sacs (follicles) seen on the ovaries via ultrasound — but not everyone with PCOS has these cysts.",
                        ),

                        _animatedSection(
                          index: 1,
                          title: "The Hormonal Imbalance",
                          icon: FontAwesomeIcons.flask,
                          content:
                          "PCOS happens when the ovaries produce an abnormal amount of androgens — male hormones that are normally present in small amounts in females.\n\n"
                              "The hormonal imbalance disrupts ovulation, meaning eggs may not develop or release regularly. "
                              "This can lead to irregular periods and sometimes infertility.\n\n"
                              "Along with high androgens, insulin resistance plays a major role. When the body doesn’t respond properly to insulin, it produces more, "
                              "which can increase androgen levels and contribute to symptoms like weight gain and acne.",
                        ),

                        _animatedSection(
                          index: 2,
                          title: "How PCOS Affects the Body",
                          icon: FontAwesomeIcons.heartbeat,
                          content:
                          "PCOS doesn’t only affect fertility — it influences multiple body systems:\n\n"
                              "💠 **Reproductive:** Irregular periods, difficulty conceiving.\n"
                              "💠 **Skin & Hair:** Acne, excess hair growth (hirsutism), hair thinning.\n"
                              "💠 **Metabolism:** Weight gain, especially around the abdomen, and higher risk of Type 2 diabetes.\n"
                              "💠 **Mental Health:** Many women experience anxiety, depression, or body-image struggles.\n"
                              "💠 **Long-term Risks:** If unmanaged, PCOS can lead to complications like endometrial cancer, high cholesterol, and heart disease.",
                        ),

                        _animatedSection(
                          index: 3,
                          title: "Why Early Diagnosis Matters",
                          icon: FontAwesomeIcons.userDoctor,
                          content:
                          "PCOS can appear as early as teenage years but is often undiagnosed for years. "
                              "Early diagnosis allows you to manage symptoms and prevent complications through lifestyle and medical care.\n\n"
                              "Doctors usually perform:\n"
                              "• Blood tests to check hormone and insulin levels\n"
                              "• Ultrasound scans to look for ovarian cysts\n"
                              "• Physical assessments for symptoms like acne or hair growth",
                        ),

                        _animatedSection(
                          index: 4,
                          title: "Common Myths",
                          icon: FontAwesomeIcons.circleExclamation,
                          content:
                          "🚫 **Myth:** Only overweight women have PCOS.\n"
                              "✅ **Fact:** PCOS can affect women of any size — even those who are underweight.\n\n"
                              "🚫 **Myth:** You can’t get pregnant if you have PCOS.\n"
                              "✅ **Fact:** With treatment and lifestyle changes, many women conceive naturally.\n\n"
                              "🚫 **Myth:** PCOS always causes cysts.\n"
                              "✅ **Fact:** Some women have hormonal imbalance without cysts on their ovaries.",
                        ),

                        _animatedSection(
                          index: 5,
                          title: "How PCOS is Managed",
                          icon: FontAwesomeIcons.notesMedical,
                          content:
                          "While there’s no cure for PCOS, the symptoms can be well managed. "
                              "A combined approach of medical treatment, nutrition, and lifestyle makes the biggest difference.\n\n"
                              "🏃‍♀️ **Lifestyle:** Regular exercise helps improve insulin sensitivity and balance hormones.\n"
                              "🥗 **Diet:** Focus on whole foods, fiber, and protein while limiting sugar and refined carbs.\n"
                              "💊 **Medications:** Your doctor may prescribe birth control pills to regulate periods or Metformin to control insulin resistance.\n"
                              "🧘‍♀️ **Stress Management:** Yoga, mindfulness, and adequate sleep help regulate cortisol and hormonal balance.",
                        ),

                        _animatedSection(
                          index: 6,
                          title: "Living Confidently with PCOS",
                          icon: FontAwesomeIcons.heart,
                          content:
                          "PCOS is not the end of your health story — it’s the start of understanding your body better. "
                              "By focusing on consistency, care, and self-awareness, you can live a healthy and confident life.\n\n"
                              "Remember: PCOS doesn’t define your womanhood — your resilience does. 💖",
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

  // --- Helper Widgets ---

  Widget _quote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.pinkAccent,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _animatedSection({
    required int index,
    required String title,
    required IconData icon,
    required String content,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 60, end: 0),
      duration: Duration(milliseconds: 700 + (index * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value / 60).clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, value), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(title, icon),
            const SizedBox(height: 10),
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

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.pinkAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ],
    );
  }
}
