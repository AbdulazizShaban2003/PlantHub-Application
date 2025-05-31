import 'package:plant_hub_app/features/articles/data/models/plant_model.dart';

class Care {
  final Fertilizer fertilizer;
  final Humidity humidity;
  final Propagation propagation;
  final Water water;

  Care({
    required this.fertilizer,
    required this.humidity,
    required this.propagation,
    required this.water,
  });

  factory Care.fromJson(Map<String, dynamic> json) {
    return Care(
      fertilizer: Fertilizer.fromJson(json['Fertilizer'] ?? {}),
      humidity: Humidity.fromJson(json['Humidity'] ?? {}),
      propagation: Propagation.fromJson(json['Propagation'] ?? {}),
      water: Water.fromJson(json['water'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Fertilizer': fertilizer.toJson(),
      'Humidity': humidity.toJson(),
      'Propagation': propagation.toJson(),
      'water': water.toJson(),
    };
  }
}

class Fertilizer {
  final String frequency;
  final String type;
  final String warning;

  Fertilizer({
    required this.frequency,
    required this.type,
    required this.warning,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      frequency: json['frequency'] ?? 'غير محدد',
      type: json['type'] ?? 'غير محدد',
      warning: json['warning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'frequency': frequency, 'type': type, 'warning': warning};
  }
}

class Humidity {
  final String preference;
  final String risk;

  Humidity({required this.preference, required this.risk});

  factory Humidity.fromJson(Map<String, dynamic> json) {
    return Humidity(
      preference: json['preference'] ?? 'غير محدد',
      risk: json['risk'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'preference': preference, 'risk': risk};
  }
}

class Propagation {
  final String method;
  final List<String> steps;

  Propagation({required this.method, required this.steps});

  factory Propagation.fromJson(Map<String, dynamic> json) {
    return Propagation(
      method: json['method'] ?? 'غير محدد',
      steps: List<String>.from(json['steps'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'steps': steps};
  }
}

class Water {
  final String frequency;
  final String notes;

  Water({required this.frequency, required this.notes});

  factory Water.fromJson(Map<String, dynamic> json) {
    return Water(
      frequency: json['frequency'] ?? 'غير محدد',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'frequency': frequency, 'notes': notes};
  }
}
