/// Shared domain vocabulary used across forms, filters and matching.
abstract final class OpportunityCategories {
  static const all = [
    'Engineering',
    'Design',
    'Marketing',
    'Data',
    'Operations',
    'Research',
    'Content',
    'Community',
    'Business',
  ];
}

abstract final class WorkTypes {
  static const all = [
    'Part-time',
    'Full-time',
    'Project-based',
    'Volunteer',
  ];
}

abstract final class Locations {
  static const all = [
    'On-campus',
    'Remote',
    'Hybrid',
    'Kigali',
  ];
}

/// Suggested skills shown during student onboarding and opportunity posting.
/// Users can also type their own; these just reduce friction and keep the
/// vocabulary consistent enough for skill matching to work.
abstract final class SuggestedSkills {
  static const all = [
    'Flutter',
    'Dart',
    'Firebase',
    'Python',
    'JavaScript',
    'UI Design',
    'UX Research',
    'Figma',
    'Graphic Design',
    'Copywriting',
    'Social Media',
    'SEO',
    'Data Analysis',
    'Excel',
    'Market Research',
    'Business Analysis',
    'Project Management',
    'Video Editing',
    'Photography',
    'Public Speaking',
    'Community Management',
    'Sales',
  ];
}
