import 'package:flutter/foundation.dart';


abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;


  @protected
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @protected
  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  @protected
  void clearError() => setError(null);


  @protected
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}