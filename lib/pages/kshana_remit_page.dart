import 'package:flutter/material.dart';

class KshanaRemitPage extends StatelessWidget {
  const KshanaRemitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kshana Remit'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: const Center(
        child: Text(
          'Welcome to Kshana Remit!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
