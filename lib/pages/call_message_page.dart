import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CallMessagePage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const CallMessagePage({
    Key? key,
    required this.currentCoins,
    required this.onCoinsEarned,
  }) : super(key: key);

  @override
  _CallMessagePageState createState() => _CallMessagePageState();
}

class _CallMessagePageState extends State<CallMessagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _coinBalance;

  // Tracking communication stats
  int _callMinutes = 0;
  int _messagesSent = 0;
  int _callRewardThreshold = 20; // Minutes to earn reward
  int _messageRewardThreshold = 50; // Messages to earn reward
  int _callRewardAmount = 5; // Coins earned per 20 min of calls
  int _messageRewardAmount = 5; // Coins earned per 50 messages

  // Mock data for contacts and chats
  final List<KshanaContact> _contacts = [
    KshanaContact(
      name: 'Rahul Sharma',
      username: 'rahul_s',
      profileImage: 'assets/profile1.jpg',
      status: 'Online',
      lastSeen: DateTime.now(),
    ),
    KshanaContact(
      name: 'Priya Patel',
      username: 'priya22',
      profileImage: 'assets/profile2.jpg',
      status: 'Last seen 2 hours ago',
      lastSeen: DateTime.now().subtract(Duration(hours: 2)),
    ),
    KshanaContact(
      name: 'Amit Kumar',
      username: 'amit_k',
      profileImage: 'assets/profile3.jpg',
      status: 'Online',
      lastSeen: DateTime.now(),
    ),
    KshanaContact(
      name: 'Sneha Gupta',
      username: 'sneha_g',
      profileImage: 'assets/profile4.jpg',
      status: 'Last seen yesterday',
      lastSeen: DateTime.now().subtract(Duration(days: 1)),
    ),
    KshanaContact(
      name: 'Kshana Support',
      username: 'kshana_support',
      profileImage: 'assets/kshana_logo.png',
      status: 'Online',
      lastSeen: DateTime.now(),
    ),
  ];

  final List<ChatMessage> _recentMessages = [
    ChatMessage(
      sender: 'Rahul Sharma',
      message: 'Hey, how are you doing?',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isRead: true,
    ),
    ChatMessage(
      sender: 'Kshana Support',
      message: 'Welcome to Kshana! Let us know if you need any help.',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      sender: 'Priya Patel',
      message: 'Did you see the new reward options?',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isRead: false,
    ),
  ];

  final List<CallLog> _recentCalls = [
    CallLog(
      contactName: 'Rahul Sharma',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      duration: Duration(minutes: 12, seconds: 45),
      isIncoming: true,
      isVideoCall: false,
    ),
    CallLog(
      contactName: 'Kshana Support',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      duration: Duration(minutes: 5, seconds: 23),
      isIncoming: false,
      isVideoCall: true,
    ),
    CallLog(
      contactName: 'Amit Kumar',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      duration: Duration(minutes: 3, seconds: 11),
      isIncoming: true,
      isVideoCall: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoins;
    _tabController = TabController(length: 3, vsync: this);
    _loadCommunicationStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunicationStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _callMinutes = prefs.getInt('callMinutes') ?? 0;
      _messagesSent = prefs.getInt('messagesSent') ?? 0;
    });
  }

  Future<void> _saveCommunicationStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('callMinutes', _callMinutes);
    await prefs.setInt('messagesSent', _messagesSent);
  }

  void _trackCallTime(int minutes) {
    setState(() {
      _callMinutes += minutes;

      // Award coins if threshold reached
      int rewardsEarned = (_callMinutes / _callRewardThreshold).floor();
      int coinsEarned = rewardsEarned * _callRewardAmount;

      if (coinsEarned > 0) {
        _coinBalance += coinsEarned;
        widget.onCoinsEarned(coinsEarned);

        // Reset tracking for next reward
        _callMinutes = _callMinutes % _callRewardThreshold;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You earned $coinsEarned coins from call time!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    _saveCommunicationStats();
  }

  void _trackMessageSent() {
    setState(() {
      _messagesSent++;

      // Award coins if threshold reached
      int rewardsEarned = (_messagesSent / _messageRewardThreshold).floor();
      int coinsEarned = rewardsEarned * _messageRewardAmount;

      if (coinsEarned > 0) {
        _coinBalance += coinsEarned;
        widget.onCoinsEarned(coinsEarned);

        // Reset tracking for next reward
        _messagesSent = _messagesSent % _messageRewardThreshold;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You earned $coinsEarned coins from messaging!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    _saveCommunicationStats();
  }

  void _makeCall(KshanaContact contact, bool isVideo) {
    // Simulate a call and earn coins
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${contact.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(contact.name[0]),
            ),
            SizedBox(height: 20),
            Text(
              isVideo ? 'Video Call in Progress...' : 'Call in Progress...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text('00:00', style: TextStyle(fontSize: 24)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Simulate a 5-minute call
              _trackCallTime(5);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _openChat(KshanaContact contact) {
    // Show chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          contact: contact,
          onMessageSent: _trackMessageSent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call & Message'),
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
            Tab(text: 'Chats'),
            Tab(text: 'Calls'),
            Tab(text: 'Contacts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chats tab
          _buildChatsTab(),

          // Calls tab
          _buildCallsTab(),

          // Contacts tab
          _buildContactsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show new chat/call options
          _showNewCommunicationOptions();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatsTab() {
    return Column(
      children: [
        // Progress indicator for message rewards
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Message Rewards Progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_messagesSent/$_messageRewardThreshold',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _messagesSent / _messageRewardThreshold,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 4),
              Text(
                'Send $_messageRewardThreshold messages to earn $_messageRewardAmount coins',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Recent chats list
        Expanded(
          child: _recentMessages.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No chats yet',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a conversation with a friend',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _recentMessages.length,
            itemBuilder: (context, index) {
              final message = _recentMessages[index];
              final contact = _contacts.firstWhere(
                    (c) => c.name == message.sender,
                orElse: () => KshanaContact(
                  name: message.sender,
                  username: '',
                  profileImage: '',
                  status: '',
                  lastSeen: DateTime.now(),
                ),
              );

              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0]),
                ),
                title: Text(contact.name),
                subtitle: Text(
                  message.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    if (!message.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () => _openChat(contact),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallsTab() {
    return Column(
      children: [
        // Progress indicator for call rewards
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Call Rewards Progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_callMinutes/$_callRewardThreshold min',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _callMinutes / _callRewardThreshold,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 4),
              Text(
                'Call for $_callRewardThreshold minutes to earn $_callRewardAmount coins',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Recent calls list
        Expanded(
          child: _recentCalls.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No calls yet',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a call with a friend',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _recentCalls.length,
            itemBuilder: (context, index) {
              final call = _recentCalls[index];
              final contact = _contacts.firstWhere(
                    (c) => c.name == call.contactName,
                orElse: () => KshanaContact(
                  name: call.contactName,
                  username: '',
                  profileImage: '',
                  status: '',
                  lastSeen: DateTime.now(),
                ),
              );

              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0]),
                ),
                title: Text(contact.name),
                subtitle: Row(
                  children: [
                    Icon(
                      call.isIncoming
                          ? Icons.call_received
                          : Icons.call_made,
                      size: 14,
                      color: call.isIncoming ? Colors.green : Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Text(_formatCallTime(call.timestamp)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatDuration(call.duration)),
                    SizedBox(width: 8),
                    Icon(
                      call.isVideoCall
                          ? Icons.videocam
                          : Icons.call,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onTap: () => _makeCall(contact, call.isVideoCall),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactsTab() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(contact.name[0]),
          ),
          title: Text(contact.name),
          subtitle: Text(contact.status),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.message, color: Colors.blue),
                onPressed: () => _openChat(contact),
              ),
              IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: () => _makeCall(contact, false),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewCommunicationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('New Chat'),
            onTap: () {
              Navigator.pop(context);
              _showContactSelector(false);
            },
          ),
          ListTile(
            leading: Icon(Icons.call),
            title: Text('New Call'),
            onTap: () {
              Navigator.pop(context);
              _showContactSelector(true);
            },
          ),
          ListTile(
            leading: Icon(Icons.videocam),
            title: Text('New Video Call'),
            onTap: () {
              Navigator.pop(context);
              _showContactSelector(true, isVideo: true);
            },
          ),
        ],
      ),
    );
  }

  void _showContactSelector(bool isForCall, {bool isVideo = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isForCall
            ? isVideo ? 'Select Contact for Video Call' : 'Select Contact for Call'
            : 'Select Contact for Chat'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0]),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.status),
                onTap: () {
                  Navigator.pop(context);
                  if (isForCall) {
                    _makeCall(contact, isVideo);
                  } else {
                    _openChat(contact);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      // Today
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.day == now.day - 1 &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Earlier
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _formatCallTime(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      // Today
      return 'Today';
    } else if (timestamp.day == now.day - 1 &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Earlier
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

// Chat screen
class ChatScreen extends StatefulWidget {
  final KshanaContact contact;
  final Function onMessageSent;

  const ChatScreen({
    Key? key,
    required this.contact,
    required this.onMessageSent,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add some mock messages
    if (widget.contact.name == 'Kshana Support') {
      _messages.add(
        ChatMessage(
          sender: widget.contact.name,
          message: 'Welcome to Kshana! How can I help you today?',
          timestamp: DateTime.now().subtract(Duration(minutes: 10)),
          isRead: true,
        ),
      );
      _messages.add(
        ChatMessage(
          sender: widget.contact.name,
          message: 'Remember, you earn 5 coins for every 50 messages you send!',
          timestamp: DateTime.now().subtract(Duration(minutes: 8)),
          isRead: true,
        ),
      );
    } else {
      _messages.add(
        ChatMessage(
          sender: widget.contact.name,
          message: 'Hi there! How are you?',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          isRead: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      // Add user's message
      _messages.add(
        ChatMessage(
          sender: 'You',
          message: message,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );

      // Track message for rewards
      widget.onMessageSent();

      // Simulate reply after 1 second
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                sender: widget.contact.name,
                message: _generateAutoReply(message),
                timestamp: DateTime.now(),
                isRead: true,
              ),
            );

            // Scroll to bottom
            _scrollToBottom();
          });
        }
      });
    });

    // Scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAutoReply(String message) {
    // Simple auto-replies
    if (message.toLowerCase().contains('hello') ||
        message.toLowerCase().contains('hi') ||
        message.toLowerCase().contains('hey')) {
      return 'Hello! How can I help you today?';
    } else if (message.toLowerCase().contains('how are you')) {
      return 'I\'m doing great, thanks for asking! How about you?';
    } else if (message.toLowerCase().contains('bye') ||
        message.toLowerCase().contains('goodbye')) {
      return 'Goodbye! Talk to you later!';
    } else if (message.toLowerCase().contains('thank')) {
      return 'You\'re welcome! 😊';
    } else if (message.toLowerCase().contains('coin') ||
        message.toLowerCase().contains('reward')) {
      return 'You can earn coins by using Kshana features! Send 50 messages to earn 5 coins, or call for 20 minutes to earn 5 coins.';
    } else {
      // Generic responses
      final responses = [
        'That\'s interesting!',
        'I see what you mean.',
        'Thanks for sharing!',
        'Got it!',
        'I understand.',
        'Let me think about that...',
        'Interesting perspective!',
      ];

      return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(widget.contact.name[0]),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.contact.name,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.contact.status,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              Navigator.pop(context);
              // Simulate call
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              Navigator.pop(context);
              // Simulate video call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message.sender == 'You';

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 8,
                      left: isUserMessage ? 48 : 0,
                      right: isUserMessage ? 0 : 48,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.message),
                        SizedBox(height: 4),
                        Text(
                          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    // Show emoji picker
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model classes
class KshanaContact {
  final String name;
  final String username;
  final String profileImage;
  final String status;
  final DateTime lastSeen;

  KshanaContact({
    required this.name,
    required this.username,
    required this.profileImage,
    required this.status,
    required this.lastSeen,
  });
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}

class CallLog {
  final String contactName;
  final DateTime timestamp;
  final Duration duration;
  final bool isIncoming;
  final bool isVideoCall;

  CallLog({
    required this.contactName,
    required this.timestamp,
    required this.duration,
    required this.isIncoming,
    required this.isVideoCall,
  });
}