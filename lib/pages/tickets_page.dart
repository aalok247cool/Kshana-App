import 'package:flutter/material.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text("All India Transport"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Book your tickets through major transport companies like RedBus, etc.",
          style: TextStyle(color: Colors.amber, fontSize: 20),
        ),
      ),
    );
  }
}
