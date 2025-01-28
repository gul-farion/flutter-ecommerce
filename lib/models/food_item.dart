class FoodItem {
  final String name;
  final String body;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  String? selectedSize;

  FoodItem({
    required this.name,
    required this.body,
    required this.price,
    required this.imageUrl,
    this.sizes = const [],
    this.selectedSize
  });
}
