import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/income.dart';
import '../../core/models/expense.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import 'transaction_list_item.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentIncomes = ref.watch(recentIncomeProvider);
    final recentExpenses = ref.watch(recentExpenseProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to transactions screen
                    // This would typically use a router or navigator
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTransactionsList(recentIncomes, recentExpenses),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    AsyncValue<List<Income>> recentIncomes,
    AsyncValue<List<Expense>> recentExpenses,
  ) {
    return recentIncomes.when(
      data: (incomes) {
        return recentExpenses.when(
          data: (expenses) {
            // Combine and sort transactions by date
            final List<dynamic> allTransactions = [
              ...incomes,
              ...expenses,
            ];

            if (allTransactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recent transactions',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first transaction to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Sort by date (most recent first)
            allTransactions.sort((a, b) {
              final dateA = a is Income ? a.date : (a as Expense).date;
              final dateB = b is Income ? b.date : (b as Expense).date;
              return dateB.compareTo(dateA);
            });

            // Take only the first 5 transactions
            final recentTransactions = allTransactions.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                
                return TransactionListItem(
                  transaction: transaction,
                  onEdit: () {
                    // Handle edit
                  },
                  onDelete: () {
                    // Handle delete
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading expenses: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading incomes: $error'),
      ),
    );
  }
}