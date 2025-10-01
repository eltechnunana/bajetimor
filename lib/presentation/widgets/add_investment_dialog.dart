import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/investment.dart';
import '../../providers/investment_provider.dart';

class AddInvestmentDialog extends ConsumerStatefulWidget {
  final Investment? investment;
  final bool isEditing;

  const AddInvestmentDialog({
    super.key,
    this.investment,
    this.isEditing = false,
  });

  @override
  ConsumerState<AddInvestmentDialog> createState() => _AddInvestmentDialogState();
}

class _AddInvestmentDialogState extends ConsumerState<AddInvestmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = 'Stocks';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _investmentTypes = [
    'Stocks',
    'Bonds',
    'Mutual Funds',
    'ETF',
    'Real Estate',
    'Cryptocurrency',
    'Commodities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.investment != null) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final investment = widget.investment!;
    _nameController.text = investment.type;
    _initialAmountController.text = investment.amount.toString();
    _currentValueController.text = investment.currentValue?.toString() ?? '';
    _expectedReturnController.text = investment.expectedReturn?.toString() ?? '';
    _notesController.text = investment.note ?? '';
    _selectedType = investment.type;
    _selectedDate = investment.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _currentValueController.dispose();
    _expectedReturnController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Investment' : 'Add Investment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Investment Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an investment name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Investment Type',
                  border: OutlineInputBorder(),
                ),
                items: _investmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Initial amount field
              TextFormField(
                controller: _initialAmountController,
                decoration: const InputDecoration(
                  labelText: 'Initial Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'GH₵ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the initial amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Current value field
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(
                  labelText: 'Current Value',
                  border: OutlineInputBorder(),
                  prefixText: 'GH₵ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the current value';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Expected return field
              TextFormField(
                controller: _expectedReturnController,
                decoration: const InputDecoration(
                  labelText: 'Expected Return (%)',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the expected return';
                  }
                  final returnRate = double.tryParse(value);
                  if (returnRate == null) {
                    return 'Please enter a valid percentage';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Purchase date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
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
          onPressed: _isLoading ? null : _saveInvestment,
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
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_initialAmountController.text);
      final currentValue = _currentValueController.text.trim().isEmpty 
          ? null 
          : double.parse(_currentValueController.text);
      final expectedReturn = _expectedReturnController.text.trim().isEmpty 
          ? null 
          : double.parse(_expectedReturnController.text);
      final type = _nameController.text.trim();
      final note = _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim();

      final investment = Investment(
        id: widget.isEditing ? widget.investment!.id : null,
        amount: amount,
        type: type,
        date: _selectedDate,
        currentValue: currentValue,
        expectedReturn: expectedReturn,
        note: note,
        createdAt: widget.isEditing ? widget.investment!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditing) {
        await ref.read(investmentNotifierProvider.notifier).updateInvestment(investment);
      } else {
        await ref.read(investmentNotifierProvider.notifier).addInvestment(investment);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Investment updated successfully'
                  : 'Investment added successfully',
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