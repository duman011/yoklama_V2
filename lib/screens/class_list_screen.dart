import 'package:flutter/material.dart';

class ClassListScreen extends StatefulWidget {
  final String studentEmail;
  final bool showOnlyEnrolled;
  const ClassListScreen({super.key, required this.studentEmail, this.showOnlyEnrolled = false});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  // Sample data; replace with API data later
  final List<Map<String, String>> _allClasses = [
    { 'name': 'Matematik', 'sınıf': 'A101', 'saat': '09:00', 'attended': '3' },
    { 'name': 'Fizik', 'sınıf': 'B202', 'saat': '11:00', 'attended': '1' },
    { 'name': 'Programlama', 'sınıf': 'C303', 'saat': '14:00', 'attended': '0' },
  ];

  @override
  Widget build(BuildContext context) {
    final classes = widget.showOnlyEnrolled ? _allClasses.take(2).toList() : _allClasses;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showOnlyEnrolled ? 'Katıldığım Dersler' : 'Ders Listesi'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = classes[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ders: ${item['name']}', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text('Sınıf: ${item['sınıf']}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Saati: ${item['saat']}', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          // If this screen is showing only enrolled classes, do not offer actions.
                          if (widget.showOnlyEnrolled) 
                            Text('Katılım: ${item['attended'] ?? '0'} kez', style: Theme.of(context).textTheme.bodyMedium)
                          else
                            ElevatedButton(
                              onPressed: () => _showJoinDialog(context, item),
                              child: const Text('Yoklamaya Gir'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJoinDialog(BuildContext context, Map<String, String> lesson) {
    final TextEditingController codeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Yoklamaya Gir — ${lesson['name']}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: codeCtrl,
            maxLength: 8,
            decoration: const InputDecoration(
              labelText: 'Kod (8 haneli)',
              hintText: 'Örn: A1B2C3D4',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Kod girin';
              if (v.trim().length > 8) return 'Maksimum 8 karakter';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final code = codeCtrl.text.trim();
              Navigator.of(ctx).pop();
              await _performJoin(context, lesson, code);
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _performJoin(BuildContext context, Map<String, String> lesson, String code) async {
    // Show loading dialog while 'calling API'
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Dismiss loading
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    // For now always success — later replace with API call and real handling
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Yoklamaya girildi — Ders: ${lesson['name']} (kod: $code)')),
    );
  }
}
