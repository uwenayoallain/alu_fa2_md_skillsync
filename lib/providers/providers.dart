import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../models/app_user.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../models/startup.dart';

/// ---------------------------------------------------------------------------
/// Infrastructure providers
/// ---------------------------------------------------------------------------

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));
final userRepositoryProvider =
    Provider((ref) => UserRepository(ref.watch(firestoreProvider)));
final startupRepositoryProvider =
    Provider((ref) => StartupRepository(ref.watch(firestoreProvider)));
final opportunityRepositoryProvider =
    Provider((ref) => OpportunityRepository(ref.watch(firestoreProvider)));
final applicationRepositoryProvider =
    Provider((ref) => ApplicationRepository(ref.watch(firestoreProvider)));

/// ---------------------------------------------------------------------------
/// Auth + current user
/// ---------------------------------------------------------------------------

/// Raw FirebaseAuth session. Everything role- or identity-dependent hangs off
/// this stream, so login/logout automatically rebuilds the whole app shell.
final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges());

/// The signed-in user's Firestore profile (name, role, skills, bookmarks).
/// Re-emits on every profile edit or bookmark toggle.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(auth.uid);
});

/// ---------------------------------------------------------------------------
/// Opportunities: live feed + client-side search & filters
/// ---------------------------------------------------------------------------

final openOpportunitiesProvider = StreamProvider<List<Opportunity>>(
    (ref) => ref.watch(opportunityRepositoryProvider).watchOpen());

final opportunityProvider = StreamProvider.family<Opportunity?, String>(
    (ref, id) => ref.watch(opportunityRepositoryProvider).watchById(id));

/// UI state for the explore screen's search bar and filter chips.
class DiscoveryFilter {
  const DiscoveryFilter({this.query = '', this.category, this.workType});
  final String query;
  final String? category;
  final String? workType;

  DiscoveryFilter copyWith({
    String? query,
    String? Function()? category,
    String? Function()? workType,
  }) =>
      DiscoveryFilter(
        query: query ?? this.query,
        category: category != null ? category() : this.category,
        workType: workType != null ? workType() : this.workType,
      );
}

class DiscoveryFilterNotifier extends Notifier<DiscoveryFilter> {
  @override
  DiscoveryFilter build() => const DiscoveryFilter();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(String? c) => state = state.copyWith(category: () => c);
  void setWorkType(String? t) => state = state.copyWith(workType: () => t);
  void clear() => state = const DiscoveryFilter();
}

final discoveryFilterProvider =
    NotifierProvider<DiscoveryFilterNotifier, DiscoveryFilter>(
        DiscoveryFilterNotifier.new);

/// The live feed with search text and filter chips applied. Because this
/// derives from [openOpportunitiesProvider] (a Firestore snapshot stream),
/// results update in real time *and* respond instantly to typing.
final filteredOpportunitiesProvider = Provider<AsyncValue<List<Opportunity>>>(
  (ref) {
    final filter = ref.watch(discoveryFilterProvider);
    return ref.watch(openOpportunitiesProvider).whenData((opps) {
      final q = filter.query.trim().toLowerCase();
      return opps.where((o) {
        if (filter.category != null && o.category != filter.category) {
          return false;
        }
        if (filter.workType != null && o.workType != filter.workType) {
          return false;
        }
        if (q.isEmpty) return true;
        return o.title.toLowerCase().contains(q) ||
            o.startupName.toLowerCase().contains(q) ||
            o.skills.any((s) => s.toLowerCase().contains(q));
      }).toList();
    });
  },
);

/// Opportunities ranked by overlap with the student's skills — the
/// "Recommended for you" rail. Only opportunities matching at least one
/// skill qualify; ties break by recency (list is already newest-first).
final recommendedOpportunitiesProvider =
    Provider<AsyncValue<List<Opportunity>>>((ref) {
  final skills = ref.watch(currentUserProvider).value?.skills ?? [];
  return ref.watch(openOpportunitiesProvider).whenData((opps) {
    if (skills.isEmpty) return const <Opportunity>[];
    final scored = opps
        .map((o) => (opp: o, score: o.matchScore(skills)))
        .where((e) => e.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.opp).take(5).toList();
  });
});

/// ---------------------------------------------------------------------------
/// Startup side
/// ---------------------------------------------------------------------------

/// The startup owned by the signed-in founder (null while onboarding).
final myStartupProvider = StreamProvider<Startup?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return ref.watch(startupRepositoryProvider).watchByOwner(auth.uid);
});

final startupProvider = StreamProvider.family<Startup?, String>(
    (ref, id) => ref.watch(startupRepositoryProvider).watchById(id));

final startupOpportunitiesProvider =
    StreamProvider.family<List<Opportunity>, String>((ref, startupId) =>
        ref.watch(opportunityRepositoryProvider).watchByStartup(startupId));

/// ---------------------------------------------------------------------------
/// Applications
/// ---------------------------------------------------------------------------

final myApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(const []);
  return ref.watch(applicationRepositoryProvider).watchByStudent(auth.uid);
});

final startupApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, startupId) =>
        ref.watch(applicationRepositoryProvider).watchByStartup(startupId));

/// Applicant profile lookup when a founder opens an application.
final applicantProvider = StreamProvider.family<AppUser?, String>(
    (ref, uid) => ref.watch(userRepositoryProvider).watchUser(uid));
