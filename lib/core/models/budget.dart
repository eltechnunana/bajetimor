import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// Budget period types
enum BudgetPeriod {
  @JsonValue('monthly')
  monthly,
  @JsonValue('weekly')
  weekly,
  @JsonValue('yearly')
  yearly,
}

/// Budget model for expense tracking and limits
@freezed
class Budget with _$Budget {
  const factory Budget({
    int? id,
    required int categoryId,
    Category? category,
    required double amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  /// Create a new budget
  factory Budget.create({
    required int categoryId,
    required double amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return Budget(
      categoryId: categoryId,
      amount: amount,
      period: period,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a monthly budget for current month
  factory Budget.monthly({
    required int categoryId,
    required double amount,
    DateTime? startDate,
  }) {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = DateTime(start.year, start.month + 1, 0); // Last day of month
    
    return Budget.create(
      categoryId: categoryId,
      amount: amount,
      period: BudgetPeriod.monthly,
      startDate: start,
      endDate: end,
    );
  }

  /// Create a weekly budget for current week
  factory Budget.weekly({
    required int categoryId,
    required double amount,
    DateTime? startDate,
  }) {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    
    return Budget.create(
      categoryId: categoryId,
      amount: amount,
      period: BudgetPeriod.weekly,
      startDate: start,
      endDate: end,
    );
  }



  /// Create from database map
  factory Budget.fromDatabase(Map<String, dynamic> map, {Category? category}) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      category: category,
      amount: (map['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Extension for Budget calculations and utilities
extension BudgetExtension on Budget {
  /// Get formatted budget amount
  String get formattedAmount => 'GH₵${amount.toStringAsFixed(2)}';

  /// Get formatted start date
  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  /// Get formatted end date
  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  /// Check if budget is currently active (within date range)
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
           now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Get remaining days in budget period
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  /// Get total days in budget period
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 100;
    
    final elapsed = now.difference(startDate).inDays;
    return (elapsed / totalDays * 100).clamp(0, 100);
  }

  /// Get budget period display name
  String get periodDisplayName {
    switch (period) {
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  /// Check if budget has expired
  bool get hasExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Get status text
  String get statusText {
    if (!isActive) return 'Inactive';
    if (hasExpired) return 'Expired';
    if (isCurrentlyActive) return 'Active';
    return 'Upcoming';
  }
}

/// Extension for BudgetPeriod
extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  /// Get duration in days
  int get durationInDays {
    switch (this) {
      case BudgetPeriod.weekly:
        return 7;
      case BudgetPeriod.monthly:
        return 30; // Approximate
      case BudgetPeriod.yearly:
        return 365;
    }
  }
}

extension BudgetDatabase on Budget {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'amount': amount,
      'period': period.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}