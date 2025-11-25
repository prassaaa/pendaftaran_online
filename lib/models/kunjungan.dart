class Kunjungan {
  final int id;
  final String noRegistrasi;
  final String noRm;
  final String tanggalKunjungan;
  final String kodeDokter;
  final String poli;
  final String instalasi;
  final int penjaminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relasi (optional, bisa null jika tidak di-include dari API)
  final Map<String, dynamic>? pasien;
  final Map<String, dynamic>? dokter;
  final Map<String, dynamic>? masterPoli;
  final Map<String, dynamic>? penjamin;

  Kunjungan({
    required this.id,
    required this.noRegistrasi,
    required this.noRm,
    required this.tanggalKunjungan,
    required this.kodeDokter,
    required this.poli,
    required this.instalasi,
    required this.penjaminId,
    this.createdAt,
    this.updatedAt,
    this.pasien,
    this.dokter,
    this.masterPoli,
    this.penjamin,
  });

  factory Kunjungan.fromJson(Map<String, dynamic> json) {
    return Kunjungan(
      id: json['id'] ?? 0,
      noRegistrasi: json['no_registrasi'] ?? '',
      noRm: json['no_rm'] ?? '',
      tanggalKunjungan: json['tanggal_kunjungan'] ?? '',
      kodeDokter: json['kode_dokter'] ?? '',
      poli: json['poli'] ?? '',
      instalasi: json['instalasi'] ?? '',
      penjaminId: json['penjamin_id'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      pasien: json['pasien'],
      dokter: json['dokter'],
      masterPoli: json['master_poli'],
      penjamin: json['penjamin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_registrasi': noRegistrasi,
      'no_rm': noRm,
      'tanggal_kunjungan': tanggalKunjungan,
      'kode_dokter': kodeDokter,
      'poli': poli,
      'instalasi': instalasi,
      'penjamin_id': penjaminId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper untuk mendapatkan nama dokter
  String get namaDokter {
    return dokter?['nama_dokter'] ?? 'Tidak diketahui';
  }

  // Helper untuk mendapatkan nama penjamin
  String get namaPenjamin {
    return penjamin?['nama_penjamin'] ?? 'Tidak diketahui';
  }
}

