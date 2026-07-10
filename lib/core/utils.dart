import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Form validators shared by every text field in the app.
abstract final class Validators {
  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? minLength(String? v, int min, String field) {
    final err = required(v, field);
    if (err != null) return err;
    if (v!.trim().length < min) return '$field must be at least $min characters';
    return null;
  }
}

/// "Posted 2d ago" style timestamps for cards and lists.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return DateFormat('d MMM yyyy').format(date);
}

/// Maps a common set of FirebaseAuth error codes to friendly messages so
/// screens never surface raw exception text to users.
String friendlyAuthError(Object error) {
  final text = error.toString();
  if (text.contains('invalid-credential') ||
      text.contains('wrong-password') ||
      text.contains('user-not-found')) {
    return 'Incorrect email or password.';
  }
  if (text.contains('email-already-in-use')) {
    return 'An account already exists with this email.';
  }
  if (text.contains('weak-password')) {
    return 'That password is too weak — use at least 6 characters.';
  }
  if (text.contains('network-request-failed')) {
    return 'Network error. Check your connection and try again.';
  }
  if (text.contains('too-many-requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  return 'Something went wrong. Please try again.';
}

void showAppSnackBar(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? const Color(0xFFD03E5E) : null,
    ));
}
