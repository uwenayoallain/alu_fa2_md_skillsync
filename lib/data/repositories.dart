import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../models/startup.dart';

/// Repository layer: the only place in the app that talks to Firebase.
///
/// Screens never import Firestore directly — they watch Riverpod providers,
/// which in turn call these repositories. That separation keeps widgets
/// testable and means the backend could be swapped without touching UI code.

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();
}

class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Stream<AppUser?> watchUser(String uid) => _col
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  Future<AppUser?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Future<void> createUser(AppUser user) => _col.doc(user.uid).set(user.toMap());

  Future<void> updateProfile(String uid,
          {required String name,
          required String bio,
          required List<String> skills}) =>
      _col.doc(uid).update({'name': name, 'bio': bio, 'skills': skills});

  Future<void> toggleBookmark(String uid, String opportunityId,
          {required bool saved}) =>
      _col.doc(uid).update({
        'savedOpportunityIds': saved
            ? FieldValue.arrayRemove([opportunityId])
            : FieldValue.arrayUnion([opportunityId]),
      });
}

class StartupRepository {
  StartupRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('startups');

  Stream<Startup?> watchByOwner(String ownerId) => _col
      .where('ownerId', isEqualTo: ownerId)
      .limit(1)
      .snapshots()
      .map((snap) =>
          snap.docs.isEmpty ? null : Startup.fromDoc(snap.docs.first));

  Stream<Startup?> watchById(String id) => _col
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Startup.fromDoc(doc) : null);

  Future<void> create(Startup startup) => _col.add(startup.toMap());

  Future<void> update(Startup startup) => _col.doc(startup.id).update({
        'name': startup.name,
        'category': startup.category,
        'description': startup.description,
        'mission': startup.mission,
      });
}

class OpportunityRepository {
  OpportunityRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('opportunities');

  /// All open opportunities, newest first. Search/filtering happens
  /// client-side in a provider so typing gives instant feedback without a
  /// Firestore round-trip per keystroke.
  Stream<List<Opportunity>> watchOpen() => _col
      .where('open', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Opportunity.fromDoc).toList());

  Stream<List<Opportunity>> watchByStartup(String startupId) => _col
      .where('startupId', isEqualTo: startupId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Opportunity.fromDoc).toList());

  Stream<Opportunity?> watchById(String id) => _col
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Opportunity.fromDoc(doc) : null);

  Future<void> create(Opportunity opp) => _col.add(opp.toMap());

  Future<void> update(String id, Map<String, dynamic> fields) =>
      _col.doc(id).update(fields);

  Future<void> delete(String id) => _col.doc(id).delete();
}

class ApplicationRepository {
  ApplicationRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('applications');

  Stream<List<Application>> watchByStudent(String studentId) => _col
      .where('studentId', isEqualTo: studentId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Application.fromDoc).toList());

  Stream<List<Application>> watchByStartup(String startupId) => _col
      .where('startupId', isEqualTo: startupId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Application.fromDoc).toList());

  Future<void> submit(Application application) => _col.add(application.toMap());

  Future<void> updateStatus(String id, ApplicationStatus status) =>
      _col.doc(id).update({'status': status.name});

  Future<void> withdraw(String id) => _col.doc(id).delete();
}
