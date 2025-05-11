// File: lib/pages/payment_success_page.dart

import 'package:flutter/material.dart';
import 'dart:async';

class PaymentSuccessPage extends StatefulWidget {
  final String amount;
  final String recipient;
  final int coinsEarned;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.recipient,
    required this.coinsEarned,
  });

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    // Stop confetti after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });

    // Go back to previous screen after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₹${widget.amount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Paid to: ${widget.recipient}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '+${widget.coinsEarned} Coins Earned!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to Kshana Pay',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ConfettiPainter(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 100; i++) {
      final color = [
        Colors.amber,
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
      ][(random + i) % 6];

      paint.color = color;

      final x = (random + i * 5) % size.width;
      final y = ((random + i * 7) % size.height) * ((random + i) % 10) / 10;

      final rect = Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        5,
        10,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
