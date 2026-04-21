class AppNameModel {
  final int id;
  final String appName;
  final String department;

  AppNameModel({
    required this.id,
    required this.appName,
    required this.department,
  });

  factory AppNameModel.fromJson(Map<String, dynamic> json) {
    return AppNameModel(
      id: json['id'] as int,
      appName: json['appName'] as String,
      department: json['department'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'appName': appName, 'department': department};
  }

  AppNameModel copyWith({
    int? id,
    String? appName,
    String? department,
  }) {
    return AppNameModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      department: department ?? this.department,
    );
  }
}
