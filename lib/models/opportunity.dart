import 'package:cloud_firestore/cloud_firestore.dart';

/// An internship / contribution opportunity stored at `opportunities/{id}`.
///
/// The posting startup's name and verification flag are denormalised onto the
/// document so list screens render from a single query instead of N+1 reads.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.workType,
    required this.location,
    this.skills = const [],
    this.hoursPerWeek = '',
    this.open = true,
    this.createdAt,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final String workType;
  final String location;
  final List<String> skills;
  final String hoursPerWeek;
  final bool open;
  final DateTime? createdAt;

  factory Opportunity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Opportunity(
      id: doc.id,
      startupId: d['startupId'] as String? ?? '',
      startupName: d['startupName'] as String? ?? '',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? '',
      workType: d['workType'] as String? ?? '',
      location: d['location'] as String? ?? '',
      skills: List<String>.from(d['skills'] as List? ?? []),
      hoursPerWeek: d['hoursPerWeek'] as String? ?? '',
      open: d['open'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'startupName': startupName,
        'title': title,
        'description': description,
        'category': category,
        'workType': workType,
        'location': location,
        'skills': skills,
        'hoursPerWeek': hoursPerWeek,
        'open': open,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };

  /// How many of the student's skills this opportunity asks for.
  /// Drives the "Recommended for you" ranking on the home screen.
  int matchScore(List<String> studentSkills) {
    final lower = studentSkills.map((s) => s.toLowerCase()).toSet();
    return skills.where((s) => lower.contains(s.toLowerCase())).length;
  }
}
