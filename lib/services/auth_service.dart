import 'package:dio/dio.dart';
import 'package:kanban_project/core/network/api_client.dart';
import 'package:kanban_project/services/token_storage.dart';

class AuthService {
  AuthService({TokenStorage? tokenStorage}) : _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio _dio = ApiClient().dio;
  final TokenStorage _tokenStorage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw const AuthException(message: 'Sunucudan geçerli oturum bilgisi alınamadı.');
      }

      await _tokenStorage.saveToken(token);
    } on DioException catch (e) {
      throw AuthException(
        message: _resolveDioMessage(e, fallback401403: 'E-posta veya şifre hatalı.'),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AuthException(message: 'Giriş işlemi sırasında beklenmeyen bir hata oluştu.');
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw AuthException(
        message: _resolveDioMessage(e, fallback401403: 'E-posta veya şifre hatalı.'),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw const AuthException(message: 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu.');
    }
  }

  Future<bool> hasToken() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  String _resolveDioMessage(DioException e, {required String fallback401403}) {
    final statusCode = e.response?.statusCode;
    final backendMessage = _extractBackendMessage(e.response?.data);

    if ((statusCode == 401 || statusCode == 403) && (backendMessage == null || backendMessage.isEmpty)) {
      return fallback401403;
    }

    if (backendMessage != null && backendMessage.isNotEmpty) {
      return backendMessage;
    }

    return e.message ?? 'Beklenmeyen bir ağ hatası oluştu.';
  }

  String? _extractBackendMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }
}

class AuthException implements Exception {
  const AuthException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
