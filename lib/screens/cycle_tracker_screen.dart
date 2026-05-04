import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  DateTime _selectedDate = DateTime.now();

  // Mock data for the calendar. In a real app, this would be dynamic.
  final DateTime _today = DateTime.now();
  final List<DateTime> _periodDays = [
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 2)),
    DateTime.now().subtract(const Duration(days: 1)),
  ];

  final List<DateTime> _fertileWindow = [
    DateTime.now().add(const Duration(days: 10)),
    DateTime.now().add(const Duration(days: 11)),
    DateTime.now().add(const Duration(days: 12)),
    DateTime.now().add(const Duration(days: 13)),
    DateTime.now().add(const Duration(days: 14)),
  ];

  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cycle Tracker"),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image section with a welcoming image and animation.
            FadeTransition(
              opacity: _animation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  "https://placehold.co/600x200/F48FB1/FFFFFF?text=Your+Wellness+Journey",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Month header with navigation buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                Text(
                  '${_monthName(_today.month)} ${_today.year}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday labels.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: _weekdays.length,
              itemBuilder: (context, index) => Center(
                child: Text(_weekdays[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ),

            // Calendar grid.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: 30, // Mocking 30 days for simplicity.
              itemBuilder: (context, index) {
                final day = DateTime(_today.year, _today.month, index + 1);
                final isToday = day.day == _today.day && day.month == _today.month;
                final isPeriodDay = _periodDays.any((d) => d.day == day.day && d.month == day.month);
                final isFertileDay = _fertileWindow.any((d) => d.day == day.day && d.month == day.month);
                final isSelected = day.day == _selectedDate.day;

                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black87;

                if (isPeriodDay) {
                  backgroundColor = AppTheme.primaryColor.withOpacity(0.2);
                  textColor = AppTheme.primaryColor;
                } else if (isFertileDay) {
                  backgroundColor = const Color(0xFFC8E6C9).withOpacity(0.8);
                  textColor = const Color(0xFF388E3C);
                }

                if (isSelected) {
                  backgroundColor = AppTheme.primaryColor;
                  textColor = Colors.white;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                    _controller.forward(from: 0.0);
                    _showDailyLogSheet(context, day);
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _animation.value : 1.0,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _showDailyLogSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log for ${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodIcon(Icons.sentiment_very_satisfied, 'Happy'),
                  _buildMoodIcon(Icons.sentiment_satisfied, 'Good'),
                  _buildMoodIcon(Icons.sentiment_neutral, 'Neutral'),
                  _buildMoodIcon(Icons.sentiment_dissatisfied, 'Sad'),
                  _buildMoodIcon(Icons.sentiment_very_dissatisfied, 'Angry'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Log symptoms',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSymptomChip('Cramps', Icons.local_hospital),
                  _buildSymptomChip('Headache', Icons.sick),
                  _buildSymptomChip('Bloating', Icons.bubble_chart),
                  _buildSymptomChip('Fatigue', Icons.battery_alert),
                  _buildSymptomChip('Nausea', Icons.local_pharmacy),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Save Log'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build a tappable icon with a label.
  Widget _buildMoodIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Handle mood selection logic here.
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor.withOpacity(0.2),
            radius: 28,
            child: Icon(icon, color: AppTheme.primaryColor, size: 30),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Helper widget to build a symptom chip.
  Widget _buildSymptomChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: AppTheme.primaryColor),
      label: Text(label),
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}