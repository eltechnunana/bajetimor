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
    
    // Debug print to help identify the issue
    print('Budget category: ${budget.category?.name}');
    print('Budget category ID: ${budget.categoryId}');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref.watch(categoriesProvider);

    return expenseCategories.when(
      data: (categoryList) {
        // Ensure the selected category is valid when categories are loaded
        if (widget.isEditing && widget.budget != null) {
          final budget = widget.budget!;
          if (budget.category?.name != null) {
            final categoryExists = categoryList.any((cat) => cat.name == budget.category!.name);
            if (categoryExists && _selectedCategory != budget.category!.name) {
              // Use a post-frame callback to avoid calling setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedCategory = budget.category!.name;
                  });
                }
              });
            }
          }
        }

        return _buildDialogContent(categoryList);
      },
      loading: () => AlertDialog(
        title: Text(widget.isEditing ? 'Edit Budget' : 'Add Budget'),
        content: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AlertDialog(
        title: Text(widget.isEditing ? 'Edit Budget' : 'Add Budget'),
        content: Text('Error loading categories: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(List<dynamic> categoryList) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Budget' : 'Add Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category dropdown
              if (categoryList.isEmpty)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No categories found. Please add categories first.',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryList.map((category) {
                    return DropdownMenuItem<String>(
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
      
      // Get the category ID from the selected category
      final categoriesAsync = ref.read(categoriesProvider);
      final categories = categoriesAsync.value ?? [];
      final selectedCategoryObj = categories.firstWhere(
        (cat) => cat.name == _selectedCategory,
        orElse: () => throw Exception('Selected category not found'),
      );

      // Check if budget already exists for this category and period (only for new budgets)
      if (!widget.isEditing) {
        final existingBudget = await ref.read(budgetRepositoryProvider)
            .budgetExistsForCategoryAndPeriod(selectedCategoryObj.id!, DateTime.now(), DateTime.now().add(const Duration(days: 30)));
        
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
        categoryId: selectedCategoryObj.id!,
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