

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/transaction_history_item.dart';

class KshanaPayPage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const KshanaPayPage({
    super.key,
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  _KshanaPayPageState createState() => _KshanaPayPageState();
}

class _KshanaPayPageState extends State<KshanaPayPage> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late TabController _tabController;
  List<Map<String, dynamic>> _recentContacts = [];
  List<Map<String, dynamic>> _transactionHistory = [];
  bool _isLoading = false;
  bool _showQrScanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecentContacts();
    _loadTransactionHistory();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentContacts() async {
    // In a real app, this would load from a database or API
    // Simulating a network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _recentContacts = [
        {
          "name": "Arun Kumar",
          "phone": "9876543210",
          "photoUrl": null,
        },
        {
          "name": "Priya Singh",
          "phone": "8765432109",
          "photoUrl": null,
        },
        {
          "name": "Rahul Sharma",
          "phone": "7654321098",
          "photoUrl": null,
        },
        {
          "name": "Sneha Patel",
          "phone": "6543210987",
          "photoUrl": null,
        },
      ];
    });
  }

  Future<void> _loadTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('transactionHistory') ?? [];

    List<Map<String, dynamic>> historyList = [];

    for (String item in history) {
      final parts = item.split('|');
      if (parts.length >= 4) {
        historyList.add({
          "name": parts[0],
          "phone": parts[1],
          "amount": parts[2],
          "date": parts[3],
          "type": parts.length > 4 ? parts[4] : "sent", // Default to "sent"
        });
      }
    }

    setState(() {
      _transactionHistory = historyList;
    });
  }

  Future<void> _saveTransaction(String name, String phone, String amount, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('transactionHistory') ?? [];

    // Current date and time
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";

    // Add new transaction to beginning of list
    history.insert(0, "$name|$phone|$amount|$dateStr|$type");

    // Keep only the last 20 transactions
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    await prefs.setStringList('transactionHistory', history);

    // Reload transaction history
    _loadTransactionHistory();
  }

  // Simulated payment processing
  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number and amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Save the transaction
    await _saveTransaction(
      "Recipient", // In a real app, you would look up the contact name
      _phoneController.text,
      _amountController.text,
      "sent",
    );

    // Award coins for completing a transaction
    widget.onCoinsEarned(25);

    setState(() {
      _isLoading = false;
      _phoneController.clear();
      _amountController.clear();
      _noteController.clear();
    });

    // Show success dialog
    _showPaymentSuccessDialog(_amountController.text, _phoneController.text);
  }

  void _showPaymentSuccessDialog(String amount, String recipient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '₹$amount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paid to: $recipient',
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '+25 Coins Earned!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _selectContact(String name, String phone) {
    setState(() {
      _phoneController.text = phone;
    });
    _tabController.animateTo(0); // Switch to pay tab
  }

  void _toggleQrScanner() {
    setState(() {
      _showQrScanner = !_showQrScanner;
    });

    if (_showQrScanner) {
      // In a real app, this would initialize the camera and scanner
      // Here we'll just simulate scanning a QR code after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showQrScanner) {
          setState(() {
            _showQrScanner = false;
            _phoneController.text = "9876543210"; // Simulated scanned value
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code scanned successfully!')),
            );
          });
        }
      });
    }
  }

  void _showBankTransferOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildBankTransferOption(
                'Transfer to Account',
                Icons.account_balance,
                    () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank transfer feature coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildBankTransferOption(
                'Self Transfer',
                Icons.person,
                    () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Self transfer feature coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildBankTransferOption(
                'Check Balance',
                Icons.account_balance_wallet,
                    () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Balance check feature coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankTransferOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber.withOpacity(0.2),
        child: Icon(icon, color: Colors.amber),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Kshana Pay',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: Icon(Icons.arrow_forward), text: 'Pay'),
            Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Pay Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade900, Colors.blue.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kshana Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/kshana_icon.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_balance_wallet, color: Colors.amber),
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                '₹10,000.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Text(
                                'Your coins: ${widget.currentCoins}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 16.0,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _showBankTransferOptions,
                                icon: const Icon(Icons.account_balance, color: Colors.white),
                                label: const Text('Bank', style: TextStyle(color: Colors.white)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(Icons.qr_code_scanner, 'Scan QR', _toggleQrScanner),
                        _buildQuickAction(Icons.document_scanner, 'Pay Bill', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bill payment feature coming soon!')),
                          );
                        }),
                        _buildQuickAction(Icons.phone_android, 'Mobile\nRecharge', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mobile recharge feature coming soon!')),
                          );
                        }),
                        _buildQuickAction(Icons.people, 'Request', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request money feature coming soon!')),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Phone Number Input
                    const Text(
                      'Pay To',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_android, color: Colors.grey),
                        hintText: 'Enter mobile number',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.contacts, color: Colors.grey),
                          onPressed: () {
                            _tabController.animateTo(1); // Switch to contacts tab
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Amount Input
                    const Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Note Input
                    const Text(
                      'Note (Optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.note, color: Colors.grey),
                        hintText: 'What\'s this for?',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Earn coins message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Earn 25 Kshana Coins for every transaction!',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contacts Tab
              _recentContacts.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _recentContacts.length,
                itemBuilder: (context, index) {
                  final contact = _recentContacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(
                        contact["name"].substring(0, 1),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(
                      contact["name"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      contact["phone"],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => _selectContact(contact["name"], contact["phone"]),
                  );
                },
              ),

              // History Tab
              _transactionHistory.isEmpty
                  ? const Center(
                child: Text(
                  'No transaction history yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactionHistory.length,
                itemBuilder: (context, index) {
                  final transaction = _transactionHistory[index];
                  return TransactionHistoryItem(
                    name: transaction["name"] ?? "Unknown",
                    phone: transaction["phone"] ?? "",
                    amount: transaction["amount"] ?? "0",
                    date: transaction["date"] ?? "",
                    type: transaction["type"] ?? "sent",
                  );
                },
              ),
            ],
          ),

          // QR Scanner Overlay
          if (_showQrScanner)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'Scanning...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _toggleQrScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}