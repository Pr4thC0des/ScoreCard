import 'package:flutter/material.dart';
import 'package:scorecard_app/app.dart'; // contains themeNotifier

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top-right toggle switch
          Positioned(
            top: 40,
            right: 20,
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
      color: Theme.of(context).iconTheme.color,
    ),
    Switch.adaptive(
      activeColor: Colors.tealAccent,
      value: currentMode == ThemeMode.dark,
      onChanged: (bool val) {
        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
      },
    ),
  ],
);

              },
            ),
          ),

          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Clean Train Station Scorecard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/form');
                  },
                  child: const Text(
                    "Start Scorecard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text("View Scorecards"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/view-scorecards');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
