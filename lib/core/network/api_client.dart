import 'package:dio/dio.dart';
import 'package:kanban_project/core/app_constants.dart';
import 'package:kanban_project/core/network/auth_interceptor.dart';
import 'package:kanban_project/services/token_storage.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(AuthInterceptor(TokenStorage()));
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio _dio;

  Dio get dio => _dio;
}
