import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import 'category_repository.dart';
import 'expense_repository.dart';

/// Repository for budget data operations
class BudgetRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Get all budget entries
  Future<List<Budget>> getAllBudgets() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      ORDER BY b.start_date DESC
    ''');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    });
  }

  /// Get active budgets (current period)
  Future<List<Budget>> getActiveBudgets() async {
    final now = DateTime.now();
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      WHERE b.start_date <= ? AND b.end_date >= ?
      ORDER BY b.start_date DESC
    ''', [now.toIso8601String(), now.toIso8601String()]);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    });
  }

  /// Get budget by ID
  Future<Budget?> getBudgetById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      WHERE b.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      final map = maps.first;
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    }
    return null;
  }

  /// Insert a new budget entry
  Future<int> insertBudget(Budget budget) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableBudgets,
      budget.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing budget entry
  Future<int> updateBudget(Budget budget) async {
    final db = await _databaseHelper.database;
    final updatedBudget = budget.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await db.update(
      DatabaseHelper.tableBudgets,
      updatedBudget.toDatabase(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Delete a budget entry
  Future<int> deleteBudget(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(int categoryId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      WHERE b.category_id = ?
      ORDER BY b.start_date DESC
    ''', [categoryId]);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    });
  }

  /// Get budgets by period
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      WHERE b.period = ?
      ORDER BY b.start_date DESC
    ''', [period.name]);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    });
  }

  /// Get budget with spending data
  Future<Map<String, dynamic>?> getBudgetWithSpending(int budgetId) async {
    final budget = await getBudgetById(budgetId);
    if (budget == null) return null;

    // Get total spending for this budget's category and period
    double totalSpent = 0.0;
    if (budget.categoryId != null) {
      final expenses = await _expenseRepository.getExpensesByDateRange(
        budget.startDate,
        budget.endDate,
      );
      
      totalSpent = expenses
          .where((expense) => expense.categoryId == budget.categoryId)
          .fold(0.0, (sum, expense) => sum + expense.amount);
    } else {
      // If no specific category, get all expenses for the period
      totalSpent = await _expenseRepository.getTotalExpensesByDateRange(
        budget.startDate,
        budget.endDate,
      );
    }

    final remaining = budget.amount - totalSpent;
    final progressPercentage = budget.amount > 0 ? (totalSpent / budget.amount) * 100 : 0.0;

    return {
      'budget': budget,
      'total_spent': totalSpent,
      'remaining': remaining,
      'progress_percentage': progressPercentage,
      'is_over_budget': totalSpent > budget.amount,
    };
  }

  /// Get all budgets with spending data
  Future<List<Map<String, dynamic>>> getAllBudgetsWithSpending() async {
    final budgets = await getAllBudgets();
    final List<Map<String, dynamic>> budgetsWithSpending = [];

    for (final budget in budgets) {
      final budgetData = await getBudgetWithSpending(budget.id!);
      if (budgetData != null) {
        budgetsWithSpending.add(budgetData);
      }
    }

    return budgetsWithSpending;
  }

  /// Get active budgets with spending data
  Future<List<Map<String, dynamic>>> getActiveBudgetsWithSpending() async {
    final budgets = await getActiveBudgets();
    final List<Map<String, dynamic>> budgetsWithSpending = [];

    for (final budget in budgets) {
      final budgetData = await getBudgetWithSpending(budget.id!);
      if (budgetData != null) {
        budgetsWithSpending.add(budgetData);
      }
    }

    return budgetsWithSpending;
  }

  /// Check if budget exists for category and period
  Future<bool> budgetExistsForCategoryAndPeriod(
    int? categoryId,
    DateTime startDate,
    DateTime endDate,
    {int? excludeBudgetId}
  ) async {
    final db = await _databaseHelper.database;
    
    String whereClause = '''
      ((start_date <= ? AND end_date >= ?) OR 
       (start_date <= ? AND end_date >= ?) OR
       (start_date >= ? AND start_date <= ?))
    ''';
    
    List<dynamic> whereArgs = [
      startDate.toIso8601String(), startDate.toIso8601String(),
      endDate.toIso8601String(), endDate.toIso8601String(),
      startDate.toIso8601String(), endDate.toIso8601String(),
    ];

    if (categoryId != null) {
      whereClause = 'category_id = ? AND ($whereClause)';
      whereArgs.insert(0, categoryId);
    } else {
      whereClause = 'category_id IS NULL AND ($whereClause)';
    }

    if (excludeBudgetId != null) {
      whereClause = '($whereClause) AND id != ?';
      whereArgs.add(excludeBudgetId);
    }

    final result = await db.query(
      DatabaseHelper.tableBudgets,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Get budget summary for a period
  Future<Map<String, dynamic>> getBudgetSummary(DateTime startDate, DateTime endDate) async {
    final budgets = await getAllBudgets();
    final periodBudgets = budgets.where((budget) =>
        budget.startDate.isBefore(endDate.add(const Duration(days: 1))) &&
        budget.endDate.isAfter(startDate.subtract(const Duration(days: 1)))
    ).toList();

    double totalBudgeted = 0.0;
    double totalSpent = 0.0;
    int overBudgetCount = 0;

    for (final budget in periodBudgets) {
      totalBudgeted += budget.amount;
      
      double spent = 0.0;
      if (budget.categoryId != null) {
        final expenses = await _expenseRepository.getExpensesByDateRange(
          budget.startDate,
          budget.endDate,
        );
        spent = expenses
            .where((expense) => expense.categoryId == budget.categoryId)
            .fold(0.0, (sum, expense) => sum + expense.amount);
      } else {
        spent = await _expenseRepository.getTotalExpensesByDateRange(
          budget.startDate,
          budget.endDate,
        );
      }
      
      totalSpent += spent;
      if (spent > budget.amount) {
        overBudgetCount++;
      }
    }

    return {
      'total_budgets': periodBudgets.length,
      'total_budgeted': totalBudgeted,
      'total_spent': totalSpent,
      'remaining': totalBudgeted - totalSpent,
      'over_budget_count': overBudgetCount,
      'budget_utilization_percentage': totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0.0,
    };
  }

  /// Search budgets
  Future<List<Budget>> searchBudgets(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableBudgets} b
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON b.category_id = c.id
      WHERE b.name LIKE ? OR c.name LIKE ?
      ORDER BY b.start_date DESC
    ''', ['%$query%', '%$query%']);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Category? category;
      
      if (map['category_name'] != null) {
        category = Category.fromDatabase({
          'id': map['category_id'],
          'name': map['category_name'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'color': map['category_color'],
          'created_at': map['category_created_at'],
          'updated_at': map['category_updated_at'],
        });
      }
      
      return Budget.fromDatabase(map, category: category);
    });
  }
}