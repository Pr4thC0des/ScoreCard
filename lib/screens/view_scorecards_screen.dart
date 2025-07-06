import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ViewScorecardsScreen extends StatefulWidget {
  const ViewScorecardsScreen({super.key});

  @override
  State<ViewScorecardsScreen> createState() => _ViewScorecardsScreenState();
}

class _ViewScorecardsScreenState extends State<ViewScorecardsScreen> {
  List<Map<String, dynamic>> submissions = [];
  Map<String, dynamic>? _lastDeleted;
  int? _lastDeletedIndex;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    loadSubmissions();
  }

  Future<void> loadSubmissions() async {
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList('submission_history') ?? [];

  final uniqueEncoded = <String>{};
  final uniqueSubmissions = <Map<String, dynamic>>[];

  for (var entry in history) {
    if (uniqueEncoded.add(entry)) {
      uniqueSubmissions.add(jsonDecode(entry));
    }
  }

  setState(() {
    submissions = uniqueSubmissions;
    _showSwipeHint = submissions.isNotEmpty;
  });

  // Save the de-duplicated list back to shared preferences
  final updatedHistory = uniqueSubmissions.map(jsonEncode).toList();
  await prefs.setStringList('submission_history', updatedHistory);
}

  Future<void> saveSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedHistory = submissions.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('submission_history', updatedHistory);
  }

  Future<void> deleteSubmission(int index) async {
    _lastDeleted = submissions[index];
    _lastDeletedIndex = index;

    setState(() {
      submissions.removeAt(index);
    });

    await saveSubmissions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Scorecard deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            undoDeletion();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void undoDeletion() async {
    if (_lastDeleted != null && _lastDeletedIndex != null) {
      setState(() {
        submissions.insert(_lastDeletedIndex!, _lastDeleted!);
      });
      await saveSubmissions();
      _lastDeleted = null;
      _lastDeletedIndex = null;
    }
  }

  Future<void> deleteAllSubmissions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete All Scorecards"),
        content: const Text("Are you sure you want to delete all submitted scorecards?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete All"),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        submissions.clear();
        _showSwipeHint = false;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('submission_history');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All scorecards deleted")),
      );
    }
  }

  Future<void> previewAllScorecardsPDF() async {
    final pdf = pw.Document();

    for (var entry in submissions) {
      final date = entry['inspectionDate']?.split('T').first ?? 'Unknown Date';
      final station = entry['stationName'] ?? 'Unknown Station';
      final scores = entry['scores'] as Map<String, dynamic>;
      final remarks = entry['remarks'] as Map<String, dynamic>;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Station: $station', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date: $date'),
              pw.SizedBox(height: 10),
              pw.Text('Scores:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...scores.entries.map(
                (e) => pw.Text('${e.key}: ${(e.value as List).join(", ")}'),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Remarks:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...remarks.entries.map(
                (e) => pw.Text('${e.key}: ${e.value}'),
              ),
              pw.Divider(),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> previewSingleScorecardPDF(Map<String, dynamic> entry) async {
    final pdf = pw.Document();

    final date = entry['inspectionDate']?.split('T').first ?? 'Unknown Date';
    final station = entry['stationName'] ?? 'Unknown Station';
    final scores = entry['scores'] as Map<String, dynamic>;
    final remarks = entry['remarks'] as Map<String, dynamic>;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Station: $station', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: $date'),
            pw.SizedBox(height: 10),
            pw.Text('Scores:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...scores.entries.map(
              (e) => pw.Text('${e.key}: ${(e.value as List).join(", ")}'),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Remarks:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...remarks.entries.map(
              (e) => pw.Text('${e.key}: ${e.value}'),
            ),
            pw.Divider(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: const Text("Scorecards"),
        actions: [
          if (submissions.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Preview All as PDF",
              onPressed: previewAllScorecardsPDF,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Delete All",
              onPressed: deleteAllSubmissions,
            ),
          ],
        ],
      ),
      body: submissions.isEmpty
          ? const Center(child: Text("No scorecards submitted yet."))
          : Column(
              children: [
                if (_showSwipeHint)
                  Container(
                    width: double.infinity,
                    color: Colors.yellow[100],
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(Icons.swipe_left, color: Colors.black54),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Swipe left on a scorecard to delete it.",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _showSwipeHint = false),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final entry = submissions[index];
                      final date = entry['inspectionDate']?.split('T').first ?? 'Unknown Date';
                      final station = entry['stationName'] ?? 'Unknown Station';

                      return Dismissible(
                        key: ValueKey(entry.hashCode),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Scorecard"),
                              content: const Text("Are you sure you want to delete this scorecard?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("Delete"),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => deleteSubmission(index),
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(station),
                            subtitle: Text("Date: $date"),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Details - $station"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Date: $date"),
                                        const SizedBox(height: 10),
                                        Text("Scores:"),
                                        ...(entry['scores'] as Map<String, dynamic>).entries.map(
                                          (e) => Text("${e.key}: ${(e.value as List).join(', ')}"),
                                        ),
                                        const SizedBox(height: 10),
                                        Text("Remarks:"),
                                        ...(entry['remarks'] as Map<String, dynamic>).entries.map(
                                          (e) => Text("${e.key}: ${e.value}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("Close"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    ElevatedButton(
                                      child: const Text("Preview PDF"),
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        previewSingleScorecardPDF(entry); // Open PDF preview
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
