class Transaction {
  final String id;
  final String accountId;
  final String type;
  final double amount;
  final String? title;
  final int dateTime;
  final String categoryId;
  final String? description;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.title,
    required this.dateTime,
    required this.categoryId,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type,
      'amount': amount,
      'title': title,
      'dateTime': dateTime,
      'categoryId': categoryId,
      'description': description,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      title: map['title'] as String?,
      dateTime: map['dateTime'] as int,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String?,
    );
  }
}
