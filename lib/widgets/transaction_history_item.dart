import 'package:flutter/material.dart';

class TransactionHistoryItem extends StatelessWidget {
  final String name;
  final String phone;
  final String amount;
  final String date;
  final String type; // 'sent' or 'received'

  const TransactionHistoryItem({
    super.key,
    required this.name,
    required this.phone,
    required this.amount,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = type == 'sent';
    final amountPrefix = isSent ? '-' : '+';
    final amountColor = isSent ? Colors.red : Colors.green;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSent ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              child: Icon(
                isSent ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSent ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${isSent ? 'Paid to' : 'Received from'}: $phone',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix₹$amount',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}