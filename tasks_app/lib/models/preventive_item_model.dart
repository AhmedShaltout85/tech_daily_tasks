class PreventiveItemModel {
  final int? id;
  final String appName;
  final String action;
//Constructor
  PreventiveItemModel({
    this.id,
    required this.appName,
    required this.action,
  });
//fromJson
  factory PreventiveItemModel.fromJson(Map<String, dynamic> json) {
    return PreventiveItemModel(
      id: json['id'] as int?,
      appName: json['appName'],
      action: json['action'],
    );
  }

//toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'action': action,
    };
  }

//copyWith
  PreventiveItemModel copyWith({
    int? id,
    String? appName,
    String? action,
  }) {
    return PreventiveItemModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      action: action ?? this.action,
    );
  }
}