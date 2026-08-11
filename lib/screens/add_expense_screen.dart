import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedCategory = 'Other';

  DateTime selectedDate = DateTime.now();

  bool isSaving = false;

  final List<String> categories = [
    'Rent',
    'Electricity',
    'Water',
    'Internet',
    'Transport',
    'Salaries',
    'Repairs',
    'Marketing',
    'Supplies',
    'Other',
  ];

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid expense amount.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final expense = Expense(
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        expenseDate: selectedDate.toIso8601String(),
      );

      await ExpenseService.addExpense(expense);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expense saved successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving expense: $e',
          ),
        ),
      );
    }
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'New Expense',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Record a business expense.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // TITLE
            TextFormField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: inputDecoration(
                'Expense Title',
                Icons.receipt_long,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an expense title';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // AMOUNT
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: inputDecoration(
                'Amount',
                Icons.payments,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }

                final amount = double.tryParse(
                  value.trim(),
                );

                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // CATEGORY
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: inputDecoration(
                'Category',
                Icons.category,
              ),
              items: categories.map(
                (category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // DATE
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.calendar_month,
                  ),
                ),
                title: const Text(
                  'Expense Date',
                ),
                subtitle: Text(
                  formatDate(selectedDate),
                ),
                trailing: IconButton(
                  onPressed: selectDate,
                  icon: const Icon(
                    Icons.edit_calendar,
                  ),
                ),
                onTap: selectDate,
              ),
            ),

            const SizedBox(height: 16),

            // NOTE
            TextFormField(
              controller: noteController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: inputDecoration(
                'Note (Optional)',
                Icons.notes,
              ),
            ),

            const SizedBox(height: 28),

            // SAVE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveExpense,
                icon: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  isSaving ? 'Saving...' : 'Save Expense',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
