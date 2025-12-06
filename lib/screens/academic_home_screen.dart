import 'package:flutter/material.dart';
import 'classroom_form_screen.dart';
import 'attendance_session_screen.dart';
import 'minute_picker_screen.dart';
// minute_clock_picker widget'ının hala gerekli olduğunu varsayıyoruz
 

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
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final c = _courses[index];
                  // `index` yerine closure _tarafından yakalanan `index` kullanılır.
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
      // Use a full-screen route for minute selection to avoid dialog/menu contention.
      final minutes = await Navigator.of(context).push<int?>(
        MaterialPageRoute(builder: (_) => MinutePickerScreen(initialMinutes: selected)),
      );

      if (minutes == null) return;

        // Generate a temporary 8-character alphanumeric session code (simulate backend)
        final sessionCode = _generateSessionCode();

        // Show the session code to the user before starting the attendance.
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dctx) => AlertDialog(
            title: const Text('Yoklama Kodu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Dersi başlattınız. Aşağıdaki 8 haneli kod öğrencilerle paylaşılacak:'),
                const SizedBox(height: 12),
                SelectableText(sessionCode, style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 2.0)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Tamam')),
            ],
          ),
        );

        Navigator.of(context, rootNavigator: true).push<bool>(
          MaterialPageRoute(builder: (_) => AttendanceSessionScreen(course: course, durationMinutes: minutes, sessionCode: sessionCode)),
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

  // The minute picker dialog helper was replaced by a full-screen
  // `MinutePickerScreen` to avoid showing a dialog while the popup menu
  // is closing (this avoids UI contention that can cause freezes on some devices).

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
                // ignore: deprecated_member_use
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

  // Helper to create a random 8-character alphanumeric session code.
  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch % 100000;
    final buf = StringBuffer();
    var seed = rnd;
    for (var i = 0; i < 8; i++) {
      seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
      buf.write(chars[seed % chars.length]);
    }
    return buf.toString();
  }
}