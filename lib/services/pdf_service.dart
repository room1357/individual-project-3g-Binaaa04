import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/expense_manager.dart';

class PdfService {
  static Future<File?> exportExpenses(List<ExpenseWithCategory> items, {String fileName = 'expenses.pdf'}) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return null;

    final doc = pw.Document();

    final tableHeaders = ['Title', 'Category', 'Amount', 'Date', 'Description'];
    final tableData = items
        .map((e) => [
              e.title,
              e.categoryName,
              e.amount.toString(),
              e.date.toString().split('.').first,
              e.description,
            ])
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Expense Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(2.5),
            },
          ),
        ],
      ),
    );

    final dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}


