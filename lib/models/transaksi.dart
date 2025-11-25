class Transaksi {
  final int id;
  final String noTransaksi;
  final String noRegistrasiKunjungan;
  final double totalHarga;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? kunjungan;
  final List<DetailTransaksi> details;

  Transaksi({
    required this.id,
    required this.noTransaksi,
    required this.noRegistrasiKunjungan,
    required this.totalHarga,
    this.createdAt,
    this.updatedAt,
    this.kunjungan,
    this.details = const [],
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    List<DetailTransaksi> detailsList = [];
    if (json['details'] != null) {
      for (var item in json['details']) {
        detailsList.add(DetailTransaksi.fromJson(item));
      }
    }

    return Transaksi(
      id: json['id'] ?? 0,
      noTransaksi: json['no_transaksi'] ?? '',
      noRegistrasiKunjungan: json['no_registrasi_kunjungan'] ?? '',
      totalHarga: double.tryParse(json['total_harga'].toString()) ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      kunjungan: json['kunjungan'],
      details: detailsList,
    );
  }
}

class DetailTransaksi {
  final int id;
  final int transaksiId;
  final String namaTindakan;
  final int jumlah;
  final double harga;
  final double subtotal;

  DetailTransaksi({
    required this.id,
    required this.transaksiId,
    required this.namaTindakan,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      id: json['id'] ?? 0,
      transaksiId: json['transaksi_id'] ?? 0,
      namaTindakan: json['nama_tindakan'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }
}

