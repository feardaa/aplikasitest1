import 'package:aplikasitest1/models/user.dart';
import 'package:aplikasitest1/services/auth_service.dart';
import 'package:aplikasitest1/controllers/base_controller.dart';

class AuthController extends BaseController {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoggedIn = false;


  AuthController(this._authService);

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String get currentUsername => _currentUser?.username ?? 'Guest';
  String get currentUserId => _currentUser?.id ?? '';

  Future<void> initialize() async {
    await executeWithLoading(() async {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromMap(userData);
        }
      }
      notifyListeners();
    });
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      setError('Username dan password harus diisi');
      return false;
    }

    return await executeWithLoading(() async {
      final success = await AuthService.login(username, password);

      if (success) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromMap(userData);
          _isLoggedIn = true;
          notifyListeners();
        }
        return true;
      } else {
        setError('Username atau password salah');
        return false;
      }
    });
  }


  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty || phone.isEmpty) {
      setError('Semua field harus diisi');
      return false;
    }

    if (password.length < 6) {
      setError('Password minimal 6 karakter');
      return false;
    }

    if (!_isValidEmail(email)) {
      setError('Format email tidak valid');
      return false;
    }

    if (!_isValidPhone(phone)) {
      setError('Format nomor telepon tidak valid');
      return false;
    }

    return await executeWithLoading(() async {
      final success = await _authService.register(username, password, email, phone);

      if (success) {
        return await login(username, password);
      } else {
        setError('Username sudah digunakan');
        return false;
      }
    });
  }

 
  Future<void> logout() async {
    await executeWithLoading(() async {
      await AuthService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    });
  }

  Future<bool> updateProfile({
    String? username,
    String? email,
    String? phone,
  }) async {
    if (_currentUser == null) {
      setError('User belum login');
      return false;
    }

    return await executeWithLoading(() async {
      final updatedUser = _currentUser!.copyWith(
        username: username,
        email: email,
        phone: phone,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    });
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) {
      setError('User belum login');
      return false;
    }

    if (newPassword.length < 6) {
      setError('Password baru minimal 6 karakter');
      return false;
    }

    return await executeWithLoading(() async {
      if (!_currentUser!.validatePassword(currentPassword)) {
        setError('Password lama salah');
        return false;
      }

    
      setError(null);
      return true;
    });
  }

 
  Future<bool> isUsernameAvailable(String username) async {
    if (username.isEmpty) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return username.length >= 3;
    } catch (e) {
      setError('Gagal mengecek username: $e');
      return false;
    }
  }


  Future<bool> resetPassword(String email) async {
    if (!_isValidEmail(email)) {
      setError('Format email tidak valid');
      return false;
    }

    return await executeWithLoading(() async {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^(\+62|62|0)[0-9]{9,13}$').hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }

  @override
  void dispose() {
    super.dispose();
  }
}