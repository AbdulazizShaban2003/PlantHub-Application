class ClimaticConditions {
  final String moisture;
  final String sensitivity;
  final String soil;
  final String temperature;

  ClimaticConditions({
    required this.moisture,
    required this.sensitivity,
    required this.soil,
    required this.temperature,
  });

  factory ClimaticConditions.fromJson(Map<String, dynamic> json) {
    return ClimaticConditions(
      moisture: json['moisture'] ?? 'undefined 🤦',
      sensitivity: json['sensitivity'] ?? 'undefined 🤦 ',
      soil: json['soil'] ?? 'undefined 🤦',
      temperature: json['temperature'] ?? 'undefined 🤦',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'sensitivity': sensitivity,
      'soil': soil,
      'temperature': temperature,
    };
  }
}
