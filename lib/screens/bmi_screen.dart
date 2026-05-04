import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:woman1/models/health_report_model.dart';
import 'report_screen.dart';

class BMIScreen extends StatefulWidget {
  final HealthReportModel report;
  const BMIScreen({super.key, required this.report});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController _heightController = TextEditingController();
  double? _calculatedBMI;
  bool _isSaving = false;

  // 🔹 Calculate BMI
  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    if (height != null && height > 0) {
      final bmi = widget.report.weight / ((height / 100) * (height / 100));
      setState(() => _calculatedBMI = bmi);
    }
  }

  // 🔹 Save BMI data to Firestore
  Future<void> _saveReportToFirestore(double bmi) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final reportData = {
      "bmi": bmi,
      "carbs": widget.report.carbs,
      "energy": widget.report.energy,
      "sleep": widget.report.sleep,
      "weight": widget.report.weight,
      "hairLoss": widget.report.hairLoss,
      "date": FieldValue.serverTimestamp(),
    };

    try {
      setState(() => _isSaving = true);

      // Save report in subcollection
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("reports")
          .add(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("BMI report saved successfully ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving report: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  //  When Finish is clicked
  Future<void> _finish() async {
    if (_calculatedBMI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please calculate your BMI first")),
      );
      return;
    }

    await _saveReportToFirestore(_calculatedBMI!);

    final updated = widget.report.copyWith(bmi: _calculatedBMI ?? 0);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReportScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bmi_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xAA8E2DE2), Color(0xAA4A00E0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 40,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "BMI Calculator 🧮",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your height to calculate your BMI automatically.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // Height input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Height (cm)",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter height (e.g. 167)",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                          ),
                          onPressed: _calculateBMI,
                          child: const Text(
                            "Calculate",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_calculatedBMI != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Your BMI: ${_calculatedBMI!.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getBMICategory(_calculatedBMI!),
                            style: TextStyle(
                              color: _getBMIColor(_calculatedBMI!),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _isSaving
                              ? const CircularProgressIndicator(
                              color: Colors.deepPurple)
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                            ),
                            onPressed: _finish,
                            child: const Text("Finish"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight 🥗 — Eat more nutritious food.";
    if (bmi < 25) return "Normal ✅ — Maintain your current lifestyle.";
    if (bmi < 30) return "Overweight ⚠️ — Include daily exercise.";
    return "Obese 🚫 — Consult a doctor and dietitian.";
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
