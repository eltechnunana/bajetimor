import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/investment.dart';
import '../models/category.dart';

/// Service for generating PDF reports from financial data
class PdfExportService {
  static const String _appName = 'Bajetimor';
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor _incomeColor = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor _expenseColor = PdfColor.fromInt(0xFFF44336);
  static const PdfColor _investmentColor = PdfColor.fromInt(0xFF9C27B0);

  /// Generate a comprehensive financial report
  static Future<Uint8List> generateFinancialReport({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Budget> budgets,
    required List<Investment> investments,
    required DateTime startDate,
    required DateTime endDate,
    String? title,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'GH₵ ');

    // Calculate totals
    final totalIncome = incomes.fold<double>(0, (sum, income) => sum + income.amount);
    final totalExpenses = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalInvestments = investments.fold<double>(0, (sum, investment) => sum + investment.amount);
    final netWorth = totalIncome - totalExpenses + totalInvestments;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(title ?? 'Financial Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Report period
          _buildReportPeriod(startDate, endDate, dateFormatter),
          pw.SizedBox(height: 20),

          // Financial summary
          _buildFinancialSummary(
            totalIncome,
            totalExpenses,
            totalInvestments,
            netWorth,
            currencyFormatter,
          ),
          pw.SizedBox(height: 30),

          // Income section
          if (incomes.isNotEmpty) ...[
            _buildSectionHeader('Income Transactions', _incomeColor),
            pw.SizedBox(height: 10),
            _buildIncomeTable(incomes, currencyFormatter, dateFormatter),
            pw.SizedBox(height: 20),
          ],

          // Expense section
          if (expenses.isNotEmpty) ...[
            _buildSectionHeader('Expense Transactions', _expenseColor),
            pw.SizedBox(height: 10),
            _buildExpenseTable(expenses, currencyFormatter, dateFormatter),
            pw.SizedBox(height: 20),
          ],

          // Budget section
          if (budgets.isNotEmpty) ...[
            _buildSectionHeader('Budget Overview', _primaryColor),
            pw.SizedBox(height: 10),
            _buildBudgetTable(budgets, currencyFormatter),
            pw.SizedBox(height: 20),
          ],

          // Investment section
          if (investments.isNotEmpty) ...[
            _buildSectionHeader('Investment Portfolio', _investmentColor),
            pw.SizedBox(height: 10),
            _buildInvestmentTable(investments, currencyFormatter, dateFormatter),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate transactions-only report
  static Future<Uint8List> generateTransactionsReport({
    required List<Income> incomes,
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'GH₵ ');

    // Combine and sort transactions
    final allTransactions = <Map<String, dynamic>>[];
    
    for (final income in incomes) {
      allTransactions.add({
        'type': 'Income',
        'amount': income.amount,
        'category': income.category?.name ?? 'Unknown',
        'date': income.date,
        'note': income.note ?? '',
        'color': _incomeColor,
      });
    }
    
    for (final expense in expenses) {
      allTransactions.add({
        'type': 'Expense',
        'amount': -expense.amount, // Negative for expenses
        'category': expense.category?.name ?? 'Unknown',
        'date': expense.date,
        'note': expense.note ?? '',
        'color': _expenseColor,
      });
    }

    allTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Transaction Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildReportPeriod(startDate, endDate, dateFormatter),
          pw.SizedBox(height: 20),
          _buildTransactionTable(allTransactions, currencyFormatter, dateFormatter),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate budget report
  static Future<Uint8List> generateBudgetReport({
    required List<Budget> budgets,
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final currencyFormatter = NumberFormat.currency(symbol: 'GH₵ ');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Budget Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildReportPeriod(startDate, endDate, dateFormatter),
          pw.SizedBox(height: 20),
          _buildBudgetAnalysisTable(budgets, expenses, currencyFormatter),
        ],
      ),
    );

    return pdf.save();
  }

  // Helper methods for building PDF components

  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _appName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          pw.Divider(color: _primaryColor),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportPeriod(
    DateTime startDate,
    DateTime endDate,
    DateFormat dateFormatter,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'Report Period: ${dateFormatter.format(startDate)} - ${dateFormatter.format(endDate)}',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildFinancialSummary(
    double totalIncome,
    double totalExpenses,
    double totalInvestments,
    double netWorth,
    NumberFormat currencyFormatter,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildSummaryItem('Total Income', totalIncome, currencyFormatter, _incomeColor),
              ),
              pw.Expanded(
                child: _buildSummaryItem('Total Expenses', totalExpenses, currencyFormatter, _expenseColor),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildSummaryItem('Total Investments', totalInvestments, currencyFormatter, _investmentColor),
              ),
              pw.Expanded(
                child: _buildSummaryItem('Net Worth', netWorth, currencyFormatter, 
                  netWorth >= 0 ? _incomeColor : _expenseColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    double amount,
    NumberFormat currencyFormatter,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      margin: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            currencyFormatter.format(amount),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildIncomeTable(
    List<Income> incomes,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Note', isHeader: true),
          ],
        ),
        // Data rows
        ...incomes.map((income) => pw.TableRow(
          children: [
            _buildTableCell(dateFormatter.format(income.date)),
            _buildTableCell(income.category?.name ?? 'Unknown'),
            _buildTableCell(currencyFormatter.format(income.amount)),
            _buildTableCell(income.note ?? ''),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildExpenseTable(
    List<Expense> expenses,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Note', isHeader: true),
          ],
        ),
        // Data rows
        ...expenses.map((expense) => pw.TableRow(
          children: [
            _buildTableCell(dateFormatter.format(expense.date)),
            _buildTableCell(expense.category?.name ?? 'Unknown'),
            _buildTableCell(currencyFormatter.format(expense.amount)),
            _buildTableCell(expense.note ?? ''),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildBudgetTable(
    List<Budget> budgets,
    NumberFormat currencyFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Budget Amount', isHeader: true),
            _buildTableCell('Period', isHeader: true),
            _buildTableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...budgets.map((budget) => pw.TableRow(
          children: [
            _buildTableCell(budget.category?.name ?? 'Unknown'),
            _buildTableCell(currencyFormatter.format(budget.amount)),
            _buildTableCell(budget.period.name.toUpperCase()),
            _buildTableCell(budget.isActive ? 'Active' : 'Inactive'),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildInvestmentTable(
    List<Investment> investments,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Current Value', isHeader: true),
          ],
        ),
        // Data rows
        ...investments.map((investment) => pw.TableRow(
          children: [
            _buildTableCell(dateFormatter.format(investment.date)),
            _buildTableCell(investment.category?.name ?? 'Unknown'),
            _buildTableCell(currencyFormatter.format(investment.amount)),
            _buildTableCell(currencyFormatter.format(investment.currentValue ?? investment.amount)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(
    List<Map<String, dynamic>> transactions,
    NumberFormat currencyFormatter,
    DateFormat dateFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Type', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Note', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map((transaction) => pw.TableRow(
          children: [
            _buildTableCell(dateFormatter.format(transaction['date'] as DateTime)),
            _buildTableCell(transaction['type'] as String),
            _buildTableCell(transaction['category'] as String),
            _buildTableCell(currencyFormatter.format((transaction['amount'] as double).abs())),
            _buildTableCell(transaction['note'] as String),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildBudgetAnalysisTable(
    List<Budget> budgets,
    List<Expense> expenses,
    NumberFormat currencyFormatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Budget', isHeader: true),
            _buildTableCell('Spent', isHeader: true),
            _buildTableCell('Remaining', isHeader: true),
            _buildTableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...budgets.map((budget) {
          final categoryExpenses = expenses
              .where((expense) => expense.categoryId == budget.categoryId)
              .fold<double>(0, (sum, expense) => sum + expense.amount);
          final remaining = budget.amount - categoryExpenses;
          final status = remaining >= 0 ? 'On Track' : 'Over Budget';

          return pw.TableRow(
            children: [
              _buildTableCell(budget.category?.name ?? 'Unknown'),
              _buildTableCell(currencyFormatter.format(budget.amount)),
              _buildTableCell(currencyFormatter.format(categoryExpenses)),
              _buildTableCell(currencyFormatter.format(remaining)),
              _buildTableCell(status),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Save PDF to device storage
  static Future<void> savePdf(Uint8List pdfData, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: fileName,
    );
  }

  /// Print PDF directly
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
    );
  }
}