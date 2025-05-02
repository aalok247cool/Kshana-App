import 'package:flutter/material.dart';

class GameZonePage extends StatelessWidget {
  const GameZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Zone')),
      body: const Center(child: Text('Welcome to Game Zone!')),
    );
  }
}
