import 'package:flutter/material.dart';

class OrderFoodPage extends StatelessWidget {
  const OrderFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text("Order Food"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Order Food from all the major online food industries like Zomato, Swiggy, etc.",
          style: TextStyle(color: Colors.amber, fontSize: 20),
        ),
      ),
    );
  }
}
