import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';

void main() async {
  // Required to interact with the engine before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 1 Requirement: Lock in Landscape for max "real estate" [cite: 53, 59]
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ZoomerApp());
}

class ZoomerApp extends StatelessWidget {
  const ZoomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoomer',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Pure Black for OLED
      ),

      // We start on the Input Screen to create our "Visual Shout" [cite: 7]
    );
  }
}
