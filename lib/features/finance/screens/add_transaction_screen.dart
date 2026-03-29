import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../receipt_scanner/models/receipt_data.dart';

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

  final List<String> _categories = [
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

  void _handleAddTransaction() {
    if (_formKey.currentState!.validate()) {
      // Create transaction object
      final transaction = {
        'amount': double.parse(_amountController.text),
        'merchant': _merchantController.text,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'date': _selectedDate,
        'timestamp': DateTime.now(),
      };

      // TODO: Save to Firestore
      Navigator.of(context).pop(transaction);
    }
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
        elevation: 0,
        backgroundColor: colorScheme.surface,
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
                  prefixText: 'LKR ',
                  prefixIcon: const Icon(Icons.currency_rupee),
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

              // Merchant field
              Text(
                'Merchant / Store Name',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  hintText: 'e.g., Starbucks',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter merchant name';
                  }
                  if (value.length < 2) {
                    return 'Merchant name too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category dropdown
              Text(
                'Category',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category),
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
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
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
