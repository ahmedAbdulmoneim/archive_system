import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/documents_model.dart';

class PdfExportService {
  static Future<void> exportDocuments(List<DocumentModel> docs) async {
    final pdf = pw.Document();

    // ✅ تحميل خط عربي
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          pw.Text(
            'أرشيف الوثائق',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),

          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerRight,
            headers: const [
              'الصنف',
              'الرقم',
              'التاريخ',
              'صادر من',
              'وارد إلى',
              'الموضوع',
              'كلمات دلالية',
              'ملاحظات',
              'مرفقات',
            ],
            data: docs.map((d) {
              return [
                d.categoryName,
                d.number,
                d.date != null
                    ? d.date!.toIso8601String().split('T').first
                    : '',
                d.from,
                d.to,
                d.subject,
                d.keywords.join(', '),
                d.notes,
                d.attachments.length.toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'documents.pdf',
    );
  }
}
