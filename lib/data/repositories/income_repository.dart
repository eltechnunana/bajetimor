import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/income.dart';
import '../../core/models/category.dart';
import 'category_repository.dart';

/// Repository for income data operations
class IncomeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Get all income entries
  Future<List<Income>> getAllIncome() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableIncome} i
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON i.category_id = c.id
      ORDER BY i.date DESC
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
      
      return Income.fromDatabase(map, category: category);
    });
  }

  /// Get income entries by date range
  Future<List<Income>> getIncomeByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableIncome} i
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON i.category_id = c.id
      WHERE i.date >= ? AND i.date <= ?
      ORDER BY i.date DESC
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
      
      return Income.fromDatabase(map, category: category);
    });
  }

  /// Get income by ID
  Future<Income?> getIncomeById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableIncome} i
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON i.category_id = c.id
      WHERE i.id = ?
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
      
      return Income.fromDatabase(map, category: category);
    }
    return null;
  }

  /// Insert a new income entry
  Future<int> insertIncome(Income income) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableIncome,
      income.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing income entry
  Future<int> updateIncome(Income income) async {
    final db = await _databaseHelper.database;
    final updatedIncome = income.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await db.update(
      DatabaseHelper.tableIncome,
      updatedIncome.toDatabase(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  /// Delete an income entry
  Future<int> deleteIncome(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableIncome,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total income for a date range
  Future<double> getTotalIncomeByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableIncome}
      WHERE date >= ? AND date <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get income by category for a date range
  Future<Map<int, double>> getIncomeByCategoryForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM ${DatabaseHelper.tableIncome}
      WHERE date >= ? AND date <= ?
      GROUP BY category_id
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final Map<int, double> result = {};
    for (final map in maps) {
      result[map['category_id'] as int] = (map['total'] as num).toDouble();
    }
    return result;
  }

  /// Get monthly income totals
  Future<List<Map<String, dynamic>>> getMonthlyIncomeTotals(int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        strftime('%m', date) as month,
        SUM(amount) as total
      FROM ${DatabaseHelper.tableIncome}
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
      ORDER BY month
    ''', [year.toString()]);

    return maps;
  }

  /// Search income entries
  Future<List<Income>> searchIncome(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableIncome} i
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON i.category_id = c.id
      WHERE i.note LIKE ? OR c.name LIKE ?
      ORDER BY i.date DESC
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
      
      return Income.fromDatabase(map, category: category);
    });
  }

  /// Get recent income entries
  Future<List<Income>> getRecentIncome({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as category_name, c.type as category_type, 
             c.icon as category_icon, c.color as category_color,
             c.created_at as category_created_at, c.updated_at as category_updated_at
      FROM ${DatabaseHelper.tableIncome} i
      LEFT JOIN ${DatabaseHelper.tableCategories} c ON i.category_id = c.id
      ORDER BY i.date DESC, i.created_at DESC
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
      
      return Income.fromDatabase(map, category: category);
    });
  }
}