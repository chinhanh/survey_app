import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/survey.dart';

class PdfService {
  static Future<File> generatePdf(Survey survey) async {
    final pdf = pw.Document();
    final image = survey.imagePath != null
        ? pw.MemoryImage(File(survey.imagePath!).readAsBytesSync())
        : null;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Báo cáo Kh?o sát Ban công/Sân vu?n', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            if (image != null) pw.Image(image, width: 200, height: 200),
            pw.SizedBox(height: 20),
            pw.Text('Di?n tích: ${survey.area} m²'),
            pw.Text('Hu?ng n?ng: ${survey.sunDirection}'),
            pw.Text('Lo?i cây: ${survey.plantType}'),
            pw.Text('Nhu c?u: ${survey.need}'),
            pw.Text('Ngân sách: ${survey.budget}'),
            pw.SizedBox(height: 20),
            pw.Text('G?i ý: ${survey.budget == "Trên 30tr" ? "S? d?ng ch?u composite" : "S? d?ng ch?u nh?a tái ch?"}'),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/survey_${survey.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

