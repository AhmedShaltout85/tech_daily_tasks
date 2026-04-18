import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String displayName;
  final String email;
  final String? password;
  final DateTime createdAt;

  UserModel({
    this.firstName,
    this.lastName,
    this.password,
    required this.id,
    required this.displayName,
    required this.email,
    required this.createdAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'email': email,
      'password': password,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime createdAtDateTime;

    // Handle Timestamp from Firestore
    if (map['createdAt'] is Timestamp) {
      createdAtDateTime = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAtDateTime = DateTime.parse(map['createdAt']);
    } else {
      createdAtDateTime = DateTime.now();
    }

    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '123456',
      createdAt: createdAtDateTime,
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
