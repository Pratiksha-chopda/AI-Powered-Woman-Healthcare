import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:woman1/models/health_report_model.dart';
import 'report_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  User? user;
  String firstName = '';
  String lastName = '';
  String photoUrl = '';
  bool isLoading = true;

  HealthReportModel latestReport = HealthReportModel(
    carbs: 0,
    energy: 0,
    sleep: 0,
    weight: 0,
    bmi: 0,
    hairLoss: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchLatestReport();
  }

  Future<void> _loadUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchLatestReport() async {
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
        latestReport = HealthReportModel(
          carbs: (data['carbs'] ?? 0).toDouble(),
          energy: (data['energy'] ?? 0).toDouble(),
          sleep: (data['sleep'] ?? 0).toDouble(),
          weight: (data['weight'] ?? 0).toDouble(),
          bmi: (data['bmi'] ?? 0).toDouble(),
          hairLoss: (data['hairLoss'] ?? 0).toDouble(),
        );
      });
    }
  }

  String get displayName =>
      "${firstName.trim()} ${lastName.trim()}".trim().isNotEmpty
          ? "${firstName.trim()} ${lastName.trim()}"
          : user?.email?.split('@')[0] ?? 'User';

  Widget frosted({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastel = const Color(0xFFEDE7FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        backgroundColor: pastel,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + Name Card
            frosted(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.deepPurple.shade200,
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : "U",
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      )
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Member since ${user!.metadata.creationTime != null ? DateFormat.yMMMM().format(user!.metadata.creationTime!) : ''}",
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Health Summary Card
            frosted(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your health summary",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Quick glance at your recent health report",
                        style: TextStyle(color: Colors.black54)),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summary("Weight", "${latestReport.weight.toStringAsFixed(0)} kg"),
                        _summary("Hair", latestReport.hairLoss.toStringAsFixed(0)),
                        _summary("BMI", latestReport.bmi.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            _listTile(Icons.article_outlined, "View reports", "See all your saved reports", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
            }),

            _listTile(Icons.notifications, "Reminders",
                "Set medication & check-in reminders", () {}),

            _listTile(Icons.settings, "Account settings",
                "Change password & manage account", () {}),

            _listTile(Icons.logout, "Sign out",
                "Sign out from this device", _signOut,
                isDanger: true),

            const SizedBox(height: 30),
            Text("App version 1.0.0", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _summary(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _listTile(IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool isDanger = false}) {
    return frosted(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isDanger ? Colors.red.shade100 : Colors.deepPurple.shade100,
          child: Icon(icon, color: isDanger ? Colors.red : Colors.deepPurple),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDanger ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
