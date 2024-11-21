import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => TransactionListState();
}

class TransactionListState extends State<TransactionList> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture =
        DatabaseHelper.instance.getTransactionsGroupedByDate();
  }

  void refresh() {
    setState(() {
      _loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.map((item) {
            if (item['isHeader'] == true) {
              return _buildDateGroup(
                date: item['displayDate'],
                day: item['dayName'],
                amount: '${item['totalAmount']} INR',
                transactions: const [], // This will be populated in the next items
              );
            }

            return GestureDetector(
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TransactionDetailScreen(
                    transaction: item,
                    onTransactionUpdated: () {
                      setState(() {
                        _loadTransactions();
                      });
                    },
                  ),
                );
                setState(() {
                  _loadTransactions();
                });
              },
              child: FutureBuilder<Map<String, dynamic>>(
                future: DatabaseHelper.instance
                    .getCategoryForTransaction(item['categoryId']),
                builder: (context, categorySnapshot) {
                  if (!categorySnapshot.hasData) return const SizedBox();

                  return _buildTransactionItem(
                    context,
                    category: item['title'] ?? categorySnapshot.data!['name'],
                    amount: item['amount'].toString(),
                    icon: IconData(
                      int.parse(categorySnapshot.data!['icon'], radix: 16),
                      fontFamily: 'MaterialIcons',
                    ),
                    iconBackgroundColor: Color(categorySnapshot.data!['color']),
                    bankName: item['accountId'],
                    type: item['type'],
                    showBank: true,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDateGroup({
    required String date,
    required String day,
    required String amount,
    required List<Widget> transactions,
  }) {
    final amountNum = double.parse(amount.replaceAll(' INR', ''));
    final displayAmount = '${amountNum > 0 ? "+" : ""}$amountNum';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        displayAmount,
                        style: TextStyle(
                          color: amountNum < 0
                              ? Colors.red[400]
                              : const Color(0xFF2AC89E),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    ' INR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...transactions,
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String category,
    required String amount,
    required IconData icon,
    required Color iconBackgroundColor,
    required String bankName,
    required String type,
    bool showBank = true,
  }) {
    final amountNum = double.parse(amount);
    final isExpense = type == 'EXPENSE';

    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getAccountForTransaction(bankName),
      builder: (context, accountSnapshot) {
        if (!accountSnapshot.hasData) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (showBank) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              accountSnapshot.data!['icon'] == 'cash'
                                  ? Icons.account_balance_wallet
                                  : Icons.account_balance,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              accountSnapshot.data!['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color:
                        isExpense ? Colors.red[400] : const Color(0xFF2AC89E),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              '${isExpense ? "-" : ""}${amountNum.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isExpense
                                    ? Colors.red[400]
                                    : const Color(0xFF2AC89E),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ' INR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
