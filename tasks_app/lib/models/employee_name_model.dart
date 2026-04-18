class EmployeeNameModel {
  //field
  final String id;
  final String employeeName;

  //constructor
  EmployeeNameModel({required this.id, required this.employeeName});

  //from json
  factory EmployeeNameModel.fromJson(Map<String, dynamic> json) {
    return EmployeeNameModel(
      id: json['id'] as String,
      employeeName: json['employee_name'] as String,
    );
  }
  //to json
  Map<String, dynamic> toJson() {
    return {'id': id, 'employee_name': employeeName};
  }
}
