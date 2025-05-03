import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderFoodPage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const OrderFoodPage({
    Key? key,
    required this.currentCoins,
    required this.onCoinsEarned,
  }) : super(key: key);

  @override
  _OrderFoodPageState createState() => _OrderFoodPageState();
}

class _OrderFoodPageState extends State<OrderFoodPage> {
  late int _coinBalance;
  bool _isLoading = false;

  // List of food delivery partners with affiliate details
  final List<FoodDeliveryPartner> _partners = [
    FoodDeliveryPartner(
      name: 'Swiggy',
      logoAsset: 'assets/swiggy_logo.png',
      description: 'Food, groceries, and essentials delivered to your doorstep',
      cashbackPercentage: 3.0,
      coinsPerRupee: 6,
      affiliateUrl: 'https://www.swiggy.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'swiggy://restaurant',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=in.swiggy.android',
    ),
    FoodDeliveryPartner(
      name: 'Zomato',
      logoAsset: 'assets/zomato_logo.png',
      description: 'Discover the best food & drinks in your area',
      cashbackPercentage: 2.5,
      coinsPerRupee: 5,
      affiliateUrl: 'https://www.zomato.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'zomato://order',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.application.zomato',
    ),
    FoodDeliveryPartner(
      name: 'Blinkit',
      logoAsset: 'assets/blinkit_logo.png',
      description: 'Groceries and essentials delivered in minutes',
      cashbackPercentage: 4.0,
      coinsPerRupee: 8,
      affiliateUrl: 'https://blinkit.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'blinkit://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.grofers.customerapp',
    ),
    FoodDeliveryPartner(
      name: 'EatFit',
      logoAsset: 'assets/eatfit_logo.png',
      description: 'Healthy food delivered at affordable prices',
      cashbackPercentage: 5.0,
      coinsPerRupee: 10,
      affiliateUrl: 'https://www.eatfit.in/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'eatfit://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=fit.cure.app',
    ),
    FoodDeliveryPartner(
      name: 'Domino\'s Pizza',
      logoAsset: 'assets/dominos_logo.png',
      description: 'Pizza delivered hot and fresh to your doorstep',
      cashbackPercentage: 3.5,
      coinsPerRupee: 7,
      affiliateUrl: 'https://www.dominos.co.in/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'dominos://order',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.dominospizza',
    ),
  ];

  List<OrderHistory> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoins;
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String>? orderData = prefs.getStringList('foodOrderHistory');

    if (orderData != null) {
      _recentOrders = orderData.map((data) {
        final parts = data.split('|');
        return OrderHistory(
          serviceName: parts[0],
          orderAmount: double.parse(parts[1]),
          coinsEarned: int.parse(parts[2]),
          date: DateTime.parse(parts[3]),
        );
      }).toList();

      // Sort by most recent
      _recentOrders.sort((a, b) => b.date.compareTo(a.date));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openPartner(FoodDeliveryPartner partner) async {
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
    _showOrderTrackingDialog(partner);
  }

  void _showOrderTrackingDialog(FoodDeliveryPartner partner) {
    // Mock amounts for demo
    final List<double> suggestedAmounts = [149, 249, 349, 499, 799];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Your Food Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'After completing your order on ${partner.name}, enter the amount to track your rewards:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Amount:',
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
                    _recordOrder(partner, amount);
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
                      _recordOrder(partner, amount);
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

  Future<void> _recordOrder(FoodDeliveryPartner partner, double amount) async {
    // Calculate coins earned
    final int coinsEarned = (amount * partner.coinsPerRupee).round();

    // Create order record
    final order = OrderHistory(
      serviceName: partner.name,
      orderAmount: amount,
      coinsEarned: coinsEarned,
      date: DateTime.now(),
    );

    // Add to local list
    setState(() {
      _recentOrders.insert(0, order);
      _coinBalance += coinsEarned;
    });

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> orderData = _recentOrders.map((p) =>
    '${p.serviceName}|${p.orderAmount}|${p.coinsEarned}|${p.date.toIso8601String()}'
    ).toList();

    await prefs.setStringList('foodOrderHistory', orderData);

    // Notify parent of coins earned
    widget.onCoinsEarned(coinsEarned);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $coinsEarned coins from your ${partner.name} order!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Food'),
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

              // Popular restaurants nearby card
              _buildPopularRestaurantsCard(),

              SizedBox(height: 24),

              // Food delivery services
              Text(
                'Food Delivery Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              ..._partners.map((partner) => _buildPartnerCard(partner)).toList(),

              SizedBox(height: 24),

              // Recent orders
              if (_recentOrders.isNotEmpty) ...[
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                ..._recentOrders.take(5).map((order) => _buildOrderCard(order)).toList(),
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
                Icon(Icons.fastfood, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'Earn While You Eat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Order food from your favorite restaurants through Kshana and earn coins on every order. The more you order, the more you earn!',
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
                      'Coins are credited within 24 hours of order confirmation',
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

  Widget _buildPopularRestaurantsCard() {
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
            Text(
              'Popular Restaurants Nearby',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRestaurantTile('Burger King', '4.2', '25-35 min'),
                  _buildRestaurantTile('KFC', '4.0', '30-40 min'),
                  _buildRestaurantTile('Pizza Hut', '4.5', '35-45 min'),
                  _buildRestaurantTile('Subway', '4.3', '20-30 min'),
                  _buildRestaurantTile('McDonald\'s', '4.1', '25-35 min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantTile(String name, String rating, String deliveryTime) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.restaurant, size: 32),
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              SizedBox(width: 2),
              Text(rating, style: TextStyle(fontSize: 12)),
            ],
          ),
          Text(
            deliveryTime,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(FoodDeliveryPartner partner) {
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

  Widget _buildOrderCard(OrderHistory order) {
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.serviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${order.orderAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${_formatDate(order.date)}',
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
                    '+${order.coinsEarned}',
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
class FoodDeliveryPartner {
  final String name;
  final String logoAsset;
  final String description;
  final double cashbackPercentage;
  final int coinsPerRupee;
  final String affiliateUrl;
  final String appUrl;
  final String playStoreUrl;

  FoodDeliveryPartner({
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

class OrderHistory {
  final String serviceName;
  final double orderAmount;
  final int coinsEarned;
  final DateTime date;

  OrderHistory({
    required this.serviceName,
    required this.orderAmount,
    required this.coinsEarned,
    required this.date,
  });
}