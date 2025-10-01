import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/pdf_export_service.dart';
import '../core/models/income.dart';
import '../core/models/expense.dart';
import '../core/models/budget.dart';
import '../core/models/investment.dart';
import 'income_provider.dart';
import 'expense_provider.dart';
import 'budget_provider.dart';
import 'investment_provider.dart';

/// Provider for PDF export functionality
final pdfExportServiceProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});

/// Provider for generating comprehensive financial report
final financialReportProvider = FutureProvider.family<List<int>, Map<String, dynamic>>((ref, params) async {
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  final title = params['title'] as String?;

  // Get all data
  final incomes = await ref.read(incomeProvider.future);
  final expenses = await ref.read(expenseProvider.future);
  final budgets = await ref.read(budgetProvider.future);
  final investments = await ref.read(investmentProvider.future);

  // Filter data by date range
  final filteredIncomes = incomes.where((income) =>
    income.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    income.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  final filteredExpenses = expenses.where((expense) =>
    expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    expense.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  final filteredInvestments = investments.where((investment) =>
    investment.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    investment.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  // Generate PDF
  final pdfData = await PdfExportService.generateFinancialReport(
    incomes: filteredIncomes,
    expenses: filteredExpenses,
    budgets: budgets,
    investments: filteredInvestments,
    startDate: startDate,
    endDate: endDate,
    title: title,
  );

  return pdfData;
});

/// Provider for generating transactions report
final transactionsReportProvider = FutureProvider.family<List<int>, Map<String, dynamic>>((ref, params) async {
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;

  // Get transaction data
  final incomes = await ref.read(incomeProvider.future);
  final expenses = await ref.read(expenseProvider.future);

  // Filter data by date range
  final filteredIncomes = incomes.where((income) =>
    income.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    income.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  final filteredExpenses = expenses.where((expense) =>
    expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    expense.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  // Generate PDF
  final pdfData = await PdfExportService.generateTransactionsReport(
    incomes: filteredIncomes,
    expenses: filteredExpenses,
    startDate: startDate,
    endDate: endDate,
  );

  return pdfData;
});

/// Provider for generating budget report
final budgetReportProvider = FutureProvider.family<List<int>, Map<String, dynamic>>((ref, params) async {
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;

  // Get budget and expense data
  final budgets = await ref.read(budgetProvider.future);
  final expenses = await ref.read(expenseProvider.future);

  // Filter expenses by date range
  final filteredExpenses = expenses.where((expense) =>
    expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    expense.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();

  // Generate PDF
  final pdfData = await PdfExportService.generateBudgetReport(
    budgets: budgets,
    expenses: filteredExpenses,
    startDate: startDate,
    endDate: endDate,
  );

  return pdfData;
});

/// State notifier for managing export operations
class PdfExportNotifier extends StateNotifier<AsyncValue<void>> {
  PdfExportNotifier() : super(const AsyncValue.data(null));

  /// Export financial report
  Future<void> exportFinancialReport({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Budget> budgets,
    required List<Investment> investments,
    required DateTime startDate,
    required DateTime endDate,
    String? title,
    String? fileName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final pdfData = await PdfExportService.generateFinancialReport(
        incomes: incomes,
        expenses: expenses,
        budgets: budgets,
        investments: investments,
        startDate: startDate,
        endDate: endDate,
        title: title,
      );

      await PdfExportService.savePdf(
        pdfData,
        fileName ?? 'financial_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Export transactions report
  Future<void> exportTransactionsReport({
    required List<Income> incomes,
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final pdfData = await PdfExportService.generateTransactionsReport(
        incomes: incomes,
        expenses: expenses,
        startDate: startDate,
        endDate: endDate,
      );

      await PdfExportService.savePdf(
        pdfData,
        fileName ?? 'transactions_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Export budget report
  Future<void> exportBudgetReport({
    required List<Budget> budgets,
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final pdfData = await PdfExportService.generateBudgetReport(
        budgets: budgets,
        expenses: expenses,
        startDate: startDate,
        endDate: endDate,
      );

      await PdfExportService.savePdf(
        pdfData,
        fileName ?? 'budget_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Print financial report
  Future<void> printFinancialReport({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Budget> budgets,
    required List<Investment> investments,
    required DateTime startDate,
    required DateTime endDate,
    String? title,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final pdfData = await PdfExportService.generateFinancialReport(
        incomes: incomes,
        expenses: expenses,
        budgets: budgets,
        investments: investments,
        startDate: startDate,
        endDate: endDate,
        title: title,
      );

      await PdfExportService.printPdf(pdfData);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for PDF export operations
final pdfExportNotifierProvider = StateNotifierProvider<PdfExportNotifier, AsyncValue<void>>((ref) {
  return PdfExportNotifier();
});