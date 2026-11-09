
import 'package:flutter/material.dart';
import 'form_siswa_screen.dart';

class DetailSiswaScreen extends StatelessWidget {
  final Map<String, String> siswa;

  const DetailSiswaScreen({
    super.key,
    required this.siswa,
  });

  static const Color primaryBlue = Color(0xFF1765D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text(
          'Detail Siswa',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color(0xFFE4EEFF),
                    child: Text(
                      _inisial(siswa['nama'] ?? ''),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    siswa['nama'] ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    siswa['kelompok'] ?? '-',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identitas Siswa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _detailItem('Nama Lengkap', siswa['nama']),
                  _detailItem('NIK', siswa['nik']),
                  _detailItem('NIS', siswa['nis']),
                  _detailItem('NISN', siswa['nisn']),
                  _detailItem('Kelompok', siswa['kelompok']),
                  _detailItem('Tahun Masuk', siswa['tahun_masuk']),
                  _detailItem('Tanggal Lahir', siswa['tanggal_lahir']),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final hasil = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormSiswaScreen(
                        initialData: siswa,
                      ),
                    ),
                  );
                  if (hasil != null && context.mounted) {
                    Navigator.pop(context, hasil);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Data Siswa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final konfirmasi = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Data Siswa?'),
                      content: Text(
                        'Apakah kamu yakin ingin menghapus data ${siswa['nama']}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (konfirmasi == true && context.mounted) {
                    Navigator.pop(context, {'_aksi': 'hapus'});
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Data Siswa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value?.isNotEmpty == true ? value! : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _inisial(String nama) {
    final bagianNama = nama.trim().split(' ');

    if (bagianNama.isEmpty || nama.trim().isEmpty) {
      return '?';
    }

    if (bagianNama.length == 1) {
      return bagianNama.first[0].toUpperCase();
    }

    return '${bagianNama[0][0]}${bagianNama[1][0]}'
        .toUpperCase();
  }
}