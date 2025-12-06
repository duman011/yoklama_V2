import 'package:flutter/material.dart';
// removed unused rootBundle import; using bundled Image.asset instead
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
              // university logo (bundled asset). Use Image.asset so it appears immediately
              // (we bundled the asset in pubspec.yaml and committed it to the repo).
              SizedBox(
                width: 140,
                height: 140,
                child: Image.asset('assets/images/amasya_logo.png', fit: BoxFit.contain),
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
