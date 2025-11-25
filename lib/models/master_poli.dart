class MasterPoli {
  final int id;
  final String kodePoli;
  final String namaPoli;
  final String? lokasi;

  MasterPoli({
    required this.id,
    required this.kodePoli,
    required this.namaPoli,
    this.lokasi,
  });

  factory MasterPoli.fromJson(Map<String, dynamic> json) {
    return MasterPoli(
      id: json['id'] ?? 0,
      kodePoli: json['kode_poli'] ?? '',
      namaPoli: json['nama_poli'] ?? '',
      lokasi: json['lokasi'],
    );
  }
}

