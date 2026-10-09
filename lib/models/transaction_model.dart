import 'dart:convert';

class Transaction {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final bool isExpense;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.isExpense = true,
  });

  // Convert Transaction Object ke Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'emoji': emoji,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isExpense': isExpense,
    };
  }

  // Convert Map (JSON) ke Transaction Object
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      emoji: map['emoji'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      paymentMethod: map['paymentMethod'] ?? '',
      isExpense: map['isExpense'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}