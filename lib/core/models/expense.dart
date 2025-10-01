import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Expense transaction model
@freezed
class Expense with _$Expense {
  const factory Expense({
    int? id,
    required double amount,
    required int categoryId,
    Category? category,
    required DateTime date,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  /// Create a new expense entry
  factory Expense.create({
    required double amount,
    required int categoryId,
    required DateTime date,
    String? note,
  }) {
    final now = DateTime.now();
    return Expense(
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }



  /// Create from database map
  factory Expense.fromDatabase(Map<String, dynamic> map, {Category? category}) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      category: category,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Extension for Expense calculations
extension ExpenseExtension on Expense {
  /// Get formatted amount
  String get formattedAmount => 'GH₵${amount.toStringAsFixed(2)}';

  /// Get formatted date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Check if expense is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if expense is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if expense is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}

extension ExpenseDatabase on Expense {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}