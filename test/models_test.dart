import 'package:fa2/core/utils.dart';
import 'package:fa2/models/opportunity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Opportunity.matchScore', () {
    const opp = Opportunity(
      id: '1',
      startupId: 's1',
      startupName: 'Learnify',
      title: 'Flutter Developer',
      description: '',
      category: 'Engineering',
      workType: 'Part-time',
      location: 'Remote',
      skills: ['Flutter', 'Dart', 'Firebase'],
    );

    test('counts overlapping skills case-insensitively', () {
      expect(opp.matchScore(['flutter', 'FIREBASE', 'Python']), 2);
    });

    test('returns 0 when nothing overlaps', () {
      expect(opp.matchScore(['Marketing']), 0);
    });

    test('returns 0 for an empty skill list', () {
      expect(opp.matchScore([]), 0);
    });
  });

  group('Validators', () {
    test('email accepts valid and rejects invalid addresses', () {
      expect(Validators.email('amina@alustudent.com'), isNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('password enforces minimum length', () {
      expect(Validators.password('secret1'), isNull);
      expect(Validators.password('abc'), isNotNull);
    });

    test('minLength trims and checks length', () {
      expect(Validators.minLength('  short  ', 30, 'Pitch'), isNotNull);
      expect(
        Validators.minLength(
            'This is a sufficiently long application pitch.', 30, 'Pitch'),
        isNull,
      );
    });
  });
}
