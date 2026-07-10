import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  founder;

  static UserRole fromName(String? name) =>
      UserRole.values.firstWhere((r) => r.name == name,
          orElse: () => UserRole.student);
}

/// Profile document stored at `users/{uid}`.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.bio = '',
    this.skills = const [],
    this.savedOpportunityIds = const [],
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String bio;
  final List<String> skills;
  final List<String> savedOpportunityIds;
  final DateTime? createdAt;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      email: d['email'] as String? ?? '',
      role: UserRole.fromName(d['role'] as String?),
      bio: d['bio'] as String? ?? '',
      skills: List<String>.from(d['skills'] as List? ?? []),
      savedOpportunityIds:
          List<String>.from(d['savedOpportunityIds'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'bio': bio,
        'skills': skills,
        'savedOpportunityIds': savedOpportunityIds,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
