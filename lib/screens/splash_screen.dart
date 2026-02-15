import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'input_screen.dart'; // Make sure this import matches your file name

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Since GIFs play automatically, we set a manual timer to navigate.
    // Adjust the 3500 milliseconds (3.5 seconds) to match your GIF's length.
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InputScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matches your app theme
      body: Center(
        child: Image.asset(
          'assets/animations/zoomer_splash.gif', // Your file path
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }
}
