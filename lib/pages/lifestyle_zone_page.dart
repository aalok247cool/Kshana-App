import 'package:flutter/material.dart';
import 'game_zone_page.dart';
import 'online_shopping_page.dart';
import 'order_food_page.dart';
import 'tickets_page.dart';
import 'call_message_page.dart';

class LifestyleZonePage extends StatelessWidget {
  const LifestyleZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifestyle'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(context, 'Online Shopping', Icons.shopping_bag, const OnlineShoppingPage()),
          _buildFeatureCard(context, 'Order Food', Icons.fastfood, const OrderFoodPage()),
          _buildFeatureCard(context, 'Transport', Icons.directions_bus, const TicketsPage()),
          _buildFeatureCard(context, 'Game Zone', Icons.videogame_asset, const GameZonePage()),
          _buildFeatureCard(context, 'Tickets', Icons.movie, const TicketsPage()),
          _buildFeatureCard(context, 'Call & Message', Icons.chat, const CallMessagePage()),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        color: Colors.green.shade100,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
