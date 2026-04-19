class PlaceNameModel {
  final String? placeId;
  final String placeName;

//constructor
  PlaceNameModel({
    this.placeId,
    required this.placeName,
  });

//fromJson
  factory PlaceNameModel.fromJson(Map<String, dynamic> json) {
    return PlaceNameModel(
      placeId: json['placeId'],
      placeName: json['placeName'],
    );
  }

//toJson
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeName': placeName,
    };
  }

}