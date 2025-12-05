import 'package:flutter/material.dart';
import 'student_qr_scan_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  final String studentEmail;
  const StudentHomeScreen({Key? key, required this.studentEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Paneli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Çıkış',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Çıkış onayı'),
                  content: const Text(
                    'Beni Hatırla seçeneğiniz sıfırlanacaktır. Çıkmak istediğinize emin misiniz?',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Onayla')),
                  ],
                ),
              );
              if (ok == true) Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Hoş geldiniz', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(studentEmail, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StudentQrScanScreen(studentEmail: studentEmail),
                    ));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Derse Katıl'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// DEPRECATED: This file was replaced by `student_qr_scan_screen.dart` and
// `scan_result_screen.dart`. Keeping an empty placeholder to avoid
// accidental imports elsewhere. You can safely delete this file locally
// if your environment allows file removals.

// (Intentionally empty)
