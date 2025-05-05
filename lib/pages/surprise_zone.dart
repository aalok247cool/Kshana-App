import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SurpriseZonePage extends StatefulWidget {
  // Parameters required for coin management
  final int currentCoins;
  final Function(int) onCoinsEarned;

  // Constructor with required parameters
  const SurpriseZonePage({
    super.key,
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  _SurpriseZonePageState createState() => _SurpriseZonePageState();
}

class _SurpriseZonePageState extends State<SurpriseZonePage> {
  // For lucky draw
  bool _hasEnteredLuckyDraw = false;
  final int _luckyDrawEntryCost = 100; // Changed from 50 to 100 coins
  int _luckyDrawEntries = 0;
  final DateTime _drawDate = DateTime(2025, 5, 31); // Example - end of month

  @override
  void initState() {
    super.initState();
    print("SURPRISE ZONE: Initializing with coins from main: ${widget.currentCoins}");
    _checkLuckyDrawEntry();
  }

  // Helper method to update coins in the parent
  void _updateCoins(int amount) {
    print("SURPRISE ZONE: Updating coins by $amount. Main dashboard coins: ${widget.currentCoins}");

    // Notify main.dart about the coin change
    widget.onCoinsEarned(amount);

    print("SURPRISE ZONE: Coin update sent to main dashboard");
  }

  Future<void> _checkLuckyDrawEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final String entryDate = prefs.getString('luckyDrawEntryDate') ?? '';
    final String today = DateTime.now().toString().split(' ')[0];

    setState(() {
      _hasEnteredLuckyDraw = entryDate == today;
      _luckyDrawEntries = prefs.getInt('luckyDrawEntries') ?? 0;
    });

    print("SURPRISE ZONE: Has entered lucky draw today: $_hasEnteredLuckyDraw");
    print("SURPRISE ZONE: Lucky draw entries: $_luckyDrawEntries");
  }

  Future<void> _enterLuckyDraw() async {
    print("SURPRISE ZONE: Attempting to enter lucky draw");
    print("SURPRISE ZONE: Main dashboard coins: ${widget.currentCoins}, Entry cost: $_luckyDrawEntryCost");

    if (widget.currentCoins < _luckyDrawEntryCost) {
      _showInsufficientCoinsDialog();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];

    // Update coin balance using the centralized method
    _updateCoins(-_luckyDrawEntryCost);

    setState(() {
      _hasEnteredLuckyDraw = true;
      _luckyDrawEntries++;
    });

    // Save entry state
    await prefs.setString('luckyDrawEntryDate', today);
    await prefs.setInt('luckyDrawEntries', _luckyDrawEntries);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have entered the monthly lucky draw!'),
        backgroundColor: Colors.amber.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );

    print("SURPRISE ZONE: Entered lucky draw. Entries now: $_luckyDrawEntries");
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red, width: 2),
        ),
        title: Text(
          'Insufficient Coins',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You don\'t have enough coins for this action.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.amber),
            ),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Surprise Zone',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lucky Draw Section
                _buildLuckyDrawSection(),

                // Information Section about Surprise Zone
                SizedBox(height: 24),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 8,
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'About Surprise Zone',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'The Surprise Zone is where you can participate in exciting events and win big rewards!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Enter our monthly lucky draw for a chance to win real cash prizes. The more entries you have, the better your chances!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Keep an eye out for special events and limited-time offers that will appear in this zone.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyDrawSection() {
    return Card(
      elevation: 8,
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Monthly Lucky Draw',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),


              // Prize info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.1),
                      Colors.amber.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Grand Prizes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Draw Date: ${_drawDate.day}/${_drawDate.month}/${_drawDate.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.hourglass_top, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Days Left: ${_daysUntilDraw()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Your Entries: $_luckyDrawEntries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Your Coins: ${widget.currentCoins}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),



              // Entry button
              ElevatedButton(
                onPressed: _hasEnteredLuckyDraw ? null : _enterLuckyDraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasEnteredLuckyDraw ? Colors.grey : Colors.amber,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade700,
                  disabledForegroundColor: Colors.grey.shade300,
                  elevation: _hasEnteredLuckyDraw ? 0 : 8,
                  shadowColor: Colors.amber.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildPrizeRow(String place, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(place, style: TextStyle(color: Colors.white70)),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}