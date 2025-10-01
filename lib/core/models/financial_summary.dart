import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_summary.freezed.dart';
part 'financial_summary.g.dart';

/// Financial summary model for dashboard analytics
@freezed
class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    required double totalIncome,
    required double totalExpenses,
    required double totalInvestments,
    required double currentInvestmentValue,
    required double netWorth,
    required double savingsRate,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default([]) List<CategorySummary> incomeByCategory,
    @Default([]) List<CategorySummary> expensesByCategory,
    @Default([]) List<CategorySummary> investmentsByCategory,
  }) = _FinancialSummary;

  factory FinancialSummary.fromJson(Map<String, dynamic> json) => 
      _$FinancialSummaryFromJson(json);

  /// Create empty summary
  factory FinancialSummary.empty({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    return FinancialSummary(
      totalIncome: 0,
      totalExpenses: 0,
      totalInvestments: 0,
      currentInvestmentValue: 0,
      netWorth: 0,
      savingsRate: 0,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }
}

/// Category-wise summary for charts and analytics
@freezed
class CategorySummary with _$CategorySummary {
  const factory CategorySummary({
    required int categoryId,
    required String categoryName,
    required double amount,
    required double percentage,
    String? categoryColor,
    String? categoryIcon,
  }) = _CategorySummary;

  factory CategorySummary.fromJson(Map<String, dynamic> json) => 
      _$CategorySummaryFromJson(json);
}

/// Extension for FinancialSummary calculations
extension FinancialSummaryExtension on FinancialSummary {
  /// Get formatted total income
  String get formattedTotalIncome => 'GH₵${totalIncome.toStringAsFixed(2)}';

  /// Get formatted total expenses
  String get formattedTotalExpenses => 'GH₵${totalExpenses.toStringAsFixed(2)}';

  /// Get formatted total investments
  String get formattedTotalInvestments => 'GH₵${totalInvestments.toStringAsFixed(2)}';

  /// Get formatted current investment value
  String get formattedCurrentInvestmentValue => 'GH₵${currentInvestmentValue.toStringAsFixed(2)}';

  /// Get formatted net worth
  String get formattedNetWorth => 'GH₵${netWorth.toStringAsFixed(2)}';

  /// Get formatted savings rate
  String get formattedSavingsRate => '${savingsRate.toStringAsFixed(1)}%';

  /// Calculate investment profit/loss
  double get investmentProfitLoss => currentInvestmentValue - totalInvestments;

  /// Get formatted investment profit/loss
  String get formattedInvestmentProfitLoss {
    final pl = investmentProfitLoss;
    final sign = pl >= 0 ? '+' : '';
    return '${sign}GH₵${pl.toStringAsFixed(2)}';
  }

  /// Calculate investment return percentage
  double get investmentReturnPercentage {
    if (totalInvestments == 0) return 0;
    return (investmentProfitLoss / totalInvestments) * 100;
  }

  /// Get formatted investment return percentage
  String get formattedInvestmentReturnPercentage {
    final rp = investmentReturnPercentage;
    final sign = rp >= 0 ? '+' : '';
    return '$sign${rp.toStringAsFixed(2)}%';
  }

  /// Calculate available balance (income - expenses)
  double get availableBalance => totalIncome - totalExpenses;

  /// Get formatted available balance
  String get formattedAvailableBalance {
    final balance = availableBalance;
    final sign = balance >= 0 ? '+' : '';
    return '${sign}GH₵${balance.toStringAsFixed(2)}';
  }

  /// Check if expenses exceed income
  bool get isOverspending => totalExpenses > totalIncome;

  /// Get expense ratio (expenses / income)
  double get expenseRatio {
    if (totalIncome == 0) return 0;
    return totalExpenses / totalIncome;
  }

  /// Get formatted expense ratio
  String get formattedExpenseRatio => '${(expenseRatio * 100).toStringAsFixed(1)}%';

  /// Get period duration in days
  int get periodDurationDays => periodEnd.difference(periodStart).inDays + 1;

  /// Get average daily income
  double get averageDailyIncome => totalIncome / periodDurationDays;

  /// Get average daily expenses
  double get averageDailyExpenses => totalExpenses / periodDurationDays;

  /// Get formatted period
  String get formattedPeriod {
    final start = '${periodStart.day}/${periodStart.month}/${periodStart.year}';
    final end = '${periodEnd.day}/${periodEnd.month}/${periodEnd.year}';
    return '$start - $end';
  }

  /// Check if this is a monthly summary
  bool get isMonthly {
    return periodStart.day == 1 && 
           periodEnd.month == periodStart.month &&
           periodEnd.year == periodStart.year;
  }

  /// Check if this is a weekly summary
  bool get isWeekly {
    return periodDurationDays == 7;
  }

  /// Get financial health score (0-100)
  double get financialHealthScore {
    double score = 50; // Base score

    // Positive factors
    if (availableBalance > 0) score += 20; // Positive balance
    if (savingsRate > 10) score += 15; // Good savings rate
    if (investmentReturnPercentage > 0) score += 10; // Profitable investments
    if (expenseRatio < 0.8) score += 5; // Controlled expenses

    // Negative factors
    if (isOverspending) score -= 30; // Overspending
    if (savingsRate < 0) score -= 20; // Negative savings
    if (investmentReturnPercentage < -10) score -= 15; // Poor investments

    return score.clamp(0, 100);
  }

  /// Get financial health status
  String get financialHealthStatus {
    final score = financialHealthScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }
}

/// Extension for CategorySummary
extension CategorySummaryExtension on CategorySummary {
  /// Get formatted amount
  String get formattedAmount => 'GH₵${amount.toStringAsFixed(2)}';

  /// Get formatted percentage
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}