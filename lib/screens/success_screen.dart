import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Scorecard Submitted!", style: TextStyle(fontSize: 18)),
            ElevatedButton(
              child: const Text("Back to Home"),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            )
          ],
        ),
      ),
    );
  }
}
