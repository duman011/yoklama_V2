import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, String> course;
  // course parametresi zorunlu
  const AttendanceScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Örnek öğrenci listesi. Gerçek uygulamada güncel verilerle değiştirilmeli.
  // Not: setState içinde harita objelerinin kendisi güncellendiği için,
  // List<Map<String, String>> türü korunmuştur.
  final List<Map<String, String>> _students = [
    {'name': 'Ayşe Yılmaz', 'avatar': '', 'status': 'present'},
    {'name': 'Ahmet Kaya', 'avatar': '', 'status': 'present'},
    {'name': 'Zeynep Öztürk', 'avatar': '', 'status': 'absent'},
    {'name': 'Mehmet Çelik', 'avatar': '', 'status': 'excused'},
    {'name': 'Ali Veli', 'avatar': '', 'status': 'none'},
    {'name': 'null', 'avatar': '', 'status': 'absent'}, // Test için null isim
  ];

  String _query = '';
  int _selectedTab = 0; // 0: all, 1: present, 2: absent, 3: excused

  // Öğrenci listesini filtreleyen getter. Null güvenliği eklendi.
  List<Map<String, String>> get _filteredStudents {
    return _students.where((s) {
      // s['name'] null ise veya eksikse, boş bir string ('') kullan. (Null Güvenliği)
      final name = (s['name'] ?? '').toLowerCase();
      final q = _query.toLowerCase();
      
      final matchesQuery = q.isEmpty || name.contains(q);
      
      final status = s['status'];
      final matchesTab = _selectedTab == 0 ||
          (_selectedTab == 1 && status == 'present') ||
          (_selectedTab == 2 && status == 'absent') ||
          (_selectedTab == 3 && status == 'excused');
          
      return matchesQuery && matchesTab;
    }).toList();
  }

  // Durum sayıları
  int get _presentCount => _students.where((s) => s['status'] == 'present').length;
  int get _absentCount => _students.where((s) => s['status'] == 'absent').length;
  int get _excusedCount => _students.where((s) => s['status'] == 'excused').length;

  // Öğrenci durumunu güncelleyen metod
  void _setStatus(int i, String status) {
    // i, _students listesindeki orijinal indeksi temsil eder.
    setState(() {
      _students[i]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kurs bilgilerinin güvenli okunması
    final courseTitle = '${widget.course['code'] ?? ''} - ${widget.course['name'] ?? 'Bilinmiyor'}';
    final time = widget.course['time'] ?? 'Zaman Belirtilmemiş';

    return Scaffold(
      // Prevent the scaffold from resizing when the keyboard appears so
      // the bottom action bar remains fixed in place instead of being
      // pushed up into the keyboard area.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Yoklama Durumu'),
        centerTitle: true,
        // pop(false) çağrısı, yoklamanın tamamlanmadığını/iptal edildiğini belirtir.
        leading: BackButton(onPressed: () => Navigator.of(context).pop(false)), 
      ),
      body: Column(
        children: [
          // Başlık ve İstatistik Kartı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100, // Yükseklik 160'dan 100'e düşürüldü, daha sade görünüm için.
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade200, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    // İç kısım boş bırakıldı.
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseTitle, 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 6),
                        Text(
                          time, 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Geldi: $_presentCount', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('Gelmedi: $_absentCount', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('İzinli: $_excusedCount', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search), 
                hintText: 'Öğrenci ara', 
                filled: true, 
                fillColor: Colors.grey[100], 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide.none
                )
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          
          // Filtreleme Sekmeleri (SingleChildScrollView ile yatay taşma önlendi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Tümü (${_students.length})', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Geldi ($_presentCount)', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Gelmedi ($_absentCount)', 2),
                  const SizedBox(width: 8),
                  _buildTabButton('İzinli ($_excusedCount)', 3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Öğrenci Listesi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView.separated(
                // add bottom padding so the last list items are not hidden
                // behind the fixed bottom action bar when keyboard is closed
                // or when it opens.
                padding: const EdgeInsets.only(bottom: 140),
                itemCount: _filteredStudents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = _filteredStudents[i];
                  // Orijinal indeksi bulma: Durum güncellemesi için gerekli.
                  // s['name'] null olabilir, bu yüzden varsayılan değerler kullanıldı.
                  final originalIndex = _students.indexOf(s); 
                  final status = s['status'];
                  
                  // Öğrenci Adı ve Avatar Metni için Null Güvenliği
                  final studentName = s['name'] ?? '? (İsim Yok)';
                  // Eğer isim boş/yoksa '?' kullan. Aksi halde ilk harfi al.
                  final avatarText = studentName.isNotEmpty && studentName != '? (İsim Yok)' ? studentName[0] : '?'; 

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24, 
                            child: Text(avatarText) // Güvenli avatar metni
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              studentName, // Güvenli öğrenci adı
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                            )
                          ),
                          const SizedBox(width: 8),
                          
                          // Geldi butonu
                          IconButton(
                            onPressed: () => _setStatus(originalIndex, 'present'),
                            icon: Icon(Icons.check_circle, color: status == 'present' ? Colors.green : Colors.grey),
                          ),
                          // Gelmedi butonu
                          IconButton(
                            onPressed: () => _setStatus(originalIndex, 'absent'),
                            icon: Icon(Icons.cancel, color: status == 'absent' ? Colors.red : Colors.grey),
                          ),
                          // İzinli butonu
                          IconButton(
                            onPressed: () => _setStatus(originalIndex, 'excused'),
                            icon: Icon(Icons.remove_circle, color: status == 'excused' ? Colors.orange : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Note: bottom action buttons moved to Scaffold.bottomNavigationBar
        ],
      ),
      // Fixed bottom action bar: stays in place when keyboard opens.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.0)],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(onPressed: () {}, child: const Icon(Icons.person_add)),
                  const SizedBox(height: 6),
                  Text('Öğrenci Ekle', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(onPressed: () {}, backgroundColor: Colors.red.shade50, child: const Icon(Icons.error_outline, color: Colors.red)),
                  const SizedBox(height: 6),
                  Text('Yoklama Eksik', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  // pop(true) çağrısı, yoklamanın başarıyla tamamlandığını belirtir.
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yoklama Tamamla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Filtreleme Sekmesi Yapısı
  Widget _buildTabButton(String label, int idx) {
    final selected = _selectedTab == idx;
    // Expanded kaldırıldı, Row SingleChildScrollView içinde olduğu için Expanded'a gerek yok.
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.blue : Colors.transparent),
        ),
        child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.blue : Colors.black87))),
      ),
    );
  }
}