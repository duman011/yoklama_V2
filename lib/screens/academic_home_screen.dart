import 'package:flutter/material.dart';
import 'classroom_form_screen.dart';
import 'attendance_session_screen.dart';
import '../widgets/minute_clock_picker.dart';

class AcademicHomeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const AcademicHomeScreen({Key? key}) : super(key: key);

  @override
  State<AcademicHomeScreen> createState() => _AcademicHomeScreenState();
}

class _AcademicHomeScreenState extends State<AcademicHomeScreen> {
  final List<Map<String, String>> _courses = [
    {
      'code': 'EDS101',
      'name': 'Eğitim Sosyolojisi',
      'faculty': 'Sağlık Bilimleri Fakültesi',
      'department': 'Çocuk Gelişimi',
      'branch': 'Şube: 1 - Örgün Eğitim',
      'image': 'linear-gradient',
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
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(builder: (_) => const ClassroomFormScreen()),
    );
    if (result != null) {
      // API would return success; currently assume true and add course
      setState(() {
        _courses.insert(0, {
          'code': result['code'] ?? 'YENI',
          'name': result['name'] ?? 'Yeni Ders',
          'faculty': result['faculty'] ?? '',
          'department': result['department'] ?? '',
          'branch': result['branch'] ?? '',
          'image': 'linear-gradient',
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
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: ListView.separated(
          itemCount: _courses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final c = _courses[index];
            return _buildCourseCard(context, c, index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateCourse,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, String> c, int index) {
    final idx = index;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: Column(
        children: [
          // image / gradient area
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.3), Theme.of(context).colorScheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // details + button (button placed after details to avoid overlap)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                // place the işlemler button after details so it doesn't overlap text
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        builder: (ctx) => SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                            child: Wrap(
                              children: [
                                ListTile(
  leading: const Icon(Icons.play_arrow),
  title: const Text('Dersi Başlat'),
  onTap: () async {
    // Close the bottom sheet first
    Navigator.of(ctx).pop();

    // Ask the user for duration in minutes using a circular minute-picker UI
    final minutes = await showDialog<int>(
      context: context,
      builder: (dctx) {
        int selected = 30;
        final mq = MediaQuery.of(dctx);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          contentPadding: const EdgeInsets.all(12),
          title: const Text('Süre seçin (dakika)'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mq.size.height * 0.65, maxWidth: mq.size.width * 0.95),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      width: mq.size.width * 0.85,
                      child: StatefulBuilder(builder: (ctx, setSt) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: MinuteClockPicker(
                                initialMinutes: selected,
                                onChanged: (m) => setSt(() => selected = m),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Seçili: ', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(width: 6),
                                Text('\$selected dk', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('İptal')),
            ElevatedButton(onPressed: () => Navigator.of(dctx).pop(selected), child: const Text('Başlat')),
          ],
        );
      },
    );

    if (minutes == null) return; // cancelled

    // Open the attendance session screen with given duration
    Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => AttendanceSessionScreen(course: c, durationMinutes: minutes),
      ),
    ).then((finished) {
      if (finished == true && mounted) {
        setState(() {
          _courses[idx] = {
            ..._courses[idx],
            'status': 'finished',
          };
        });
      }
    });
  },
),
                                ListTile(leading: const Icon(Icons.edit), title: const Text('Düzenle'), onTap: () async {
                                  Navigator.of(ctx).pop();
                                  final edited = await Navigator.of(context).push<Map<String, String?>>(
                                    MaterialPageRoute(builder: (_) => ClassroomFormScreen(initial: c)),
                                  );
                                  if (edited != null) {
                                    // assume API returns true
                                    setState(() {
                                      _courses[idx] = {
                                        'code': edited['code'] ?? c['code']!,
                                        'name': edited['name'] ?? c['name']!,
                                        'faculty': edited['faculty'] ?? c['faculty']!,
                                        'department': edited['department'] ?? c['department']!,
                                        'branch': edited['branch'] ?? c['branch']!,
                                        'image': c['image']!,
                                      };
                                    });
                                  }
                                }),
                                ListTile(leading: const Icon(Icons.delete), title: const Text('Sil'), onTap: () async {
                                  Navigator.of(ctx).pop();
                                  // simulate API delete
                                  final ok = await Future.delayed(const Duration(milliseconds: 400), () => true);
                                  if (ok) {
                                    setState(() => _courses.removeAt(idx));
                                  }
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.more_horiz),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                      child: Text('İşlemler'),
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
