
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/bottom_navbar.dart';
import 'dashboard_screen.dart';
import 'siswa/form_siswa_screen.dart';
import 'siswa/detail_siswa_screen.dart';
import 'absensi/absensi_screen.dart';

class DataSiswaScreen extends StatefulWidget {
  const DataSiswaScreen({super.key});

  @override
  State<DataSiswaScreen> createState() => _DataSiswaScreenState();
}

class _DataSiswaScreenState extends State<DataSiswaScreen> {
  final supabase = Supabase.instance.client;

  String searchQuery = '';
  String selectedGroup = 'Semua';

  List<Map<String, String>> students = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // Ambil data siswa dari Supabase
  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase
          .from('siswa')
          .select('*, kelompok(nama_kelompok)')
          .order('nama_lengkap');

      final List<Map<String, String>> loadedStudents =
          (response as List).map((row) {
        final kelompokData = row['kelompok'] as Map<String, dynamic>?;

        final nama = row['nama_lengkap']?.toString() ?? '';

        return {
          'id': row['id'].toString(),
          'nama': nama,
          'inisial': _buatInisial(nama),
          'nik': row['nik']?.toString() ?? '',
          'nis': row['nis']?.toString() ?? '',
          'nisn': row['nisn']?.toString() ?? '',
          'kelompok':
              kelompokData?['nama_kelompok']?.toString() ?? '-',
          'tahun_masuk': row['tahun_masuk']?.toString() ?? '',
          'tanggal_lahir':
              row['tanggal_lahir']?.toString() ?? '',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        students = loadedStudents;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Membuat inisial nama siswa
  String _buatInisial(String nama) {
    if (nama.trim().isEmpty) return '?';

    return nama
        .trim()
        .split(RegExp(r'\s+'))
        .map((kata) => kata[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students.where((student) {
      final matchesSearch = student['nama']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesGroup = selectedGroup == 'Semua' ||
          student['kelompok'] == selectedGroup;

      return matchesSearch && matchesGroup;
    }).toList();

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PENCARIAN
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama siswa',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // FILTER KELOMPOK
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Kelompok A', 'Kelompok B']
                    .map((group) {
                  final selected = selectedGroup == group;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group),
                      selected: selected,
                      selectedColor: const Color(0xFF1765D9),
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 11,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedGroup = group;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            // DAFTAR SISWA
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1765D9),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Gagal mengambil data siswa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: loadStudents,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : filteredStudents.isEmpty
                          ? const Center(
                              child: Text('Data siswa tidak ditemukan',),
                            )
                          : RefreshIndicator(
                              onRefresh: loadStudents,
                              child: ListView.builder(
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                      
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:BorderRadius.circular(14),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                         
                                      onTap: () async {
                                        final hasil =
                                            await Navigator.push<Map<String, String>>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>DetailSiswaScreen(siswa: student,),
                                          ),
                                        );

                                        if (hasil != null) {
                                          await loadStudents();
                                        }
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(13),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFFDCEAFF,),
                                                
                                              child: Text(
                                                student['inisial']!,
                                                style: const TextStyle(
                                                  color: Color( 0xFF1765D9,),
                                                  fontWeight:FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    student['nama']!,
                                                    style:
                                                        const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    'NIS: ${student['nis']}',
                                                    style:
                                                        const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    'NISN: ${student['nisn']}',
                                                    style:
                                                        const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: student['kelompok'] =='Kelompok A'
                                                    ? const Color(0xFFE0F5EB,)
                                                    : const Color(0xFFFFEEDC,),
                                                        
                                                borderRadius: BorderRadius.circular(20,),
                                              ),
                                              child: Text(
                                                student['kelompok']!,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: student['kelompok'] =='Kelompok A'
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),

      // TOMBOL TAMBAH SISWA
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1765D9),
        foregroundColor: Colors.white,
        onPressed: () async {
          final hasil = await Navigator.push<Map<String, String>>(
            context,
            MaterialPageRoute(
              builder: (context) => const FormSiswaScreen(),
            ),
          );

          if (hasil != null) {
            await loadStudents();
          }
        },
        child: const Icon(Icons.add),
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AbsensiScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}