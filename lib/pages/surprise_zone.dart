import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SurpriseZonePage extends StatefulWidget {
  // Add these parameters to match what main.dart expects
  final int currentCoins;
  final Function(int) onCoinsEarned;

  // Constructor with required parameters
  const SurpriseZonePage({super.key, 
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  _SurpriseZonePageState createState() => _SurpriseZonePageState();
}

class _SurpriseZonePageState extends State<SurpriseZonePage> with SingleTickerProviderStateMixin {
  late int _coinBalance;
  bool _hasDailyFreeSpin = true;
  bool _isWheelSpinning = false;
  final int _spinCost = 100;
  double _spinAngle = 0.0;
  final List<String> _prizes = ['10 Coins', '20 Coins', '50 Coins', '100 Coins', '500 Coins', 'Better Luck', '200 Coins', 'Better Luck'];
  String _lastPrize = '';
  late AnimationController _animationController;

  // For lucky draw
  bool _hasEnteredLuckyDraw = false;
  final int _luckyDrawEntryCost = 50; // 50 coins or Rs 1
  int _luckyDrawEntries = 0;
  final DateTime _drawDate = DateTime(2025, 5, 31); // Example - end of month

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoins; // Initialize with the current coins from main
    _checkDailyFreeSpin();
    _checkLuckyDrawEntry();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleSpinResult();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkDailyFreeSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final String lastSpinDate = prefs.getString('lastSpinDate') ?? '';
    final String today = DateTime.now().toString().split(' ')[0];

    setState(() {
      _hasDailyFreeSpin = lastSpinDate != today;
    });
  }

  Future<void> _checkLuckyDrawEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final String entryDate = prefs.getString('luckyDrawEntryDate') ?? '';
    final String today = DateTime.now().toString().split(' ')[0];

    setState(() {
      _hasEnteredLuckyDraw = entryDate == today;
      _luckyDrawEntries = prefs.getInt('luckyDrawEntries') ?? 0;
    });
  }

  Future<void> _markFreeSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];
    await prefs.setString('lastSpinDate', today);

    setState(() {
      _hasDailyFreeSpin = false;
    });
  }

  Future<void> _enterLuckyDraw() async {
    if (_coinBalance < _luckyDrawEntryCost) {
      _showInsufficientCoinsDialog();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];

    // Update coin balance - use the callback to inform main.dart
    setState(() {
      _coinBalance -= _luckyDrawEntryCost;
      _hasEnteredLuckyDraw = true;
      _luckyDrawEntries++;
    });

    // Use negative value to reduce coins in the main app
    widget.onCoinsEarned(-_luckyDrawEntryCost);

    // Save state
    await prefs.setString('luckyDrawEntryDate', today);
    await prefs.setInt('luckyDrawEntries', _luckyDrawEntries);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have entered the monthly lucky draw!')),
    );
  }

  void _spinWheel() {
    if (_isWheelSpinning) return;

    if (!_hasDailyFreeSpin && _coinBalance < _spinCost) {
      _showInsufficientCoinsDialog();
      return;
    }

    setState(() {
      _isWheelSpinning = true;
      if (!_hasDailyFreeSpin) {
        _coinBalance -= _spinCost;
        // Notify main.dart about the spent coins
        widget.onCoinsEarned(-_spinCost);
      }
    });

    // Calculate random spin angle (2 to 10 full rotations plus random position)
    final random = math.Random();
    final double spins = 2 + random.nextDouble() * 8; // Between 2-10 spins
    final double angle = spins * 2 * math.pi + (random.nextDouble() * 2 * math.pi);

    // Use animation controller for smooth spinning
    _animationController.reset();
    _animationController.animateTo(1.0, curve: Curves.easeOutExpo);

    // Animate to final angle
    _spinAngle = angle;

    // Mark free spin as used if applicable
    if (_hasDailyFreeSpin) {
      _markFreeSpin();
    }
  }

  void _handleSpinResult() {
    // Calculate which prize was won based on the final angle
    final int segmentCount = _prizes.length;
    final double segmentAngle = 2 * math.pi / segmentCount;

    // Normalize the angle to 0-2π
    final double normalizedAngle = _spinAngle % (2 * math.pi);

    // Calculate the winning segment index
    final int segmentIndex = (normalizedAngle / segmentAngle).floor();
    final String prize = _prizes[segmentIndex % segmentCount];

    setState(() {
      _lastPrize = prize;
      _isWheelSpinning = false;

      // Award coins if applicable
      if (prize.contains('Coins')) {
        final int coins = int.parse(prize.split(' ')[0]);
        _coinBalance += coins;

        // Notify main.dart about the earned coins
        widget.onCoinsEarned(coins);
      }
    });

    _showPrizeDialog(prize);
  }

  void _showPrizeDialog(String prize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You won: $prize'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Claim'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Insufficient Coins'),
        content: Text('You don\'t have enough coins for this action.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  int _daysUntilDraw() {
    final now = DateTime.now();
    return _drawDate.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surprise Zone'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 4),
                Text('$_coinBalance', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lucky Draw Section
              _buildLuckyDrawSection(),

              SizedBox(height: 24),

              // Spinning Wheel Section
              _buildSpinningWheelSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuckyDrawSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Lucky Draw',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Prize info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Grand Prizes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildPrizeRow('1st Prize', '₹10,000'),
                  _buildPrizeRow('2nd Prize', '₹5,000'),
                  _buildPrizeRow('3rd Prize', '₹2,000'),
                  _buildPrizeRow('4th-10th', '₹500 each'),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Draw info
            Row(
              children: [
                Icon(Icons.event, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Draw Date: ${_drawDate.day}/${_drawDate.month}/${_drawDate.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Days Left: ${_daysUntilDraw()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.confirmation_number, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Your Entries: $_luckyDrawEntries',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Entry button
            ElevatedButton(
              onPressed: _hasEnteredLuckyDraw ? null : _enterLuckyDraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _hasEnteredLuckyDraw
                    ? 'Already Entered Today'
                    : 'Enter Lucky Draw (₹1 or $_luckyDrawEntryCost coins)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeRow(String place, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(place),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinningWheelSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spin & Win',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Wheel of fortune
            Center(
              child: SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning wheel
                    Transform.rotate(
                      angle: _spinAngle * _animationController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          size: Size(280, 280),
                          painter: WheelPainter(_prizes),
                        ),
                      ),
                    ),

                    // Center point
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),

                    // Pointer
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Spin button
            Center(
              child: ElevatedButton(
                onPressed: _isWheelSpinning ? null : _spinWheel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _hasDailyFreeSpin
                      ? 'Free Spin (1/day)'
                      : 'Spin ($_spinCost coins)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Last result
            if (_lastPrize.isNotEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Last spin: $_lastPrize',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the wheel
class WheelPainter extends CustomPainter {
  final List<String> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final int segments = prizes.length;
    final double sweepAngle = 2 * math.pi / segments;

    for (int i = 0; i < segments; i++) {
      // Alternate colors
      if (i % 2 == 0) {
        paint.color = Colors.orange[300]!;
      } else {
        paint.color = Colors.purple[300]!;
      }

      final double startAngle = i * sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw text
      final double textAngle = startAngle + (sweepAngle / 2);
      final double textX = centerX + (radius * 0.6) * math.cos(textAngle);
      final double textY = centerY + (radius * 0.6) * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}