import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// permission_handler removed due to Android embedding compatibility issues.
import 'scan_result_screen.dart';

class StudentQrScanScreen extends StatefulWidget {
  final String studentEmail;
  const StudentQrScanScreen({Key? key, required this.studentEmail}) : super(key: key);

  @override
  State<StudentQrScanScreen> createState() => _StudentQrScanScreenState();
}

class _StudentQrScanScreenState extends State<StudentQrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasPermission = false;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    // Try to start the camera. If platform denies permission this will throw
    // or fail — we catch and show a retry UI. This avoids depending on
    // `permission_handler` which caused build errors on some environments.
    try {
      await _controller.start();
      if (!mounted) return;
      setState(() => _hasPermission = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasPermission = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          await _controller.stop();
        } catch (_) {}
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yoklama QR Okut'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              try {
                await _controller.stop();
              } catch (_) {}
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _hasPermission
            ? Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _controller,
                          onDetect: (capture) async {
                            if (_scanned) return;
                            if (capture.barcodes.isEmpty) return;
                            final code = capture.barcodes.first.rawValue;
                            if (code == null) return;
                            _scanned = true;
                            try {
                              await _controller.stop();
                            } catch (_) {}

                            // Here you would call your API to validate the scanned code.
                            // We'll simulate a successful response and pass details to result screen.
                            final details = {
                              'faculty': 'Mühendislik Fakültesi',
                              'department': 'Bilgisayar Mühendisliği',
                              'course': 'BLM301',
                              'courseName': 'Yazılım Mühendisliği',
                              'time': '10:00',
                              'branch': 'Şube A',
                              'program': 'Lisans',
                              'studentEmail': widget.studentEmail,
                            };

                            if (!mounted) return;
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (_) => ScanResultScreen(details: details)));
                          },
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Kamerayı QR koduna çevirin', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _controller.stop();
                        } catch (_) {}
                        // allow manual cancel
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('İptal'),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Kamera izni verilmedi.'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _initCamera, child: const Text('İzin İste')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
