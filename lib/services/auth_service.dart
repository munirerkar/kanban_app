import 'package:dio/dio.dart';
import 'package:kanban_project/core/network/api_client.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/services/token_storage.dart';

class AuthService {
  AuthService({TokenStorage? tokenStorage}) : _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio _dio = ApiClient().dio;
  final TokenStorage _tokenStorage;

  Future<User> login({
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

      final backendUser = _extractBackendUser(data);
      final user = backendUser ?? await _fetchCurrentUserFromApi();
      await _tokenStorage.saveUser(_toPersistedUserJson(user));
      return user;
    } on DioException catch (e) {
      throw AuthException(
        message: _resolveDioMessage(e, fallback401403: 'E-posta veya şifre hatalı.'),
        statusCode: e.response?.statusCode,
      );
    } on AuthException {
      rethrow;
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

  Future<User?> tryRestoreSession() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await _fetchCurrentUserFromApi();
      await _tokenStorage.saveUser(_toPersistedUserJson(user));
      return user;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        await _tokenStorage.clearAuthSession();
        return null;
      }

      if (statusCode == 404) {
        return getStoredUser();
      }

      rethrow;
    }
  }

  Future<bool> hasToken() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<User?> getStoredUser() async {
    final cached = await _tokenStorage.getUser();
    if (cached == null) {
      return null;
    }

    return User.fromJson(cached);
  }

  Future<User> refreshCurrentUser() async {
    final user = await _fetchCurrentUserFromApi();
    await _tokenStorage.saveUser(_toPersistedUserJson(user));
    return user;
  }

  Future<void> logout() async {
    await _tokenStorage.clearAuthSession();
  }

  Future<User> _fetchCurrentUserFromApi() async {
    const endpoints = ['/auth/me', '/users/me'];

    DioException? lastDioException;
    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(endpoint);
        final json = _extractUserMap(response.data);
        if (json != null) {
          return User.fromJson(json);
        }
      } on DioException catch (e) {
        lastDioException = e;
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          continue;
        }
        rethrow;
      }
    }

    if (lastDioException != null) {
      throw lastDioException;
    }

    throw const AuthException(message: 'Kullanıcı bilgisi alınamadı.');
  }

  User? _extractBackendUser(Map<String, dynamic> data) {
    final userRaw = data['user'];
    if (userRaw is Map<String, dynamic>) {
      return User.fromJson(userRaw);
    }
    return null;
  }

  Map<String, dynamic>? _extractUserMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['id'] != null) {
        return responseData;
      }

      final nested = responseData['data'];
      if (nested is Map<String, dynamic> && nested['id'] != null) {
        return nested;
      }
    }

    return null;
  }

  Map<String, dynamic> _toPersistedUserJson(User user) {
    final nameParts = user.name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return {
      'id': user.id,
      'name': user.name,
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email,
      'profilePictureUrl': user.profilePictureUrl,
    };
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
