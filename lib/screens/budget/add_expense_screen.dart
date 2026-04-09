import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/expense.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Create/Edit expense screen. Pass [expense] to edit existing.
class AddExpenseScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  final Expense? expense; // null = create mode

  const AddExpenseScreen({
    super.key,
    required this.appState,
    required this.concertId,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descController;
  late final TextEditingController _amountController;
  late String _selectedCategory;
  bool _loading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _descController = TextEditingController(text: e?.description ?? '');
    _amountController =
        TextEditingController(text: e?.amount.toStringAsFixed(2) ?? '');
    _selectedCategory = e?.category ?? Expense.categories.first;
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isEditing) {
        widget.expense!.description = _descController.text.trim();
        widget.expense!.amount =
            double.parse(_amountController.text.trim());
        widget.expense!.category = _selectedCategory;
        await widget.appState.updateExpense(widget.expense!);
        if (!mounted) return;
        AppSnackbar.success(context, 'Expense updated!');
      } else {
        final expense = Expense(
          category: _selectedCategory,
          amount: double.parse(_amountController.text.trim()),
          description: _descController.text.trim(),
          concertId: widget.concertId,
        );
        await widget.appState.addExpense(expense);
        if (!mounted) return;
        AppSnackbar.success(context, 'Expense logged!');
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to save expense. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Log Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Category'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: DropdownButtonFormField<String>(
                  value: Expense.categories.contains(_selectedCategory)
                      ? _selectedCategory
                      : Expense.categories.first,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: Expense.categories
                      .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat,
                              style: const TextStyle(
                                  color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) => setState(
                      () => _selectedCategory = val ?? _selectedCategory),
                ),
              ),
              const SizedBox(height: 16),

              _label('Description'),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'What was this expense for?',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _label('Amount (₹)'),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(v.trim());
                  if (amount == null) {
                    return 'Enter a valid number';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: _isEditing ? 'Update Expense' : 'Log Expense',
                icon: _isEditing
                    ? Icons.save_rounded
                    : Icons.add_shopping_cart_rounded,
                isLoading: _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );
}
