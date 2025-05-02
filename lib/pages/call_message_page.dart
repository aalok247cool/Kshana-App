import 'package:flutter/material.dart';







class CallMessagePage extends StatelessWidget {
  const CallMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text("Call & Message"),
        centerTitle: true,
      ),
      body: Center(
        child:Text(
          "Call and message other Kshana app users directly within the app.",  // Directly writing the text
          style: TextStyle(color: Colors.amber, fontSize: 20),
        ),

      ),
    );
  }
}
