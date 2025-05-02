import 'package:flutter/material.dart';

class KshanaSecurePage extends StatelessWidget {
  const KshanaSecurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kshana Secure'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.cyan,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Kshana Secure!\nFeature Coming Soon...',
          style: TextStyle(color: Colors.cyan, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
