class AppNameModel {
  final int id;
  final String appName;

  //constructor
  AppNameModel({required this.id, required this.appName});
  //from json
  factory AppNameModel.fromJson(Map<String, dynamic> json) {
    return AppNameModel(
      id: json['id'] as int,
      appName: json['appName'] as String,
    );
  }
  //to json
  Map<String, dynamic> toJson() {
    return {'id': id, 'appName': appName};
  }
  //copywith
  AppNameModel copyWith({
    int? id,
    String? appName,
  }) {
    return AppNameModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
    );
  }
}
