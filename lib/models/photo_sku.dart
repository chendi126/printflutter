
class PhotoSku {
  String name;
  double price;

  PhotoSku({
    required this.name,
    required this.price,
  });

  factory PhotoSku.fromJson(Map<String, dynamic> json) {
    return PhotoSku(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
