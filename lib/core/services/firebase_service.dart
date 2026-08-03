import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  Future<void> init() async {
    try {
      // In a real environment, you need google-services.json (Android) and GoogleService-Info.plist (iOS)
      // If they are missing, Firebase.initializeApp() throws a FirebaseException.
      await Firebase.initializeApp();
      _isFirebaseAvailable = true;
      debugPrint('Firebase successfully initialized.');
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase not initialized (running in Offline/Mock mode): $e');
    }
  }
}
