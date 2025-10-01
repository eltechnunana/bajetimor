import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/income.dart';
import '../data/repositories/income_repository.dart';

/// Provider for IncomeRepository
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepository();
});

/// Provider for all income entries
final incomeProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getAllIncome();
});

/// Provider for recent income entries
final recentIncomeProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getRecentIncome(limit: 10);
});

/// StateNotifier for managing income state
class IncomeNotifier extends StateNotifier<AsyncValue<List<Income>>> {
  IncomeNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadIncome();
  }

  final IncomeRepository _repository;

  /// Load all income entries
  Future<void> loadIncome() async {
    state = const AsyncValue.loading();
    try {
      final income = await _repository.getAllIncome();
      state = AsyncValue.data(income);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new income entry
  Future<void> addIncome(Income income) async {
    try {
      await _repository.insertIncome(income);
      await loadIncome(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing income entry
  Future<void> updateIncome(Income income) async {
    try {
      await _repository.updateIncome(income);
      await loadIncome(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete an income entry
  Future<void> deleteIncome(int id) async {
    try {
      await _repository.deleteIncome(id);
      await loadIncome(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search income entries
  Future<List<Income>> searchIncome(String query) async {
    try {
      return await _repository.searchIncome(query);
    } catch (error) {
      return [];
    }
  }

  /// Get income by date range
  Future<List<Income>> getIncomeByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getIncomeByDateRange(startDate, endDate);
    } catch (error) {
      return [];
    }
  }

  /// Get total income for date range
  Future<double> getTotalIncomeByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getTotalIncomeByDateRange(startDate, endDate);
    } catch (error) {
      return 0.0;
    }
  }
}

/// Provider for IncomeNotifier
final incomeNotifierProvider = StateNotifierProvider<IncomeNotifier, AsyncValue<List<Income>>>((ref) {
  final repository = ref.read(incomeRepositoryProvider);
  return IncomeNotifier(repository);
});

/// Provider for a specific income entry by ID
final incomeByIdProvider = FutureProvider.family<Income?, int>((ref, id) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getIncomeById(id);
});

/// Provider for income by date range
final incomeByDateRangeProvider = FutureProvider.family<List<Income>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getIncomeByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for total income by date range
final totalIncomeByDateRangeProvider = FutureProvider.family<double, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getTotalIncomeByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for current month income
final currentMonthIncomeProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getIncomeByDateRange(startDate, endDate);
});

/// Provider for current month total income
final currentMonthTotalIncomeProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getTotalIncomeByDateRange(startDate, endDate);
});

/// Provider for this week income
final thisWeekIncomeProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getIncomeByDateRange(startDate, endDate);
});

/// Provider for this week total income
final thisWeekTotalIncomeProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getTotalIncomeByDateRange(startDate, endDate);
});

/// Provider for today's income
final todayIncomeProvider = FutureProvider<List<Income>>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getIncomeByDateRange(startDate, endDate);
});

/// Provider for today's total income
final todayTotalIncomeProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(incomeRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getTotalIncomeByDateRange(startDate, endDate);
});

/// Provider for income by category for date range
final incomeByCategoryProvider = FutureProvider.family<Map<int, double>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getIncomeByCategoryForDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for monthly income totals
final monthlyIncomeTotalsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final repository = ref.read(incomeRepositoryProvider);
  return await repository.getMonthlyIncomeTotals(year);
});