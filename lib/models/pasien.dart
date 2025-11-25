class Pasien {
  final int id;
  final String noRm;
  final String namaPasien;
  final String tanggalLahir;
  final String jenisKelamin;
  final String alamat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pasien({
    required this.id,
    required this.noRm,
    required this.namaPasien,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alamat,
    this.createdAt,
    this.updatedAt,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'] ?? 0,
      noRm: json['no_rm'] ?? '',
      namaPasien: json['nama_pasien'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      alamat: json['alamat'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_rm': noRm,
      'nama_pasien': namaPasien,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper untuk mendapatkan jenis kelamin lengkap
  String get jenisKelaminLengkap {
    return jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';
  }

  // Helper untuk mendapatkan umur
  int get umur {
    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}

