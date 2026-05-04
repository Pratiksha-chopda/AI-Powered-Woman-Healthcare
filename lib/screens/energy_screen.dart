import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'carb_screen.dart';
import 'sleep_screen.dart';
import 'package:woman1/models/health_report_model.dart';

class EnergyScreen extends StatefulWidget {
  final HealthReportModel report;
  const EnergyScreen({super.key, required this.report});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  double? selectedValue;
  String? selectedLabel;

  final List<Map<String, dynamic>> energyLevels = [
    {"label": "Low", "value": 2.0, "color": Colors.redAccent},
    {"label": "Normal", "value": 4.0, "color": Colors.orangeAccent},
    {"label": "Good", "value": 6.0, "color": Colors.lightBlueAccent},
    {"label": "High", "value": 8.0, "color": Colors.greenAccent},
    {"label": "Excellent", "value": 10.0, "color": Colors.tealAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/energy_bg.jpg"),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Energy Tracker",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Select your current energy level for today.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Energy selection boxes
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: energyLevels.map((item) {
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? item["color"].withOpacity(0.5)
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
                            color: isSelected ? Colors.white : Colors.teal,
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

              // 🔘 Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: _btnStyle(),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: CarbScreen(report: widget.report),
                      ),
                    ),
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: _btnStyle(),
                    onPressed: () {
                      if (selectedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please select your energy level.")),
                        );
                        return;
                      }

                      final updated =
                      widget.report.copyWith(energy: selectedValue);
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: SleepScreen(report: updated),
                        ),
                      );
                    },
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

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.9),
    foregroundColor: Colors.teal,
    padding:
    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
