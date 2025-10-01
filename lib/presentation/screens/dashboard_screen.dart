import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/financial_summary_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonthSummary = ref.watch(currentMonthSummaryProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bajetimor'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(financialSummaryNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(financialSummaryNotifierProvider.notifier).refresh();
          ref.invalidate(currentMonthSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Here\'s your financial overview',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Financial summary cards
              currentMonthSummary.when(
                data: (summary) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Income',
                            amount: 'GH₵${summary.totalIncome.toStringAsFixed(2)}',
                            icon: Icons.trending_up,
                            color: AppTheme.incomeColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Expenses',
                            amount: 'GH₵${summary.totalExpenses.toStringAsFixed(2)}',
                            icon: Icons.trending_down,
                            color: AppTheme.expenseColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Investments',
                            amount: 'GH₵${summary.totalInvestments.toStringAsFixed(2)}',
                            icon: Icons.show_chart,
                            color: AppTheme.investmentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Net Worth',
                            amount: 'GH₵${summary.netWorth.toStringAsFixed(2)}',
                            icon: Icons.account_balance,
                            color: AppTheme.savingsColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load financial summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Charts section
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Income vs Expense chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income vs Expenses',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 200,
                        child: IncomeExpenseChart(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expense breakdown chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Breakdown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 200,
                        child: ExpenseChart(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent transactions
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const RecentTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}