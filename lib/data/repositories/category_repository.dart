import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/category.dart';

/// Repository for category data operations
class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Category.fromDatabase(maps[i]);
    });
  }

  /// Get categories by type
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Category.fromDatabase(maps[i]);
    });
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromDatabase(maps.first);
    }
    return null;
  }

  /// Insert a new category
  Future<int> insertCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableCategories,
      category.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing category
  Future<int> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    final updatedCategory = category.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await db.update(
      DatabaseHelper.tableCategories,
      updatedCategory.toDatabase(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a category
  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if category is being used in transactions
  Future<bool> isCategoryInUse(int categoryId) async {
    final db = await _databaseHelper.database;
    
    // Check income table
    final incomeCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableIncome} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    // Check expenses table
    final expenseCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableExpenses} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    // Check investments table
    final investmentCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableInvestments} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    // Check budgets table
    final budgetCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableBudgets} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    return (incomeCount + expenseCount + investmentCount + budgetCount) > 0;
  }

  /// Search categories by name
  Future<List<Category>> searchCategories(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Category.fromDatabase(maps[i]);
    });
  }

  /// Get category usage statistics
  Future<Map<String, int>> getCategoryUsageStats(int categoryId) async {
    final db = await _databaseHelper.database;
    
    final incomeCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableIncome} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    final expenseCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableExpenses} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    final investmentCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableInvestments} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    final budgetCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.tableBudgets} WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    return {
      'income': incomeCount,
      'expenses': expenseCount,
      'investments': investmentCount,
      'budgets': budgetCount,
    };
  }
}