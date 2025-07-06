import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard_app/providers/score_provider.dart';
import 'package:scorecard_app/services/pdf_service.dart';
import 'package:scorecard_app/services/submission_service.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool isSubmitting = false;

  Future<void> submitForm(BuildContext context) async {
    final provider = Provider.of<FormProvider>(context, listen: false);
    final jsonData = provider.toJson();

    setState(() {
      isSubmitting = true;
    });

    final success = await SubmissionService.submitScorecard(jsonData);

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      provider.reset();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/success');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Offline or failed. Saved locally for retry."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(title: const Text("Preview Scorecard")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Station: ${provider.stationName}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              "📅 Date: ${provider.inspectionDate?.toLocal().toIso8601String().split('T')[0] ?? 'Not selected'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: provider.scores.entries.map((entry) {
                  final activity = entry.key;
                  final score = entry.value.join(', ');
                  final remark = provider.getRemark(activity);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(activity),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Scores: $score"),
                          if (remark.isNotEmpty) Text("Remark: $remark"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Preview PDF"),
                  onPressed: () => PdfService.previewPdf(provider.toJson()),
                ),
                isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Submit"),
                        onPressed: () => submitForm(context),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
