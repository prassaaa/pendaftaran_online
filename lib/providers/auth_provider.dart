import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pasien.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  Pasien? _currentPasien;
  bool _isLoading = false;
  String? _errorMessage;

  Pasien? get currentPasien => _currentPasien;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentPasien != null;

  final ApiService _apiService = ApiService();

  // Login dengan NO RM
  Future<bool> login(String noRm) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pasien = await _apiService.loginWithNoRM(noRm);
      
      if (pasien != null) {
        _currentPasien = pasien;
        await _savePasienToLocal(pasien);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Data pasien tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentPasien = null;
    await _clearPasienFromLocal();
    notifyListeners();
  }

  // Simpan data pasien ke local storage
  Future<void> _savePasienToLocal(Pasien pasien) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pasien_data', json.encode(pasien.toJson()));
  }

  // Hapus data pasien dari local storage
  Future<void> _clearPasienFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pasien_data');
  }

  // Load data pasien dari local storage (untuk auto-login)
  Future<void> loadPasienFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pasienData = prefs.getString('pasien_data');
      
      if (pasienData != null) {
        final pasienJson = json.decode(pasienData);
        _currentPasien = Pasien.fromJson(pasienJson);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading pasien from local: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

