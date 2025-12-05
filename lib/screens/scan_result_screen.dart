import 'package:flutter/material.dart';
import 'student_home_screen.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, String> details;
  const ScanResultScreen({Key? key, required this.details}) : super(key: key);

  Widget _chip(BuildContext context, String text) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(color: Colors.green[900])),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yoklama Başarılı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text('✓ Yoklama Başarıyla Alındı!', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('Ders Detayları', style: Theme.of(context).textTheme.titleMedium)),
                      const SizedBox(height: 12),
                      _chip(context, details['courseName'] ?? ''),
                      _chip(context, details['course'] ?? ''),
                      _chip(context, details['time'] ?? ''),
                      _chip(context, details['branch'] ?? ''),
                      _chip(context, details['faculty'] ?? ''),
                      _chip(context, details['department'] ?? ''),
                      _chip(context, details['program'] ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Return to student home screen
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => StudentHomeScreen(studentEmail: details['studentEmail'] ?? ''),
                  ));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Yeni Yoklama Tara'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
