import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/pdf_export_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/investment_provider.dart';

enum ExportType {
  financial('Complete Financial Report'),
  transactions('Transactions Only'),
  budgets('Budget Analysis');

  const ExportType(this.displayName);
  final String displayName;
}

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportType _selectedType = ExportType.financial;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _titleController = TextEditingController();
  final _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Financial Report';
    _updateFileName();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  void _updateFileName() {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final typePrefix = _selectedType.name;
    _fileNameController.text = '${typePrefix}_${dateFormatter.format(_startDate)}_to_${dateFormatter.format(_endDate)}.pdf';
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
        _updateFileName();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
        _updateFileName();
      });
    }
  }

  Future<void> _exportData() async {
    final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);
    
    try {
      switch (_selectedType) {
        case ExportType.financial:
          final incomes = await ref.read(incomeProvider.future);
          final expenses = await ref.read(expenseProvider.future);
          final budgets = await ref.read(budgetProvider.future);
          final investments = await ref.read(investmentProvider.future);

          // Filter data by date range
          final filteredIncomes = incomes.where((income) =>
            income.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            income.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          final filteredExpenses = expenses.where((expense) =>
            expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          final filteredInvestments = investments.where((investment) =>
            investment.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            investment.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          await exportNotifier.exportFinancialReport(
            incomes: filteredIncomes,
            expenses: filteredExpenses,
            budgets: budgets,
            investments: filteredInvestments,
            startDate: _startDate,
            endDate: _endDate,
            title: _titleController.text.isNotEmpty ? _titleController.text : null,
            fileName: _fileNameController.text,
          );
          break;

        case ExportType.transactions:
          final incomes = await ref.read(incomeProvider.future);
          final expenses = await ref.read(expenseProvider.future);

          // Filter data by date range
          final filteredIncomes = incomes.where((income) =>
            income.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            income.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          final filteredExpenses = expenses.where((expense) =>
            expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          await exportNotifier.exportTransactionsReport(
            incomes: filteredIncomes,
            expenses: filteredExpenses,
            startDate: _startDate,
            endDate: _endDate,
            fileName: _fileNameController.text,
          );
          break;

        case ExportType.budgets:
          final budgets = await ref.read(budgetProvider.future);
          final expenses = await ref.read(expenseProvider.future);

          // Filter expenses by date range
          final filteredExpenses = expenses.where((expense) =>
            expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1)))
          ).toList();

          await exportNotifier.exportBudgetReport(
            budgets: budgets,
            expenses: filteredExpenses,
            startDate: _startDate,
            endDate: _endDate,
            fileName: _fileNameController.text,
          );
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(pdfExportNotifierProvider);
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download, color: Colors.blue),
          SizedBox(width: 8),
          Text('Export Data to PDF'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Export type selection
              Text(
                'Export Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ExportType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ExportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _updateFileName();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date range selection
              Text(
                'Date Range',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(dateFormatter.format(_startDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(dateFormatter.format(_endDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Report title (for financial reports)
              if (_selectedType == ExportType.financial) ...[
                Text(
                  'Report Title',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter report title',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // File name
              Text(
                'File Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter file name',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // Export info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Export Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getExportDescription(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: exportState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: exportState.isLoading ? null : _exportData,
          icon: exportState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_download),
          label: Text(exportState.isLoading ? 'Exporting...' : 'Export'),
        ),
      ],
    );
  }

  String _getExportDescription() {
    switch (_selectedType) {
      case ExportType.financial:
        return 'Includes income, expenses, budgets, and investments with financial summary and analysis.';
      case ExportType.transactions:
        return 'Includes all income and expense transactions for the selected date range.';
      case ExportType.budgets:
        return 'Includes budget analysis with spending comparison and remaining amounts.';
    }
  }
}

/// Quick export buttons widget for common export actions
class QuickExportButtons extends ConsumerWidget {
  const QuickExportButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Export button
        IconButton.outlined(
          onPressed: () => _showExportDialog(context),
          icon: const Icon(Icons.file_download),
          tooltip: 'Export to PDF',
        ),
        const SizedBox(width: 8),
        // Quick monthly report
        IconButton.outlined(
          onPressed: () => _quickMonthlyExport(context, ref),
          icon: const Icon(Icons.calendar_month),
          tooltip: 'Export This Month',
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExportDialog(),
    );
  }

  Future<void> _quickMonthlyExport(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);

    try {
      final incomes = await ref.read(incomeProvider.future);
      final expenses = await ref.read(expenseProvider.future);
      final budgets = await ref.read(budgetProvider.future);
      final investments = await ref.read(investmentProvider.future);

      // Filter data for current month
      final filteredIncomes = incomes.where((income) =>
        income.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        income.date.isBefore(endOfMonth.add(const Duration(days: 1)))
      ).toList();

      final filteredExpenses = expenses.where((expense) =>
        expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))
      ).toList();

      final filteredInvestments = investments.where((investment) =>
        investment.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        investment.date.isBefore(endOfMonth.add(const Duration(days: 1)))
      ).toList();

      await exportNotifier.exportFinancialReport(
        incomes: filteredIncomes,
        expenses: filteredExpenses,
        budgets: budgets,
        investments: filteredInvestments,
        startDate: startOfMonth,
        endDate: endOfMonth,
        title: 'Monthly Financial Report - ${DateFormat('MMMM yyyy').format(now)}',
        fileName: 'monthly_report_${DateFormat('yyyy_MM').format(now)}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly report exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}