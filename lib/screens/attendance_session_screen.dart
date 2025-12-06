import 'dart:async';
import 'package:flutter/material.dart';

class AttendanceSessionScreen extends StatefulWidget {
  final Map<String, String> course;
  final int durationMinutes;
  final String? sessionCode;
  // Key kullanımı için 'use_super_parameters' yerine doğrudan 'super.key'
  const AttendanceSessionScreen({super.key, required this.course, required this.durationMinutes, this.sessionCode});

  @override
  State<AttendanceSessionScreen> createState() => _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState extends State<AttendanceSessionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  // Durum Yönetimi: Timer'ın çalışıp çalışmadığını temsil eder
  bool _isRunning = true; 

  // Veri Modeli İyileştirmesi: 'excused' (izinli) durumu için bir Map elemanı eklenmediğinden 
  // listeye bir öğrenci eklenip bu durum test edildi.
  final List<Map<String, String>> _students = [
    {'name': 'Ayşe Yılmaz', 'status': 'present', 'time': ''},
    {'name': 'Ahmet Kaya', 'status': 'present', 'time': ''},
    {'name': 'Zeynep Öztürk', 'status': 'absent', 'time': ''},
    {'name': 'Caner Demir', 'status': 'excused', 'time': 'İzinli'}, // İzinli durumu için örnek
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;

    // Defer initialization that may run synchronous work until after
    // the first frame is rendered. This avoids blocking UI when the
    // route is pushed from a menu or dialog.
    // ignore: avoid_print
    print('AttendanceSessionScreen.initState start for ${widget.course['code']}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // run initialization asynchronously after first frame so transition won't jank
      try {
        // ignore: avoid_print
        print('AttendanceSessionScreen.postFrameCallback: calling _initStudentTimes');
        _initStudentTimes();
        // ignore: avoid_print
        print('AttendanceSessionScreen.postFrameCallback: _initStudentTimes completed');

        // Start timer after init
        // ignore: avoid_print
        print('AttendanceSessionScreen.postFrameCallback: starting timer');
        _startTimer();
        // ignore: avoid_print
        print('AttendanceSessionScreen.postFrameCallback: _startTimer scheduled');
      } catch (e, st) {
        // If anything unexpected occurs, report to console but don't crash UI
        // ignore: avoid_print
        print('Error during attendance init: $e\n$st');
      }
    });
  }

  void _initStudentTimes() {
    // ignore: avoid_print
    print('_initStudentTimes: initializing ${_students.length} students');
    for (final s in _students) {
      if (s['status'] == 'present' && (s['time'] ?? '').isEmpty) {
        final now = DateTime.now();
        s['time'] = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }
    }
    // ignore: avoid_print
    print('_initStudentTimes: completed');
  }

  void _startTimer() {
    _timer?.cancel();
    // ignore: avoid_print
    print('_startTimer: starting timer with _remainingSeconds=$_remainingSeconds');
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // ÖNEMLİ İYİLEŞTİRME: Eğer _isRunning false ise, setState çağrısı YAPILMAZ.
      // Bu, Timer'ın hala çalışırken (periodic olduğu için) gereksiz setState çağrılarını engeller.
      if (!_isRunning) return; 

      if (_remainingSeconds <= 0) {
        t.cancel();
        _onFinished();
        return;
      }
      // Küçük bir durum kontrolü: Eğer uygulama arka plana alınırsa bu değer negatif olabilir.
      if (mounted) {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _onFinished() {
    // `mounted` kontrolü, Widget Tree'de olup olmadığımızı kontrol eder.
    if (mounted) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yoklama süresi doldu.')));
      // ignore: avoid_print
      print('_onFinished: attendance finished, popping with true');
      // Opsiyonel: Bitişte pop edilebilir
      Navigator.of(context).pop(true);
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    // Dakika, 9999 dakikadan fazlaysa (yaklaşık 166 saat) göstermek için
    if (seconds >= 360000) return 'Çok Uzun Süre';
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fonksiyon: Yoklama durumunu günceller.
  void _updateAttendanceStatus(Map<String, String> student, String newStatus) {
    if (mounted) {
      setState(() {
        student['status'] = newStatus;
        if (newStatus == 'present') {
          final now = DateTime.now();
          student['time'] = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        } else if (newStatus == 'excused') {
          student['time'] = 'İzinli'; // 'excused' için özel zaman etiketi
        } else {
          student['time'] = '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sayaçları build metodu içinde hesaplamak doğru yaklaşımdır.
    final int presentCount = _students.where((s) => s['status'] == 'present').length;
    final int absentCount = _students.where((s) => s['status'] == 'absent').length;
    final int excusedCount = _students.where((s) => s['status'] == 'excused').length;
    final courseTitle = '${widget.course['code'] ?? ''} - ${widget.course['name'] ?? ''}';
    
    // Sayaç durumuna göre arka plan rengini ayarlama: Kırmızıya doğru geçiş
    final double timeRatio = (_remainingSeconds / (widget.durationMinutes * 60)).clamp(0.0, 1.0);
    final Color headerColor = Color.lerp(Colors.red.shade400, Colors.green.shade600, timeRatio)!;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoklama Durumu'),
        centerTitle: true,
        // Bitir/İptal için onay dialog'u eklemek kullanıcı deneyimini artırır.
        leading: BackButton(onPressed: () => _showEndConfirmationDialog(context)),
      ),
      body: Column(
        children: [
          // Başlık ve Geri Sayım Alanı
          _buildHeader(context, courseTitle, headerColor, presentCount, absentCount, excusedCount),
          
          const SizedBox(height: 12),
          
          // Kontrol Butonları (Durdur/Devam Et ve Bitir)
          _buildControlButtons(context),

          const SizedBox(height: 12),

          // Öğrenci Listesi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding artırıldı
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                // ÖNEMLİ İYİLEŞTİRME: Öğrenci listesini alfabetik veya duruma göre sıralamak
                // (örneğin gelmeyenler üste) takip kolaylığı sağlar.
                itemCount: _students.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = _students[i];
                  return _buildStudentCard(context, s);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // *** Alt Widget/Fonksiyonlar ***

  Widget _buildHeader(BuildContext context, String title, Color color, int present, int absent, int excused) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Kalan süreye göre renk geçişi (daha az süre = daha kırmızı)
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [color.withOpacity(0.8), color], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (widget.sessionCode != null) ...[
            Row(
              children: [
                const Text('Oturum Kodu: ', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                SelectableText(widget.sessionCode!, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              // Sayacın görünürlüğü artırıldı
              _buildCountChip('Geldi: $present', Colors.green.shade700),
              const SizedBox(width: 8),
              _buildCountChip('Gelmedi: $absent', Colors.red.shade700),
              const SizedBox(width: 8),
              _buildCountChip('İzinli: $excused', Colors.blue.shade700),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Kalan süre', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(_formatTime(_remainingSeconds), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.8),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              // Buton tipine göre renk ve ikon ayarlandı
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.orange.shade800 : Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  _isRunning = !_isRunning;
                  if (_isRunning) _startTimer();
                });
              },
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(_isRunning ? 'DURDUR' : 'DEVAM ETTİR', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _showEndConfirmationDialog(context),
            icon: const Icon(Icons.stop),
            label: const Text('BİTİR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, String> s) {
    final status = s['status'];
    Color statusColor = status == 'present'
        ? Colors.green.shade600
        : (status == 'absent' ? Colors.red.shade600 : Colors.blue.shade600);

    // Listeyi daha okunaklı yapmak için Card yerine ListTile veya Container kullanımı
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        // Duruma göre solda ince bir çizgi eklendi
        border: Border(left: BorderSide(color: statusColor, width: 6)),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          // Avatar: Arka planı duruma göre renklendirme
          CircleAvatar(
            radius: 22,
            // ignore: deprecated_member_use
            backgroundColor: statusColor.withOpacity(0.15),
            foregroundColor: statusColor,
            child: Text((s['name'] ?? '?')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  // İzinli durumu için de metin eklendi
                  status == 'present' ? 'Geldi: ${s['time'] ?? '-'}' : (status == 'absent' ? 'Gelmedi' : 'İzinli: ${s['time']}'),
                  style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Durum butonları
          _buildStatusIconButton(Icons.check_circle, 'present', s, Colors.green),
          _buildStatusIconButton(Icons.cancel, 'absent', s, Colors.red),
          _buildStatusIconButton(Icons.info, 'excused', s, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatusIconButton(IconData icon, String statusValue, Map<String, String> student, Color activeColor) {
    final isActive = student['status'] == statusValue;
    return IconButton(
      onPressed: () => _updateAttendanceStatus(student, statusValue),
      icon: Icon(
        icon,
        color: isActive ? activeColor : Colors.grey.shade300,
      ),
      tooltip: statusValue == 'present' ? 'Geldi Olarak İşaretle' : (statusValue == 'absent' ? 'Gelmedi Olarak İşaretle' : 'İzinli Olarak İşaretle'),
    );
  }

  // ** Geri / Bitir Dialogu **
  Future<void> _showEndConfirmationDialog(BuildContext context) async {
    final bool? shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Yoklamayı Bitir'),
        content: Text('Yoklama süresini bitirmek istediğinizden emin misiniz? (${_formatTime(_remainingSeconds)} süre kaldı)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(dctx).pop(true),
            child: const Text('Bitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      _timer?.cancel();
      // false ile geri dönmek, oturumun tamamlanmadığı anlamına gelir.
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(false); 
    }
  }
}