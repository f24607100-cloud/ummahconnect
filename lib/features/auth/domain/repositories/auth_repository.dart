import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signUp(
    String email, 
    String password, 
    String name, 
    String country, 
    String city
  );
  
  Future<UserModel?> login(String email, String password, bool rememberMe);
  
  Future<UserModel?> loginWithGoogle();
  
  Future<void> forgotPassword(String email);
  
  Future<void> logout();
  
  UserModel? getCurrentUser();
  
  Stream<UserModel?> get authStateChanges;
  
  Future<void> updateUserProfile(UserModel user);
}
