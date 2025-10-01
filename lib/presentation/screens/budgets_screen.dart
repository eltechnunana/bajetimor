import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/budget.dart';
import '../../providers/budget_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/add_budget_dialog.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetProvider);
    final activeBudgets = ref.watch(activeBudgetsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budgets'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active', icon: Icon(Icons.play_circle_outline)),
              Tab(text: 'All', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active budgets
            _buildBudgetList(activeBudgets, ref, isActive: true),
            
            // All budgets
            _buildBudgetList(budgets, ref, isActive: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddBudgetDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBudgetList(
    AsyncValue<List<Budget>> budgetsAsync,
    WidgetRef ref, {
    required bool isActive,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(budgetProvider);
        ref.invalidate(activeBudgetsProvider);
      },
      child: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return _buildEmptyState(isActive);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BudgetCard(
                  budget: budget,
                  spent: 0.0, // TODO: Calculate actual spent amount
                  onTap: () => _showBudgetDetails(context, budget),
                  onEdit: () => _editBudget(context, budget),
                  onDelete: () => _deleteBudget(context, ref, budget),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString(), ref),
      ),
    );
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isActive ? 'No active budgets' : 'No budgets found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive 
                ? 'Create a budget to start tracking your spending'
                : 'Tap the + button to create your first budget',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(budgetProvider);
              ref.invalidate(activeBudgetsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  void _showBudgetDetails(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Budget Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount', budget.formattedAmount),
              _buildDetailRow('Period', budget.period.displayName),
              _buildDetailRow('Start Date', budget.formattedStartDate),
              _buildDetailRow('End Date', budget.formattedEndDate),
              _buildDetailRow('Status', budget.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Days Remaining', '${budget.remainingDays}'),
              _buildDetailRow('Progress', '${budget.progressPercentage.toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editBudget(context, budget);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editBudget(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        budget: budget,
        isEditing: true,
      ),
    );
  }

  void _deleteBudget(BuildContext context, WidgetRef ref, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete this budget? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await ref.read(budgetNotifierProvider.notifier).deleteBudget(budget.id!);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete budget: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}