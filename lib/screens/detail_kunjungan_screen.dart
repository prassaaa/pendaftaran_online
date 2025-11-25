import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/antrian.dart';
import '../models/transaksi.dart';
import '../services/api_service.dart';

class DetailKunjunganScreen extends StatefulWidget {
  final Antrian antrian;

  const DetailKunjunganScreen({super.key, required this.antrian});

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
    // Load billing data dari API
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    setState(() {
      _isLoadingBilling = true;
    });

    try {
      // Ambil semua transaksi
      final transaksiList = await _apiService.getTransaksiByNoRM(widget.antrian.noRm);

      // Filter transaksi berdasarkan no_rm dan tanggal kunjungan
      final tanggalKunjungan = DateTime.parse(widget.antrian.tanggalKunjungan);

      Transaksi? foundTransaksi;

      // Prioritas 1: Cari transaksi dengan tanggal yang sama
      for (var transaksi in transaksiList) {
        if (transaksi.kunjungan != null) {
          final noRmTransaksi = transaksi.kunjungan!['no_rm'];
          final tanggalTransaksi = DateTime.parse(
            transaksi.kunjungan!['tanggal_kunjungan']
          );

          // Cek apakah no_rm dan tanggal sama
          if (noRmTransaksi == widget.antrian.noRm &&
              tanggalTransaksi.year == tanggalKunjungan.year &&
              tanggalTransaksi.month == tanggalKunjungan.month &&
              tanggalTransaksi.day == tanggalKunjungan.day) {
            foundTransaksi = transaksi;
            break;
          }
        }
      }

      // Prioritas 2: Jika tidak ada yang sama tanggalnya, ambil transaksi terbaru
      if (foundTransaksi == null && transaksiList.isNotEmpty) {
        for (var transaksi in transaksiList) {
          if (transaksi.kunjungan != null &&
              transaksi.kunjungan!['no_rm'] == widget.antrian.noRm) {
            foundTransaksi = transaksi;
            break; // Ambil yang pertama (biasanya yang terbaru)
          }
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
    final tanggal = DateTime.parse(widget.antrian.tanggalKunjungan);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (widget.antrian.status) {
      case 'menunggu':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        statusText = 'Menunggu';
        break;
      case 'dipanggil':
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.notifications_active;
        statusText = 'Dipanggil';
        break;
      case 'selesai':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Selesai';
        break;
      case 'batal':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        statusText = 'Dibatalkan';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = widget.antrian.status;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kunjungan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with status
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
                    child: Icon(
                      statusIcon,
                      size: 48,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusText,
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nomor Antrian',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.antrian.noAntrian,
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
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
                      _DetailItem('Nama', widget.antrian.namaPasien),
                      _DetailItem('No. RM', widget.antrian.noRm),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDetailCard(
                    icon: Icons.local_hospital,
                    title: 'Layanan Kesehatan',
                    items: [
                      _DetailItem('Poli', widget.antrian.namaPoli),
                      _DetailItem('Instalasi', widget.antrian.jadwalDokter?['instalasi'] ?? 'Rawat Jalan'),
                      _DetailItem('Dokter', widget.antrian.namaDokter),
                      _DetailItem('Jam Praktek', widget.antrian.jamPraktek),
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
                      _DetailItem(
                        'Hari',
                        DateFormat('EEEE', 'id_ID').format(tanggal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDetailCard(
                    icon: Icons.payment,
                    title: 'Penjamin',
                    items: [
                      _DetailItem('Penjamin', widget.antrian.namaPenjamin),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Billing Section
                  _buildBillingSection(),
                  
                  const SizedBox(height: 32),

                  // Action buttons (if needed)
                  if (widget.antrian.status == 'menunggu') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelDialog(context);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Batalkan Antrian'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                      if (_transaksi != null && _transaksi!.kunjungan != null)
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
                    const SizedBox(height: 4),
                    Text(
                      'Billing akan muncul setelah kunjungan selesai',
                      style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 10),
            Text('Batalkan Antrian'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin membatalkan antrian ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Antrian: ${widget.antrian.noAntrian}',
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dokter: ${widget.antrian.namaDokter}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => _cancelAntrian(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAntrian(BuildContext dialogContext) async {
    // Close dialog
    Navigator.pop(dialogContext);

    if (!mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Membatalkan antrian...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final success = await _apiService.deleteAntrian(widget.antrian.id);

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor),
                SizedBox(width: 10),
                Text('Berhasil'),
              ],
            ),
            content: const Text('Antrian berhasil dibatalkan'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to riwayat
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppTheme.errorColor),
              SizedBox(width: 10),
              Text('Gagal'),
            ],
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}

