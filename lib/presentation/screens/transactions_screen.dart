import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/income.dart';
import '../../core/models/expense.dart';
import '../../core/models/category.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/export_dialog.dart';

/// Provider for managing the current transaction type filter
final transactionTypeFilterProvider = StateProvider<TransactionType>((ref) => TransactionType.all);

enum TransactionType { all, income, expense }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomeEntries = ref.watch(incomeProvider);
    final expenseEntries = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: const [
          QuickExportButtons(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Income', icon: Icon(Icons.trending_up)),
            Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Transaction list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All transactions
                _buildAllTransactionsList(incomeEntries, expenseEntries),
                
                // Income only
                _buildIncomeList(incomeEntries),
                
                // Expenses only
                _buildExpenseList(expenseEntries),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllTransactionsList(
    AsyncValue<List<Income>> incomeEntries,
    AsyncValue<List<Expense>> expenseEntries,
  ) {
    return incomeEntries.when(
      data: (incomes) => expenseEntries.when(
        data: (expenses) {
          // Combine and sort transactions by date
          final List<dynamic> allTransactions = [
            ...incomes.where((income) => 
              _searchQuery.isEmpty || 
              (income.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
            ),
            ...expenses.where((expense) => 
              _searchQuery.isEmpty || 
              (expense.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
            ),
          ];
          
          allTransactions.sort((a, b) => b.date.compareTo(a.date));

          if (allTransactions.isEmpty) {
            return _buildEmptyState('No transactions found');
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allTransactions.length,
            itemBuilder: (context, index) {
              final transaction = allTransactions[index];
              return TransactionListItem(
                transaction: transaction,
                onTap: () => _showTransactionDetails(context, transaction),
                onEdit: () => _editTransaction(context, transaction),
                onDelete: () => _deleteTransaction(context, transaction),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState('Failed to load expenses: $error'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Failed to load income: $error'),
    );
  }

  Widget _buildIncomeList(AsyncValue<List<Income>> incomeEntries) {
    return incomeEntries.when(
      data: (incomes) {
        final filteredIncomes = incomes.where((income) => 
          _searchQuery.isEmpty || 
          (income.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();

        if (filteredIncomes.isEmpty) {
          return _buildEmptyState('No income entries found');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredIncomes.length,
          itemBuilder: (context, index) {
            final income = filteredIncomes[index];
            return TransactionListItem(
              transaction: income,
              onTap: () => _showTransactionDetails(context, income),
              onEdit: () => _editTransaction(context, income),
              onDelete: () => _deleteTransaction(context, income),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Failed to load income: $error'),
    );
  }

  Widget _buildExpenseList(AsyncValue<List<Expense>> expenseEntries) {
    return expenseEntries.when(
      data: (expenses) {
        final filteredExpenses = expenses.where((expense) => 
          _searchQuery.isEmpty || 
          (expense.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();

        if (filteredExpenses.isEmpty) {
          return _buildEmptyState('No expense entries found');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredExpenses.length,
          itemBuilder: (context, index) {
            final expense = filteredExpenses[index];
            return TransactionListItem(
              transaction: expense,
              onTap: () => _showTransactionDetails(context, expense),
              onEdit: () => _editTransaction(context, expense),
              onDelete: () => _deleteTransaction(context, expense),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Failed to load expenses: $error'),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(incomeProvider);
              ref.invalidate(expenseProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: const Text('What type of transaction would you like to add?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => const AddTransactionDialog(type: 'income'),
              );
            },
            child: const Text('Income'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => const AddTransactionDialog(type: 'expense'),
              );
            },
            child: const Text('Expense'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction is Income ? 'Income Details' : 'Expense Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${transaction.description}'),
            const SizedBox(height: 8),
            Text('Amount: GH₵${transaction.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Date: ${transaction.formattedDate}'),
            if (transaction.note?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Notes: ${transaction.note}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        type: transaction is Income ? 'income' : 'expense',
        transaction: transaction,
        isEditing: true,
      ),
    );
  }

  void _deleteTransaction(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this ${transaction is Income ? 'income' : 'expense'} entry?'
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
                if (transaction is Income) {
                  await ref.read(incomeNotifierProvider.notifier).deleteIncome(transaction.id!);
                } else if (transaction is Expense) {
                  await ref.read(expenseNotifierProvider.notifier).deleteExpense(transaction.id!);
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete transaction: $e'),
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