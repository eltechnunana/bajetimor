import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/income.dart';
import '../../core/models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final String type; // 'income' or 'expense'
  final dynamic transaction; // Income or Expense for editing
  final bool isEditing;

  const AddTransactionDialog({
    super.key,
    required this.type,
    this.transaction,
    this.isEditing = false,
  });

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.transaction != null) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    if (widget.type == 'income' && widget.transaction is Income) {
      final income = widget.transaction as Income;
      _descriptionController.text = income.note ?? '';
      _amountController.text = income.amount.toString();
      _selectedCategory = income.category?.name;
      _selectedDate = income.date;
    } else if (widget.type == 'expense' && widget.transaction is Expense) {
      final expense = widget.transaction as Expense;
      _descriptionController.text = expense.note ?? '';
      _amountController.text = expense.amount.toString();
      _selectedCategory = expense.category?.name;
      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.type == 'income' 
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    return AlertDialog(
      title: Text(
        widget.isEditing 
            ? 'Edit ${widget.type.toUpperCase()}'
            : 'Add ${widget.type.toUpperCase()}',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'GH₵ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category dropdown
              categories.when(
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
                                'No ${widget.type} categories found. Please add categories first.',
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
              
              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
          onPressed: _isLoading ? null : _saveTransaction,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      if (widget.type == 'income') {
        final income = Income(
          id: widget.isEditing ? (widget.transaction as Income).id : null,
          amount: amount,
          categoryId: 1, // TODO: Get actual category ID from name
          date: _selectedDate,
          note: description.isEmpty ? null : description,
          createdAt: widget.isEditing ? (widget.transaction as Income).createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.isEditing) {
          await ref.read(incomeNotifierProvider.notifier).updateIncome(income);
        } else {
          await ref.read(incomeNotifierProvider.notifier).addIncome(income);
        }
      } else {
        final expense = Expense(
          id: widget.isEditing ? (widget.transaction as Expense).id : null,
          amount: amount,
          categoryId: 1, // TODO: Get actual category ID from name
          date: _selectedDate,
          note: description.isEmpty ? null : description,
          createdAt: widget.isEditing ? (widget.transaction as Expense).createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.isEditing) {
          await ref.read(expenseNotifierProvider.notifier).updateExpense(expense);
        } else {
          await ref.read(expenseNotifierProvider.notifier).addExpense(expense);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? '${widget.type.toUpperCase()} updated successfully'
                  : '${widget.type.toUpperCase()} added successfully',
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