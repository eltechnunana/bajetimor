import '../../core/models/financial_summary.dart';
import '../../core/models/category.dart';
import 'income_repository.dart';
import 'expense_repository.dart';
import 'investment_repository.dart';
import 'category_repository.dart';

/// Repository for financial summary and analytics data
class FinancialSummaryRepository {
  final IncomeRepository _incomeRepository = IncomeRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final InvestmentRepository _investmentRepository = InvestmentRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Get financial summary for a specific date range
  Future<FinancialSummary> getFinancialSummary(DateTime startDate, DateTime endDate) async {
    // Get totals for the period
    final totalIncome = await _incomeRepository.getTotalIncomeByDateRange(startDate, endDate);
    final totalExpenses = await _expenseRepository.getTotalExpensesByDateRange(startDate, endDate);
    final totalInvestments = await _investmentRepository.getTotalInvestmentByDateRange(startDate, endDate);
    final totalInvestmentValue = await _investmentRepository.getTotalCurrentValueByDateRange(startDate, endDate);

    // Get category breakdowns
    final incomeByCategory = await _incomeRepository.getIncomeByCategoryForDateRange(startDate, endDate);
    final expensesByCategory = await _expenseRepository.getExpensesByCategoryForDateRange(startDate, endDate);
    final investmentsByType = await _investmentRepository.getInvestmentsByTypeForDateRange(startDate, endDate);

    // Create category summaries for income
    final List<CategorySummary> incomeCategorySummaries = [];
    for (final entry in incomeByCategory.entries) {
      final category = await _categoryRepository.getCategoryById(entry.key);
      if (category != null) {
        incomeCategorySummaries.add(CategorySummary(
          categoryId: entry.key,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: entry.value,
          percentage: totalIncome > 0 ? (entry.value / totalIncome) * 100 : 0,
        ));
      }
    }

    // Create category summaries for expenses
    final List<CategorySummary> expenseCategorySummaries = [];
    for (final entry in expensesByCategory.entries) {
      final category = await _categoryRepository.getCategoryById(entry.key);
      if (category != null) {
        expenseCategorySummaries.add(CategorySummary(
          categoryId: entry.key,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: entry.value,
          percentage: totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0,
        ));
      }
    }

    // Create investment type summaries
    final List<CategorySummary> investmentTypeSummaries = [];
    for (final entry in investmentsByType.entries) {
      investmentTypeSummaries.add(CategorySummary(
        categoryId: 0, // Investment types don't have category IDs
        categoryName: entry.key,
        categoryIcon: _getInvestmentTypeIcon(entry.key),
        categoryColor: _getInvestmentTypeColor(entry.key),
        amount: entry.value,
        percentage: totalInvestmentValue > 0 ? (entry.value / totalInvestmentValue) * 100 : 0,
      ));
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalInvestments: totalInvestments,
      currentInvestmentValue: totalInvestmentValue,
      netWorth: totalIncome - totalExpenses + totalInvestmentValue,
      savingsRate: totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0,
      periodStart: startDate,
      periodEnd: endDate,
      incomeByCategory: incomeCategorySummaries,
      expensesByCategory: expenseCategorySummaries,
      investmentsByCategory: investmentTypeSummaries,
    );
  }

  /// Get monthly financial summary for the current year
  Future<List<FinancialSummary>> getMonthlyFinancialSummary(int year) async {
    final List<FinancialSummary> monthlySummaries = [];

    for (int month = 1; month <= 12; month++) {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
      
      final summary = await getFinancialSummary(startDate, endDate);
      monthlySummaries.add(summary);
    }

    return monthlySummaries;
  }

  /// Get yearly financial summary
  Future<FinancialSummary> getYearlyFinancialSummary(int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    
    return await getFinancialSummary(startDate, endDate);
  }

  /// Get current month financial summary
  Future<FinancialSummary> getCurrentMonthSummary() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    
    return await getFinancialSummary(startDate, endDate);
  }

  /// Get current year financial summary
  Future<FinancialSummary> getCurrentYearSummary() async {
    final now = DateTime.now();
    return await getYearlyFinancialSummary(now.year);
  }

  /// Get last 30 days financial summary
  Future<FinancialSummary> getLast30DaysSummary() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    return await getFinancialSummary(startDate, endDate);
  }

  /// Get financial trends (comparing current period with previous period)
  Future<Map<String, dynamic>> getFinancialTrends(DateTime startDate, DateTime endDate) async {
    final currentSummary = await getFinancialSummary(startDate, endDate);
    
    // Calculate previous period
    final periodDuration = endDate.difference(startDate);
    final previousEndDate = startDate.subtract(const Duration(days: 1));
    final previousStartDate = previousEndDate.subtract(periodDuration);
    
    final previousSummary = await getFinancialSummary(previousStartDate, previousEndDate);

    // Calculate trends
    final incomeChange = _calculatePercentageChange(previousSummary.totalIncome, currentSummary.totalIncome);
    final expenseChange = _calculatePercentageChange(previousSummary.totalExpenses, currentSummary.totalExpenses);
    final investmentChange = _calculatePercentageChange(previousSummary.currentInvestmentValue, currentSummary.currentInvestmentValue);
    final netWorthChange = _calculatePercentageChange(previousSummary.netWorth, currentSummary.netWorth);

    return {
      'current_summary': currentSummary,
      'previous_summary': previousSummary,
      'income_change_percentage': incomeChange,
      'expense_change_percentage': expenseChange,
      'investment_change_percentage': investmentChange,
      'net_worth_change_percentage': netWorthChange,
      'income_trend': _getTrendDirection(incomeChange),
      'expense_trend': _getTrendDirection(expenseChange),
      'investment_trend': _getTrendDirection(investmentChange),
      'net_worth_trend': _getTrendDirection(netWorthChange),
    };
  }

  /// Get top spending categories for a period
  Future<List<CategorySummary>> getTopSpendingCategories(
    DateTime startDate, 
    DateTime endDate, 
    {int limit = 5}
  ) async {
    final topCategories = await _expenseRepository.getTopSpendingCategories(
      startDate, 
      endDate, 
      limit: limit
    );

    return topCategories.map((categoryData) => CategorySummary(
      categoryId: categoryData['id'] as int,
      categoryName: categoryData['name'] as String,
      categoryIcon: categoryData['icon'] as String?,
      categoryColor: categoryData['color'] as String?,
      amount: (categoryData['total_amount'] as num).toDouble(),
      percentage: 0, // Will be calculated if needed
    )).toList();
  }

  /// Get daily spending trends for a period
  Future<List<Map<String, dynamic>>> getDailySpendingTrends(DateTime startDate, DateTime endDate) async {
    return await _expenseRepository.getDailyExpenseTotals(startDate, endDate);
  }

  /// Get investment performance summary
  Future<Map<String, dynamic>> getInvestmentPerformanceSummary() async {
    return await _investmentRepository.getInvestmentPerformanceSummary();
  }

  /// Helper method to calculate percentage change
  double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) {
      return newValue > 0 ? 100 : 0;
    }
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Helper method to get trend direction
  String _getTrendDirection(double changePercentage) {
    if (changePercentage > 5) return 'up';
    if (changePercentage < -5) return 'down';
    return 'stable';
  }

  /// Helper method to get investment type icon
  String _getInvestmentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'stocks':
        return 'trending_up';
      case 'bonds':
        return 'account_balance';
      case 'crypto':
        return 'currency_bitcoin';
      case 'real estate':
        return 'home';
      case 'mutual funds':
        return 'pie_chart';
      case 'etf':
        return 'show_chart';
      default:
        return 'savings';
    }
  }

  /// Helper method to get investment type color
  String _getInvestmentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'stocks':
        return '#4CAF50';
      case 'bonds':
        return '#2196F3';
      case 'crypto':
        return '#FF9800';
      case 'real estate':
        return '#795548';
      case 'mutual funds':
        return '#9C27B0';
      case 'etf':
        return '#607D8B';
      default:
        return '#757575';
    }
  }
}