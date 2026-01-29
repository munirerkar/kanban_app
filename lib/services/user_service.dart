import 'package:dio/dio.dart';
import '../core/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get(AppConstants.usersEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Users could not be loaded');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}