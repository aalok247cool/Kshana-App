import 'package:flutter/material.dart';

class OnlineShoppingPage extends StatelessWidget {
  const OnlineShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text("Online Shopping"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Welcome to Online Shopping! Shop from Branded Companies.",
          style: TextStyle(color: Colors.amber, fontSize: 20),
        ),
      ),
    );
  }
}
