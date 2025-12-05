import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = CurvedAnimation(parent: _ctl, curve: Curves.elasticOut);
    _ctl.forward();
    // after a delay navigate to login
    Timer(const Duration(milliseconds: 1500), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // logo (asset if bundled) - gracefully fall back to FlutterLogo
              SizedBox(
                width: 140,
                height: 140,
                child: FutureBuilder<ByteData>(
                  future: rootBundle.load('assets/images/amasya_logo.png'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return Image.memory(snapshot.data!.buffer.asUint8List(), fit: BoxFit.contain);
                    }
                    return const FlutterLogo(size: 140);
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text('Amasya Üniversitesi - Yoklama', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
