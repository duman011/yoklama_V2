import 'package:flutter/material.dart';
import 'classroom_form_screen.dart';
import 'attendance_session_screen.dart';
// minute_clock_picker widget'ının hala gerekli olduğunu varsayıyoruz
import '../widgets/minute_clock_picker.dart'; 

class AcademicHomeScreen extends StatefulWidget {
  // Key kullanımı için 'use_super_parameters' yerine
  // doğrudan 'super.key' kullanmak Flutter'ın önerdiği yöntemdir.
  const AcademicHomeScreen({super.key}); 

  @override
  State<AcademicHomeScreen> createState() => _AcademicHomeScreenState();
}

class _AcademicHomeScreenState extends State<AcademicHomeScreen> {
  // Veri modelini Map yerine daha güvenli bir Class veya Tipi belirlenmiş Map ile tanımlamak daha iyidir.
  // Ancak mevcut yapınızda Map<String, String> olarak bırakıldı.
  final List<Map<String, String>> _courses = [
    {
      'code': 'EDS101',
      'name': 'Eğitim Sosyolojisi',
      'faculty': 'Sağlık Bilimleri Fakültesi',
      'department': 'Çocuk Gelişimi',
      'branch': 'Şube: 1 - Örgün Eğitim',
      'image': 'linear-gradient', // Bu sadece bir placeholder gibi görünüyor.
    },
    {
      'code': 'MAT203',
      'name': 'İleri Matematik',
      'faculty': 'Mühendislik Fakültesi',
      'department': 'Bilgisayar Mühendisliği',
      'branch': 'Şube: 2 - Örgün Eğitim',
      'image': 'linear-gradient-2',
    },
    {
      'code': 'TAR101',
      'name': 'Atatürk İlkeleri ve İnkılap Tarihi',
      'faculty': 'Fen-Edebiyat Fakültesi',
      'department': 'Tarih',
      'branch': 'Şube: 1 - İkinci Öğretim',
      'image': 'linear-gradient-3',
    },
  ];

  void _openCreateCourse() async {
    // Rota geçişi için rootNavigator: true kullanmak,
    // eğer ClassroomFormScreen tüm ekranı kaplayacaksa iyi bir pratik olabilir.
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(builder: (_) => const ClassroomFormScreen()),
    );
    if (result != null) {
      setState(() {
        _courses.insert(0, {
          // Null değerler için varsayılan değer atama (Mevcut kodunuzda da doğruydu)
          'code': result['code'] ?? 'YENI',
          'name': result['name'] ?? 'Yeni Ders',
          'faculty': result['faculty'] ?? '',
          'department': result['department'] ?? '',
          'branch': result['branch'] ?? '',
          'image': 'linear-gradient', // Varsayılan görsel/gradient
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama işlevi burada tetiklenmeli
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Padding artırıldı
        child: _courses.isEmpty
            ? const Center(
                child: Text('Henüz eklenmiş bir dersiniz yok.'),
              )
            : ListView.separated(
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final c = _courses[index];
                  // `index` yerine closure tarafından yakalanan `index` kullanılır.
                  return _buildCourseCard(context, c, index); 
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended( // `extended` daha iyi görünebilir.
        onPressed: _openCreateCourse,
        icon: const Icon(Icons.add),
        label: const Text('Ders Ekle'),
      ),
    );
  }

  // Fonksiyonu daha okunaklı hale getirmek için _handlePopupMenuSelection eklendi
  void _handlePopupMenuSelection(int value, Map<String, String> course, int index) async {
    final idx = index;
    if (value == 0) {
      // 1. Dersi Başlat (Yoklama Oturumu)
      int selected = 30; // Başlangıç değeri
      // Schedule dialog to next event-loop tick so the popup menu can close first.
      // Add simple debug prints to help pinpoint freeze location.
      // ignore: avoid_print
      print('Popup menu: Dersi Başlat seçildi — scheduling minute dialog');

      final minutes = await Future<int?>.delayed(Duration.zero, () {
        // This returns the future produced by showDialog and schedules it after the popup closes.
        return showDialog<int>(
          context: context,
          builder: (dctx) => _buildMinutePickerDialog(dctx, selected),
        );
      });

      // ignore: avoid_print
      print('Minute dialog closed, result: $minutes');

      if (minutes == null) return;

      // rootNavigator: true kullanımı doğru, ancak gerekliyse kullanın.
      // ignore: avoid_print
      print('Navigating to AttendanceSessionScreen with $minutes minutes');
      Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute(builder: (_) => AttendanceSessionScreen(course: course, durationMinutes: minutes)),
      );
    } else if (value == 1) {
      // 2. Düzenle
      final edited = await Navigator.of(context).push<Map<String, String?>>(
        MaterialPageRoute(builder: (_) => ClassroomFormScreen(initial: course)),
      );
      if (edited != null) {
        setState(() {
          // Değişiklikleri mevcut Map üzerine doğru şekilde uygular.
          _courses[idx] = {
            'code': edited['code'] ?? course['code']!,
            'name': edited['name'] ?? course['name']!,
            'faculty': edited['faculty'] ?? course['faculty']!,
            'department': edited['department'] ?? course['department']!,
            'branch': edited['branch'] ?? course['branch']!,
            'image': course['image']!, // Görseli koru
          };
        });
      }
    } else if (value == 2) {
      // 3. Sil
      // Silme öncesi kullanıcıya sorulacak bir AlertDialog eklemek kullanıcı deneyimi için iyi olurdu.
      // Basitleştirmek için mevcut kod korundu.
      final ok = await Future.delayed(const Duration(milliseconds: 400), () => true);
      if (ok) {
        setState(() => _courses.removeAt(idx));
      }
    }
  }

  // Süre Seçme Dialog'unu ana widget'tan ayırmak daha temizdir.
  Widget _buildMinutePickerDialog(BuildContext dctx, int initialSelected) {
    int selected = initialSelected;
    final controller = TextEditingController(text: selected.toString());

    return StatefulBuilder(
      builder: (dctx2, setSt) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          contentPadding: const EdgeInsets.all(12),
          title: const Text('Süre seçin (dakika)'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Numeric text input for minutes
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Dakika', hintText: 'örn. 30'),
                    onChanged: (s) {
                      final v = int.tryParse(s) ?? selected;
                      final clamped = v.clamp(1, 999);
                      setSt(() => selected = clamped);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Minute wheel picker
                  MinuteClockPicker(
                    initialMinutes: selected,
                    onChanged: (m) {
                      setSt(() {
                        selected = m;
                        controller.text = m.toString();
                        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('$selected dk', style: Theme.of(dctx).textTheme.titleLarge), // dctx kullanmak daha doğru
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dctx2).pop(), child: const Text('İptal')),
            ElevatedButton(onPressed: () => Navigator.of(dctx2).pop(selected), child: const Text('Başlat')),
          ],
        );
      },
    );
  }

  // CourseCard Widget'ı
  Widget _buildCourseCard(BuildContext context, Map<String, String> c, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      elevation: 4, // Gölge biraz artırıldı
      child: Column(
        children: [
          // image / gradient area
          Container(
            height: 150, // Yükseklik biraz azaltıldı
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.3), Theme.of(context).colorScheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // İçine bir şeyler eklemek görsel olarak daha iyi olabilir (örneğin ders kodu).
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  c['code'] ?? '',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w300),
                ),
              ),
            ),
          ),
          // details + button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Denge için alt padding artırıldı
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // details column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c['code']} - ${c['name']}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${c['faculty']} - ${c['department']}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(c['branch'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                  ],
                ),
                // İşlemler button
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<int>(
                    tooltip: 'İşlemler',
                    onSelected: (value) => _handlePopupMenuSelection(value, c, index),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 0, child: ListTile(leading: Icon(Icons.play_arrow), title: Text('Dersi Başlat'))),
                      PopupMenuItem(value: 1, child: ListTile(leading: Icon(Icons.edit), title: Text('Düzenle'))),
                      PopupMenuItem(value: 2, child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Sil', style: TextStyle(color: Colors.red))))
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.more_horiz, color: Colors.white), SizedBox(width: 6), Text('İşlemler', style: TextStyle(color: Colors.white))]),
                    ),
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