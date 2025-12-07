import '../../core/services/firebase_auth_service.dart';
import '../../core/services/user_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService authService = FirebaseAuthService();
  final UserService userService = UserService();

  Future<bool> login(String email, String password) async {
    final user = await authService.signIn(email, password);
    return user != null;
  }

  Future<bool> register(String email, String password) async {
    final user = await authService.register(email, password);
    if (user != null) {
      await userService.createUser(
        UserModel(uid: user.uid, email: user.email!),
      );
      return true;
    }
    return false;
  }
}
