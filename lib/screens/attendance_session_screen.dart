import 'dart:async';
import 'package:flutter/material.dart';

class AttendanceSessionScreen extends StatefulWidget {
  final Map<String, String> course;
  final int durationMinutes;
  const AttendanceSessionScreen({Key? key, required this.course, required this.durationMinutes}) : super(key: key);

  @override
  State<AttendanceSessionScreen> createState() => _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState extends State<AttendanceSessionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _running = true;

  final List<Map<String, String>> _students = [
    {'name': 'Ayşe Yılmaz', 'status': 'present'},
    {'name': 'Ahmet Kaya', 'status': 'present'},
    {'name': 'Zeynep Öztürk', 'status': 'absent'},
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_running) return;
      if (_remainingSeconds <= 0) {
        t.cancel();
        _onFinished();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _onFinished() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yoklama süresi doldu.')));
    // Optionally pop with true to mark finished
    Navigator.of(context).pop(true);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseTitle = '${widget.course['code'] ?? ''} - ${widget.course['name'] ?? ''}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoklama Durumu'),
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.of(context).pop(false)),
      ),
      body: Column(
        children: [
          // Green header with countdown
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade300, Colors.green.shade600]),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kalan süre', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    Text(_formatTime(_remainingSeconds), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _running = !_running;
                        if (_running) _startTimer();
                      });
                    },
                    child: Text(_running ? 'Durdur' : 'Devam Ettir'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Bitir'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Student list (reusing AttendanceScreen style)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = _students[i];
                  final status = s['status'];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 22, child: Text((s['name'] ?? '?')[0])),
                          const SizedBox(width: 12),
                          Expanded(child: Text(s['name'] ?? '')), 
                          IconButton(onPressed: () => setState(() => s['status'] = 'present'), icon: Icon(Icons.check_circle, color: status == 'present' ? Colors.green : Colors.grey)),
                          IconButton(onPressed: () => setState(() => s['status'] = 'absent'), icon: Icon(Icons.cancel, color: status == 'absent' ? Colors.red : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
