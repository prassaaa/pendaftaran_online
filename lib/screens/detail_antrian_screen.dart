import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/antrian.dart';
import '../services/api_service.dart';

class DetailAntrianScreen extends StatefulWidget {
  final Antrian antrian;

  const DetailAntrianScreen({super.key, required this.antrian});

  @override
  State<DetailAntrianScreen> createState() => _DetailAntrianScreenState();
}

class _DetailAntrianScreenState extends State<DetailAntrianScreen> {
  final ApiService _apiService = ApiService();

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
        title: const Text('Detail Antrian'),
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
                  Text('Informasi Antrian', style: AppTheme.headingSmall),
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

