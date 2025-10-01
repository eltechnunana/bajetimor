import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/expense.dart';
import '../../core/models/category.dart';
import 'category_repository.dart';

/// Repository for expense data operations
class ExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Get all expense entries
  Future<List<Expense>> getAllExpenses() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      ORDER BY e.date DESC
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
      
      return Expense.fromDatabase(map, category: category);
    });
  }

  /// Get expense entries by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      WHERE e.date >= ? AND e.date <= ?
      ORDER BY e.date DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

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
      
      return Expense.fromDatabase(map, category: category);
    });
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      WHERE e.id = ?
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
      
      return Expense.fromDatabase(map, category: category);
    }
    return null;
  }

  /// Insert a new expense entry
  Future<int> insertExpense(Expense expense) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableExpenses,
      expense.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing expense entry
  Future<int> updateExpense(Expense expense) async {
    final db = await _databaseHelper.database;
    final updatedExpense = expense.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await db.update(
      DatabaseHelper.tableExpenses,
      updatedExpense.toDatabase(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete an expense entry
  Future<int> deleteExpense(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableExpenses}
      WHERE date >= ? AND date <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get expenses by category for a date range
  Future<Map<int, double>> getExpensesByCategoryForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM ${DatabaseHelper.tableExpenses}
      WHERE date >= ? AND date <= ?
      GROUP BY category_id
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final Map<int, double> result = {};
    for (final map in maps) {
      result[map['category_id'] as int] = (map['total'] as num).toDouble();
    }
    return result;
  }

  /// Get monthly expense totals
  Future<List<Map<String, dynamic>>> getMonthlyExpenseTotals(int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        strftime('%m', date) as month,
        SUM(amount) as total
      FROM ${DatabaseHelper.tableExpenses}
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
      ORDER BY month
    ''', [year.toString()]);

    return maps;
  }

  /// Search expense entries
  Future<List<Expense>> searchExpenses(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      WHERE e.note LIKE ? OR c.name LIKE ?
      ORDER BY e.date DESC
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
      
      return Expense.fromDatabase(map, category: category);
    });
  }

  /// Get recent expense entries
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      ORDER BY e.date DESC, e.created_at DESC
      LIMIT ?
    ''', [limit]);

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
      
      return Expense.fromDatabase(map, category: category);
    });
  }

  /// Get top spending categories for a date range
  Future<List<Map<String, dynamic>>> getTopSpendingCategories(
    DateTime startDate, 
    DateTime endDate, 
    {int limit = 5}
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.icon,
        c.color,
        SUM(e.amount) as total_amount,
        COUNT(e.id) as transaction_count
      FROM ${DatabaseHelper.tableExpenses} e
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON e.category_id = c.id
      WHERE e.date >= ? AND e.date <= ?
      GROUP BY c.id, c.name, c.icon, c.color
      ORDER BY total_amount DESC
      LIMIT ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String(), limit]);

    return maps;
  }

  /// Get daily expense totals for a date range
  Future<List<Map<String, dynamic>>> getDailyExpenseTotals(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        DATE(date) as date,
        SUM(amount) as total
      FROM ${DatabaseHelper.tableExpenses}
      WHERE date >= ? AND date <= ?
      GROUP BY DATE(date)
      ORDER BY date
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return maps;
  }
}