import 'package:flutter/material.dart';

class NewWidget extends StatelessWidget {
  // Add any parameters your widget needs
  final String text;

  const NewWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(text),
    );
  }
}