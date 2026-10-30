import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class DataSiswaScreen extends StatefulWidget {
  const DataSiswaScreen({super.key});

  @override
  State<DataSiswaScreen> createState() => _DataSiswaScreenState();
}

class _DataSiswaScreenState extends State<DataSiswaScreen> {
  String searchQuery = '';
  String selectedGroup = 'Semua';

  final List<Map<String, String>> students = [
    {
      'nama': 'Aisya Putri',
      'inisial': 'AP',
      'nis': '001',
      'nisn': '1234567890',
      'kelompok': 'Kelompok A',
    },
    {
      'nama': 'Bagas Santoso',
      'inisial': 'BS',
      'nis': '002',
      'nisn': '1234567891',
      'kelompok': 'Kelompok B',
    },
    {
      'nama': 'Citra Lestari',
      'inisial': 'CL',
      'nis': '003',
      'nisn': '1234567892',
      'kelompok': 'Kelompok A',
    },
    {
      'nama': 'Dedi Ramadhan',
      'inisial': 'DR',
      'nis': '004',
      'nisn': '1234567893',
      'kelompok': 'Kelompok B',
    },
    {
      'nama': 'Eka Nurhaliza',
      'inisial': 'EN',
      'nis': '005',
      'nisn': '1234567894',
      'kelompok': 'Kelompok A',
    },
  ];

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        title: const Text(
          'Data Siswa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

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
              child: filteredStudents.isEmpty
                  ? const Center(
                      child: Text('Data siswa tidak ditemukan'),
                    )
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color(0xFFDCEAFF),
                                child: Text(
                                  student['inisial']!,
                                  style: const TextStyle(
                                    color: Color(0xFF1765D9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student['nama']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'NIS: ${student['nis']}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'NISN: ${student['nisn']}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: student['kelompok'] ==
                                          'Kelompok A'
                                      ? const Color(0xFFE0F5EB)
                                      : const Color(0xFFFFEEDC),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  student['kelompok']!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: student['kelompok'] ==
                                            'Kelompok A'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1765D9),
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah siswa akan dibuat berikutnya'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}