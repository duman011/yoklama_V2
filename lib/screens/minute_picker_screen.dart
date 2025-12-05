import 'package:flutter/material.dart';
import '../widgets/minute_clock_picker.dart';

class MinutePickerScreen extends StatefulWidget {
  final int initialMinutes;
  const MinutePickerScreen({super.key, this.initialMinutes = 30});

  @override
  State<MinutePickerScreen> createState() => _MinutePickerScreenState();
}

class _MinutePickerScreenState extends State<MinutePickerScreen> {
  late int _selected;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMinutes;
    _controller = TextEditingController(text: _selected.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Süre seçin')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dakika'),
                onChanged: (s) {
                  final v = int.tryParse(s) ?? _selected;
                  final clamped = v.clamp(1, 999);
                  setState(() => _selected = clamped);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: MinuteClockPicker(
                    initialMinutes: _selected,
                    onChanged: (m) {
                      setState(() {
                        _selected = m;
                        _controller.text = m.toString();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop<int?>(null),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop<int>(_selected),
                      child: const Text('Başlat'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
