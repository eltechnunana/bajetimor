import 'dart:convert';
import 'package:flutter/foundation.dart';

// Web-only download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

import '../repositories/income_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/investment_repository.dart';
import '../repositories/category_repository.dart';

/// Service to export application data in portable formats.
class ExportService {
  final IncomeRepository _incomeRepo = IncomeRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final BudgetRepository _budgetRepo = BudgetRepository();
  final InvestmentRepository _investmentRepo = InvestmentRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  /// Export all data as a JSON file. On Web, triggers a download.
  Future<String> exportAllAsJson() async {
    // Collect data
    final incomes = await _incomeRepo.getAllIncome();
    final expenses = await _expenseRepo.getAllExpenses();
    final budgets = await _budgetRepo.getAllBudgets();
    final investments = await _investmentRepo.getAllInvestments();
    final categories = await _categoryRepo.getAllCategories();

    final data = {
      'generatedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'categories': categories.map((c) => c.toJson()).toList(),
      'income': incomes.map((i) => i.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'investments': investments.map((inv) => inv.toJson()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final fileName = 'bajetimor_export_${_dateStamp()}.json';

    if (kIsWeb) {
      final bytes = utf8.encode(jsonStr);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }

    return fileName;
  }

  /// Export all data as a PDF file with simple tables per section.
  Future<String> exportAllAsPdf() async {
    final incomes = await _incomeRepo.getAllIncome();
    final expenses = await _expenseRepo.getAllExpenses();
    final budgets = await _budgetRepo.getAllBudgets();
    final investments = await _investmentRepo.getAllInvestments();
    final categories = await _categoryRepo.getAllCategories();

    final doc = pw.Document();

    pw.Widget section(String title, List<List<String>> rows) {
      final headers = rows.isNotEmpty ? rows.first : <String>[];
      final dataRows = rows.length > 1 ? rows.sublist(1) : <List<String>>[];
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(headers: headers, data: dataRows, cellAlignment: pw.Alignment.centerLeft, headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold), cellStyle: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Bajetimor Export', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('Generated at: ${DateTime.now().toIso8601String()}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),
          section('Categories', [
            ['ID', 'Name', 'Type'],
            ...categories.map((c) => [c.id?.toString() ?? '', c.name, c.type.name])
          ]),
          section('Income', [
            ['ID', 'Date', 'Amount', 'Category', 'Note'],
            ...incomes.map((i) => [
              i.id?.toString() ?? '',
              i.date.toIso8601String(),
              i.amount.toStringAsFixed(2),
              i.category?.name ?? '',
              i.note ?? ''
            ])
          ]),
          section('Expenses', [
            ['ID', 'Date', 'Amount', 'Category', 'Note'],
            ...expenses.map((e) => [
              e.id?.toString() ?? '',
              e.date.toIso8601String(),
              e.amount.toStringAsFixed(2),
              e.category?.name ?? '',
              e.note ?? ''
            ])
          ]),
          section('Budgets', [
            ['ID', 'Category', 'Period', 'Start', 'End', 'Amount'],
            ...budgets.map((b) => [
              b.id?.toString() ?? '',
              b.category?.name ?? '',
              b.period.name,
              b.startDate.toIso8601String(),
              b.endDate.toIso8601String(),
              b.amount.toStringAsFixed(2)
            ])
          ]),
          section('Investments', [
            ['ID', 'Name', 'Type', 'Date', 'Initial', 'Current', 'Note'],
            ...investments.map((inv) => [
              inv.id?.toString() ?? '',
              inv.type, // Using type as name label
              inv.type,
              inv.date.toIso8601String(),
              inv.amount.toStringAsFixed(2),
              (inv.currentValue ?? inv.amount).toStringAsFixed(2),
              inv.note ?? ''
            ])
          ]),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = 'bajetimor_export_${_dateStamp()}.pdf';

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }

    return fileName;
  }

  /// Export all data as an Excel (.xlsx) file with separate sheets.
  Future<String> exportAllAsExcel() async {
    final incomes = await _incomeRepo.getAllIncome();
    final expenses = await _expenseRepo.getAllExpenses();
    final budgets = await _budgetRepo.getAllBudgets();
    final investments = await _investmentRepo.getAllInvestments();
    final categories = await _categoryRepo.getAllCategories();

    final excel = Excel.createExcel();

    void addSheet(String name, List<List<dynamic>> rows) {
      final sheet = excel[name];
      for (final row in rows) {
        sheet.appendRow(row);
      }
    }

    addSheet('Categories', [
      ['ID', 'Name', 'Type', 'Icon', 'Color'],
      ...categories.map((c) => [c.id, c.name, c.type.name, c.icon, c.color])
    ]);

    addSheet('Income', [
      ['ID', 'Date', 'Amount', 'Category', 'Note'],
      ...incomes.map((i) => [i.id, i.date.toIso8601String(), i.amount, i.category?.name, i.note])
    ]);

    addSheet('Expenses', [
      ['ID', 'Date', 'Amount', 'Category', 'Note'],
      ...expenses.map((e) => [e.id, e.date.toIso8601String(), e.amount, e.category?.name, e.note])
    ]);

    addSheet('Budgets', [
      ['ID', 'Category', 'Period', 'Start', 'End', 'Amount', 'Active'],
      ...budgets.map((b) => [b.id, b.category?.name, b.period.name, b.startDate.toIso8601String(), b.endDate.toIso8601String(), b.amount, b.isActive])
    ]);

    addSheet('Investments', [
      ['ID', 'Name', 'Type', 'Date', 'Initial', 'Current', 'ExpectedReturn', 'Note'],
      ...investments.map((inv) => [inv.id, inv.type, inv.type, inv.date.toIso8601String(), inv.amount, inv.currentValue ?? inv.amount, inv.expectedReturn, inv.note])
    ]);

    final bytes = excel.encode()!;
    final fileName = 'bajetimor_export_${_dateStamp()}.xlsx';

    if (kIsWeb) {
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }

    return fileName;
  }

  String _dateStamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}