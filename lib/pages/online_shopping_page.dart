import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineShoppingPage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const OnlineShoppingPage({super.key, 
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  _OnlineShoppingPageState createState() => _OnlineShoppingPageState();
}

class _OnlineShoppingPageState extends State<OnlineShoppingPage> {
  late int _coinBalance;
  bool _isLoading = false;

  // List of e-commerce partners with affiliate details
  final List<EcommercePartner> _partners = [
    EcommercePartner(
      name: 'Amazon',
      logoAsset: 'assets/amazon_logo.png',
      description: 'India\'s largest online store with millions of products',
      cashbackPercentage: 2.5,
      coinsPerRupee: 5,
      affiliateUrl: 'https://www.amazon.in/?tag=your-actual-affiliate-id',
      appUrl: 'amzn://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=in.amazon.mShop.android.shopping',
    ),
    EcommercePartner(
      name: 'Flipkart',
      logoAsset: 'assets/flipkart_logo.png',
      description: 'Shop for electronics, fashion and more with great deals',
      cashbackPercentage: 3.0,
      coinsPerRupee: 6,
      affiliateUrl: 'https://www.flipkart.com/?affid=kshanaapp',
      appUrl: 'flipkart://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.flipkart.android',
    ),
    EcommercePartner(
      name: 'Myntra',
      logoAsset: 'assets/myntra_logo.png',
      description: 'India\'s fashion destination for the latest trends',
      cashbackPercentage: 4.0,
      coinsPerRupee: 8,
      affiliateUrl: 'https://www.myntra.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'myntra://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.myntra.android',
    ),
    EcommercePartner(
      name: 'Meesho',
      logoAsset: 'assets/meesho_logo.png',
      description: 'Affordable shopping with reseller network',
      cashbackPercentage: 5.0,
      coinsPerRupee: 10,
      affiliateUrl: 'https://meesho.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'meesho://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.meesho.supply',
    ),
    EcommercePartner(
      name: 'Ajio',
      logoAsset: 'assets/ajio_logo.png',
      description: 'Curated fashion for men, women and kids',
      cashbackPercentage: 3.5,
      coinsPerRupee: 7,
      affiliateUrl: 'https://www.ajio.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'ajio://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.ril.ajio',
    ),
    EcommercePartner(
      name: 'Nykaa',
      logoAsset: 'assets/nykaa_logo.png',
      description: 'Beauty, wellness and fashion products',
      cashbackPercentage: 4.5,
      coinsPerRupee: 9,
      affiliateUrl: 'https://www.nykaa.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'nykaa://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.nykaa.android',
    ),
  ];

  List<PurchaseHistory> _recentPurchases = [];

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoins;
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String>? purchaseData = prefs.getStringList('purchaseHistory');

    if (purchaseData != null) {
      _recentPurchases = purchaseData.map((data) {
        final parts = data.split('|');
        return PurchaseHistory(
          storeName: parts[0],
          purchaseAmount: double.parse(parts[1]),
          coinsEarned: int.parse(parts[2]),
          date: DateTime.parse(parts[3]),
        );
      }).toList();

      // Sort by most recent
      _recentPurchases.sort((a, b) => b.date.compareTo(a.date));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openPartner(EcommercePartner partner) async {
    // Try to open the app first
    bool launched = false;

    try {
      Uri appUri = Uri.parse(partner.appUrl);
      if (await canLaunchUrl(appUri)) {
        launched = await launchUrl(appUri);
      }
    } catch (e) {
      // App not installed or can't be launched
      launched = false;
    }

    // If app couldn't be launched, open the web URL
    if (!launched) {
      Uri webUri = Uri.parse(partner.affiliateUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }

    // Show tracking dialog
    _showPurchaseTrackingDialog(partner);
  }

  void _showPurchaseTrackingDialog(EcommercePartner partner) {
    // Mock amounts for demo
    final List<double> suggestedAmounts = [499, 999, 1499, 2999, 4999];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Your Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'After completing your purchase on ${partner.name}, enter the amount to track your rewards:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${partner.cashbackPercentage}% cashback',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                hintText: 'Enter amount',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  double amount = double.tryParse(value) ?? 0;
                  if (amount > 0) {
                    _recordPurchase(partner, amount);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            SizedBox(height: 16),
            Text('Quick Select:'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: suggestedAmounts.map((amount) =>
                  ActionChip(
                    label: Text('₹$amount'),
                    onPressed: () {
                      _recordPurchase(partner, amount);
                      Navigator.of(context).pop();
                    },
                  )
              ).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Will use text field value when submitted
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordPurchase(EcommercePartner partner, double amount) async {
    // Calculate coins earned
    final int coinsEarned = (amount * partner.coinsPerRupee).round();

    // Create purchase record
    final purchase = PurchaseHistory(
      storeName: partner.name,
      purchaseAmount: amount,
      coinsEarned: coinsEarned,
      date: DateTime.now(),
    );

    // Add to local list
    setState(() {
      _recentPurchases.insert(0, purchase);
      _coinBalance += coinsEarned;
    });

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> purchaseData = _recentPurchases.map((p) =>
    '${p.storeName}|${p.purchaseAmount}|${p.coinsEarned}|${p.date.toIso8601String()}'
    ).toList();

    await prefs.setStringList('purchaseHistory', purchaseData);

    // Notify parent of coins earned
    widget.onCoinsEarned(coinsEarned);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $coinsEarned coins from your ${partner.name} purchase!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Shopping'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              _buildInfoCard(),

              SizedBox(height: 24),

              // Partner shops
              Text(
                'Shop & Earn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              ..._partners.map((partner) => _buildPartnerCard(partner)),

              SizedBox(height: 24),

              // Recent purchases
              if (_recentPurchases.isNotEmpty) ...[
                Text(
                  'Recent Purchases',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                ..._recentPurchases.take(5).map((purchase) => _buildPurchaseCard(purchase)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.purple, size: 28),
                SizedBox(width: 12),
                Text(
                  'Earn While You Shop',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Shop from your favorite stores through Kshana and earn coins on every purchase. The more you shop, the more you earn!',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coins are credited within 24 hours of purchase confirmation',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(EcommercePartner partner) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openPartner(partner),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo placeholder - replace with actual logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    partner.name[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      partner.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${partner.cashbackPercentage}% Cashback',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${partner.coinsPerRupee}x Coins',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseHistory purchase) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(Icons.shopping_bag, color: Colors.blue),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.storeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${purchase.purchaseAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _formatDate(purchase.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, size: 12, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    '+${purchase.coinsEarned}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Model classes
class EcommercePartner {
  final String name;
  final String logoAsset;
  final String description;
  final double cashbackPercentage;
  final int coinsPerRupee;
  final String affiliateUrl;
  final String appUrl;
  final String playStoreUrl;

  EcommercePartner({
    required this.name,
    required this.logoAsset,
    required this.description,
    required this.cashbackPercentage,
    required this.coinsPerRupee,
    required this.affiliateUrl,
    required this.appUrl,
    required this.playStoreUrl,
  });
}

class PurchaseHistory {
  final String storeName;
  final double purchaseAmount;
  final int coinsEarned;
  final DateTime date;

  PurchaseHistory({
    required this.storeName,
    required this.purchaseAmount,
    required this.coinsEarned,
    required this.date,
  });
}