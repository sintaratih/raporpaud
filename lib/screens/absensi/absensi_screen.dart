
import 'package:flutter/material.dart';
import 'package:raporpaud/screens/data_siswa_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/bottom_navbar.dart';
import '../dashboard_screen.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final supabase = Supabase.instance.client;

  final Color primaryBlue = const Color(0xFF1765D9);

  DateTime selectedDate = DateTime.now();
  String selectedGroup = 'Kelompok A';

  List<Map<String, dynamic>> students = [];
  Map<String, String> attendance = {};

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    ambilDataSiswa();
  }

  // FORMAT TANGGAL UNTUK DATABASE
  String get tanggalDatabase {
    return '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';
  }

  // FORMAT TANGGAL UNTUK TAMPILAN
  String get tanggalTampilan {
    final hari = days[selectedDate.weekday - 1];
    final bulan = months[selectedDate.month - 1];

    return '$hari, ${selectedDate.day} $bulan ${selectedDate.year}';
  }

  // AMBIL DATA SISWA DARI SUPABASE
  Future<void> ambilDataSiswa() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await supabase
          .from('siswa')
          .select(
            'id, nama_lengkap, nis, kelompok(nama_kelompok)',
          )
          .order('nama_lengkap');

      students = List<Map<String, dynamic>>.from(data);

      await ambilDataAbsensi();
    } catch (e) {
      errorMessage = 'Gagal mengambil data siswa: $e';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // AMBIL DATA ABSENSI BERDASARKAN TANGGAL
  Future<void> ambilDataAbsensi() async {
    final data = await supabase
        .from('absensi')
        .select('siswa_id, status')
        .eq('tanggal', tanggalDatabase);

    attendance = {};

    for (final item in data) {
      attendance[item['siswa_id'].toString()] =
          item['status'].toString();
    }
  }

  // GANTI TANGGAL
  Future<void> ubahTanggal(DateTime tanggal) async {
    setState(() {
      selectedDate = tanggal;
      isLoading = true;
      errorMessage = null;
    });

    try {
      await ambilDataAbsensi();
    } catch (e) {
      errorMessage = 'Gagal mengambil data absensi: $e';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // PILIH TANGGAL
  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      await ubahTanggal(picked);
    }
  }

  // FILTER SISWA BERDASARKAN KELOMPOK
  List<Map<String, dynamic>> get filteredStudents {
    return students.where((student) {
      final kelompok = student['kelompok'];

      final namaKelompok = kelompok is Map
          ? kelompok['nama_kelompok']?.toString()
          : null;

      return namaKelompok == selectedGroup;
    }).toList();
  }

  // HITUNG STATUS KEHADIRAN
  int hitungStatus(String status) {
    return filteredStudents.where((student) {
      final id = student['id'].toString();
      return attendance[id] == status;
    }).length;
  }

  // WARNA STATUS
  Color statusColor(String status) {
    switch (status) {
      case 'Hadir':
        return const Color(0xFF16A879);
      case 'Izin':
        return const Color(0xFFFFA000);
      case 'Sakit':
        return const Color(0xFFE53935);
      case 'Alpa':
        return const Color(0xFF8E44AD);
      default:
        return Colors.grey;
    }
  }

  // KARTU RINGKASAN
  Widget kartuRingkasan(
    String judul,
    int jumlah,
    Color warna,
    IconData ikon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEAF0FA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warna.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              ikon,
              color: warna,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$jumlah',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: warna,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL FILTER KELOMPOK
  Widget tombolKelompok(String kelompok) {
    final selected = selectedGroup == kelompok;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGroup = kelompok;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? primaryBlue
                  : const Color(0xFFDCE3EF),
            ),
          ),
          child: Text(
            kelompok,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // PILIHAN STATUS KEHADIRAN
  Widget pilihanStatus(String siswaId, String status) {
    final selected = attendance[siswaId] == status;
    final color = statusColor(status);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            attendance[siswaId] = status;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTU DATA SISWA
  Widget kartuSiswa(Map<String, dynamic> student) {
    final id = student['id'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAF0FA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            student['nama_lengkap']?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF17243A),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              pilihanStatus(id, 'Hadir'),
              pilihanStatus(id, 'Izin'),
              pilihanStatus(id, 'Sakit'),
            ],
          ),
        ],
      ),
    );
  }

  // SIMPAN ABSENSI KE SUPABASE
  Future<void> simpanAbsensi() async {
    final daftarSiswa = filteredStudents;

    if (daftarSiswa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada siswa untuk diabsen'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final dataAbsensi = daftarSiswa.map((student) {
        final id = student['id'].toString();

        // Status yang belum dipilih otomatis menjadi Alpa.
        final status = attendance[id] ?? 'Alpa';

        return {
          'siswa_id': id,
          'tanggal': tanggalDatabase,
          'status': status,
        };
      }).toList();

      await supabase.from('absensi').upsert(
        dataAbsensi,
        onConflict: 'siswa_id,tanggal',
      );

      // Perbarui ringkasan setelah berhasil disimpan.
      for (final student in daftarSiswa) {
        final id = student['id'].toString();
        attendance[id] ??= 'Alpa';
      }

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil disimpan'),
          backgroundColor: Color(0xFF16A879),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan absensi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftarSiswa = filteredStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: ambilDataSiswa,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PILIH TANGGAL
                            Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2EAF6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha:0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: selectedDate.isAfter(
                                      DateTime(2020),
                                    )
                                        ? () => ubahTanggal(
                                              selectedDate.subtract(
                                                const Duration(days: 1),
                                              ),
                                            )
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_left,
                                      color: Color(0xFF9AB8E8),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tanggalTampilan,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: const Color(0xFFE8EDF5),
                                  ),
                                  IconButton(
                                    onPressed: pilihTanggal,
                                    icon: Icon(
                                      Icons.calendar_month,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // RINGKASAN KEHADIRAN
                            const Text(
                              'Ringkasan Kehadiran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17243A),
                              ),
                            ),

                            const SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.1,
                              children: [
                                kartuRingkasan(
                                  'Hadir',
                                  hitungStatus('Hadir'),
                                  const Color(0xFF16A879),
                                  Icons.check_circle_outline,
                                ),
                                kartuRingkasan(
                                  'Izin',
                                  hitungStatus('Izin'),
                                  const Color(0xFFFFA000),
                                  Icons.info_outline,
                                ),
                                kartuRingkasan(
                                  'Sakit',
                                  hitungStatus('Sakit'),
                                  const Color(0xFFE53935),
                                  Icons.medical_services_outlined,
                                ),
                                kartuRingkasan(
                                  'Alpa',
                                  hitungStatus('Alpa'),
                                  const Color(0xFF8E44AD),
                                  Icons.cancel_outlined,
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // FILTER KELOMPOK
                            const Text(
                              'Pilih Kelompok',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17243A),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                tombolKelompok('Kelompok A'),
                                const SizedBox(width: 12),
                                tombolKelompok('Kelompok B'),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // DAFTAR SISWA
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Siswa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF17243A),
                                  ),
                                ),
                                Text(
                                  '${daftarSiswa.length} Siswa',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            if (daftarSiswa.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Belum ada siswa di kelompok ini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ...daftarSiswa.map(kartuSiswa),
                          ],
                        ),
                      ),
                    ),

                    // TOMBOL SIMPAN
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        16,
                      ),
                      color: const Color(0xFFF4F7FC),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              isSaving || daftarSiswa.isEmpty
                                  ? null
                                  : simpanAbsensi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.blueGrey,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Absensi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DataSiswaScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}