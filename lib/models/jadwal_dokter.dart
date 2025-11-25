class JadwalDokter {
  final int id;
  final String kodeDokter;
  final String kodePoli;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final int kuota;
  final String status;
  final Map<String, dynamic>? dokter;
  final Map<String, dynamic>? poli;

  JadwalDokter({
    required this.id,
    required this.kodeDokter,
    required this.kodePoli,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
    required this.status,
    this.dokter,
    this.poli,
  });

  factory JadwalDokter.fromJson(Map<String, dynamic> json) {
    return JadwalDokter(
      id: json['id'] ?? 0,
      kodeDokter: json['kode_dokter'] ?? '',
      kodePoli: json['kode_poli'] ?? '',
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      kuota: json['kuota'] ?? 0,
      status: json['status'] ?? '',
      dokter: json['dokter'],
      poli: json['poli'],
    );
  }

  String get namaDokter {
    return dokter?['nama_dokter'] ?? 'Tidak diketahui';
  }

  String get namaPoli {
    return poli?['nama_poli'] ?? 'Tidak diketahui';
  }

  String get jamPraktek {
    return '$jamMulai - $jamSelesai';
  }
}

