import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:woman1/models/health_report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  HealthReportModel? report;

  @override
  void initState() {
    super.initState();
    _fetchLatestReport();
  }

  Future<void> _fetchLatestReport() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // fetch latest report from subcollection
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reports')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          report = HealthReportModel(
            bmi: (data['bmi'] ?? 0).toDouble(),
            energy: (data['energy'] ?? 0).toDouble(),
            sleep: (data['sleep'] ?? 0).toDouble(),
            carbs: (data['carbs'] ?? 0).toDouble(),
            hairLoss: (data['hairLoss'] ?? 0).toDouble(),
            weight: (data['weight'] ?? 0).toDouble(),
            date: (data['date'] as Timestamp).toDate(),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching report: $e");
    }
  }

  // --- All your helper functions (unchanged) ---
  double _calculateHealthScore() {
    if (report == null) return 0;
    double score = 100;

    if (report!.bmi < 18.5 || report!.bmi > 29.9) score -= 25;
    else if (report!.bmi > 24.9) score -= 15;

    if (report!.energy < 4) score -= 20;
    else if (report!.energy < 7) score -= 10;

    if (report!.sleep < 6) score -= 15;
    else if (report!.sleep > 9) score -= 5;

    if (report!.carbs < 3 || report!.carbs > 8) score -= 10;

    if (report!.hairLoss > 5) score -= 10;

    return max(0, min(100, score));
  }

  String _getHealthSummary(double score) {
    if (score >= 85) return "💪 Excellent! You’re in great health.";
    if (score >= 70) return "🌿 Good! A little improvement will make you perfect.";
    if (score >= 50) return "⚡ Average! Focus on your sleep and diet.";
    return "🚨 Needs Attention! Consult a doctor or nutritionist.";
  }

  String getBmiSuggestion(double bmi) {
    if (bmi < 18.5) return "You're underweight. Add protein and strength training.";
    if (bmi < 24.9) return "Healthy BMI. Maintain your balance with good habits.";
    if (bmi < 29.9) return "You're overweight. Add cardio and reduce sugar.";
    return "High BMI detected. Go for regular walks and healthy meals.";
  }

  String getSleepSuggestion(double sleep) {
    if (sleep < 6) return "Increase sleep hours — target at least 7–8 hrs daily.";
    if (sleep <= 8) return "Perfect sleep routine. Keep it consistent!";
    return "Too much sleep — stay active throughout the day.";
  }

  String getEnergySuggestion(double energy) {
    if (energy < 4) return "Low energy detected. Improve diet and hydration.";
    if (energy <= 6) return "Moderate energy — try stretching or short workouts.";
    return "High energy! Keep your active routine consistent.";
  }

  String getCarbSuggestion(double carbs) {
    if (carbs < 3) return "Low carbs — add fruits and whole grains.";
    if (carbs <= 6) return "Balanced carb intake. Great job!";
    return "Too many carbs — reduce sugar and fried foods.";
  }

  String getHairLossSuggestion(double hair) {
    if (hair > 6) return "Hair loss is above normal — focus on vitamins and protein.";
    if (hair >= 3) return "Mild hair loss — drink more water and reduce stress.";
    return "Healthy hair! Maintain your routine.";
  }

  String getExerciseTip(double bmi, double energy) {
    if (bmi < 18.5) return "🧘 Yoga and light resistance workouts with high-calorie meals.";
    if (bmi < 24.9) return "🏃 Brisk walking and light weight training (30 mins daily).";
    if (energy < 5) return "🚶 Take 20-min walks and avoid overexertion.";
    return "💪 Try HIIT, cycling, and core workouts for stamina.";
  }

  // --- UI Section (unchanged except for loading state) ---
  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final score = _calculateHealthScore();
    final summary = _getHealthSummary(score);
    final bmiAdvice = getBmiSuggestion(report!.bmi);
    final sleepAdvice = getSleepSuggestion(report!.sleep);
    final energyAdvice = getEnergySuggestion(report!.energy);
    final carbAdvice = getCarbSuggestion(report!.carbs);
    final hairAdvice = getHairLossSuggestion(report!.hairLoss);
    final exerciseTip = getExerciseTip(report!.bmi, report!.energy);

    // ⬇ Your same beautiful UI (no changes below this point)
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Your Health Report 🩺",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 14,
                      backgroundColor: Colors.white24,
                      color: score >= 80
                          ? Colors.greenAccent
                          : score >= 60
                          ? Colors.orangeAccent
                          : Colors.redAccent,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${score.toInt()}",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text("Health Score", style: TextStyle(color: Colors.white70))
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              Text(summary, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
              const SizedBox(height: 30),
              _infoCard("Your Stats", [
                _infoRow("Carbs", "${report!.carbs}"),
                _infoRow("Energy", "${report!.energy}"),
                _infoRow("Sleep", "${report!.sleep} hrs"),
                _infoRow("Weight", "${report!.weight} kg"),
                _infoRow("Hair Loss", "${report!.hairLoss} strands"),
                _infoRow("BMI", report!.bmi.toStringAsFixed(1)),
              ]),
              const SizedBox(height: 20),
              _tipCard("AI Health Insights", [
                "🍞 $carbAdvice",
                "⚡ $energyAdvice",
                "💤 $sleepAdvice",
                "🧠 $hairAdvice",
                "📏 $bmiAdvice",
              ]),
              const SizedBox(height: 20),
              _tipCard("Suggested Exercise", [exerciseTip]),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI helpers (same as before) ---
  Widget _infoCard(String title, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const Divider(),
      ...children,
    ]),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    ),
  );

  Widget _tipCard(String title, List<String> tips) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...tips.map((t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text("• $t", style: const TextStyle(color: Colors.white, fontSize: 15)),
      )),
    ]),
  );
}
