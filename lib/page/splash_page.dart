import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 180, height: 180),
            const SizedBox(height: 24),
            const SizedBox(
              width: 180,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(minHeight: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
