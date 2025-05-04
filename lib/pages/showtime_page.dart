import 'package:flutter/material.dart';

class ShowtimePage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const ShowtimePage({
    super.key,
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  _ShowtimePageState createState() => _ShowtimePageState();
}

class _ShowtimePageState extends State<ShowtimePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Showtime'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 4),
                Text('${widget.currentCoins}', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Tickets Feature',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Example of how to use the onCoinsEarned callback
                widget.onCoinsEarned(15);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You earned 15 coins!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Test Earning Coins'),
            ),
          ],
        ),
      ),
    );
  }
}