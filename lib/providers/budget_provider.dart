import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/budget.dart';
import '../data/repositories/budget_repository.dart';

/// Provider for BudgetRepository
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Provider for all budget entries
final budgetProvider = FutureProvider<List<Budget>>((ref) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getAllBudgets();
});

/// Provider for active budgets
final activeBudgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getActiveBudgets();
});

/// StateNotifier for managing budget state
class BudgetNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  final BudgetRepository _repository;

  /// Load all budget entries
  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    try {
      final budgets = await _repository.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new budget entry
  Future<void> addBudget(Budget budget) async {
    try {
      // Check if budget already exists for this category and period
      final exists = await _repository.budgetExistsForCategoryAndPeriod(
        budget.categoryId,
        budget.startDate,
        budget.endDate,
      );
      
      if (exists) {
        throw Exception('Budget already exists for this category and period');
      }
      
      await _repository.insertBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing budget entry
  Future<void> updateBudget(Budget budget) async {
    try {
      // Check if budget already exists for this category and period (excluding current budget)
      final exists = await _repository.budgetExistsForCategoryAndPeriod(
        budget.categoryId,
        budget.startDate,
        budget.endDate,
        excludeBudgetId: budget.id,
      );
      
      if (exists) {
        throw Exception('Budget already exists for this category and period');
      }
      
      await _repository.updateBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a budget entry
  Future<void> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search budget entries
  Future<List<Budget>> searchBudgets(String query) async {
    try {
      return await _repository.searchBudgets(query);
    } catch (error) {
      return [];
    }
  }

  /// Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(int categoryId) async {
    try {
      return await _repository.getBudgetsByCategory(categoryId);
    } catch (error) {
      return [];
    }
  }

  /// Get budgets by period
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period) async {
    try {
      return await _repository.getBudgetsByPeriod(period);
    } catch (error) {
      return [];
    }
  }
}

/// Provider for BudgetNotifier
final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<List<Budget>>>((ref) {
  final repository = ref.read(budgetRepositoryProvider);
  return BudgetNotifier(repository);
});

/// Provider for a specific budget entry by ID
final budgetByIdProvider = FutureProvider.family<Budget?, int>((ref, id) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getBudgetById(id);
});

/// Provider for budget with spending data
final budgetWithSpendingProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, budgetId) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getBudgetWithSpending(budgetId);
});

/// Provider for all budgets with spending data
final allBudgetsWithSpendingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getAllBudgetsWithSpending();
});

/// Provider for active budgets with spending data
final activeBudgetsWithSpendingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getActiveBudgetsWithSpending();
});

/// Provider for budgets by category
final budgetsByCategoryProvider = FutureProvider.family<List<Budget>, int>((ref, categoryId) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getBudgetsByCategory(categoryId);
});

/// Provider for budgets by period
final budgetsByPeriodProvider = FutureProvider.family<List<Budget>, BudgetPeriod>((ref, period) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getBudgetsByPeriod(period);
});

/// Provider for budget summary
final budgetSummaryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, DateTime>>((ref, dateRange) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.getBudgetSummary(dateRange['startDate']!, dateRange['endDate']!);
});

/// Provider for current month budget summary
final currentMonthBudgetSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(budgetRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
  return await repository.getBudgetSummary(startDate, endDate);
});

/// Provider for checking if budget exists for category and period
final budgetExistsProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(budgetRepositoryProvider);
  return await repository.budgetExistsForCategoryAndPeriod(
    params['categoryId'] as int?,
    params['startDate'] as DateTime,
    params['endDate'] as DateTime,
    excludeBudgetId: params['excludeBudgetId'] as int?,
  );
});