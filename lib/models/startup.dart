import 'package:cloud_firestore/cloud_firestore.dart';

/// Startup profile stored at `startups/{id}`.
///
/// `verified` starts false and can only be flipped by an admin from the
/// Firebase console — security rules reject any client write that changes it.
/// This is how the platform guarantees only recognised ALU ventures can post.
class Startup {
  const Startup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.description,
    this.mission = '',
    this.verified = false,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String category;
  final String description;
  final String mission;
  final bool verified;
  final DateTime? createdAt;

  factory Startup.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Startup(
      id: doc.id,
      ownerId: d['ownerId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      category: d['category'] as String? ?? '',
      description: d['description'] as String? ?? '',
      mission: d['mission'] as String? ?? '',
      verified: d['verified'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'category': category,
        'description': description,
        'mission': mission,
        'verified': verified,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };
}
