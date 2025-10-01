import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/financial_summary.dart';
import '../data/repositories/financial_summary_repository.dart';

/// Provider for FinancialSummaryRepository
final financialSummaryRepositoryProvider = Provider<FinancialSummaryRepository>((ref) {
  return FinancialSummaryRepository();
});

/// Provider for financial summary by date range
final financialSummaryProvider = FutureProvider.family<FinancialSummary, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getFinancialSummary(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for current month financial summary
final currentMonthSummaryProvider = FutureProvider<FinancialSummary>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getFinancialSummary(startDate, endDate);
});

/// Provider for current year financial summary
final currentYearSummaryProvider = FutureProvider<FinancialSummary>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, 1, 1);
  final endDate = DateTime(now.year, 12, 31);
  return await repository.getFinancialSummary(startDate, endDate);
});

/// Provider for last 30 days financial summary
final last30DaysSummaryProvider = FutureProvider<FinancialSummary>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  return await repository.getFinancialSummary(startDate, endDate);
});

/// Provider for last 7 days financial summary
final last7DaysSummaryProvider = FutureProvider<FinancialSummary>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 7));
  return await repository.getFinancialSummary(startDate, endDate);
});

/// Provider for income breakdown by category
final incomeBreakdownProvider = FutureProvider.family<List<CategorySummary>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getFinancialSummary(dateRange['startDate']!, dateRange['endDate']!);
  return summary.incomeByCategory;
});

/// Provider for expense breakdown by category
final expenseBreakdownProvider = FutureProvider.family<List<CategorySummary>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getFinancialSummary(dateRange['startDate']!, dateRange['endDate']!);
  return summary.expensesByCategory;
});

/// Provider for investment summary by type
final investmentSummaryProvider = FutureProvider.family<List<CategorySummary>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getFinancialSummary(dateRange['startDate']!, dateRange['endDate']!);
  return summary.investmentsByCategory;
});

/// Provider for current month income breakdown
final currentMonthIncomeBreakdownProvider = FutureProvider<List<CategorySummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getCurrentMonthSummary();
  return summary.incomeByCategory;
});

/// Provider for current month expense breakdown
final currentMonthExpenseBreakdownProvider = FutureProvider<List<CategorySummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getCurrentMonthSummary();
  return summary.expensesByCategory;
});

/// Provider for current month investment summary
final currentMonthInvestmentSummaryProvider = FutureProvider<List<CategorySummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final summary = await repository.getCurrentMonthSummary();
  return summary.investmentsByCategory;
});

/// Provider for monthly trend analysis
final monthlyTrendProvider = FutureProvider.family<List<FinancialSummary>, int>((ref, year) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getMonthlyFinancialSummary(year);
});

/// Provider for last 12 months trend
final last12MonthsTrendProvider = FutureProvider<List<FinancialSummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final now = DateTime.now();
  return await repository.getMonthlyFinancialSummary(now.year);
});

/// Provider for last 6 months trend
final last6MonthsTrendProvider = FutureProvider<List<FinancialSummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final now = DateTime.now();
  return await repository.getMonthlyFinancialSummary(now.year);
});

/// Provider for top spending categories
final topSpendingCategoriesProvider = FutureProvider.family<List<CategorySummary>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getTopSpendingCategories(
    params['startDate'] as DateTime,
    params['endDate'] as DateTime,
    limit: params['limit'] as int? ?? 5,
  );
});

/// Provider for current month top spending categories
final currentMonthTopSpendingProvider = FutureProvider<List<CategorySummary>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getTopSpendingCategories(startDate, endDate, limit: 5);
});

/// Provider for daily spending trend
final dailySpendingTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getDailySpendingTrends(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for last 30 days daily spending trend
final last30DaysSpendingTrendProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  return await repository.getDailySpendingTrends(startDate, endDate);
});

/// Provider for investment performance summary
final investmentPerformanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getInvestmentPerformanceSummary();
});

/// Provider for current year investment performance
final currentYearInvestmentPerformanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(financialSummaryRepositoryProvider);
  return await repository.getInvestmentPerformanceSummary();
});

/// StateNotifier for managing financial summary refresh
class FinancialSummaryNotifier extends StateNotifier<DateTime> {
  FinancialSummaryNotifier() : super(DateTime.now());

  /// Refresh all financial data
  void refresh() {
    state = DateTime.now();
  }
}

/// Provider for FinancialSummaryNotifier
final financialSummaryNotifierProvider = StateNotifierProvider<FinancialSummaryNotifier, DateTime>((ref) {
  return FinancialSummaryNotifier();
});

/// Provider that watches for refresh and invalidates other providers
final refreshWatcherProvider = Provider<DateTime>((ref) {
  return ref.watch(financialSummaryNotifierProvider);
});