import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SurprizeZone extends StatefulWidget {
  final int coinBalance;

  const SurprizeZone({super.key, required this.coinBalance});

  @override
  _SurprizeZoneState createState() => _SurprizeZoneState();
}

class _SurprizeZoneState extends State<SurprizeZone> {
  int _investedCoins = 0;
  bool _hasInvestedToday = false;
  String _nextDrawDate = "";
  final List<Map<String, dynamic>> _prizesList = [
    {"rank": "1st", "prize": "₹10,000", "icon": Icons.emoji_events},
    {"rank": "2nd", "prize": "₹5,000", "icon": Icons.card_giftcard},
    {"rank": "3rd", "prize": "₹2,000", "icon": Icons.redeem},
    {"rank": "4th-10th", "prize": "₹500", "icon": Icons.monetization_on},
  ];

  @override
  void initState() {
    super.initState();
    _loadInvestedData();
    _calculateNextDrawDate();
    _initializeMainBalance(); // Add this line
  }

// Add this new method
  Future<void> _initializeMainBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('mainCoinBalance')) {
      await prefs.setInt('mainCoinBalance', widget.coinBalance);
    }
  }

  Future<void> _loadInvestedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _investedCoins = prefs.getInt('investedCoins') ?? 0;
      _hasInvestedToday = prefs.getBool('investedToday_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}') ?? false;

      // Temporarily remove this for testing
      _hasInvestedToday = false;
    });
  }

  Future<void> _saveInvestedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('investedCoins', _investedCoins);
    await prefs.setBool('investedToday_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}', true);
  }

  void _calculateNextDrawDate() {
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastDayOfMonth = DateTime(nextMonth.year, nextMonth.month, 0);

    setState(() {
      _nextDrawDate = "${lastDayOfMonth.day}/${lastDayOfMonth.month}/${lastDayOfMonth.year}";
    });
  }

  void _investCoins() async {
    if (_hasInvestedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already invested for today!'))
      );
      return;
    }

    if (widget.coinBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough coins! You need 100 coins to invest.'))
      );
      return;
    }

    setState(() {
      _investedCoins += 100;
      _hasInvestedToday = true;
    });

    await _saveInvestedData();

    // Get the true current balance
    final prefs = await SharedPreferences.getInstance();
    final currentBalance = prefs.getInt('coinBalance') ?? widget.coinBalance;
    final newBalance = currentBalance - 100;

    // Save it
    await prefs.setInt('coinBalance', newBalance);
    print("SAVED NEW BALANCE IN SURPRISE ZONE: $newBalance");

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully invested 100 coins for the monthly draw!'))
    );

    await Future.delayed(Duration(seconds: 1));

    // Return to previous screen with a special signal
    Navigator.pop(context, {'spent': 100, 'newBalance': newBalance});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Lucky Draw"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Monthly Lucky Winner",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ]
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Invest 100 coins daily for a chance to win big prizes!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Coin balance display
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Coin Balance:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          "${widget.coinBalance}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Invested coins and next draw info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Invested Coins:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: [
                            Icon(Icons.savings, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              "$_investedCoins",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Next Draw Date:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              _nextDrawDate,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _investCoins,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Invest 100 Coins (Testing)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prizes section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lucky Draw Prizes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _prizesList.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Icon(_prizesList[index]["icon"], color: Colors.white),
                          ),
                          title: Text(
                            "${_prizesList[index]["rank"]} Prize",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            "${_prizesList[index]["prize"]}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Rules section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          "How It Works",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildRuleText("Invest 100 coins daily to increase your chances."),
                    _buildRuleText("Each investment gives you one entry in the monthly draw."),
                    _buildRuleText("Winners are announced on the last day of each month."),
                    _buildRuleText("Prizes will be credited to your account as coins equivalent to the prize amount within 48 hours."),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}