import 'package:cloud_firestore/cloud_firestore.dart';

class HealthReportModel {
  final double carbs;
  final double energy;
  final double sleep;
  final double weight;
  final double bmi;
  final double hairLoss;
  final DateTime? date; // optional field for reports
  final String? id; // Firestore document ID (optional)

  HealthReportModel({
    required this.carbs,
    required this.energy,
    required this.sleep,
    required this.weight,
    required this.bmi,
    required this.hairLoss,
    this.date,
    this.id,
  });

  HealthReportModel copyWith({
    double? carbs,
    double? energy,
    double? sleep,
    double? weight,
    double? bmi,
    double? hairLoss,
    DateTime? date,
    String? id,
  }) {
    return HealthReportModel(
      carbs: carbs ?? this.carbs,
      energy: energy ?? this.energy,
      sleep: sleep ?? this.sleep,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      hairLoss: hairLoss ?? this.hairLoss,
      date: date ?? this.date,
      id: id ?? this.id,
    );
  }

  /// ✅ Convert model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'carbs': carbs,
      'energy': energy,
      'sleep': sleep,
      'weight': weight,
      'bmi': bmi,
      'hairLoss': hairLoss,
      'date': date != null ? Timestamp.fromDate(date!) : Timestamp.now(),
    };
  }

  /// ✅ Create model from Firestore document
  factory HealthReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthReportModel(
      id: doc.id,
      carbs: (data['carbs'] ?? 0).toDouble(),
      energy: (data['energy'] ?? 0).toDouble(),
      sleep: (data['sleep'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      bmi: (data['bmi'] ?? 0).toDouble(),
      hairLoss: (data['hairLoss'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }
}
