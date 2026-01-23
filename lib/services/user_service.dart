import 'package:dio/dio.dart';
import '../models/user_model.dart';

class UserService {
  final String _baseUrl = 'http://10.0.2.2:8080/api/users';
  final Dio _dio = Dio();

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get(_baseUrl);

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