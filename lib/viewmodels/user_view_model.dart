import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      print("User pull error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}