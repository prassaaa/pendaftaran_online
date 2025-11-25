class ApiConfig {
  // Base URL untuk API Laravel
  // Gunakan 10.0.2.2 untuk Android Emulator
  // Gunakan localhost atau IP komputer untuk device fisik
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Endpoints
  static const String pasienEndpoint = '$baseUrl/pasien';
  static const String kunjunganEndpoint = '$baseUrl/kunjungan';
  static const String transaksiEndpoint = '$baseUrl/transaksi';

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}

