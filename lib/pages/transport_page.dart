import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TransportPage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const TransportPage({
    Key? key,
    required this.currentCoins,
    required this.onCoinsEarned,
  }) : super(key: key);

  @override
  _TransportPageState createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> with SingleTickerProviderStateMixin {
  late int _coinBalance;
  bool _isLoading = false;
  late TabController _tabController;

  // Sample booking history
  List<BookingHistory> _bookingHistory = [];

  // List of transport partners with affiliate details
  final List<TransportPartner> _busPartners = [
    TransportPartner(
      name: 'RedBus',
      logoAsset: 'assets/redbus_logo.png',
      description: 'India\'s largest online bus ticket booking platform',
      cashbackPercentage: 3.0,
      coinsPerRupee: 6,
      affiliateUrl: 'https://www.redbus.in/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'redbus://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=in.redbus.android',
    ),
    TransportPartner(
      name: 'AbhiBus',
      logoAsset: 'assets/abhibus_logo.png',
      description: 'Book bus tickets online with great discounts',
      cashbackPercentage: 3.5,
      coinsPerRupee: 7,
      affiliateUrl: 'https://www.abhibus.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'abhibus://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.abhibus',
    ),
    TransportPartner(
      name: 'Paytm Bus',
      logoAsset: 'assets/paytm_logo.png',
      description: 'Book bus tickets with cashback offers',
      cashbackPercentage: 2.5,
      coinsPerRupee: 5,
      affiliateUrl: 'https://paytm.com/bus-tickets/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'paytm://travel/bus',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=net.one97.paytm',
    ),
  ];

  final List<TransportPartner> _trainPartners = [
    TransportPartner(
      name: 'IRCTC',
      logoAsset: 'assets/irctc_logo.png',
      description: 'Official Indian Railway ticket booking platform',
      cashbackPercentage: 1.5,
      coinsPerRupee: 3,
      affiliateUrl: 'https://www.irctc.co.in/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'irctc://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=cris.org.in.prs.ima',
    ),
    TransportPartner(
      name: 'Ixigo Trains',
      logoAsset: 'assets/ixigo_logo.png',
      description: 'Check PNR status and book train tickets',
      cashbackPercentage: 2.0,
      coinsPerRupee: 4,
      affiliateUrl: 'https://www.ixigo.com/trains/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'ixigo://trains',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.ixigo.train.search',
    ),
    TransportPartner(
      name: 'Confirmtkt',
      logoAsset: 'assets/confirmtkt_logo.png',
      description: 'Train ticket booking with prediction',
      cashbackPercentage: 2.5,
      coinsPerRupee: 5,
      affiliateUrl: 'https://www.confirmtkt.com/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'confirmtkt://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.confirmtkt',
    ),
  ];

  final List<TransportPartner> _flightPartners = [
    TransportPartner(
      name: 'MakeMyTrip',
      logoAsset: 'assets/makemytrip_logo.png',
      description: 'Book flights, hotels and holiday packages',
      cashbackPercentage: 1.0,
      coinsPerRupee: 2,
      affiliateUrl: 'https://www.makemytrip.com/flights/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'makemytrip://flight',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.makemytrip',
    ),
    TransportPartner(
      name: 'Skyscanner',
      logoAsset: 'assets/skyscanner_logo.png',
      description: 'Compare flights from all major airlines',
      cashbackPercentage: 1.5,
      coinsPerRupee: 3,
      affiliateUrl: 'https://www.skyscanner.co.in/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'skyscanner://home',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=net.skyscanner.android.main',
    ),
    TransportPartner(
      name: 'Cleartrip',
      logoAsset: 'assets/cleartrip_logo.png',
      description: 'Search & book flights at lowest prices',
      cashbackPercentage: 1.2,
      coinsPerRupee: 3,
      affiliateUrl: 'https://www.cleartrip.com/flights/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'cleartrip://flight',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.cleartrip.android',
    ),
    TransportPartner(
      name: 'Yatra',
      logoAsset: 'assets/yatra_logo.png',
      description: 'Book flights, hotels, buses and trains',
      cashbackPercentage: 1.5,
      coinsPerRupee: 3,
      affiliateUrl: 'https://www.yatra.com/flights/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'yatra://flight',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.yatra.base',
    ),
    TransportPartner(
      name: 'Ixigo Flights',
      logoAsset: 'assets/ixigo_logo.png',
      description: 'Compare flights and get lowest fares',
      cashbackPercentage: 1.7,
      coinsPerRupee: 4,
      affiliateUrl: 'https://www.ixigo.com/flights/?utm_source=kshana&utm_medium=affiliate',
      appUrl: 'ixigo://flights',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=in.ixigo.flights',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoins;
    _tabController = TabController(length: 3, vsync: this);
    _loadBookingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingHistory() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String>? bookingData = prefs.getStringList('transportBookingHistory');

    if (bookingData != null) {
      _bookingHistory = bookingData.map((data) {
        final parts = data.split('|');
        return BookingHistory(
          serviceName: parts[0],
          bookingType: parts[1],
          bookingAmount: double.parse(parts[2]),
          coinsEarned: int.parse(parts[3]),
          date: DateTime.parse(parts[4]),
          source: parts[5],
          destination: parts[6],
        );
      }).toList();

      // Sort by most recent
      _bookingHistory.sort((a, b) => b.date.compareTo(a.date));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openPartner(TransportPartner partner) async {
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
    _showBookingTrackingDialog(partner);
  }

  void _showBookingTrackingDialog(TransportPartner partner) {
    String bookingType = '';
    if (_busPartners.contains(partner)) {
      bookingType = 'Bus';
    } else if (_trainPartners.contains(partner)) {
      bookingType = 'Train';
    } else if (_flightPartners.contains(partner)) {
      bookingType = 'Flight';
    }

    // Mock amounts for demo based on type
    List<double> suggestedAmounts = [];
    switch (bookingType) {
      case 'Bus':
        suggestedAmounts = [500, 800, 1200, 1500, 2000];
        break;
      case 'Train':
        suggestedAmounts = [600, 1000, 1500, 2000, 3000];
        break;
      case 'Flight':
        suggestedAmounts = [3000, 5000, 8000, 12000, 15000];
        break;
      default:
        suggestedAmounts = [1000, 2000, 5000, 10000];
    }

    TextEditingController sourceController = TextEditingController();
    TextEditingController destinationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Your $bookingType Booking'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'After completing your booking on ${partner.name}, enter the details to track your rewards:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Amount:',
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
                      _recordBooking(
                          partner,
                          bookingType,
                          amount,
                          sourceController.text,
                          destinationController.text
                      );
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
                        _recordBooking(
                            partner,
                            bookingType,
                            amount,
                            sourceController.text,
                            destinationController.text
                        );
                        Navigator.of(context).pop();
                      },
                    )
                ).toList(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: sourceController,
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
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
              // Get values from the text fields
              String source = sourceController.text.isNotEmpty
                  ? sourceController.text
                  : 'Not specified';
              String destination = destinationController.text.isNotEmpty
                  ? destinationController.text
                  : 'Not specified';

              // Use a default value if amount is not entered
              _recordBooking(partner, bookingType, suggestedAmounts[0], source, destination);
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordBooking(
      TransportPartner partner,
      String bookingType,
      double amount,
      String source,
      String destination
      ) async {
    // Calculate coins earned
    final int coinsEarned = (amount * partner.coinsPerRupee).round();

    // Set default values if not provided
    if (source.isEmpty) source = 'Not specified';
    if (destination.isEmpty) destination = 'Not specified';

    // Create booking record
    final booking = BookingHistory(
      serviceName: partner.name,
      bookingType: bookingType,
      bookingAmount: amount,
      coinsEarned: coinsEarned,
      date: DateTime.now(),
      source: source,
      destination: destination,
    );

    // Add to local list
    setState(() {
      _bookingHistory.insert(0, booking);
      _coinBalance += coinsEarned;
    });

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookingData = _bookingHistory.map((b) =>
    '${b.serviceName}|${b.bookingType}|${b.bookingAmount}|${b.coinsEarned}|${b.date.toIso8601String()}|${b.source}|${b.destination}'
    ).toList();

    await prefs.setStringList('transportBookingHistory', bookingData);

    // Notify parent of coins earned
    widget.onCoinsEarned(coinsEarned);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $coinsEarned coins from your ${partner.name} $bookingType booking!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Bookings'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Bus'),
            Tab(text: 'Train'),
            Tab(text: 'Flight'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Bus tab
                _buildPartnerList(_busPartners),

                // Train tab
                _buildPartnerList(_trainPartners),

                // Flight tab
                _buildPartnerList(_flightPartners),
              ],
            ),
          ),

          // Recent bookings section
          if (_bookingHistory.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Bookings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Could navigate to a full history page
                        },
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _bookingHistory
                          .take(5)
                          .map((booking) => _buildBookingCard(booking))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for destinations',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Search functionality would be implemented here
            },
            child: Text('Search'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerList(List<TransportPartner> partners) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            _buildInfoCard(),

            SizedBox(height: 16),

            // Partners list
            ...partners.map((partner) => _buildPartnerCard(partner)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    String tabText = '';
    String tabInfo = '';

    switch (_tabController.index) {
      case 0:
        tabText = 'Book Bus Tickets';
        tabInfo = 'Earn coins when you book bus tickets through our partner platforms. Compare prices and find the best deals for your journey.';
        break;
      case 1:
        tabText = 'Book Train Tickets';
        tabInfo = 'Book train tickets and earn rewards. Check PNR status, seat availability and more through our partner platforms.';
        break;
      case 2:
        tabText = 'Book Flight Tickets';
        tabInfo = 'Find the best deals on flight tickets worldwide. Book domestic and international flights and earn coins with every booking.';
        break;
      default:
        tabText = 'Book Transport Tickets';
        tabInfo = 'Book tickets for your journey and earn rewards. Compare prices across platforms for the best deals.';
    }

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
              tabText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              tabInfo,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coins are credited within 24 hours of booking confirmation',
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

  Widget _buildPartnerCard(TransportPartner partner) {
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

  Widget _buildBookingCard(BookingHistory booking) {
    IconData iconData;
    Color iconColor;

    switch (booking.bookingType) {
      case 'Bus':
        iconData = Icons.directions_bus;
        iconColor = Colors.green;
        break;
      case 'Train':
        iconData = Icons.train;
        iconColor = Colors.blue;
        break;
      case 'Flight':
        iconData = Icons.flight;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.directions_transit;
        iconColor = Colors.purple;
    }

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${booking.source} → ${booking.destination}',
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '₹${booking.bookingAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(booking.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 14,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '+${booking.coinsEarned}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Model classes
class TransportPartner {
  final String name;
  final String logoAsset;
  final String description;
  final double cashbackPercentage;
  final int coinsPerRupee;
  final String affiliateUrl;
  final String appUrl;
  final String playStoreUrl;

  TransportPartner({
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

class BookingHistory {
  final String serviceName;
  final String bookingType;
  final double bookingAmount;
  final int coinsEarned;
  final DateTime date;
  final String source;
  final String destination;

  BookingHistory({
    required this.serviceName,
    required this.bookingType,
    required this.bookingAmount,
    required this.coinsEarned,
    required this.date,
    required this.source,
    required this.destination,
  });
}