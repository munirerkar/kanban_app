import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/models/user_model.dart';
import 'package:kanban_project/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;
  User? get currentUser => _currentUser;

  Future<void> checkLoginStatus() async {
    if (!_isCheckingAuth) {
      _isCheckingAuth = true;
      notifyListeners();
    }

    try {
      final hasToken = await _authService.hasToken();
      if (!hasToken) {
        _isAuthenticated = false;
        _currentUser = null;
        _errorMessage = null;
        return;
      }

      // Kalıcı login için kaynak doğrulama: token + local user cache.
      // Backend'de /auth/me yoksa açılışta LoginView'a düşmeyi engeller.
      final cachedUser = await _authService.getStoredUser();
      _isAuthenticated = true;
      _currentUser = cachedUser;
      _errorMessage = null;

      // Sadece cache yoksa arka planda restore dene (best-effort).
      if (cachedUser == null) {
        final restoredUser = await _authService.tryRestoreSession();
        if (restoredUser != null) {
          _currentUser = restoredUser;
        }
      }
    } on DioException {
      final stillHasToken = await _authService.hasToken();
      _isAuthenticated = stillHasToken;
      _errorMessage = null;
    } catch (_) {
      final stillHasToken = await _authService.hasToken();
      _isAuthenticated = stillHasToken;
      _errorMessage = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    _setLoading(true);

    try {
      final user = await _authService.login(email: email, password: password);
      _isAuthenticated = true;
      _currentUser = user;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = e.message;
      return false;
    } on DioException catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = _resolveDioExceptionMessage(e, l10n: l10n);
      return false;
    } catch (_) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = l10n.authUnexpectedLoginError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    _setLoading(true);

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      final user = await _authService.login(email: email, password: password);
      _isAuthenticated = true;
      _currentUser = user;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = e.message;
      return false;
    } on DioException catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = _resolveDioExceptionMessage(e, l10n: l10n);
      return false;
    } catch (_) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = l10n.authUnexpectedRegisterError;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      _currentUser = await _authService.refreshCurrentUser();
      notifyListeners();
    } catch (_) {
      // Mevcut ekranı kırmamak için sessiz geçilir.
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } on DioException catch (e) {
      _errorMessage = _resolveDioExceptionMessage(e);
    } catch (_) {
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  String _resolveDioExceptionMessage(DioException e, {AppLocalizations? l10n}) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      return l10n?.authInvalidCredentials ?? '';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? l10n?.authNetworkErrorFallback ?? '';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
