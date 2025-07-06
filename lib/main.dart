import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard_app/providers/score_provider.dart';
import 'package:scorecard_app/services/offline_handler.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to resubmit any unsent data saved offline
  await OfflineHandler.tryResubmitSavedData();

  // Initialize the form provider
  final formProvider = FormProvider();
  await formProvider.loadSavedForm(); // custom method you added

  runApp(
    ChangeNotifierProvider<FormProvider>.value(
      value: formProvider,
      child: const ScoreCardApp(),
    ),
  );
}
