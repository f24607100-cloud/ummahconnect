import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();
  
  // For offline mock auth stream
  final _mockUserStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  AuthRepositoryImpl() {
    // Determine initial user
    _initCurrentUser();
  }

  void _initCurrentUser() {
    if (_firebaseService.isFirebaseAvailable) {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        // Fetch from firestore is async, so we seed with basic info first
        _currentUser = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? 'Ummah Member',
          country: 'Saudi Arabia',
          city: 'Makkah',
          photoUrl: fbUser.photoURL,
        );
      }
    } else {
      final isLoggedIn = _hiveService.getValue<bool>(HiveService.settingsBox, 'is_logged_in', defaultValue: false);
      if (isLoggedIn!) {
        final cachedData = _hiveService.getValue<Map>(HiveService.settingsBox, 'current_user');
        if (cachedData != null) {
          _currentUser = UserModel.fromMap(cachedData);
        } else {
          // Fallback basic user
          _currentUser = UserModel(
            uid: 'mock_uid_123',
            email: 'user@ummahconnect.com',
            name: 'Ahmad Abdullah',
            country: 'Saudi Arabia',
            city: 'Makkah',
          );
        }
      }
    }
    _mockUserStreamController.add(_currentUser);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (_firebaseService.isFirebaseAvailable) {
      return fb.FirebaseAuth.instance.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) {
          _currentUser = null;
          return null;
        }
        
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = UserModel.fromMap(doc.data()!);
          } else {
            _currentUser = UserModel(
              uid: fbUser.uid,
              email: fbUser.email ?? '',
              name: fbUser.displayName ?? 'Ummah Member',
              country: 'Saudi Arabia',
              city: 'Makkah',
              photoUrl: fbUser.photoURL,
            );
          }
        } catch (e) {
          _currentUser = UserModel(
            uid: fbUser.uid,
            email: fbUser.email ?? '',
            name: fbUser.displayName ?? 'Ummah Member',
            country: 'Saudi Arabia',
            city: 'Makkah',
            photoUrl: fbUser.photoURL,
          );
        }
        return _currentUser;
      });
    } else {
      return _mockUserStreamController.stream;
    }
  }

  @override
  UserModel? getCurrentUser() => _currentUser;

  @override
  Future<UserModel?> login(String email, String password, bool rememberMe) async {
    if (_firebaseService.isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user == null) return null;
        
        final doc = await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).get();
        UserModel user;
        if (doc.exists && doc.data() != null) {
          user = UserModel.fromMap(doc.data()!);
        } else {
          user = UserModel(
            uid: credential.user!.uid,
            email: credential.user!.email ?? '',
            name: credential.user!.displayName ?? 'Ummah Member',
            country: 'Saudi Arabia',
            city: 'Makkah',
          );
        }
        
        _currentUser = user;
        if (rememberMe) {
          await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', true);
          await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
        }
        return user;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline simulation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final usersMap = _hiveService.getValue<Map>(HiveService.settingsBox, 'mock_users', defaultValue: {})!;
      
      if (!usersMap.containsKey(email.trim())) {
        // Register mock email if it doesn't exist, to make testing easy!
        final mockUser = UserModel(
          uid: 'mock_uid_${email.hashCode}',
          email: email.trim(),
          name: email.split('@').first,
          country: 'Saudi Arabia',
          city: 'Makkah',
        );
        usersMap[email.trim()] = {
          'user': mockUser.toMap(),
          'password': password,
        };
        await _hiveService.setValue<Map>(HiveService.settingsBox, 'mock_users', usersMap);
      }
      
      final userData = usersMap[email.trim()] as Map;
      if (userData['password'] != password) {
        throw Exception('Invalid password for this account.');
      }
      
      final user = UserModel.fromMap(userData['user']);
      _currentUser = user;
      
      await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', true);
      await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
      _mockUserStreamController.add(user);
      return user;
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name, String country, String city) async {
    if (_firebaseService.isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user == null) return null;
        
        final user = UserModel(
          uid: credential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          country: country.trim(),
          city: city.trim(),
        );
        
        await credential.user!.updateDisplayName(name.trim());
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap());
        
        _currentUser = user;
        await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', true);
        await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
        return user;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline simulation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final usersMap = _hiveService.getValue<Map>(HiveService.settingsBox, 'mock_users', defaultValue: {})!;
      if (usersMap.containsKey(email.trim())) {
        throw Exception('Email already in use.');
      }
      
      final user = UserModel(
        uid: 'mock_uid_${email.hashCode}',
        email: email.trim(),
        name: name.trim(),
        country: country.trim(),
        city: city.trim(),
      );
      
      usersMap[email.trim()] = {
        'user': user.toMap(),
        'password': password,
      };
      await _hiveService.setValue<Map>(HiveService.settingsBox, 'mock_users', usersMap);
      
      _currentUser = user;
      await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', true);
      await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
      _mockUserStreamController.add(user);
      return user;
    }
  }

  @override
  Future<UserModel?> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Create mock user
    final user = UserModel(
      uid: 'google_user_999',
      email: 'prophet_follower@gmail.com',
      name: 'Abdur Rahman',
      country: 'Saudi Arabia',
      city: 'Medina',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde', // clean male avatar mockup
    );
    
    _currentUser = user;
    await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', true);
    await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
    _mockUserStreamController.add(user);
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (_firebaseService.isFirebaseAvailable) {
      await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
      final usersMap = _hiveService.getValue<Map>(HiveService.settingsBox, 'mock_users', defaultValue: {})!;
      if (!usersMap.containsKey(email.trim())) {
        throw Exception('User email not registered.');
      }
    }
  }

  @override
  Future<void> logout() async {
    if (_firebaseService.isFirebaseAvailable) {
      await fb.FirebaseAuth.instance.signOut();
    }
    
    _currentUser = null;
    await _hiveService.setValue<bool>(HiveService.settingsBox, 'is_logged_in', false);
    await _hiveService.deleteValue(HiveService.settingsBox, 'current_user');
    _mockUserStreamController.add(null);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    _currentUser = user;
    await _hiveService.setValue<Map>(HiveService.settingsBox, 'current_user', user.toMap());
    
    if (_firebaseService.isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(user.toMap());
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        await fbUser.updateDisplayName(user.name);
      }
    } else {
      final usersMap = _hiveService.getValue<Map>(HiveService.settingsBox, 'mock_users', defaultValue: {})!;
      if (usersMap.containsKey(user.email)) {
        usersMap[user.email]['user'] = user.toMap();
        await _hiveService.setValue<Map>(HiveService.settingsBox, 'mock_users', usersMap);
      }
      _mockUserStreamController.add(user);
    }
  }
}
