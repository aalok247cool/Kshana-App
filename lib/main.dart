import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/task_zone_page.dart';
import 'pages/surprise_zone.dart';
import 'redeem_page.dart';
import 'pages/youtube_zone_page.dart';
import 'pages/instagram_zone_page.dart';
import 'pages/facebook_zone_page.dart';
import 'pages/others_zone_page.dart';
import 'pages/online_shopping_page.dart';
import 'pages/order_food_page.dart';
import 'pages/showtime_page.dart';
import 'pages/call_message_page.dart';
import 'pages/game_zone_page.dart';
import 'pages/earnings_zone_page.dart';
import 'pages/money_tools_zone_page.dart';
import 'pages/lifestyle_zone_page.dart';
import '../pages/profile_page.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/login_page.dart';
import 'dart:async';
import 'pages/kyc_page.dart';
import 'package:quick_actions/quick_actions.dart';
import 'pages/media_zone_page.dart';
import 'pages/kshana_reels_page.dart';



class ZoneNames {
  static const String mediaPaidZone = 'Media Paid Zone';
  static const String youTubeZone = 'YouTube Zone';
  static const String instagramZone = 'Instagram Zone';
  static const String facebookZone = 'Facebook Zone';
  static const String kshanaReels = 'Kshana Reels';
  static const String earningsZone = 'Earnings';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');  // Initial locale is English

  // Set locale and propagate to ProfilePage
  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
    print('Locale changed to: $newLocale');  // Debugging line
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kshana',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.amber,
      ),
      locale: _locale,  // Use updated locale here
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('kn', 'IN'),
      ],
    initialRoute: '/',
    routes: {
    '/': (context) => LoginPage(),
    '/dashboard': (context) => DashboardPage(onLocaleChange: setLocale),

    } // Pass the locale change handler
    );
  }
}


class DashboardPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const DashboardPage({super.key, required this.onLocaleChange}); // ✅ This makes sure it’s initialized

  @override
  _DashboardPageState createState() => _DashboardPageState();
}


void _setupQuickActions() {
  final QuickActions quickActions = const QuickActions();

  // Set up shortcuts
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'action_kshana_pay',
      localizedTitle: 'Kshana Pay',
      icon: 'icon_pay',
    ),
    const ShortcutItem(
      type: 'action_daily_reward',
      localizedTitle: 'Daily Reward',
      icon: 'icon_reward',
    ),
  ]);

  // Just print a message when shortcuts are used - no navigation yet
  quickActions.initialize((shortcutType) {
    print('App launched from shortcut: $shortcutType');
    // Shortcut functionality will be implemented in a future update
  });
}


class _DashboardPageState extends State<DashboardPage> {
  int _coinBalance = 75425;
  bool _isRewardClaimed = false;
  int currentCoins = 1000;
  String _userName = "User123";
  File? _profileImage;
  final String _trustScore = 'Red';

  List<Map<String, dynamic>> _userShortcuts = [];

  // Add this at the top of your _DashboardPageState class
  static const MethodChannel _shortcutChannel = MethodChannel('com.kshana.app/shortcuts');

  Future<bool> _createShortcut(String shortcutId, String shortcutName, String iconResourceName, String deepLink) async {
    try {
      final bool result = await _shortcutChannel.invokeMethod('createShortcut', {
        'shortcutId': shortcutId,
        'shortcutName': shortcutName,
        'iconResourceName': iconResourceName,
        'deepLink': deepLink,
      });
      return result;
    } catch (e) {
      print('Error creating shortcut: $e');
      return false;
    }
  }
  void _showCreateShortcutDialog(String title, String featureKey, String deepLink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Create Shortcut',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Do you want to add "$title" to your home screen?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final iconName = _getIconResourceName(featureKey);
              final success = await _createShortcut(
                  featureKey,
                  title,
                  iconName,
                  deepLink
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '$title shortcut created on home screen!'
                        : 'Could not create shortcut. Please try again.',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: Text(
              'Create',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconResourceName(String featureKey) {
    // Map feature keys to drawable resource names
    switch (featureKey) {
      case 'kshana_pay':
        return 'kshana_pay_icon';
      case 'daily_reward':
        return 'daily_reward_icon';
      case 'earnings':
        return 'earnings_icon';
      case 'kyc':
        return 'kyc_icon';
      default:
        return 'app_icon';
    }
  }

  // Add locale dropdown variables
  final Locale _selectedLocale = const Locale('en', 'US');
  final Map<String, Locale> _supportedLanguages = {
    'English': Locale('en', 'US'),
    'Hindi': Locale('hi', 'IN'),
    'Kannada': Locale('kn', 'IN'),
  };
  // Function to convert your existing trust score to KycStatus
  KycStatus _getKycStatusFromTrustScore(String trustScore) {
    switch (trustScore) {
      case 'Red':
        return KycStatus.notVerified;
      case 'Yellow':
        return KycStatus.partiallyVerified;
      case 'Green':
        return KycStatus.fullyVerified;
      default:
        return KycStatus.notVerified;
    }
  }
  Future<void> _openProfile() async {
    final result = await Navigator.push<dynamic>(  // Change to dynamic to handle both bool and other results
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          onLocaleChange: (Locale newLocale) {
            print("New locale selected: $newLocale");
            widget.onLocaleChange(newLocale); // Pass locale change back to main app
            setState(() {}); // refresh dashboard
          },
        ),
      ),
    );

    print("Returned from profile, result: $result");


    // Handle profile image update
    if (result == true || result is bool) {
      await _loadProfileImage();

      // Also refresh user data
      print("PROFILE WAS UPDATED, REFRESHING USER DATA");
      _loadUserData();
    }
  }


  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath');
    if (imagePath != null && mounted) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }
  @override
  Future<bool> didPopRoute() {
    // Force refresh when returning to this route
    setState(() {
      _loadCoinBalance();
    });
    return Future.value(false);
  }

  // Add this line

  void updateCoinBalance(int amount) {
    setState(() {
      _coinBalance -= amount;
    });
  }
  Color get trustScoreColor {
    switch (_trustScore) {
      case 'Yellow':
        return Colors.orange;
      case 'Red':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
// ADD THE FUNCTION RIGHT HERE:
  String getTrustScoreMessage() {
    switch (_trustScore) {
      case 'Red':
        return 'Your verification is incomplete.';
      case 'Yellow':
        return 'Your verification is partially complete.';
      case 'Green':
      default:
        return 'Your verification is complete.';
    }
  }
// END OF ADDED FUNCTION


  void _setupSharedPrefsListener() {
    // Check for changes every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final currentName = prefs.getString('userName');
      if (currentName != null && currentName != _userName) {
        print("DETECTED USERNAME CHANGE: $_userName -> $currentName");
        setState(() {
          _userName = currentName;
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _loadCoins();
    _checkIfRewardClaimed();
    _loadProfileImage();
    print("CALLING LOAD USER DATA FROM INIT STATE");
    _loadUserData();
    _setupSharedPrefsListener();
    _setupQuickActions();
    _loadCoinBalance(); // Add this line
    _loadUserShortcuts();

  }


  Future<void> _loadCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final newBalance = prefs.getInt('coinBalance') ?? 75425;
    print("LOADED BALANCE FROM STORAGE: $newBalance");

    if (mounted) {
      setState(() {
        _coinBalance = newBalance;
      });
    }
  }
  void refreshUserData() {
    _loadUserData();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coinBalance = prefs.getInt('coinBalance') ?? 0;
    });
  }
  Future<void> _loadUserData() async {
    print("LOAD USER DATA METHOD CALLED");
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? "UNIQUE_TEST_STRING";
    print("LOADED USERNAME FROM PREFS: $userName");
    setState(() {
      _userName = userName;
      print("SET STATE WITH USERNAME: $_userName");
    });
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coinBalance', _coinBalance);
  }

  Future<void> _checkIfRewardClaimed() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _isRewardClaimed = (prefs.getString('claimedDate') ?? '') == today;
    });
  }

  Future<void> _claimDailyReward() async {
    if (_isRewardClaimed) return;
    setState(() {
      _coinBalance += 50;
      _isRewardClaimed = true;
    });
    await _saveCoins();
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('claimedDate', today);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 50 coins claimed for today!')),
    );
  }

  void _onTaskCompleted(int coins) {
    setState(() => _coinBalance += coins);
    _saveCoins();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Task completed! +$coins coins')),
    );
  }

// Add `async` here so that `await` can be used
  void _handleZoneTap(String zoneName) async {  // <-- Add async here
    late Widget page;
    switch (zoneName) {


      case 'YouTube Zone':  // If a specific sub-zone for YouTube
        page = YouTubeZonePage();
        break;

      case 'Instagram Zone':  // If a specific sub-zone for Instagram
        page = InstagramZonePage();
        break;

      case 'Facebook Zone':  // If a specific sub-zone for Facebook
        page =  FacebookZonePage();
        break;

      case 'Others Zone':
        page = OthersZonePage(
          currentCoins: currentCoins,
          onCoinsEarned: (coins) {
            setState(() {
              _coinBalance += coins;
            });
          },
        );
        break;


      case 'Game Zone':
        page = GameZonePage(
          currentCoins: _coinBalance,
          onCoinsEarned: (earned) {
            setState(() => _coinBalance += earned);
            _saveCoins();
          },
        );
        break;

      case 'Online Shopping':
        page = OnlineShoppingPage(
          currentCoins: _coinBalance,
          onCoinsEarned: (earned) {
            setState(() => _coinBalance += earned);
            _saveCoins();
          },
        );
        break;

      case 'Order Food':
        page = OrderFoodPage(
          currentCoins: _coinBalance,
          onCoinsEarned: (earned) {
            setState(() => _coinBalance += earned);
            _saveCoins();
          },
        );
        break;

      case 'Transport':
        page = ShowtimePage(
          currentCoins: _coinBalance,
          onCoinsEarned: (earned) {
            setState(() => _coinBalance += earned);
            _saveCoins();
          },
        );
        break;

      case 'Call & Message':
        page = CallMessagePage(
          currentCoins: _coinBalance,
          onCoinsEarned: (earned) {
            setState(() => _coinBalance += earned);
            _saveCoins();
          },
        );
        break;


      case 'Task Zone':
        page = TaskZonePage(onTaskCompleted: _onTaskCompleted);
        break;

      case 'Earnings':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EarningsZonePage(
            coinBalance: _coinBalance,
          )),
        );

        if (result != null) {
          if (result is Map && result.containsKey('newBalance')) {
            // Directly set the new balance
            setState(() {
              _coinBalance = result['newBalance'];
            });
            print("DIRECTLY UPDATED BALANCE TO: ${result['newBalance']}");
          } else if (result is int) {
            setState(() {
              _coinBalance -= result;
            });
          }
          _saveCoins();
        }
        return;

      case 'Surprise Zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SurprizeZone(coinBalance: _coinBalance)),
        ).then((result) {
          if (result != null) {
            print("RESULT FROM SURPRISE ZONE: $result");

            // Update balance
            setState(() {
              _coinBalance -= 100; // Just directly subtract 100
              print("UPDATED COIN BALANCE: $_coinBalance");
            });

            // Force rebuild
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {});
              }
            });
          }
        });
        return;



      default:
        print("No matching zone for: $zoneName");
        return;  // Skip if no zone matches
    }

    // Capture the result after the ad is finished or skipped
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result != null) {
      if (result is num) {
        setState(() {
          _coinBalance += result.toInt();  // <-- Safely cast result to int
        });
        _saveCoins();
      }
    }
    setState(() {
      _loadCoinBalance();
    });
  }

  Future<void> saveBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coinBalance', balance);
  }

  @override
  Widget build(BuildContext context) {

    print("BUILDING DASHBOARD UI, USERNAME: $_userName");
    print("Current username: $_userName");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '🌟 Kshana Dashboard',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.verified,
              color: trustScoreColor,
              size: 26,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.amberAccent.shade200,
                        width: 3,
                      ),
                    ),
                    elevation: 20,
                    title: Text(
                      "Verification Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      getTrustScoreMessage(),
                      style: TextStyle(fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.amber.shade800),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),


          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  '$_coinBalance', // This is your coin balance
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // Rest of your existing body content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                GestureDetector(
                onTap: _openProfile,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.grey.shade800,
                      child: _profileImage == null
                          ? Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back!', style: TextStyle(color: Colors.white70)),
                        Text(_userName,  // Change 'User123' to _userName
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 20),
// Refresh Balance Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                      ),
                      child: TextButton.icon(
                        icon: Icon(Icons.refresh, color: Colors.amber),
                        label: Text(
                          "Refresh Balance",
                          style: TextStyle(color: Colors.amber),
                        ),
                        onPressed: () async {
                          await _loadCoinBalance();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Balance updated: $_coinBalance coins')),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  // 🔸 Keep all your existing cards and widgets below
                  // Redeem Card
                  Card(
                    color: Colors.grey.shade900,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.currency_rupee, color: Colors.green),
                      title: const Text('Redeem Coins', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Min 50000 coins (₹500)', style: TextStyle(color: Colors.white54)),
                      trailing: ElevatedButton(
                        onPressed: _coinBalance >= 50000
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RedeemPage(
                                currentCoins: _coinBalance,
                                onRedeem: (redeemedCoins) {
                                  setState(() {
                                    _coinBalance -= redeemedCoins;
                                  });
                                  _saveCoins();
                                },
                              ),
                            ),
                          );
                        }

                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coinBalance >= 50000 ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Redeem'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Replace your current KYC Notice with this:
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KycPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🔒 KYC required before redemption.\nPlease verify your identity.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),


                  // 🔸 Daily Reward Card
                  Card(
                    color: Colors.grey.shade900,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.card_giftcard, color: Colors.amber),
                      title: const Text('Daily Reward', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Claim 50 coins every day!', style: TextStyle(color: Colors.white54)),
                      trailing: ElevatedButton(
                        onPressed: _isRewardClaimed ? null : _claimDailyReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRewardClaimed ? Colors.grey : Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(_isRewardClaimed ? 'Claimed' : 'Claim'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add this after the Daily Reward Card and before the grid
                  const SizedBox(height: 20),

// 🔸Shortcuts Highlights Row
                  Container(
                    height: 85,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Add shortcut button
                        _buildShortcutItem(
                          icon: Icons.add,
                          label: "Add",
                          onTap: () {
                            // Show dialog to select what to add as shortcut
                            _showAddShortcutDialog();
                          },
                          isAdd: true,
                        ),


                        // User shortcuts with explicit rebuilding
                        if (_userShortcuts.isNotEmpty)
                          ...List.generate(_userShortcuts.length, (index) {
                            var shortcut = _userShortcuts[index];
                            return _buildShortcutItem(
                              icon: IconData(shortcut['icon'], fontFamily: 'MaterialIcons'),
                              label: shortcut['title'],
                              route: shortcut['route'],
                              onTap: () {
                                _navigateToRoute(shortcut['route']);
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔸 Zones Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildZoneCard('Earnings', Icons.monetization_on, EarningsZonePage(
                        coinBalance: _coinBalance,
                      )),
                      _buildZoneCard('Others Zone', Icons.apps),

                      _buildZoneCard('Money Tools', Icons.account_balance, MoneyToolsZonePage(
                        currentCoins: _coinBalance,
                        onCoinsEarned: (earned) {
                          setState(() => _coinBalance += earned);
                          _saveCoins();
                        },
                      )),
                      _buildZoneCard('Lifestyle', Icons.style, LifestyleZonePage(

                        currentCoins: _coinBalance,
                        onCoinsEarned: (earned) {
                          setState(() => _coinBalance += earned);
                          _saveCoins();
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(String title, IconData icon, [Widget? page]) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.amberAccent,
      child: InkWell(
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title shortcut has been added to your home screen!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onTap: () async {  // Add async keyword here
          if (page != null) {
            // If a page is provided, navigate to it
            await Navigator.push(  // Add await here
              context,
              MaterialPageRoute(builder: (context) => page),
            );

            // After returning from any page, refresh user data
            _loadUserData();
          } else {
            // Otherwise, handle it normally
            _handleZoneTap(title);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.amberAccent),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.amber, blurRadius: 8)])),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _saveUserShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> serializedShortcuts = _userShortcuts.map((shortcut) {
      return "${shortcut['title']}|${shortcut['icon']}|${shortcut['route']}";
    }).toList();

    await prefs.setStringList('userShortcuts', serializedShortcuts);
  }

  Future<void> _loadUserShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? serializedShortcuts = prefs.getStringList('userShortcuts');

    if (serializedShortcuts != null) {
      _userShortcuts = serializedShortcuts.map((shortcut) {
        List<String> parts = shortcut.split('|');
        return {
          'title': parts[0],
          'icon': int.parse(parts[1]),
          'route': parts[2],
        };
      }).toList();
    }
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case 'daily_reward':
        _claimDailyReward();
        break;
      case 'surprise_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SurprizeZone(coinBalance: _coinBalance)),
        );
        break;

      case 'task_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskZonePage(onTaskCompleted: _onTaskCompleted)),
        );
        break;
    // Add these new cases
      case 'media_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MediaPaidZonePage()),
        );
        break;
      case 'kshana_reels':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KshanaReelsPage()),
        );
        break;
      case 'game_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameZonePage(
            currentCoins: _coinBalance,
            onCoinsEarned: (earned) {
              setState(() => _coinBalance += earned);
              _saveCoins();
            },
          )),
        );
        break;
      case 'shopping_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OnlineShoppingPage(
            currentCoins: _coinBalance,
            onCoinsEarned: (earned) {
              setState(() => _coinBalance += earned);
              _saveCoins();
            },
          )),
        );
        break;
      case 'food_zone':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderFoodPage(
            currentCoins: _coinBalance,
            onCoinsEarned: (earned) {
              setState(() => _coinBalance += earned);
              _saveCoins();
            },
          )),
        );
        break;
      case 'test_shortcut':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test shortcut tapped!')),
        );
        break;
      default:
        print("Unknown route: $route");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route not implemented: $route')),
        );
    }
  }

  void _addShortcut(String title, IconData icon, String route) {
    bool alreadyExists = _userShortcuts.any((s) => s['route'] == route);

    if (!alreadyExists) {

      // Important: Create a new list instead of modifying the existing one
      setState(() {
        _userShortcuts = [
          ..._userShortcuts,
          {
            'title': title,
            'icon': icon.codePoint,
            'route': route,
          }
        ];
      });

      _saveUserShortcuts();

      // Force another rebuild after a delay
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) setState(() {});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title shortcut added!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title shortcut already exists')),
      );
    }
  }
  // Add the new method right here
  void _showDeleteShortcutDialog(String shortcutLabel, String route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text("Remove Shortcut", style: TextStyle(color: Colors.amber)),
        content: Text(
            "Remove $shortcutLabel from your shortcuts?",
            style: TextStyle(color: Colors.white)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Remove the shortcut
              setState(() {
                _userShortcuts.removeWhere((s) => s['route'] == route);
              });
              _saveUserShortcuts();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$shortcutLabel removed')),
              );
            },
            child: Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isAdd = false,
    String route = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: onTap,
        onLongPress: isAdd ? null : () {
          // Show delete confirmation
          _showDeleteShortcutDialog(label, route);
        },
        child: Column(
          // rest of method
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAdd ? Colors.grey.shade800 : Colors.grey.shade900,
                border: Border.all(
                  color: isAdd ? Colors.white30 : Colors.amber.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isAdd ? Colors.white54 : Colors.amber,
                size: 28,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isAdd ? Colors.white54 : Colors.amber,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddShortcutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          "Add Shortcut",
          style: TextStyle(color: Colors.amber),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildShortcutOption(
                icon: Icons.monetization_on,
                title: "Daily Reward",
                description: "Claim daily coins",
                onTap: () {
                  Navigator.pop(context);
                  // Add delay for better state management
                  Future.delayed(Duration(milliseconds: 100), () {
                    _addShortcut("Daily", Icons.monetization_on, "daily_reward");
                  });
                },
              ),

              _buildShortcutOption(
                icon: Icons.card_giftcard,
                title: "Surprise Zone",
                description: "Participate in lucky draws",
                onTap: () {
                  Navigator.pop(context);
                  // Add delay for better state management
                  Future.delayed(Duration(milliseconds: 100), () {
                    _addShortcut("Surprise", Icons.card_giftcard, "surprise_zone");
                  });
                },
              ),
// Media Zones
              _buildShortcutOption(
                icon: Icons.ondemand_video,
                title: "Media Paid Zone",
                description: "Watch videos to earn",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Media", Icons.ondemand_video, "media_zone");
                  });
                },
              ),

              _buildShortcutOption(
                icon: Icons.video_library,
                title: "Kshana Reels",
                description: "Watch reels to earn",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Reels", Icons.video_library, "kshana_reels");
                  });
                },
              ),

// Other zones
              _buildShortcutOption(
                icon: Icons.games,
                title: "Game Zone",
                description: "Play games to earn",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Games", Icons.games, "game_zone");
                  });
                },
              ),

              _buildShortcutOption(
                icon: Icons.shopping_cart,
                title: "Online Shopping",
                description: "Earn from shopping",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Shopping", Icons.shopping_cart, "shopping_zone");
    });
  },
  ),

              _buildShortcutOption(
                icon: Icons.restaurant,
                title: "Order Food",
                description: "Earn from food orders",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Food", Icons.restaurant, "food_zone");
                  });
                },
              ),
              _buildShortcutOption(
                icon: Icons.task_alt,
                title: "Task Zone",
                description: "Complete tasks for coins",
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 100), () {
                  _addShortcut("Tasks", Icons.task_alt, "task_zone");
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

// Add this helper method
  Widget _buildShortcutOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Icon(icon, color: Colors.amber),
      ),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(description, style: TextStyle(color: Colors.white70, fontSize: 12)),
      onTap: onTap,
    );
  }
}