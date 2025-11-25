class MasterPenjamin {
  final int id;
  final String kodePenjamin;
  final String namaPenjamin;
  final String? keterangan;

  MasterPenjamin({
    required this.id,
    required this.kodePenjamin,
    required this.namaPenjamin,
    this.keterangan,
  });

  factory MasterPenjamin.fromJson(Map<String, dynamic> json) {
    return MasterPenjamin(
      id: json['id'] ?? 0,
      kodePenjamin: json['kode_penjamin'] ?? '',
      namaPenjamin: json['nama_penjamin'] ?? '',
      keterangan: json['keterangan'],
    );
  }
}

