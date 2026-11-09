
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormSiswaScreen extends StatefulWidget {
  final Map<String, String>? initialData;

  const FormSiswaScreen({
    super.key,
    this.initialData,
  });

  @override
  State<FormSiswaScreen> createState() => _FormSiswaScreenState();
}

class _FormSiswaScreenState extends State<FormSiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nisController = TextEditingController();
  final nisnController = TextEditingController();

  String? selectedGroup = 'Kelompok A';
  String? selectedYear = '2026';

  DateTime? selectedDate;

  bool isSaving = false;

  final Color primaryBlue = const Color(0xFF1765D9);

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    if (data != null) {
      namaController.text = data['nama'] ?? '';
      nikController.text = data['nik'] ?? '';
      nisController.text = data['nis'] ?? '';
      nisnController.text = data['nisn'] ?? '';

      selectedGroup = data['kelompok'] ?? 'Kelompok A';
      selectedYear = data['tahun_masuk'] ?? data['tahun'] ?? '2026';

      final tanggal = data['tanggal_lahir'] ?? data['tanggalLahir'];

      if (tanggal != null && tanggal.isNotEmpty) {
        try {
          if (tanggal.contains('-')) {
            selectedDate = DateTime.parse(tanggal);
          } else if (tanggal.contains('/')) {
            final bagian = tanggal.split('/');

            if (bagian.length == 3) {
              selectedDate = DateTime(
                int.parse(bagian[2]),
                int.parse(bagian[1]),
                int.parse(bagian[0]),
              );
            }
          }
        } catch (_) {
          selectedDate = null;
        }
      }
    }
  }

  // Memilih tanggal lahir
  Future<void> pilihTanggal() async {
    final DateTime sekarang = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2022),
      firstDate: DateTime(2015),
      lastDate: sekarang,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Menyimpan atau memperbarui data siswa di Supabase
  Future<void> simpanData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal lahir harus diisi'),
        ),
      );
      return;
    }

    if (selectedGroup == null || selectedYear == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Mengambil ID kelompok berdasarkan nama kelompok.
      final kelompok = await supabase
          .from('kelompok')
          .select('id')
          .eq('nama_kelompok', selectedGroup!)
          .single();

      final dataSiswa = {
        'nama_lengkap': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'nis': nisController.text.trim(),
        'nisn': nisnController.text.trim(),
        'kelompok_id': kelompok['id'],
        'tahun_masuk': int.parse(selectedYear!),
        'tanggal_lahir':
            '${selectedDate!.year.toString().padLeft(4, '0')}-'
            '${selectedDate!.month.toString().padLeft(2, '0')}-'
            '${selectedDate!.day.toString().padLeft(2, '0')}',
      };

      Map<String, dynamic> hasil;

      if (widget.initialData != null) {
        // UPDATE DATA SISWA
        final id = widget.initialData!['id'];

        if (id == null || id.isEmpty) {
          throw Exception('ID siswa tidak ditemukan.');
        }

        hasil = await supabase
            .from('siswa')
            .update(dataSiswa)
            .eq('id', id)
            .select()
            .single();
      } else {
        // TAMBAH DATA SISWA
        hasil = await supabase
            .from('siswa')
            .insert(dataSiswa)
            .select()
            .single();
      }

      if (!mounted) return;

      // Mengembalikan data agar halaman siswa dapat memuat ulang.
      Navigator.pop(context, {
        'id': hasil['id'].toString(),
        'nama': hasil['nama_lengkap'].toString(),
        'nik': hasil['nik'].toString(),
        'nis': hasil['nis'].toString(),
        'nisn': hasil['nisn'].toString(),
        'kelompok': selectedGroup!,
        'tahun_masuk': hasil['tahun_masuk'].toString(),
        'tanggal_lahir': hasil['tanggal_lahir'].toString(),
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
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
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nisController.dispose();
    nisnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialData == null
              ? 'Tambah Data Siswa'
              : 'Edit Data Siswa',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                // NAMA LENGKAP
                const Text('Nama Lengkap *'),
                const SizedBox(height: 7),

                inputField(
                  controller: namaController,
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // NIK
                const Text('NIK *'),
                const SizedBox(height: 7),

                inputField(
                  controller: nikController,
                  hint: '16 digit NIK',
                  icon: Icons.credit_card_outlined,
                  numberOnly: true,
                  maxLength: 16,
                  minLength: 16,
                ),

                const SizedBox(height: 16),

                // NIS DAN NISN
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NIS *'),
                          const SizedBox(height: 7),
                          inputField(
                            controller: nisController,
                            hint: 'Nomor NIS',
                            numberOnly: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NISN *'),
                          const SizedBox(height: 7),
                          inputField(
                            controller: nisnController,
                            hint: 'Nomor NISN',
                            numberOnly: true,
                            maxLength: 10,
                            minLength: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // KELOMPOK DAN TAHUN
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kelompok *'),
                          const SizedBox(height: 7),
                          DropdownButtonFormField<String>(
                            initialValue: selectedGroup,
                            decoration: inputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                value: 'Kelompok A',
                                child: Text('Kelompok A'),
                              ),
                              DropdownMenuItem(
                                value: 'Kelompok B',
                                child: Text('Kelompok B'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedGroup = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tahun Masuk *'),
                          const SizedBox(height: 7),
                          DropdownButtonFormField<String>(
                            initialValue: selectedYear,
                            decoration: inputDecoration(),
                            items: List.generate(
                              12,
                              (index) {
                                final year =
                                    (DateTime.now().year - index).toString();

                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                );
                              },
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // TANGGAL LAHIR
                const Text('Tanggal Lahir *'),
                const SizedBox(height: 7),

                InkWell(
                  onTap: pilihTanggal,
                  child: InputDecorator(
                    decoration: inputDecoration(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                    ),
                    child: Text(
                      selectedDate == null
                          ? 'dd/mm/yyyy'
                          : '${selectedDate!.day}/'
                              '${selectedDate!.month}/'
                              '${selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedDate == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : simpanData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
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
                            'Simpan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget input yang digunakan berulang
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool numberOnly = false,
    int? maxLength,
    int? minLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numberOnly
          ? TextInputType.number
          : TextInputType.text,
      inputFormatters: numberOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 13),
      decoration: inputDecoration(
        hint: hint,
        suffixIcon: icon == null ? null : Icon(icon, size: 18),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Wajib diisi';
        }

        if (minLength != null && value.trim().length != minLength) {
          return 'Harus $minLength digit';
        }

        return null;
      },
    );
  }

  // Desain input seragam
  InputDecoration inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F3),
        ),
      ),
    );
  }
}