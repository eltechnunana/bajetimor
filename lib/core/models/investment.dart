import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';

part 'investment.freezed.dart';
part 'investment.g.dart';

/// Investment transaction model
@freezed
class Investment with _$Investment {
  const factory Investment({
    int? id,
    required double amount,
    required String type,
    int? categoryId,
    Category? category,
    required DateTime date,
    double? expectedReturn,
    double? currentValue,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Investment;

  factory Investment.fromJson(Map<String, dynamic> json) => _$InvestmentFromJson(json);

  /// Create a new investment entry
  factory Investment.create({
    required double amount,
    required String type,
    int? categoryId,
    required DateTime date,
    double? expectedReturn,
    double? currentValue,
    String? note,
  }) {
    final now = DateTime.now();
    return Investment(
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      expectedReturn: expectedReturn,
      currentValue: currentValue ?? amount, // Default to initial amount
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }



  /// Create from database map
  factory Investment.fromDatabase(Map<String, dynamic> map, {Category? category}) {
    return Investment(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as int?,
      category: category,
      date: DateTime.parse(map['date'] as String),
      expectedReturn: (map['expected_return'] as num?)?.toDouble(),
      currentValue: (map['current_value'] as num?)?.toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Extension for Investment calculations
extension InvestmentExtension on Investment {
  /// Get formatted initial amount
  String get formattedAmount => 'GH₵${amount.toStringAsFixed(2)}';

  /// Get formatted current value
  String get formattedCurrentValue => 'GH₵${(currentValue ?? amount).toStringAsFixed(2)}';

  /// Get formatted expected return
  String get formattedExpectedReturn => expectedReturn != null 
      ? '${expectedReturn!.toStringAsFixed(2)}%' 
      : 'N/A';

  /// Get formatted date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Calculate profit/loss
  double get profitLoss => (currentValue ?? amount) - amount;

  /// Get formatted profit/loss
  String get formattedProfitLoss {
    final pl = profitLoss;
    final sign = pl >= 0 ? '+' : '';
    return '${sign}GH₵${pl.toStringAsFixed(2)}';
  }

  /// Calculate return percentage
  double get returnPercentage {
    if (amount == 0) return 0;
    return ((currentValue ?? amount) - amount) / amount * 100;
  }

  /// Get formatted return percentage
  String get formattedReturnPercentage {
    final rp = returnPercentage;
    final sign = rp >= 0 ? '+' : '';
    return '$sign${rp.toStringAsFixed(2)}%';
  }

  /// Check if investment is profitable
  bool get isProfitable => profitLoss > 0;

  /// Check if investment is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if investment is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if investment is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}

extension InvestmentDatabase on Investment {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'expected_return': expectedReturn,
      'current_value': currentValue,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}