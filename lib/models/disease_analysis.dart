import 'package:flutter/material.dart';

class DiseaseAnalysis {
  final String plantName;
  final String healthStatus; // 'Healthy', 'Diseased', 'Unknown'
  final String? diseaseName;
  final String? severity; // 'Mild', 'Moderate', 'Severe'
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<Treatment> treatments;
  final List<String> preventionTips;
  final double confidenceScore; // 0.0 to 1.0
  final DateTime analyzedAt;
  final String? imagePath;

  DiseaseAnalysis({
    required this.plantName,
    required this.healthStatus,
    this.diseaseName,
    this.severity,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.preventionTips,
    required this.confidenceScore,
    required this.analyzedAt,
    this.imagePath,
  });

  bool get isHealthy => healthStatus.toLowerCase() == 'healthy';

  Color get statusColor {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF2D6A4F);
      case 'diseased':
        switch (severity?.toLowerCase()) {
          case 'mild':
            return const Color(0xFFE9C46A);
          case 'moderate':
            return const Color(0xFFF4A261);
          case 'severe':
            return const Color(0xFFE63946);
          default:
            return const Color(0xFFF4A261);
        }
      default:
        return const Color(0xFF6C757D);
    }
  }

  factory DiseaseAnalysis.fromJson(Map<String, dynamic> json) {
    return DiseaseAnalysis(
      plantName: json['plant_name'] ?? 'Unknown Plant',
      healthStatus: json['health_status'] ?? 'Unknown',
      diseaseName: json['disease_name'],
      severity: json['severity'],
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      treatments: (json['treatments'] as List<dynamic>? ?? [])
          .map((t) => Treatment.fromJson(t as Map<String, dynamic>))
          .toList(),
      preventionTips: List<String>.from(json['prevention_tips'] ?? []),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'plant_name': plantName,
    'health_status': healthStatus,
    'disease_name': diseaseName,
    'severity': severity,
    'description': description,
    'symptoms': symptoms,
    'causes': causes,
    'treatments': treatments.map((t) => t.toJson()).toList(),
    'prevention_tips': preventionTips,
    'confidence_score': confidenceScore,
    'analyzed_at': analyzedAt.toIso8601String(),
    'image_path': imagePath,
  };
}

class Treatment {
  final String type; // 'Organic', 'Chemical', 'Cultural', 'Biological'
  final String name;
  final String description;
  final String howToApply;
  final bool isOrganic;

  Treatment({
    required this.type,
    required this.name,
    required this.description,
    required this.howToApply,
    required this.isOrganic,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      type: json['type'] ?? 'General',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      howToApply: json['how_to_apply'] ?? '',
      isOrganic: json['is_organic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'how_to_apply': howToApply,
    'is_organic': isOrganic,
  };
}
