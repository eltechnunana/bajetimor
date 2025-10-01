import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/category.dart';
import '../data/repositories/category_repository.dart';

/// Provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Provider for all categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

/// Provider for income categories
final incomeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getCategoriesByType(CategoryType.income);
});

/// Provider for expense categories
final expenseCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getCategoriesByType(CategoryType.expense);
});

/// StateNotifier for managing category state
class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  final CategoryRepository _repository;

  /// Load all categories
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new category
  Future<void> addCategory(Category category) async {
    try {
      await _repository.insertCategory(category);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing category
  Future<void> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    try {
      // Check if category is in use before deleting
      final isInUse = await _repository.isCategoryInUse(id);
      if (isInUse) {
        throw Exception('Cannot delete category that is in use');
      }
      
      await _repository.deleteCategory(id);
      await loadCategories(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search categories
  Future<List<Category>> searchCategories(String query) async {
    try {
      return await _repository.searchCategories(query);
    } catch (error) {
      return [];
    }
  }


}

/// Provider for CategoryNotifier
final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

/// Provider for a specific category by ID
final categoryByIdProvider = FutureProvider.family<Category?, int>((ref, id) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getCategoryById(id);
});

/// Provider for category usage statistics
final categoryUsageStatsProvider = FutureProvider.family<Map<String, int>, int>((ref, categoryId) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getCategoryUsageStats(categoryId);
});

/// Provider for checking if a category is in use
final categoryInUseProvider = FutureProvider.family<bool, int>((ref, categoryId) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.isCategoryInUse(categoryId);
});