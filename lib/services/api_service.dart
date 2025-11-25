import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pasien.dart';
import '../models/kunjungan.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Login dengan NO RM (cek apakah pasien ada)
  Future<Pasien?> loginWithNoRM(String noRm) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.pasienEndpoint}?no_rm=$noRm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Cek apakah ada data pasien
        if (data['data'] != null && data['data'].isNotEmpty) {
          // Ambil pasien pertama yang cocok
          return Pasien.fromJson(data['data'][0]);
        }
        return null; // Pasien tidak ditemukan
      } else {
        throw Exception('Gagal mengambil data pasien');
      }
    } catch (e) {
      debugPrint('Error login: $e');
      rethrow;
    }
  }

  // Get pasien by ID
  Future<Pasien?> getPasienById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.pasienEndpoint}/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pasien.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error get pasien: $e');
      rethrow;
    }
  }

  // Get kunjungan by pasien (no_rm)
  Future<List<Kunjungan>> getKunjunganByNoRM(String noRm) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.kunjunganEndpoint}?no_rm=$noRm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          List<Kunjungan> kunjunganList = [];
          for (var item in data['data']) {
            kunjunganList.add(Kunjungan.fromJson(item));
          }
          return kunjunganList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data kunjungan');
      }
    } catch (e) {
      debugPrint('Error get kunjungan: $e');
      rethrow;
    }
  }

  // Create kunjungan baru
  Future<Kunjungan?> createKunjungan(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.kunjunganEndpoint),
        headers: ApiConfig.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Kunjungan.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal membuat kunjungan');
      }
    } catch (e) {
      debugPrint('Error create kunjungan: $e');
      rethrow;
    }
  }

  // Get all kunjungan dengan pagination
  Future<List<Kunjungan>> getAllKunjungan({int page = 1, int perPage = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.kunjunganEndpoint}?page=$page&per_page=$perPage'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          List<Kunjungan> kunjunganList = [];
          for (var item in data['data']) {
            kunjunganList.add(Kunjungan.fromJson(item));
          }
          return kunjunganList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data kunjungan');
      }
    } catch (e) {
      debugPrint('Error get all kunjungan: $e');
      rethrow;
    }
  }
}

