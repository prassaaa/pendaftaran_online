import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/kunjungan.dart';
import '../models/transaksi.dart';
import '../services/api_service.dart';

class DetailKunjunganScreen extends StatefulWidget {
  final Kunjungan kunjungan;

  const DetailKunjunganScreen({super.key, required this.kunjungan});

  @override
  State<DetailKunjunganScreen> createState() => _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState extends State<DetailKunjunganScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoadingBilling = false;
  Transaksi? _transaksi;

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    setState(() {
      _isLoadingBilling = true;
    });

    try {
      // Ambil transaksi berdasarkan no_registrasi_kunjungan
      final transaksiList = await _apiService.getTransaksiByNoRM(widget.kunjungan.noRm);
      
      // Cari transaksi yang sesuai dengan no_registrasi_kunjungan
      Transaksi? foundTransaksi;
      for (var transaksi in transaksiList) {
        if (transaksi.noRegistrasiKunjungan == widget.kunjungan.noRegistrasi) {
          foundTransaksi = transaksi;
          break;
        }
      }
      
      setState(() {
        _transaksi = foundTransaksi;
        _isLoadingBilling = false;
      });
    } catch (e) {
      debugPrint('Error loading billing: $e');
      setState(() {
        _isLoadingBilling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.parse(widget.kunjungan.tanggalKunjungan);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kunjungan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kunjungan Selesai',
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No. Registrasi',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.kunjungan.noRegistrasi,
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Detail Information
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Kunjungan', style: AppTheme.headingSmall),
                  const SizedBox(height: 20),
                  
                  _buildDetailCard(
                    icon: Icons.person,
                    title: 'Data Pasien',
                    items: [
                      _DetailItem('Nama', widget.kunjungan.pasien?['nama_pasien'] ?? '-'),
                      _DetailItem('No. RM', widget.kunjungan.noRm),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(
                    icon: Icons.local_hospital,
                    title: 'Layanan Kesehatan',
                    items: [
                      _DetailItem('Poli', widget.kunjungan.masterPoli?['nama_poli'] ?? widget.kunjungan.poli),
                      _DetailItem('Instalasi', widget.kunjungan.instalasi),
                      _DetailItem('Dokter', widget.kunjungan.namaDokter),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDetailCard(
                    icon: Icons.calendar_today,
                    title: 'Jadwal Kunjungan',
                    items: [
                      _DetailItem(
                        'Tanggal',
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDetailCard(
                    icon: Icons.payment,
                    title: 'Penjamin',
                    items: [
                      _DetailItem('Penjamin', widget.kunjungan.namaPenjamin),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Billing Section
                  _buildBillingSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billing / Tagihan',
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (_transaksi != null)
                        Text(
                          'Transaksi: ${_transaksi!.noTransaksi}',
                          style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingBilling)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_transaksi != null)
              _buildBillingDetails()
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Billing belum tersedia',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingDetails() {
    if (_transaksi == null) return const SizedBox();

    return Column(
      children: [
        // Detail tindakan
        if (_transaksi!.details.isNotEmpty)
          ...List.generate(_transaksi!.details.length, (index) {
            final detail = _transaksi!.details[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.namaTindakan,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${detail.jumlah}x @ ${_formatCurrency(detail.harga)}',
                          style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(detail.subtotal),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          })
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Belum ada detail tindakan',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
            ),
          ),

        const Divider(height: 24),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatCurrency(_transaksi!.totalHarga),
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount ?? 0);
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<_DetailItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      item.label,
                      style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  ),
                  const Text(': '),
                  Expanded(
                    child: Text(
                      item.value,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}

