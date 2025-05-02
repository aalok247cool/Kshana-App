import 'package:flutter/material.dart';
import 'referral_zone.dart'; // Correct import based on your project structure

class TaskZonePage extends StatefulWidget {
  final Function(int) onTaskCompleted;

  const TaskZonePage({super.key, required this.onTaskCompleted});

  @override
  State<TaskZonePage> createState() => _TaskZonePageState();
}

class _TaskZonePageState extends State<TaskZonePage> {
  final List<bool> _isTaskCompleted = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Task Zone'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _isTaskCompleted.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 3,
            child: ListTile(
              title: Text('Task ${index + 1}'),
              trailing:
                  _isTaskCompleted[index]
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isTaskCompleted[index] = true;
                          });

                          // Reward coins
                          widget.onTaskCompleted(20); // Add coins

                          // Call the static methods of ReferralZonePage
                          await ReferralZonePage.markTaskCompletionForToday();
                          await ReferralZonePage.rewardReferralIfEligible();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Task ${index + 1} completed! +20 coins',
                              ),
                            ),
                          );
                        },
                        child: const Text('Complete'),
                      ),
            ),
          );
        },
      ),
    );
  }
}
