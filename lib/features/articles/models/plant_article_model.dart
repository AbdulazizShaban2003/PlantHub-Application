class PlantArticle {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  bool isBookmarked;
  PlantArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.isBookmarked = false,
  });
}