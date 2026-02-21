import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/documents_model.dart';

class PdfExportService {
  static Future<void> exportDocuments(List<DocumentModel> docs) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final today = DateFormat.yMd('ar').format(DateTime.now());
    final logo = await imageFromAssetBundle('assets/logo.jpg');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        margin: const pw.EdgeInsets.fromLTRB(24, 32, 24, 32),

        // ================= HEADER =================
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(logo, width: 40),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'نظام أرشفة الوثائق',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'التاريخ: $today',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },

        // ================= FOOTER =================
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        },

        // ================= BODY =================
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
              'الحفظ الورقي',
              'مرفقات',
            ],
            data: docs.map((d) {
              final keywords = d.keywords ?? [];
              final attachments = d.attachments ?? [];

              return [
                d.categoryName ?? '',
                d.number ?? '',
                d.date == null
                    ? ''
                    : DateFormat.yMd('ar').format(d.date!),
                d.from ?? '',
                d.to ?? '',
                d.subject ?? '',
                keywords.isEmpty ? '' : keywords.join(', '),
                d.notes ?? '',
                d.paperArchive ?? '',
                attachments.length.toString(),
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
