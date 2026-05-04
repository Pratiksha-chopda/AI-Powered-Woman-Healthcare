import 'package:flutter/material.dart';

class PcosTipsScreen extends StatefulWidget {
  const PcosTipsScreen({super.key});

  @override
  State<PcosTipsScreen> createState() => _PcosTipsScreenState();
}

class _PcosTipsScreenState extends State<PcosTipsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _c1;
  late Animation<Color?> _c2;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _c1 = ColorTween(
      begin: const Color(0xFF00BFA5).withOpacity(0.6),
      end: const Color(0xFF1DE9B6).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _c2 = ColorTween(
      begin: const Color(0xFF00796B).withOpacity(0.6),
      end: const Color(0xFF64FFDA).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🌸 Main UI
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
            // Background Image with Parallax
            Positioned.fill(
              top: -_scrollOffset * 0.25,
              child: Hero(
                tag: "PCOS Tips",
                child: Image.asset(
                  "assets/images/guide3.jpg",
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

            // Scrollable Content
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  expandedHeight: 220,
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text(
                      "PCOS Tips & Care",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),
                SliverToBoxAdapter(child: _buildContent()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🌿 Main Content
  Widget _buildContent() => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fadeIn(
          const Text(
            "“Consistency is more powerful than perfection.”",
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 24),

        _sectionTitle(Icons.local_dining, "Nutrition & Diet"),
        _tip(
            "🍎 Focus on whole foods: fruits, vegetables, whole grains, and lean proteins."),
        _tip("🥑 Include healthy fats — avocado, olive oil, nuts, and seeds."),
        _tip(
            "🚫 Limit processed foods, refined sugars, and white flour to balance insulin."),
        _tip(
            "🥗 Eat smaller, more frequent meals to keep blood sugar levels steady."),
        _tip(
            "💧 Stay hydrated — aim for 2–3 liters of water daily to help hormone balance."),
        const SizedBox(height: 24),

        _sectionTitle(Icons.fitness_center, "Exercise & Movement"),
        _tip("🏃‍♀️ Do moderate exercise 4–5 times a week — brisk walking, cycling, or dancing."),
        _tip("🧘‍♀️ Add yoga or Pilates to manage stress and improve flexibility."),
        _tip("🏋️ Strength training improves insulin sensitivity and boosts metabolism."),
        _tip("🚶 Move throughout the day — avoid sitting for long periods."),
        const SizedBox(height: 24),

        _sectionTitle(Icons.self_improvement, "Stress Management"),
        _tip("🧘 Practice deep breathing, meditation, or journaling daily."),
        _tip("💆 Take regular breaks from work and screen time."),
        _tip("🌅 Spend time in sunlight and nature for mood regulation."),
        _tip("💞 Stay socially connected — talk with friends or family when stressed."),
        const SizedBox(height: 24),

        _sectionTitle(Icons.nightlight_round, "Sleep & Recovery"),
        _tip("🛌 Aim for 7–8 hours of restful sleep every night."),
        _tip("📵 Avoid screens 1 hour before bed to improve melatonin levels."),
        _tip("🌙 Maintain a consistent sleep schedule — sleep and wake at the same time daily."),
        _tip("🕯️ Create a relaxing bedtime routine (dim lights, soft music, herbal tea)."),
        const SizedBox(height: 24),

        _sectionTitle(Icons.healing, "Medical & Self-Care"),
        _tip("👩‍⚕️ Regular check-ups with your gynecologist or endocrinologist."),
        _tip("💊 If prescribed, take medications like Metformin or birth control consistently."),
        _tip("🩸 Track your menstrual cycle to monitor changes or improvements."),
        _tip("💖 Remember — PCOS is manageable with lifestyle balance and awareness."),
        const SizedBox(height: 30),

        _fadeIn(
          const Text(
            "🌸 Remember: PCOS is not the end of your story. With balanced nutrition, mindful habits, and patience, you can feel healthy, strong, and confident every day.",
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    ),
  );

  // 🌼 Helper widgets
  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.teal, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.teal.shade700, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );

  Widget _fadeIn(Widget child) => TweenAnimationBuilder(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeIn,
    builder: (context, opacity, _) => Opacity(
      opacity: opacity,
      child: child,
    ),
  );
}
