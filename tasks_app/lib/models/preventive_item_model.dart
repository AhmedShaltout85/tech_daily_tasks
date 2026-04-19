class PreventiveItemModel {
  final String? id;
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
      id: json['id'],
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
    String? id,
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