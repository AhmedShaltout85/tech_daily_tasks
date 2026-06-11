class PlaceItemModel {
  final int? id;
  final String placeName;

  PlaceItemModel({
    this.id,
    required this.placeName,
  });

  factory PlaceItemModel.fromJson(Map<String, dynamic> json) {
    return PlaceItemModel(
      id: json['id'],
      placeName: json['placeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
    };
  }

  PlaceItemModel copyWith({
    int? id,
    String? placeName,
  }) {
    return PlaceItemModel(
      id: id ?? this.id,
      placeName: placeName ?? this.placeName,
    );
  }
}
