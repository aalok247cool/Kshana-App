import 'package:flutter/material.dart';

class KshanaPayPage extends StatelessWidget {
  const KshanaPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kshana Pay'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Welcome to Kshana Pay!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
