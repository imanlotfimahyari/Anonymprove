import 'package:flutter/material.dart';

void main() {
  runApp(const FeedbackApp());
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const FoundationPage(),
    );
  }
}

class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Feedback')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48),
              SizedBox(height: 16),
              Text(
                'Constructive feedback, without exposing who said what.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
