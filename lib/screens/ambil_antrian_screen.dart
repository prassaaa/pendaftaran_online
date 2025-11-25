import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/master_poli.dart';
import '../models/master_penjamin.dart';
import '../models/jadwal_dokter.dart';
import '../models/antrian.dart';

class AmbilAntrianScreen extends StatefulWidget {
  const AmbilAntrianScreen({super.key});

  @override
  State<AmbilAntrianScreen> createState() => _AmbilAntrianScreenState();
}

class _AmbilAntrianScreenState extends State<AmbilAntrianScreen> {
  final ApiService _apiService = ApiService();
  
  // Step tracking
  int _currentStep = 0;
  
  // Form data
  DateTime? _selectedDate;
  MasterPenjamin? _selectedPenjamin;
  MasterPoli? _selectedPoli;
  JadwalDokter? _selectedJadwal;
  
  // Data lists
  List<MasterPoli> _poliList = [];
  List<MasterPenjamin> _penjaminList = [];
  List<JadwalDokter> _jadwalList = [];
  
  // Loading states
  bool _isLoadingPoli = false;
  bool _isLoadingPenjamin = false;
  bool _isLoadingJadwal = false;
  bool _isCreatingAntrian = false;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() {
      _isLoadingPoli = true;
      _isLoadingPenjamin = true;
    });

    try {
      final poli = await _apiService.getMasterPoli();
      final penjamin = await _apiService.getMasterPenjamin();
      
      setState(() {
        _poliList = poli;
        _penjaminList = penjamin;
        _isLoadingPoli = false;
        _isLoadingPenjamin = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPoli = false;
        _isLoadingPenjamin = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _loadJadwalDokter() async {
    if (_selectedPoli == null || _selectedDate == null) return;

    setState(() {
      _isLoadingJadwal = true;
      _jadwalList = [];
      _selectedJadwal = null;
    });

    try {
      final hari = DateFormat('EEEE', 'id_ID').format(_selectedDate!);
      final hariIndonesia = _convertToIndonesianDay(hari);
      
      final jadwal = await _apiService.getJadwalDokter(
        poli: _selectedPoli!.kodePoli,
        hari: hariIndonesia,
      );
      
      setState(() {
        _jadwalList = jadwal;
        _isLoadingJadwal = false;
      });

      if (jadwal.isEmpty && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.warningColor),
                SizedBox(width: 10),
                Text('Jadwal Tidak Tersedia'),
              ],
            ),
            content: Text(
              'Tidak ada jadwal dokter untuk poli ${_selectedPoli!.namaPoli} pada hari $hariIndonesia.',
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

  String _convertToIndonesianDay(String day) {
    const dayMap = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    return dayMap[day] ?? day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Antrian'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 30),
          _buildCurrentStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, 'Tanggal', _currentStep >= 0),
        _buildStepLine(_currentStep >= 1),
        _buildStepCircle(2, 'Penjamin', _currentStep >= 1),
        _buildStepLine(_currentStep >= 2),
        _buildStepCircle(3, 'Poli', _currentStep >= 2),
        _buildStepLine(_currentStep >= 3),
        _buildStepCircle(4, 'Dokter', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTheme.bodyLarge.copyWith(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 30),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDateSelection();
      case 1:
        return _buildPenjaminSelection();
      case 2:
        return _buildPoliSelection();
      case 3:
        return _buildDokterSelection();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Pilih Tanggal
  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Tanggal Kunjungan', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                            : 'Pilih tanggal kunjungan',
                        style: AppTheme.bodyLarge.copyWith(
                          color: _selectedDate != null
                              ? AppTheme.textPrimaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedDate != null
                    ? () {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    : null,
                child: const Text('Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Pilih Penjamin
  Widget _buildPenjaminSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Penjamin', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            if (_isLoadingPenjamin)
              const Center(child: CircularProgressIndicator())
            else if (_penjaminList.isEmpty)
              const Center(child: Text('Tidak ada data penjamin'))
            else
              ..._penjaminList.map((penjamin) => _buildPenjaminCard(penjamin)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPenjamin != null
                        ? () {
                            setState(() {
                              _currentStep = 2;
                            });
                          }
                        : null,
                    child: const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenjaminCard(MasterPenjamin penjamin) {
    final isSelected = _selectedPenjamin?.id == penjamin.id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPenjamin = penjamin;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                penjamin.namaPenjamin,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Pilih Poli
  Widget _buildPoliSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Poli', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            if (_isLoadingPoli)
              const Center(child: CircularProgressIndicator())
            else if (_poliList.isEmpty)
              const Center(child: Text('Tidak ada data poli'))
            else
              ..._poliList.map((poli) => _buildPoliCard(poli)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPoli != null
                        ? () {
                            _loadJadwalDokter();
                            setState(() {
                              _currentStep = 3;
                            });
                          }
                        : null,
                    child: const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliCard(MasterPoli poli) {
    final isSelected = _selectedPoli?.id == poli.id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPoli = poli;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poli.namaPoli,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (poli.lokasi != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      poli.lokasi!,
                      style: AppTheme.bodySmall,
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

  // Step 4: Pilih Dokter/Jadwal
  Widget _buildDokterSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Jadwal Dokter', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            if (_isLoadingJadwal)
              const Center(child: CircularProgressIndicator())
            else if (_jadwalList.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada jadwal dokter tersedia',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._jadwalList.map((jadwal) => _buildJadwalCard(jadwal)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 2;
                      });
                    },
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedJadwal != null && !_isCreatingAntrian
                        ? _submitAntrian
                        : null,
                    child: _isCreatingAntrian
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ambil Antrian'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalCard(JadwalDokter jadwal) {
    final isSelected = _selectedJadwal?.id == jadwal.id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedJadwal = jadwal;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        jadwal.jamPraktek,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Kuota: ${jadwal.kuota} pasien',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAntrian() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pasien = authProvider.currentPasien;

    if (pasien == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pasien tidak ditemukan')),
      );
      return;
    }

    setState(() {
      _isCreatingAntrian = true;
    });

    try {
      final antrian = await _apiService.createAntrian({
        'no_rm': pasien.noRm,
        'jadwal_dokter_id': _selectedJadwal!.id,
        'tanggal_kunjungan': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'penjamin_id': _selectedPenjamin!.id,
      });

      setState(() {
        _isCreatingAntrian = false;
      });

      if (antrian != null && mounted) {
        _showSuccessDialog(antrian);
      }
    } catch (e) {
      setState(() {
        _isCreatingAntrian = false;
      });
      if (mounted) {
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

  void _showSuccessDialog(Antrian antrian) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor, size: 32),
            SizedBox(width: 10),
            Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Antrian berhasil dibuat', style: AppTheme.bodyLarge),
            const SizedBox(height: 20),
            _buildInfoRow('Nomor Antrian', antrian.noAntrian),
            _buildInfoRow('Dokter', antrian.namaDokter),
            _buildInfoRow('Poli', antrian.namaPoli),
            _buildInfoRow('Jam Praktek', antrian.jamPraktek),
            _buildInfoRow('Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(antrian.tanggalKunjungan))),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

