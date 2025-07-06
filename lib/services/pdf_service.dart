import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> previewPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("📍 Station: ${data['stationName']}"),
            pw.Text("📅 Date: ${data['inspectionDate']}"),
            pw.SizedBox(height: 10),
            pw.Text("Scores:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...data['scores'].entries.map((e) =>
              pw.Text("${e.key}: ${e.value.join(', ')}")),
            pw.SizedBox(height: 10),
            pw.Text("Remarks:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...data['remarks'].entries.map((e) =>
              pw.Text("${e.key}: ${e.value}")),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
