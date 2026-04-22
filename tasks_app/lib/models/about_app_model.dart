class AboutApp {
  final int? id;
  final String appName;
  final String recommended;

  // Constructor
  AboutApp({
    this.id,
    required this.appName,
    required this.recommended,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'recommended': recommended,
    };
  }

  // Extract a AboutApps object from a Map object
  factory AboutApp.fromMap(Map<String, dynamic> map) {
    return AboutApp(
      id: map['id'],
      appName: map['appName'],
      recommended: map['recommended'],
    );
  }

  //copyWith
  AboutApp copyWith({
    int? id,
    String? appName,
    String? recommended,
  }) {
    return AboutApp(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      recommended: recommended ?? this.recommended,
    );
  }
  
}