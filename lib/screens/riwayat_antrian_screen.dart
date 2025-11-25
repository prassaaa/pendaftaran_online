import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/antrian.dart';
import 'detail_antrian_screen.dart';

class RiwayatAntrianScreen extends StatefulWidget {
  const RiwayatAntrianScreen({super.key});

  @override
  State<RiwayatAntrianScreen> createState() => _RiwayatAntrianScreenState();
}

class _RiwayatAntrianScreenState extends State<RiwayatAntrianScreen> {
  final ApiService _apiService = ApiService();
  
  List<Antrian> _antrianList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRiwayatAntrian();
  }

  Future<void> _loadRiwayatAntrian() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pasien = authProvider.currentPasien;

    if (pasien == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pasien tidak ditemukan')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final antrian = await _apiService.getAntrianByNoRM(pasien.noRm);
      
      setState(() {
        _antrianList = antrian;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Antrian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRiwayatAntrian,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_antrianList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat antrian',
              style: AppTheme.headingSmall.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat antrian Anda akan muncul di sini',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRiwayatAntrian,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _antrianList.length,
        itemBuilder: (context, index) {
          final antrian = _antrianList[index];
          return _buildKunjunganCard(antrian);
        },
      ),
    );
  }

  Widget _buildKunjunganCard(Antrian antrian) {
    final tanggal = DateTime.parse(antrian.tanggalKunjungan);
    final isToday = DateFormat('yyyy-MM-dd').format(tanggal) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    Color statusColor;
    IconData statusIcon;
    
    switch (antrian.status) {
      case 'menunggu':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        break;
      case 'dipanggil':
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.notifications_active;
        break;
      case 'selesai':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'batal':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailAntrianScreen(antrian: antrian),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          antrian.status.toUpperCase(),
                          style: AppTheme.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HARI INI',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Nomor Antrian
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nomor Antrian', style: AppTheme.bodySmall),
                        Text(
                          antrian.noAntrian,
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Info kunjungan
              _buildInfoRow(Icons.local_hospital, 'Poli', antrian.namaPoli),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, 'Dokter', antrian.namaDokter),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today,
                'Tanggal',
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggal),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, 'Jam Praktek', antrian.jamPraktek),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodySmall.copyWith(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

