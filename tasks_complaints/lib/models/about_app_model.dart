class AboutAppModel {
  final int? id;
  final String appName;
  final String? recommended;
  final String department;

  AboutAppModel({
    this.id,
    required this.appName,
    this.recommended,
    required this.department,
  });

  factory AboutAppModel.fromJson(Map<String, dynamic> json) {
    return AboutAppModel(
      id: json['id'],
      appName: json['appName'] ?? '',
      recommended: json['recommended'],
      department: json['department'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'recommended': recommended,
      'department': department,
    };
  }

  AboutAppModel copyWith({
    int? id,
    String? appName,
    String? recommended,
    String? department,
  }) {
    return AboutAppModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      recommended: recommended ?? this.recommended,
      department: department ?? this.department,
    );
  }
}
