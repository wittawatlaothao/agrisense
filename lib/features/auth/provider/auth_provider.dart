import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final _repo = AuthRepository();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _repo.login(email, password);
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _repo.register(email, password);
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;
}
