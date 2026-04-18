class AppNameModel {
  final String id;
  final String appName;

  //constructor
  AppNameModel({required this.id, required this.appName});
  //from json
  factory AppNameModel.fromJson(Map<String, dynamic> json) {
    return AppNameModel(
      id: json['id'] as String,
      appName: json['appName'] as String,
    );
  }
  //to json
  Map<String, dynamic> toJson() {
    return {'id': id, 'appName': appName};
  }
}
