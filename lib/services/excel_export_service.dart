import 'dart:typed_data';
import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/documents_model.dart';

class ExcelExportService {
  static void exportDocuments(List<DocumentModel> docs) {
    final excel = Excel.createExcel();

    final sheet = excel.sheets[excel.getDefaultSheet()]!;

    // 🟩 HEADER
    sheet.appendRow([
      TextCellValue('الصنف'),
      TextCellValue('الرقم'),
      TextCellValue('التاريخ'),
      TextCellValue('صادر من'),
      TextCellValue('وارد إلى'),
      TextCellValue('الموضوع'),
      TextCellValue('كلمات دلالية'),
      TextCellValue('ملاحظات'),
      TextCellValue('الحفظ الورقي'),
      TextCellValue('مرفقات'),
    ]);

    // 🟦 DATA
    for (final d in docs) {
      final keywords = d.keywords ?? [];
      final attachments = d.attachments ?? [];

      sheet.appendRow([
        TextCellValue(d.categoryName ?? ''),
        TextCellValue(d.number ?? ''),
        TextCellValue(
          d.date == null
              ? ''
              : DateFormat.yMd('ar').format(d.date!),
        ),
        TextCellValue(d.from ?? ''),
        TextCellValue(d.to ?? ''),
        TextCellValue(d.subject ?? ''),
        TextCellValue(
          keywords.isEmpty ? '' : keywords.join(', '),
        ),
        TextCellValue(d.notes ?? ''),
        TextCellValue(d.paperArchive ?? ''),
        TextCellValue(attachments.length.toString()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final blob = html.Blob(
      [Uint8List.fromList(bytes)],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'documents.xlsx')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
