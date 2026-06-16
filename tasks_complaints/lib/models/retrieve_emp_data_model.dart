class RetrieveEmpDataModel {
  final int? id;
  final int? empId;
  final String empName;
  final String? empType;
  final String empJob;
  final String? empDegree;
  final String empLocation;
  final String? empDept;
  final String? empAdmin;
  final String? empSector;

  RetrieveEmpDataModel({
    this.id,
    this.empId,
    required this.empName,
    this.empType,
    required this.empJob,
    this.empDegree,
    required this.empLocation,
    this.empDept,
    this.empAdmin,
    this.empSector,
  });

  factory RetrieveEmpDataModel.fromJson(Map<String, dynamic> json) {
    return RetrieveEmpDataModel(
      id: json['id'],
      empId: json['empId'],
      empName: json['empName'] ?? '',
      empType: json['empType'],
      empJob: json['empJob'] ?? '',
      empDegree: json['empDegree'],
      empLocation: json['empLocation'] ?? '',
      empDept: json['empDept'],
      empAdmin: json['empAdmin'],
      empSector: json['empSector'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'empName': empName,
      'empType': empType,
      'empJob': empJob,
      'empDegree': empDegree,
      'empLocation': empLocation,
      'empDept': empDept,
      'empAdmin': empAdmin,
      'empSector': empSector,
    };
  }

  RetrieveEmpDataModel copyWith({
    int? id,
    int? empId,
    String? empName,
    String? empType,
    String? empJob,
    String? empDegree,
    String? empLocation,
    String? empDept,
    String? empAdmin,
    String? empSector,
  }) {
    return RetrieveEmpDataModel(
      id: id ?? this.id,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      empType: empType ?? this.empType,
      empJob: empJob ?? this.empJob,
      empDegree: empDegree ?? this.empDegree,
      empLocation: empLocation ?? this.empLocation,
      empDept: empDept ?? this.empDept,
      empAdmin: empAdmin ?? this.empAdmin,
      empSector: empSector ?? this.empSector,
    );
  }
}
