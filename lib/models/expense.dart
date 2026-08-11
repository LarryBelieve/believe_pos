class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String? note;
  final String expenseDate;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.note,
    required this.expenseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'note': note,
      'expenseDate': expenseDate,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      note: map['note'],
      expenseDate: map['expenseDate'],
    );
  }
}
