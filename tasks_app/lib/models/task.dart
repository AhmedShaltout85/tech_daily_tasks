class Task {
  //Properties
  final String? id;
  final String taskTitle;
  final bool taskStatus;
  final String appName;
  final String visitPlace;
  final String subPlace;
  final String assignedTo;
  final String assignedBy;
  final List<dynamic> coOperator;
  final DateTime expectedCompletionDate;
  final String taskPriority;
  final String? taskNote;
  final bool? isRemote;
  final DateTime createdAt;

  //Constructor
  Task({
    this.id,
    required this.taskTitle,
    required this.taskStatus,
    required this.appName,
    required this.visitPlace,
    required this.subPlace,
    required this.assignedTo,
    required this.assignedBy,
    required this.coOperator,
    required this.expectedCompletionDate,
    required this.taskPriority,
    this.taskNote,
    this.isRemote,
    required this.createdAt,
  });

  //fromJson
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskTitle: json['taskTitle'],
      taskStatus: json['taskStatus'],
      appName: json['appName'],
      visitPlace: json['visitPlace'],
      subPlace: json['subPlace'],
      assignedTo: json['assignedTo'],
      assignedBy: json['assignedBy'],
      coOperator: json['coOperator'],
      expectedCompletionDate: json['expectedCompletionDate'].toDate(),
      taskPriority: json['taskPriority'],
      taskNote: json['taskNote'],
      isRemote: json['isRemote'],
      createdAt: json['createdAt'].toDate(),
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTitle': taskTitle,
      'taskStatus': taskStatus,
      'appName': appName,
      'visitPlace': visitPlace,
      'subPlace': subPlace,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'coOperator': coOperator,
      'expectedCompletionDate': expectedCompletionDate,
      'taskPriority': taskPriority,
      'taskNote': taskNote,
      'isRemote': isRemote,
      'createdAt': createdAt
    };
  }

  //copyWith
  Task copyWith({
    String? id,
    String? taskTitle,
    bool? taskStatus,
    String? appName,
    String? visitPlace,
    String? subPlace,
    String? assignedTo,
    String? assignedBy,
    List<dynamic>? coOperator,
    DateTime? expectedCompletionDate,
    String? taskPriority,
    String? taskNote,
    bool? isRemote,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskStatus: taskStatus ?? this.taskStatus,
      appName: appName ?? this.appName,
      visitPlace: visitPlace ?? this.visitPlace,
      subPlace: subPlace ?? this.subPlace,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      coOperator: coOperator ?? this.coOperator,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      taskPriority: taskPriority ?? this.taskPriority,
      taskNote: taskNote ?? this.taskNote,
      isRemote: isRemote ?? this.isRemote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
