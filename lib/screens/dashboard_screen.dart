
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/bottom_navbar.dart';
import 'data_siswa_screen.dart';
import 'absensi/absensi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int jumlahSiswa = 0;
  bool sedangMemuat = true;
  bool gagalMemuat = false;

  @override
  void initState() {
    super.initState();
    ambilJumlahSiswa();
  }

  // Mengambil jumlah siswa dari Supabase
  Future<void> ambilJumlahSiswa() async {
    try {
      final data = await Supabase.instance.client
          .from('siswa')
          .select('id');

      if (!mounted) return;

      setState(() {
        jumlahSiswa = data.length;
        sedangMemuat = false;
        gagalMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuat = false;
        gagalMemuat = true;
      });

      debugPrint('Gagal mengambil jumlah siswa: $e');
    }
  }

  // Membuka halaman siswa dan memperbarui statistik saat kembali
  Future<void> bukaDataSiswa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataSiswaScreen(),
      ),
    );

    ambilJumlahSiswa();
  }

  // Membuka halaman absensi
  void bukaAbsensi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AbsensiScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF1765D9),
                    child: Text(
                      'BS',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Budi Santoso',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Operator PAUD',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none),
                ],
              ),

              const SizedBox(height: 22),

              // TAHUN AJARAN
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1765D9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tahun Ajaran 2026/2027',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Semester Ganjil',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // STATISTIK
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  StatCard(
                    title: 'Siswa Aktif',
                    value: sedangMemuat
                        ? '...'
                        : gagalMemuat
                            ? '-'
                            : jumlahSiswa.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFF1765D9),
                  ),
                  const StatCard(
                    title: 'Rapor Selesai',
                    value: '15',
                    icon: Icons.check_circle_outline,
                    color: Color(0xFF16A879),
                  ),
                  const StatCard(
                    title: 'Belum Selesai',
                    value: '10',
                    icon: Icons.access_time,
                    color: Color(0xFFFF9D35),
                  ),
                  const StatCard(
                    title: 'Perlu Revisi',
                    value: '2',
                    icon: Icons.warning_amber,
                    color: Color(0xFFE94B4B),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

              // MENU UTAMA
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  MenuCard(
                    title: 'Data Siswa',
                    icon: Icons.people_outline,
                    color: const Color(0xFF1765D9),
                    onTap: bukaDataSiswa,
                  ),
                  const MenuCard(
                    title: 'Penilaian',
                    icon: Icons.camera_alt_outlined,
                    color: Color(0xFF16A879),
                  ),
                  MenuCard(
                    title: 'Absensi',
                    icon: Icons.calendar_month,
                    color: const Color(0xFF7650D9),
                    onTap: bukaAbsensi,
                  ),
                  const MenuCard(
                    title: 'Buat Rapor',
                    icon: Icons.description_outlined,
                    color: Color(0xFFFF9235),
                  ),
                  const MenuCard(
                    title: 'Kurikulum',
                    icon: Icons.spa_outlined,
                    color: Color(0xFF16A879),
                  ),
                  const MenuCard(
                    title: 'Kalender',
                    icon: Icons.event,
                    color: Color(0xFFE94B4B),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            bukaDataSiswa();
          } else if (index == 2) {
            bukaAbsensi();
          }
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
