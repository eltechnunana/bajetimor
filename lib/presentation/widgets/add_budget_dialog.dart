import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/budget.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Budget? budget;
  final bool isEditing;

  const AddBudgetDialog({
    super.key,
    this.budget,
    this.isEditing = false,
  });

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedPeriod = 'monthly';
  bool _isLoading = false;

  final List<String> _periods = ['weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.budget != null) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final budget = widget.budget!;
    _amountController.text = budget.amount.toString();
    _selectedCategory = budget.category?.name;
    _selectedPeriod = budget.period.name;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref.watch(expenseCategoriesProvider);

    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Budget' : 'Add Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category dropdown
              expenseCategories.when(
                data: (categoryList) {
                  if (categoryList.isEmpty) {
                    return Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No expense categories found. Please add expense categories first.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryList.map((category) {
                      return DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error loading categories: $error'),
              ),
              
              const SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'GH₵ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Period dropdown
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                items: _periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              

            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveBudget,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      // Check if budget already exists for this category and period (only for new budgets)
      if (!widget.isEditing) {
        final existingBudget = await ref.read(budgetRepositoryProvider)
            .budgetExistsForCategoryAndPeriod(1, DateTime.now(), DateTime.now().add(const Duration(days: 30)));
        
        if (existingBudget) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'A $_selectedPeriod budget for $_selectedCategory already exists',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      final budget = Budget(
        id: widget.isEditing ? widget.budget!.id : null,
        categoryId: widget.isEditing ? widget.budget!.categoryId : 1, // TODO: Get actual category ID
        amount: amount,
        period: BudgetPeriod.values.firstWhere((p) => p.name == _selectedPeriod),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: widget.isEditing ? widget.budget!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditing) {
        await ref.read(budgetNotifierProvider.notifier).updateBudget(budget);
      } else {
        await ref.read(budgetNotifierProvider.notifier).addBudget(budget);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Budget updated successfully'
                  : 'Budget added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}