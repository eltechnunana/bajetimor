import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/expense.dart';
import '../data/repositories/expense_repository.dart';

/// Provider for ExpenseRepository
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

/// Provider for all expense entries
final expenseProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getAllExpenses();
});

/// Provider for recent expense entries
final recentExpenseProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getRecentExpenses(limit: 10);
});

/// StateNotifier for managing expense state
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  ExpenseNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  final ExpenseRepository _repository;

  /// Load all expense entries
  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _repository.getAllExpenses();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new expense entry
  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.insertExpense(expense);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing expense entry
  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete an expense entry
  Future<void> deleteExpense(int id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search expense entries
  Future<List<Expense>> searchExpenses(String query) async {
    try {
      return await _repository.searchExpenses(query);
    } catch (error) {
      return [];
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getExpensesByDateRange(startDate, endDate);
    } catch (error) {
      return [];
    }
  }

  /// Get total expenses for date range
  Future<double> getTotalExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getTotalExpensesByDateRange(startDate, endDate);
    } catch (error) {
      return 0.0;
    }
  }
}

/// Provider for ExpenseNotifier
final expenseNotifierProvider = StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  final repository = ref.read(expenseRepositoryProvider);
  return ExpenseNotifier(repository);
});

/// Provider for a specific expense entry by ID
final expenseByIdProvider = FutureProvider.family<Expense?, int>((ref, id) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getExpenseById(id);
});

/// Provider for expenses by date range
final expensesByDateRangeProvider = FutureProvider.family<List<Expense>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getExpensesByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for total expenses by date range
final totalExpensesByDateRangeProvider = FutureProvider.family<double, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getTotalExpensesByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for current month expenses
final currentMonthExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getExpensesByDateRange(startDate, endDate);
});

/// Provider for current month total expenses
final currentMonthTotalExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getTotalExpensesByDateRange(startDate, endDate);
});

/// Provider for this week expenses
final thisWeekExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getExpensesByDateRange(startDate, endDate);
});

/// Provider for this week total expenses
final thisWeekTotalExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getTotalExpensesByDateRange(startDate, endDate);
});

/// Provider for today's expenses
final todayExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getExpensesByDateRange(startDate, endDate);
});

/// Provider for today's total expenses
final todayTotalExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getTotalExpensesByDateRange(startDate, endDate);
});

/// Provider for expenses by category for date range
final expensesByCategoryProvider = FutureProvider.family<Map<int, double>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getExpensesByCategoryForDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for monthly expense totals
final monthlyExpenseTotalsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getMonthlyExpenseTotals(year);
});

/// Provider for top spending categories
final topSpendingCategoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(expenseRepositoryProvider);
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  final limit = params['limit'] as int? ?? 5;
  return await repository.getTopSpendingCategories(startDate, endDate, limit: limit);
});

/// Provider for daily expense totals
final dailyExpenseTotalsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getDailyExpenseTotals(dateRange['startDate']!, dateRange['endDate']!);
});