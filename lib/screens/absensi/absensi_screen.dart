
import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final Color primaryBlue = const Color(0xFF1765D9);

  DateTime selectedDate = DateTime.now();
  String selectedGroup = 'Semua';

  final List<Map<String, String>> students = [
    {'nama': 'Aisya Putri', 'nis': '001', 'kelompok': 'Kelompok A'},
    {'nama': 'Bagas Santoso', 'nis': '002', 'kelompok': 'Kelompok B'},
    {'nama': 'Citra Lestari', 'nis': '003', 'kelompok': 'Kelompok A'},
    {'nama': 'Dedi Ramadhan', 'nis': '004', 'kelompok': 'Kelompok B'},
    {'nama': 'Eka Nurhaliza', 'nis': '005', 'kelompok': 'Kelompok A'},
  ];

  final Map<String, String> attendance = {};

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatTanggal(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int hitungStatus(String status) {
    return students.where((student) {
      final cocokKelompok = selectedGroup == 'Semua' ||
          student['kelompok'] == selectedGroup;

      return cocokKelompok &&
          attendance[student['nis']] == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students.where((student) {
      return selectedGroup == 'Semua' ||
          student['kelompok'] == selectedGroup;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        title: const Text(
          'Absensi Siswa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PILIH TANGGAL
            const Text(
              'Tanggal Absensi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            InkWell(
              onTap: pilihTanggal,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formatTanggal(selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // RINGKASAN
            const Text(
              'Ringkasan Kehadiran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _summaryCard('Hadir', hitungStatus('Hadir'),
                    const Color(0xFF16A879), Icons.check_circle_outline),
                _summaryCard('Izin', hitungStatus('Izin'),
                    const Color(0xFF1765D9), Icons.info_outline),
                _summaryCard('Sakit', hitungStatus('Sakit'),
                    const Color(0xFFFF9D35), Icons.medical_services_outlined),
                _summaryCard('Alpa', hitungStatus('Alpa'),
                    const Color(0xFFE94B4B), Icons.cancel_outlined),
              ],
            ),

            const SizedBox(height: 22),

            // FILTER KELOMPOK
            const Text(
              'Pilih Kelompok',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: ['Semua', 'Kelompok A', 'Kelompok B'].map((group) {
                final selected = selectedGroup == group;

                return ChoiceChip(
                  label: Text(group),
                  selected: selected,
                  selectedColor: primaryBlue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 11,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedGroup = group;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // DAFTAR SISWA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Siswa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${filteredStudents.length} Siswa',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...filteredStudents.map((student) {
              final nis = student['nis']!;
              final status = attendance[nis];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFDCEAFF),
                          child: Text(
                            student['nama']!
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join()
                                .toUpperCase(),
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['nama']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'NIS: $nis • ${student['kelompok']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (status != null)
                          Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: ['Hadir', 'Izin', 'Sakit', 'Alpa']
                          .map((item) {
                        final isSelected = status == item;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  attendance[nis] = item;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _statusColor(item)
                                      : const Color(0xFFF1F4F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (attendance.length < students.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Masih ada siswa yang belum diabsen',
                        ),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Absensi berhasil disimpan sementara',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Absensi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _summaryCard(
    String title,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hadir':
        return const Color(0xFF16A879);
      case 'Izin':
        return const Color(0xFF1765D9);
      case 'Sakit':
        return const Color(0xFFFF9D35);
      case 'Alpa':
        return const Color(0xFFE94B4B);
      default:
        return Colors.grey;
    }
  }
}
