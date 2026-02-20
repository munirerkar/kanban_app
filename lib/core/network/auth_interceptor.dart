import 'package:dio/dio.dart';
import 'package:kanban_project/services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  static const Set<String> _authExemptPaths = {
    '/auth/login',
    '/auth/register',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthExempt(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  bool _isAuthExempt(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return _authExemptPaths.contains(normalized);
  }
}
