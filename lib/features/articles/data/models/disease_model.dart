class Disease {
  final String name;
  final String image;
  final List<String> listImage;
  final String symptoms;
  final String causedBy;
  final String transmission;
  final List<String> treatment;

  Disease({
    required this.name,
    required this.image,
    required this.listImage,
    required this.symptoms,
    required this.causedBy,
    required this.transmission,
    required this.treatment,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'] ?? 'unknown disease 🤷‍♀️🤷‍♀️',
      image: json['image'] ?? '',
      listImage: List<String>.from(json['listImage'] ?? []),
      symptoms: json['symptoms'] ?? 'There are no specific symptoms.',
      causedBy: json['causedBy'] ?? 'Unknown cause',
      transmission: json['transmission'] ?? 'Unknown mode of transmission',
      treatment: List<String>.from(json['treatment'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'listImage': listImage,
      'symptoms': symptoms,
      'causedBy': causedBy,
      'transmission': transmission,
      'treatment': treatment,
    };
  }
}
