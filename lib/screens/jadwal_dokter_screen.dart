import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../models/jadwal_dokter.dart';
import '../models/master_poli.dart';

class JadwalDokterScreen extends StatefulWidget {
  const JadwalDokterScreen({super.key});

  @override
  State<JadwalDokterScreen> createState() => _JadwalDokterScreenState();
}

class _JadwalDokterScreenState extends State<JadwalDokterScreen> {
  final ApiService _apiService = ApiService();
  
  List<JadwalDokter> _jadwalList = [];
  List<MasterPoli> _poliList = [];
  MasterPoli? _selectedPoli;
  
  bool _isLoadingJadwal = false;
  bool _isLoadingPoli = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadJadwalDokter(),
      _loadMasterPoli(),
    ]);
  }

  Future<void> _loadJadwalDokter({String? poli}) async {
    setState(() {
      _isLoadingJadwal = true;
    });

    try {
      final jadwal = await _apiService.getJadwalDokter(poli: poli);
      
      setState(() {
        _jadwalList = jadwal;
        _isLoadingJadwal = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingJadwal = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat jadwal: $e')),
        );
      }
    }
  }

  Future<void> _loadMasterPoli() async {
    setState(() {
      _isLoadingPoli = true;
    });

    try {
      final poli = await _apiService.getMasterPoli();
      
      setState(() {
        _poliList = poli;
        _isLoadingPoli = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPoli = false;
      });
    }
  }

  void _filterByPoli(MasterPoli? poli) {
    setState(() {
      _selectedPoli = poli;
    });
    _loadJadwalDokter(poli: poli?.kodePoli);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Dokter'),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildJadwalList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Poli', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (_isLoadingPoli)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', _selectedPoli == null, () => _filterByPoli(null)),
                  const SizedBox(width: 8),
                  ..._poliList.map((poli) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      poli.namaPoli,
                      _selectedPoli?.id == poli.id,
                      () => _filterByPoli(poli),
                    ),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildJadwalList() {
    if (_isLoadingJadwal) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal dokter',
              style: AppTheme.bodyLarge.copyWith(color: Colors.grey),
            ),
            if (_selectedPoli != null) ...[
              const SizedBox(height: 8),
              Text(
                'untuk poli ${_selectedPoli!.namaPoli}',
                style: AppTheme.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    // Group jadwal by hari
    final groupedJadwal = <String, List<JadwalDokter>>{};
    for (var jadwal in _jadwalList) {
      if (!groupedJadwal.containsKey(jadwal.hari)) {
        groupedJadwal[jadwal.hari] = [];
      }
      groupedJadwal[jadwal.hari]!.add(jadwal);
    }

    // Sort hari
    final hariOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final sortedHari = groupedJadwal.keys.toList()
      ..sort((a, b) => hariOrder.indexOf(a).compareTo(hariOrder.indexOf(b)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHari.length,
      itemBuilder: (context, index) {
        final hari = sortedHari[index];
        final jadwalHari = groupedJadwal[hari]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hari,
                    style: AppTheme.headingSmall.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            ...jadwalHari.map((jadwal) => _buildJadwalCard(jadwal)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildJadwalCard(JadwalDokter jadwal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.namaDokter,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          jadwal.namaPoli,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Hari Praktik',
                    jadwal.hari,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.access_time,
                    'Jam Praktek',
                    jadwal.jamPraktek,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.people,
              'Kuota Pasien',
              '${jadwal.kuota} pasien/hari',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(color: Colors.grey),
              ),
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
