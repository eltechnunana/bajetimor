import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/investment.dart';

/// Repository for investment data operations
class InvestmentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Get all investment entries
  Future<List<Investment>> getAllInvestments() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get investment entries by date range
  Future<List<Investment>> getInvestmentsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get investment by ID
  Future<Investment?> getInvestmentById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Investment.fromDatabase(maps.first);
    }
    return null;
  }

  /// Insert a new investment entry
  Future<int> insertInvestment(Investment investment) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableInvestments,
      investment.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing investment entry
  Future<int> updateInvestment(Investment investment) async {
    final db = await _databaseHelper.database;
    final updatedInvestment = investment.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await db.update(
      DatabaseHelper.tableInvestments,
      updatedInvestment.toDatabase(),
      where: 'id = ?',
      whereArgs: [investment.id],
    );
  }

  /// Delete an investment entry
  Future<int> deleteInvestment(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableInvestments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total investment amount for a date range
  Future<double> getTotalInvestmentByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.tableInvestments}
      WHERE date >= ? AND date <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total current value of investments for a date range
  Future<double> getTotalCurrentValueByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(current_value) as total
      FROM ${DatabaseHelper.tableInvestments}
      WHERE date >= ? AND date <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get investments by type for a date range
  Future<Map<String, double>> getInvestmentsByTypeForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT type, SUM(amount) as total_initial, SUM(current_value) as total_current
      FROM ${DatabaseHelper.tableInvestments}
      WHERE date >= ? AND date <= ?
      GROUP BY type
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final Map<String, double> result = {};
    for (final map in maps) {
      result[map['type'] as String] = (map['total_current'] as num).toDouble();
    }
    return result;
  }

  /// Get monthly investment totals
  Future<List<Map<String, dynamic>>> getMonthlyInvestmentTotals(int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        strftime('%m', date) as month,
        SUM(amount) as total_initial,
        SUM(current_value) as total_current
      FROM ${DatabaseHelper.tableInvestments}
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
      ORDER BY month
    ''', [year.toString()]);

    return maps;
  }

  /// Search investment entries
  Future<List<Investment>> searchInvestments(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      where: 'type LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get recent investment entries
  Future<List<Investment>> getRecentInvestments({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get investment performance summary
  Future<Map<String, dynamic>> getInvestmentPerformanceSummary() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_investments,
        SUM(amount) as total_invested,
        SUM(current_value) as total_current_value,
        AVG(expected_return) as avg_expected_return,
        SUM(current_value - amount) as total_profit_loss
      FROM ${DatabaseHelper.tableInvestments}
    ''');

    final data = result.first;
    final totalInvested = (data['total_invested'] as num?)?.toDouble() ?? 0.0;
    final totalCurrentValue = (data['total_current_value'] as num?)?.toDouble() ?? 0.0;
    final totalProfitLoss = (data['total_profit_loss'] as num?)?.toDouble() ?? 0.0;
    
    double returnPercentage = 0.0;
    if (totalInvested > 0) {
      returnPercentage = (totalProfitLoss / totalInvested) * 100;
    }

    return {
      'total_investments': data['total_investments'] as int,
      'total_invested': totalInvested,
      'total_current_value': totalCurrentValue,
      'avg_expected_return': (data['avg_expected_return'] as num?)?.toDouble() ?? 0.0,
      'total_profit_loss': totalProfitLoss,
      'return_percentage': returnPercentage,
    };
  }

  /// Get top performing investments
  Future<List<Investment>> getTopPerformingInvestments({int limit = 5}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT *,
        (current_value - amount) as profit_loss,
        ((current_value - amount) / amount * 100) as return_percentage
      FROM ${DatabaseHelper.tableInvestments}
      WHERE amount > 0
      ORDER BY return_percentage DESC
      LIMIT ?
    ''', [limit]);

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get investments by type
  Future<List<Investment>> getInvestmentsByType(String type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableInvestments,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Investment.fromDatabase(maps[i]);
    });
  }

  /// Get unique investment types
  Future<List<String>> getInvestmentTypes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT type
      FROM ${DatabaseHelper.tableInvestments}
      ORDER BY type
    ''');

    return maps.map((map) => map['type'] as String).toList();
  }

  /// Get investment portfolio distribution
  Future<List<Map<String, dynamic>>> getPortfolioDistribution() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        type,
        COUNT(*) as count,
        SUM(amount) as total_invested,
        SUM(current_value) as total_current_value,
        SUM(current_value - amount) as total_profit_loss
      FROM ${DatabaseHelper.tableInvestments}
      GROUP BY type
      ORDER BY total_current_value DESC
    ''');

    return maps;
  }
}