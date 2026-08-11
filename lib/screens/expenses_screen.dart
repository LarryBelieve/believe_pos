import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> expenses = [];

  bool isLoading = true;

  double totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final loadedExpenses = await ExpenseService.getExpenses();

      double total = 0;

      for (final expense in loadedExpenses) {
        total += expense.amount;
      }

      if (!mounted) return;

      setState(() {
        expenses = loadedExpenses;
        totalExpenses = total;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading expenses: $e',
          ),
        ),
      );
    }
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);

    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = parsedDate.month.toString().padLeft(2, '0');
    final year = parsedDate.year.toString();

    return '$day/$month/$year';
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Rent':
        return Icons.home;

      case 'Electricity':
        return Icons.electrical_services;

      case 'Water':
        return Icons.water_drop;

      case 'Internet':
        return Icons.wifi;

      case 'Transport':
        return Icons.directions_car;

      case 'Salaries':
        return Icons.people;

      case 'Repairs':
        return Icons.build;

      case 'Marketing':
        return Icons.campaign;

      case 'Supplies':
        return Icons.shopping_cart;

      default:
        return Icons.receipt_long;
    }
  }

  Future<void> addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );

    if (result == true) {
      await loadExpenses();
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    if (expense.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Expense?',
          ),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ExpenseService.deleteExpense(
        expense.id!,
      );

      await loadExpenses();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expense deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting expense: $e',
          ),
        ),
      );
    }
  }

  Widget buildExpenseCard(Expense expense) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.red.withOpacity(0.12),
          child: Icon(
            getCategoryIcon(expense.category),
            color: Colors.red,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.category,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatDate(expense.expenseDate),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              if (expense.note != null && expense.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  expense.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: SizedBox(
          width: 105,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () {
                  deleteExpense(expense);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 65,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
            const Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start recording your business expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: addExpense,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Add Expense',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadExpenses,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addExpense,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Expense',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadExpenses,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Expense Overview',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Track and manage your business expenses.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOTAL EXPENSES
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.red.withOpacity(0.12),
                            child: const Icon(
                              Icons.payments,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'R${totalExpenses.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense History',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (expenses.isEmpty)
                    buildEmptyState()
                  else
                    ...expenses.map(
                      buildExpenseCard,
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
