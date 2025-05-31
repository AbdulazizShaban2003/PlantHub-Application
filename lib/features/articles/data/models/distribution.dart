class Distribution {
  final String native;
  final List<String> current;
  final String image;
  final List<String> distributionImages;

  Distribution({
    required this.native,
    required this.current,
    required this.image,
    required this.distributionImages,
  });

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      native: json['native'] ?? 'غير معروف',
      current: List<String>.from(json['current'] ?? []),
      image: json['image'] ?? '',
      distributionImages: List<String>.from(json['listImage'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'native': native,
      'current': current,
      'image': image,
      'listImage': distributionImages,
    };
  }
}