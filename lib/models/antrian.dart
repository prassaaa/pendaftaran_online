class Antrian {
  final int id;
  final String noAntrian;
  final String noRm;
  final int jadwalDokterId;
  final String tanggalKunjungan;
  final int penjaminId;
  final String status;
  final Map<String, dynamic>? pasien;
  final Map<String, dynamic>? jadwalDokter;
  final Map<String, dynamic>? penjamin;

  Antrian({
    required this.id,
    required this.noAntrian,
    required this.noRm,
    required this.jadwalDokterId,
    required this.tanggalKunjungan,
    required this.penjaminId,
    required this.status,
    this.pasien,
    this.jadwalDokter,
    this.penjamin,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) {
    return Antrian(
      id: json['id'] ?? 0,
      noAntrian: json['no_antrian'] ?? '',
      noRm: json['no_rm'] ?? '',
      jadwalDokterId: json['jadwal_dokter_id'] ?? 0,
      tanggalKunjungan: json['tanggal_kunjungan'] ?? '',
      penjaminId: json['penjamin_id'] ?? 0,
      status: json['status'] ?? '',
      pasien: json['pasien'],
      jadwalDokter: json['jadwal_dokter'],
      penjamin: json['penjamin'],
    );
  }

  String get namaPasien {
    return pasien?['nama_pasien'] ?? 'Tidak diketahui';
  }

  String get namaDokter {
    return jadwalDokter?['dokter']?['nama_dokter'] ?? 'Tidak diketahui';
  }

  String get namaPoli {
    return jadwalDokter?['poli']?['nama_poli'] ?? 'Tidak diketahui';
  }

  String get jamPraktek {
    final jamMulai = jadwalDokter?['jam_mulai'] ?? '';
    final jamSelesai = jadwalDokter?['jam_selesai'] ?? '';
    return '$jamMulai - $jamSelesai';
  }

  String get namaPenjamin {
    return penjamin?['nama_penjamin'] ?? 'Tidak diketahui';
  }
}

