import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/investment.dart';
import '../data/repositories/investment_repository.dart';

/// Provider for InvestmentRepository
final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository();
});

/// Provider for all investment entries
final investmentProvider = FutureProvider<List<Investment>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getAllInvestments();
});

/// Provider for recent investment entries
final recentInvestmentProvider = FutureProvider<List<Investment>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getRecentInvestments(limit: 10);
});

/// StateNotifier for managing investment state
class InvestmentNotifier extends StateNotifier<AsyncValue<List<Investment>>> {
  InvestmentNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInvestments();
  }

  final InvestmentRepository _repository;

  /// Load all investment entries
  Future<void> loadInvestments() async {
    state = const AsyncValue.loading();
    try {
      final investments = await _repository.getAllInvestments();
      state = AsyncValue.data(investments);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new investment entry
  Future<void> addInvestment(Investment investment) async {
    try {
      await _repository.insertInvestment(investment);
      await loadInvestments(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing investment entry
  Future<void> updateInvestment(Investment investment) async {
    try {
      await _repository.updateInvestment(investment);
      await loadInvestments(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete an investment entry
  Future<void> deleteInvestment(int id) async {
    try {
      await _repository.deleteInvestment(id);
      await loadInvestments(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search investment entries
  Future<List<Investment>> searchInvestments(String query) async {
    try {
      return await _repository.searchInvestments(query);
    } catch (error) {
      return [];
    }
  }

  /// Get investments by date range
  Future<List<Investment>> getInvestmentsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getInvestmentsByDateRange(startDate, endDate);
    } catch (error) {
      return [];
    }
  }

  /// Get total investment for date range
  Future<double> getTotalInvestmentByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getTotalInvestmentByDateRange(startDate, endDate);
    } catch (error) {
      return 0.0;
    }
  }
}

/// Provider for InvestmentNotifier
final investmentNotifierProvider = StateNotifierProvider<InvestmentNotifier, AsyncValue<List<Investment>>>((ref) {
  final repository = ref.read(investmentRepositoryProvider);
  return InvestmentNotifier(repository);
});

/// Provider for a specific investment entry by ID
final investmentByIdProvider = FutureProvider.family<Investment?, int>((ref, id) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentById(id);
});

/// Provider for investments by date range
final investmentsByDateRangeProvider = FutureProvider.family<List<Investment>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentsByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for total investment by date range
final totalInvestmentByDateRangeProvider = FutureProvider.family<double, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getTotalInvestmentByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for total current value by date range
final totalCurrentValueByDateRangeProvider = FutureProvider.family<double, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getTotalCurrentValueByDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for current month investments
final currentMonthInvestmentsProvider = FutureProvider<List<Investment>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getInvestmentsByDateRange(startDate, endDate);
});

/// Provider for current month total investment
final currentMonthTotalInvestmentProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getTotalInvestmentByDateRange(startDate, endDate);
});

/// Provider for this week investments
final thisWeekInvestmentsProvider = FutureProvider<List<Investment>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getInvestmentsByDateRange(startDate, endDate);
});

/// Provider for this week total investment
final thisWeekTotalInvestmentProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: now.weekday - 1));
  final endDate = startDate.add(const Duration(days: 6));
  return await repository.getTotalInvestmentByDateRange(startDate, endDate);
});

/// Provider for today's investments
final todayInvestmentsProvider = FutureProvider<List<Investment>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getInvestmentsByDateRange(startDate, endDate);
});

/// Provider for today's total investment
final todayTotalInvestmentProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
  return await repository.getTotalInvestmentByDateRange(startDate, endDate);
});

/// Provider for investments by type for date range
final investmentsByTypeProvider = FutureProvider.family<Map<String, double>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentsByTypeForDateRange(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for monthly investment totals
final monthlyInvestmentTotalsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getMonthlyInvestmentTotals(year);
});

/// Provider for investment performance summary
final investmentPerformanceSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentPerformanceSummary();
});

/// Provider for top performing investments
final topPerformingInvestmentsProvider = FutureProvider.family<List<Investment>, int>((ref, limit) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getTopPerformingInvestments(limit: limit);
});

/// Provider for investments by type
final investmentsByTypeNameProvider = FutureProvider.family<List<Investment>, String>((ref, type) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentsByType(type);
});

/// Provider for investment types
final investmentTypesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getInvestmentTypes();
});

/// Provider for portfolio distribution
final portfolioDistributionProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  return await repository.getPortfolioDistribution();
});

/// Provider for total investment amount (all time)
final totalInvestmentProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  // Get all investments and sum their initial amounts
  final investments = await repository.getAllInvestments();
  double total = 0.0;
  for (final investment in investments) {
    total += investment.amount;
  }
  return total;
});

/// Provider for total current value (all time)
final totalCurrentValueProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(investmentRepositoryProvider);
  // Get all investments and sum their current values
  final investments = await repository.getAllInvestments();
  double total = 0.0;
  for (final investment in investments) {
    total += investment.currentValue ?? investment.amount;
  }
  return total;
});