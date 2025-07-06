import 'package:flutter/material.dart';
import 'package:scorecard_app/screens/form_screen.dart';
import 'package:scorecard_app/screens/home_screen.dart';
import 'package:scorecard_app/screens/preview_screen.dart';
import 'package:scorecard_app/screens/success_screen.dart';
import 'package:scorecard_app/screens/view_scorecards_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class ScoreCardApp extends StatelessWidget {
  const ScoreCardApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Clean Train Scorecard',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/form': (_) => const ScoreCardFormScreen(),
            '/preview': (_) => const PreviewScreen(),
            '/success': (_) => const SuccessScreen(),
            '/view-scorecards': (_) => const ViewScorecardsScreen(),
          },
        );
      },
    );
  }
}
