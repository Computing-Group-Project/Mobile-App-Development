import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../receipt_scanner/models/receipt_data.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final ReceiptData? prefilledReceiptData;

  const AddTransactionScreen({
    super.key,
    this.prefilledReceiptData,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food & Drinks';
  String _selectedType = 'expense';

  static const List<String> _expenseCategories = [
    'Food & Drinks',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Education',
    'Health',
    'Groceries',
    'Rent',
    'Subscriptions',
    'Other',
  ];

  static const List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Scholarship',
    'Part-time Job',
    'Gift',
    'Business',
    'Investment',
    'Other',
  ];

  List<String> get _categories =>
      _selectedType == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _merchantController = TextEditingController();
    _descriptionController = TextEditingController();

    // Pre-fill with receipt data if provided
    if (widget.prefilledReceiptData != null) {
      _prefillFormWithReceipt();
    }
  }

  void _prefillFormWithReceipt() {
    final receipt = widget.prefilledReceiptData!;

    if (receipt.totalAmount != null) {
      _amountController.text = receipt.totalAmount!.toStringAsFixed(2);
    }

    if (receipt.merchantName != null) {
      _merchantController.text = receipt.merchantName!;
    }

    if (receipt.date != null) {
      _selectedDate = receipt.date!;
    }

    // Auto-detect category from merchant name
    if (receipt.merchantName != null) {
      _selectedCategory = _detectCategory(receipt.merchantName!);
    }
  }

  String _detectCategory(String merchantName) {
    final name = merchantName.toLowerCase();

    if (name.contains('restaurant') ||
        name.contains('cafe') ||
        name.contains('pizza')) {
      return 'Food & Drinks';
    } else if (name.contains('uber') ||
        name.contains('taxi') ||
        name.contains('bus')) {
      return 'Transport';
    } else if (name.contains('shop') ||
        name.contains('store') ||
        name.contains('mall')) {
      return 'Shopping';
    } else if (name.contains('cinema') || name.contains('movie')) {
      return 'Entertainment';
    } else if (name.contains('hospital') || name.contains('pharmacy')) {
      return 'Health';
    } else if (name.contains('school') || name.contains('university')) {
      return 'Education';
    } else if (name.contains('grocery') || name.contains('supermarket')) {
      return 'Groceries';
    }

    return 'Food & Drinks'; // Default
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleAddTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      id: '',
      title: _merchantController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      type: _selectedType,
      notes: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prefilledReceiptData != null
              ? 'Confirm Receipt'
              : 'Add Transaction',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount field
              Text(
                'Amount',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefix: const Text('LKR ', style: TextStyle(fontSize: 14)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: _selectedType == 'expense',
                      selectedColor:
                          Colors.red.withValues(alpha: 0.15),
                      onSelected: (_) => setState(() {
                        _selectedType = 'expense';
                        _selectedCategory = _expenseCategories.first;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: _selectedType == 'income',
                      selectedColor:
                          Colors.green.withValues(alpha: 0.15),
                      onSelected: (_) => setState(() {
                        _selectedType = 'income';
                        _selectedCategory = _incomeCategories.first;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title field (context-aware)
              Text(
                _selectedType == 'income' ? 'Income Source' : 'Merchant / Store',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  hintText: _selectedType == 'income'
                      ? 'e.g., Part-time job, Scholarship'
                      : 'e.g., Starbucks',
                  prefixIcon: Icon(
                    _selectedType == 'income'
                        ? Icons.account_balance_wallet_outlined
                        : Icons.store_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _selectedType == 'income'
                        ? 'Please enter an income source'
                        : 'Please enter merchant name';
                  }
                  if (value.length < 2) return 'Name too short';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category dropdown
              Text(
                _selectedType == 'income' ? 'Income Type' : 'Category',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedType),
                value: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    _selectedType == 'income'
                        ? Icons.payments_outlined
                        : Icons.category_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 24),

              // Date picker
              Text(
                'Date',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description field
              Text(
                'Description (Optional)',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add any notes...',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleAddTransaction,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
