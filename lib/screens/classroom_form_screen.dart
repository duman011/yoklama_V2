import 'package:flutter/material.dart';

class ClassroomFormScreen extends StatefulWidget {
  final Map<String, String>? initial;
  const ClassroomFormScreen({Key? key, this.initial}) : super(key: key);

  @override
  State<ClassroomFormScreen> createState() => _ClassroomFormScreenState();
}

class _ClassroomFormScreenState extends State<ClassroomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _subeKodController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _sinifController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '50');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  TimeOfDay? _time;
  String? _selectedFaculty;
  String? _selectedDepartment;

  final List<String> _faculties = ['Sağlık Bilimleri Fakültesi', 'Mühendislik Fakültesi', 'Fen-Edebiyat Fakültesi'];
  final List<String> _departments = ['Çocuk Gelişimi', 'Bilgisayar Mühendisliği', 'Tarih'];
  
  final List<String> _dersTipleri = ['Örgün', 'İkinci Öğretim', 'Uzaktan Eğitim'];
  final List<String> _dersSekilleri = ['Normal', 'Laboratuvar', 'Uygulama'];
  String? _selectedDersTipi;
  String? _selectedDersSekli;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _subeKodController.dispose();
    _programController.dispose();
    _sinifController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  void _createQr() {
    if (_formKey.currentState?.validate() ?? false) {
      final course = _courseNameController.text.trim();
      final code = _courseCodeController.text.trim();
      final details = {
        'code': code,
        'name': course,
        'sube': _subeKodController.text.trim(),
        'faculty': _selectedFaculty ?? '',
        'department': _selectedDepartment ?? '',
        'program': _programController.text.trim(),
        'class': _sinifController.text.trim(),
        'ders_tipi': _selectedDersTipi ?? '',
        'ders_sekli': _selectedDersSekli ?? '',
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'time': _time?.format(context) ?? '',
      };
      // Return the created course to caller
      Navigator.of(context).pop(details);
    }
  }

  @override
  void initState() {
    super.initState();
    // if initial data provided, populate fields
    final init = widget.initial;
    if (init != null) {
      _courseNameController.text = init['name'] ?? '';
      _courseCodeController.text = init['code'] ?? '';
      _subeKodController.text = init['sube'] ?? (init['branch'] ?? '');
      _programController.text = init['programName'] ?? init['program'] ?? '';
      _sinifController.text = init['class'] ?? '';
      _durationController.text = init['duration'] ?? _durationController.text;
      _descriptionController.text = init['description'] ?? '';
      _locationController.text = init['location'] ?? '';
      // If the incoming values are not part of the predefined lists,
      // insert them so DropdownButtonFormField has an exact matching item.
      final incomingFaculty = init['faculty'];
      if (incomingFaculty != null && incomingFaculty.isNotEmpty) {
        if (!_faculties.contains(incomingFaculty)) _faculties.insert(0, incomingFaculty);
        _selectedFaculty = incomingFaculty;
      }

      final incomingDepartment = init['department'];
      if (incomingDepartment != null && incomingDepartment.isNotEmpty) {
        if (!_departments.contains(incomingDepartment)) _departments.insert(0, incomingDepartment);
        _selectedDepartment = incomingDepartment;
      }

      // incoming program handled via _programController
      final incomingDersTipi = init['ders_tipi'];
      if (incomingDersTipi != null && incomingDersTipi.isNotEmpty) _selectedDersTipi = incomingDersTipi;
      final incomingDersSekli = init['ders_sekli'];
      if (incomingDersSekli != null && incomingDersSekli.isNotEmpty) _selectedDersSekli = incomingDersSekli;
      // time left as is; caller can provide formatted time in 'time' if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF8C6BE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Ders Yoklaması Başlat',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Ders bilgilerini girerek yoklama QR kodu oluşturun',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _courseNameController,
                          decoration: const InputDecoration(labelText: 'Ders Adı', hintText: 'Örn: Eğitim Sosyolojisi'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ders adı girin' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _courseCodeController,
                          decoration: const InputDecoration(labelText: 'Ders Kodu', hintText: 'Örn: CGPM267'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ders kodu girin' : null,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Saat'),
                            child: Text(_time == null ? '-- : --' : _time!.format(context)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _subeKodController,
                          decoration: const InputDecoration(labelText: 'Şube Kod', hintText: 'Örn: 1'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Şube kodu girin' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedFaculty,
                          decoration: const InputDecoration(labelText: 'Fakülte'),
                          items: _faculties.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedFaculty = v),
                          validator: (v) => v == null ? 'Fakülte seçin' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(labelText: 'Bölüm'),
                          items: _departments.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedDepartment = v),
                          validator: (v) => v == null ? 'Bölüm seçin' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _programController,
                          decoration: const InputDecoration(labelText: 'Program Adı', hintText: 'Örn: Çocuk Gelişimi'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Program adı girin' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sinifController,
                          decoration: const InputDecoration(labelText: 'Sınıf', hintText: 'Örn: 2'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedDersTipi,
                          decoration: const InputDecoration(labelText: 'Ders Tipi'),
                          items: _dersTipleri.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedDersTipi = v),
                          validator: (v) => v == null ? 'Ders tipi seçin' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedDersSekli,
                          decoration: const InputDecoration(labelText: 'Ders Şekli'),
                          items: _dersSekilleri.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedDersSekli = v),
                          validator: (v) => v == null ? 'Ders şekli seçin' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Ders Süre (dakika)', hintText: 'Örn: 50'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Ders süre girin';
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) return 'Geçerli bir sayı girin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Açıklama'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(labelText: 'Lokasyon Adı', hintText: 'Örn: Derslik 101 / Akıllı Tahta A1'),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: _createQr,
                            child: const Text('KAREKOD OKUT', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
