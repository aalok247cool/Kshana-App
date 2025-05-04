import 'package:flutter/material.dart';

class TaskZonePage extends StatefulWidget {
  // Add this parameter to match what main.dart expects
  final Function? onTaskCompleted;

  // Constructor with the parameter
  const TaskZonePage({super.key, this.onTaskCompleted});

  @override
  _TaskZonePageState createState() => _TaskZonePageState();
}

class _TaskZonePageState extends State<TaskZonePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _coinBalance = 425;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Earning Tasks'),
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
          isScrollable: true,
          tabs: [
            Tab(text: 'Market Research'),
            Tab(text: 'App Testing'),
            Tab(text: 'Content Creation'),
            Tab(text: 'Micro Jobs'),
            Tab(text: 'Crypto Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Market Research Tab
          _buildMarketResearchTasks(),

          // App Testing Tab
          _buildAppTestingTasks(),

          // Content Creation Tab
          _buildContentCreationTasks(),

          // Micro Jobs Tab
          _buildMicroJobsTasks(),

          // Crypto Tasks Tab
          _buildCryptoTasks(),
        ],
      ),
    );
  }

  Widget _buildMarketResearchTasks() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard(
          title: 'User Interview Study',
          description: 'Participate in a 30-minute user interview about mobile app usage',
          iconData: Icons.record_voice_over,
          iconColor: Colors.purple,
          timeRequired: '30',
          reward: '₹500',
        ),
        _buildTaskCard(
          title: 'Product Testing',
          description: 'Test a new skincare product and provide detailed feedback',
          iconData: Icons.science,
          iconColor: Colors.blue,
          timeRequired: '45',
          reward: '₹750',
        ),
        _buildTaskCard(
          title: 'Focus Group',
          description: 'Join a virtual focus group about food delivery services',
          iconData: Icons.groups,
          iconColor: Colors.green,
          timeRequired: '60',
          reward: '₹1000',
        ),
      ],
    );
  }

  Widget _buildAppTestingTasks() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard(
          title: 'Gaming App Test',
          description: 'Test a new mobile game and report bugs or issues',
          iconData: Icons.sports_esports,
          iconColor: Colors.red,
          timeRequired: '45',
          reward: '₹300',
        ),
        _buildTaskCard(
          title: 'Fitness App Evaluation',
          description: 'Try a new fitness app and provide detailed feedback',
          iconData: Icons.fitness_center,
          iconColor: Colors.orange,
          timeRequired: '30',
          reward: '₹250',
        ),
        _buildTaskCard(
          title: 'Banking App User Flow',
          description: 'Test specific features in a banking app prototype',
          iconData: Icons.account_balance,
          iconColor: Colors.indigo,
          timeRequired: '20',
          reward: '₹350',
        ),
      ],
    );
  }

  Widget _buildContentCreationTasks() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard(
          title: 'Product Review',
          description: 'Write a 300-word review for a smartphone accessory',
          iconData: Icons.rate_review,
          iconColor: Colors.deepPurple,
          timeRequired: '30',
          reward: '₹200',
        ),
        _buildTaskCard(
          title: 'Photo Assignment',
          description: 'Take 5 high-quality photos of street food in your area',
          iconData: Icons.photo_camera,
          iconColor: Colors.cyan,
          timeRequired: '45',
          reward: '₹350',
        ),
        _buildTaskCard(
          title: 'Social Media Content',
          description: 'Create short video content for a fashion brand',
          iconData: Icons.video_call,
          iconColor: Colors.pink,
          timeRequired: '60',
          reward: '₹400',
        ),
      ],
    );
  }

  Widget _buildMicroJobsTasks() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard(
          title: 'Data Entry',
          description: 'Enter product information from images into a spreadsheet',
          iconData: Icons.input,
          iconColor: Colors.teal,
          timeRequired: '40',
          reward: '₹150',
        ),
        _buildTaskCard(
          title: 'Audio Transcription',
          description: 'Transcribe a 10-minute audio recording to text',
          iconData: Icons.mic,
          iconColor: Colors.amber,
          timeRequired: '30',
          reward: '₹200',
        ),
        _buildTaskCard(
          title: 'Image Tagging',
          description: 'Tag and categorize 100 product images for an e-commerce site',
          iconData: Icons.image,
          iconColor: Colors.brown,
          timeRequired: '25',
          reward: '₹180',
        ),
      ],
    );
  }

  Widget _buildCryptoTasks() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTaskCard(
          title: 'DeFi App Testing',
          description: 'Test a new cryptocurrency wallet app and complete specific actions',
          iconData: Icons.account_balance_wallet,
          iconColor: Colors.deepOrange,
          timeRequired: '30',
          reward: '₹300',
        ),
        _buildTaskCard(
          title: 'NFT Community Engagement',
          description: 'Participate in Discord community activities for an NFT project',
          iconData: Icons.art_track,
          iconColor: Colors.purple,
          timeRequired: '45',
          reward: '₹250',
        ),
        _buildTaskCard(
          title: 'Web3 Survey',
          description: 'Complete a detailed survey about blockchain technology usage',
          iconData: Icons.poll,
          iconColor: Colors.blue,
          timeRequired: '20',
          reward: '₹200',
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required IconData iconData,
    required Color iconColor,
    required String timeRequired,
    required String reward,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '$timeRequired mins',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        reward,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Add task start functionality here
                      _showTaskStartDialog(title, reward);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Start Task'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskStartDialog(String taskTitle, String reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Task'),
        content: Text('You are about to start "$taskTitle" which will reward you with $reward upon completion. Proceed?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Add code to navigate to the specific task page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task started: $taskTitle')),
              );

              // Call the onTaskCompleted callback when task is completed
              // This is what main.dart expects
              if (widget.onTaskCompleted != null) {
                widget.onTaskCompleted!();
              }
            },
            child: Text('Start'),
          ),
        ],
      ),
    );
  }
}