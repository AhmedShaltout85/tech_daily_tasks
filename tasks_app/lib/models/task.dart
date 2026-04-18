import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String taskTitle;
  final bool taskStatus;
  final String applicationName;
  final String visitPlace;
  final String assignedTo;
  final String assignedBy;
  final List<dynamic> coOperator;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime expectedCompletionDate;
  final String taskPriority;
  final String? taskNote;

  Task({
    required this.applicationName,
    required this.assignedBy,
    required this.coOperator,
    required this.expectedCompletionDate,
    required this.taskPriority,
    required this.visitPlace,
    required this.id,
    required this.taskTitle,
    required this.taskStatus,
    required this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.taskNote,
  });

  // Convert Firestore document to Task
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      taskTitle: data['taskTitle'] as String? ?? '',
      taskStatus: data['taskStatus'] as bool? ?? true,
      assignedTo: data['assignedTo'] as String? ?? '',
      taskNote: data['taskNote'] as String?,
      visitPlace: data['visitPlace'] as String? ?? '',
      applicationName: data['applicationName'] as String? ?? '',
      assignedBy: data['assignedBy'] as String? ?? '',
      coOperator: List<dynamic>.from(data['coOperator'] as List<dynamic>),
      expectedCompletionDate:
          (data['expectedCompletionDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      taskPriority: data['taskPriority'] as String? ?? '',
      // Convert Timestamp to DateTime
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // CopyWith method for updating
  Task copyWith({
    String? id,
    String? taskTitle,
    bool? taskStatus,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? visitPlace,
    String? notes,
    String? applicationName,
    String? assignedBy,
    String? coOperator,
    DateTime? expectedCompletionDate,
    String? taskPriority,
  }) {
    return Task(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskStatus: taskStatus ?? this.taskStatus,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskNote: taskNote,
      visitPlace: visitPlace ?? this.visitPlace,
      applicationName: applicationName ?? this.applicationName,
      assignedBy: assignedBy ?? this.assignedBy,
      coOperator: coOperator != null ? [coOperator] : this.coOperator,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      taskPriority: taskPriority ?? this.taskPriority,
    );
  }
}
