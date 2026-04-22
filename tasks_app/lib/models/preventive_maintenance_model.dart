class PreventiveMaintenanceModel {
  final int? id;
  final String appName;
  final String placeName;
  final String? subPlace;
  final String? isRemote;
  final String username;
  final String action;

  // Constructor
  PreventiveMaintenanceModel({
    this.id,
    required this.appName,
    required this.placeName,
    this.subPlace,
    this.isRemote,
    required this.username,
    required this.action,
  });

  // From JSON method
  factory PreventiveMaintenanceModel.fromJson(Map<String, dynamic> json) {
    return PreventiveMaintenanceModel(
      id: json['id'] as int?,
      appName: json['appName'],
      placeName: json['placeName'],
      subPlace: json['subPlace'],
      isRemote: json['isRemote'],
      username: json['username'],
      action: json['action'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'placeName': placeName,
      'subPlace': subPlace,
      'isRemote': isRemote,
      'username': username,
      'action': action,
    };
  }

  // Copy with method
  PreventiveMaintenanceModel copyWith({
    int? id,
    String? appName,
    String? placeName,
    String? subPlace,
    String? isRemote,
    String? username,
    String? action,
  }) {
    return PreventiveMaintenanceModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      placeName: placeName ?? this.placeName,
      subPlace: subPlace ?? this.subPlace,
      isRemote: isRemote ?? this.isRemote,
      username: username ?? this.username,
      action: action ?? this.action,
    );
  }
}
