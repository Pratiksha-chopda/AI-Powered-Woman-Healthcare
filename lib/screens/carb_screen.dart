import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'energy_screen.dart';
import 'package:woman1/models/health_report_model.dart';

class CarbScreen extends StatefulWidget {
  final HealthReportModel report;
  const CarbScreen({super.key, required this.report});

  @override
  State<CarbScreen> createState() => _CarbScreenState();
}

class _CarbScreenState extends State<CarbScreen> {
  double? selectedValue; // numeric value (2, 4, 6, 8)
  String? selectedLabel; // visual label (Low, Medium...)
  bool _isSaving = false;

  final List<Map<String, dynamic>> cravings = [
    {"label": "Low", "value": 2.0, "color": Colors.greenAccent},
    {"label": "Medium", "value": 4.0, "color": Colors.lightBlueAccent},
    {"label": "Moderate", "value": 6.0, "color": Colors.orangeAccent},
    {"label": "High", "value": 8.0, "color": Colors.redAccent},
  ];

  bool _isImageLoaded = false;
  final ImageProvider _backgroundImage =
  const AssetImage("assets/images/carb_img.jpg");

  @override
  void initState() {
    super.initState();
    //  Preload background image
    _backgroundImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((_, __) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      }),
    );
  }

  // 🔹 Save carb craving selection to Firestore
  Future<void> _saveCarbDataToFirestore(double carbLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final reportData = {
      "carbs": carbLevel,
      "energy": widget.report.energy,
      "sleep": widget.report.sleep,
      "weight": widget.report.weight,
      "bmi": widget.report.bmi,
      "hairLoss": widget.report.hairLoss,
      "date": FieldValue.serverTimestamp(),
    };

    try {
      setState(() => _isSaving = true);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("reports")
          .add(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carb data saved successfully ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isImageLoaded
            ? _buildMainUI()
            : const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF7F50),
          ),
        ),
      ),
    );
  }

  Widget _buildMainUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE5B4), // light peach
            Color(0xFFFFCBA4), // mid peach
            Color(0xFFFFB07C), // deeper peach
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: _backgroundImage,
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select Your Carb Craving Level",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 🍑 Craving boxes
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: cravings.map((item) {
                  final bool isSelected = selectedValue == item["value"];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedValue = item["value"];
                        selectedLabel = item["label"];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 140,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item["color"]
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? item["color"].withOpacity(0.6)
                                : Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item["label"],
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFBF360C),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Back"),
                  ),
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: () async {
                      if (selectedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text("Please select a craving level."),
                          ),
                        );
                        return;
                      }

                      await _saveCarbDataToFirestore(selectedValue!);

                      final updated = widget.report
                          .copyWith(carbs: selectedValue ?? 0);
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EnergyScreen(report: updated),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
