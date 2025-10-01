import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/investment.dart';
import '../../providers/investment_provider.dart';
import '../widgets/investment_card.dart';
import '../widgets/add_investment_dialog.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investments = ref.watch(investmentProvider);
    final portfolioDistribution = ref.watch(portfolioDistributionProvider);
    final totalInvestment = ref.watch(totalInvestmentProvider);
    final totalCurrentValue = ref.watch(totalCurrentValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => _showPortfolioDistribution(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(investmentProvider);
          ref.invalidate(portfolioDistributionProvider);
          ref.invalidate(totalInvestmentProvider);
          ref.invalidate(totalCurrentValueProvider);
        },
        child: Column(
          children: [
            // Investment summary card
            _buildInvestmentSummary(ref),
            
            // Investment list
            Expanded(
              child: investments.when(
                data: (investmentList) {
                  if (investmentList.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: investmentList.length,
                    itemBuilder: (context, index) {
                      final investment = investmentList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InvestmentCard(
                          investment: investment,
                          onTap: () => _showInvestmentDetails(context, investment),
                          onEdit: () => _editInvestment(context, investment),
                          onDelete: () => _deleteInvestment(context, ref, investment),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error.toString(), ref),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvestmentSummary(WidgetRef ref) {
    final performanceSummary = ref.watch(investmentPerformanceSummaryProvider);
    final totalInvestment = ref.watch(totalInvestmentProvider);
    final totalCurrentValue = ref.watch(totalCurrentValueProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Summary',
              style: Theme.of(ref.context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            performanceSummary.when(
              data: (summary) => Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Invested',
                      'GH₵${(summary['total_invested'] as double).toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryItem(
                      'Current Value',
                      'GH₵${(summary['total_current_value'] as double).toStringAsFixed(2)}',
                      Icons.account_balance,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 12),
            // Profit/Loss calculation
            totalInvestment.when(
              data: (invested) => totalCurrentValue.when(
                data: (current) {
                  final profitLoss = current - invested;
                  final percentage = invested > 0 ? (profitLoss / invested) * 100 : 0.0;
                  final isProfit = profitLoss >= 0;
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isProfit ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up : Icons.trending_down,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isProfit ? 'Total Gain' : 'Total Loss',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${isProfit ? '+' : ''}GH₵${profitLoss.toStringAsFixed(2)} (${percentage.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isProfit ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No investments found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your investment portfolio',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
              ref.invalidate(investmentProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddInvestmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddInvestmentDialog(),
    );
  }

  void _showInvestmentDetails(BuildContext context, Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Investment Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', investment.type),
              _buildDetailRow('Type', investment.type),
              _buildDetailRow('Initial Amount', investment.formattedAmount),
              _buildDetailRow('Current Value', investment.formattedCurrentValue),
              _buildDetailRow('Expected Return', '${investment.expectedReturn?.toStringAsFixed(2) ?? 'N/A'}%'),
              _buildDetailRow('Profit/Loss', investment.formattedProfitLoss),
              _buildDetailRow('Return %', '${investment.returnPercentage.toStringAsFixed(2)}%'),
              _buildDetailRow('Purchase Date', investment.formattedDate),
              if (investment.note?.isNotEmpty == true)
                _buildDetailRow('Notes', investment.note!),
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
              _editInvestment(context, investment);
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
            width: 120,
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

  void _editInvestment(BuildContext context, Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AddInvestmentDialog(
        investment: investment,
        isEditing: true,
      ),
    );
  }

  void _deleteInvestment(BuildContext context, WidgetRef ref, Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment'),
        content: const Text(
          'Are you sure you want to delete this investment? This action cannot be undone.',
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
                await ref.read(investmentNotifierProvider.notifier).deleteInvestment(investment.id!);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Investment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete investment: $e'),
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

  void _showPortfolioDistribution(BuildContext context, WidgetRef ref) {
    final distribution = ref.read(portfolioDistributionProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Portfolio Distribution'),
        content: distribution.when(
          data: (data) {
            if (data.isEmpty) {
              return const Text('No investment data available');
            }
            
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: data.map((item) {
                  final percentage = (item['percentage'] as double).toStringAsFixed(1);
                  final amount = (item['total_amount'] as double).toStringAsFixed(2);
                  
                  return ListTile(
                    title: Text(item['type'] as String),
                    subtitle: Text('GH₵$amount'),
                    trailing: Text('$percentage%'),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
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
}