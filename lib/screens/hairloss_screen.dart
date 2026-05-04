import 'package:flutter/material.dart';
import 'bmi_screen.dart';
import 'package:woman1/models/health_report_model.dart';

class HairLossScreen extends StatefulWidget {
  final HealthReportModel report;
  const HairLossScreen({super.key, required this.report});

  @override
  State<HairLossScreen> createState() => _HairLossScreenState();
}

class _HairLossScreenState extends State<HairLossScreen> {
  double? selectedValue;
  String? selectedLabel;

  final List<Map<String, dynamic>> hairLossLevels = [
    {"label": "No Loss", "value": 0.0, "color": Colors.greenAccent},
    {"label": "Mild", "value": 2.0, "color": Colors.lightGreenAccent},
    {"label": "Moderate", "value": 4.0, "color": Colors.amberAccent},
    {"label": "High", "value": 6.0, "color": Colors.orangeAccent},
    {"label": "Severe", "value": 8.0, "color": Colors.redAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/hairloss_bg.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hair Loss Tracker 💇‍♀️",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "How much hair fall did you notice today?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 💇‍♀️ Hair loss level boxes
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: hairLossLevels.map((item) {
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
                            : Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? item["color"].withOpacity(0.6)
                                : Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item["label"],
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : Colors.redAccent,
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

              // 🟩 Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please select your hair loss level.")),
                        );
                        return;
                      }

                      final updated =
                      widget.report.copyWith(hairLoss: selectedValue);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BMIScreen(report: updated)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
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
