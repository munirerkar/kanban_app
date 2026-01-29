class AppConstants {
  // Bu sınıfın başlatılmasını engellemek için private constructor
  AppConstants._();

  // BASE URL
  static const String baseUrl = 'http://192.168.1.2:8080/api';

  // ENDPOINTS
  static const String tasksEndpoint = '/tasks';
  static const String usersEndpoint = '/users';
}