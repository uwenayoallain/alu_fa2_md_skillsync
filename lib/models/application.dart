import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

enum ApplicationStatus {
  submitted('Submitted'),
  underReview('Under review'),
  shortlisted('Shortlisted'),
  accepted('Accepted'),
  rejected('Not selected');

  const ApplicationStatus(this.label);
  final String label;

  static ApplicationStatus fromName(String? name) => ApplicationStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => ApplicationStatus.submitted,
  );

  Color get color => switch (this) {
    submitted => AppColors.info,
    underReview => AppColors.warning,
    shortlisted => AppColors.primaryDark,
    accepted => AppColors.success,
    rejected => AppColors.danger,
  };

  Color get softColor => switch (this) {
    submitted => AppColors.infoSoft,
    underReview => AppColors.warningSoft,
    shortlisted => AppColors.primarySoft,
    accepted => AppColors.successSoft,
    rejected => AppColors.dangerSoft,
  };
}

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.message,
    this.status = ApplicationStatus.submitted,
    this.createdAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String message;
  final ApplicationStatus status;
  final DateTime? createdAt;

  factory Application.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Application(
      id: doc.id,
      opportunityId: d['opportunityId'] as String? ?? '',
      opportunityTitle: d['opportunityTitle'] as String? ?? '',
      startupId: d['startupId'] as String? ?? '',
      startupName: d['startupName'] as String? ?? '',
      studentId: d['studentId'] as String? ?? '',
      studentName: d['studentName'] as String? ?? '',
      message: d['message'] as String? ?? '',
      status: ApplicationStatus.fromName(d['status'] as String?),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'opportunityId': opportunityId,
    'opportunityTitle': opportunityTitle,
    'startupId': startupId,
    'startupName': startupName,
    'studentId': studentId,
    'studentName': studentName,
    'message': message,
    'status': status.name,
    'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
  };
}
