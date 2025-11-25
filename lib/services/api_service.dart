import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pasien.dart';
import '../models/kunjungan.dart';
import '../models/jadwal_dokter.dart';
import '../models/antrian.dart';
import '../models/master_poli.dart';
import '../models/master_penjamin.dart';
import '../models/transaksi.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Login dengan NO RM (cek apakah pasien ada)
  Future<Pasien?> loginWithNoRM(String noRm) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.pasienEndpoint}/search/$noRm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cek apakah berhasil dan ada data
        if (data['success'] == true && data['data'] != null) {
          return Pasien.fromJson(data['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        // Pasien tidak ditemukan
        return null;
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

      debugPrint('=== API Response Debug ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw Response Body:');
      debugPrint(response.body);
      debugPrint('========================');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          List<Kunjungan> kunjunganList = [];
          for (var item in data['data']) {
            debugPrint('Processing item: $item');
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

  // Get jadwal dokter
  Future<List<JadwalDokter>> getJadwalDokter({String? poli, String? hari}) async {
    try {
      String url = '${ApiConfig.baseUrl}/jadwal-dokter?';
      if (poli != null) url += 'poli=$poli&';
      if (hari != null) url += 'hari=$hari';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<JadwalDokter> jadwalList = [];
          for (var item in data['data']) {
            jadwalList.add(JadwalDokter.fromJson(item));
          }
          return jadwalList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil jadwal dokter');
      }
    } catch (e) {
      debugPrint('Error get jadwal dokter: $e');
      rethrow;
    }
  }

  // Get master poli
  Future<List<MasterPoli>> getMasterPoli() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/master-poli'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<MasterPoli> poliList = [];
          for (var item in data['data']) {
            poliList.add(MasterPoli.fromJson(item));
          }
          return poliList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data poli');
      }
    } catch (e) {
      debugPrint('Error get master poli: $e');
      rethrow;
    }
  }

  // Get master penjamin
  Future<List<MasterPenjamin>> getMasterPenjamin() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/master-penjamin'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<MasterPenjamin> penjaminList = [];
          for (var item in data['data']) {
            penjaminList.add(MasterPenjamin.fromJson(item));
          }
          return penjaminList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data penjamin');
      }
    } catch (e) {
      debugPrint('Error get master penjamin: $e');
      rethrow;
    }
  }

  // Create antrian
  Future<Antrian?> createAntrian(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/antrian'),
        headers: ApiConfig.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Antrian.fromJson(responseData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat antrian');
      }
    } catch (e) {
      debugPrint('Error create antrian: $e');
      rethrow;
    }
  }

  // Get antrian by no_rm
  Future<List<Antrian>> getAntrianByNoRM(String noRm) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/antrian?no_rm=$noRm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<Antrian> antrianList = [];
          for (var item in data['data']) {
            antrianList.add(Antrian.fromJson(item));
          }
          return antrianList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data antrian');
      }
    } catch (e) {
      debugPrint('Error get antrian: $e');
      rethrow;
    }
  }

  // Get transaksi by no_rm
  Future<List<Transaksi>> getTransaksiByNoRM(String noRm) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transaksi?no_rm=$noRm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<Transaksi> transaksiList = [];
          for (var item in data['data']) {
            transaksiList.add(Transaksi.fromJson(item));
          }
          return transaksiList;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil data transaksi');
      }
    } catch (e) {
      debugPrint('Error get transaksi: $e');
      rethrow;
    }
  }

  // Delete/Cancel antrian
  Future<bool> deleteAntrian(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/antrian/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membatalkan antrian');
      }
    } catch (e) {
      debugPrint('Error delete antrian: $e');
      rethrow;
    }
  }
}

