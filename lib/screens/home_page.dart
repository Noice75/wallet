import 'package:flutter/material.dart';

import '../widgets/header_section.dart';

import '../widgets/balance_cards_section.dart';

import '../widgets/transaction_list.dart';

import '../screens/amount_input_modal.dart';

import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<TransactionListState> _transactionListKey = GlobalKey();
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _updateBalanceData();
  }

  Future<void> _updateBalanceData() async {
    final income =
        await DatabaseHelper.instance.getTotalByType(TransactionType.INCOME);
    final expenses =
        await DatabaseHelper.instance.getTotalByType(TransactionType.EXPENSE);
    setState(() {
      _totalIncome = income;
      _totalExpenses = expenses;
      _totalBalance = income - expenses;
    });
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            _buildQuickActionButton(
              context,
              icon: Icons.bolt_rounded,
              label: 'Quick Transfer',
              gradient: const LinearGradient(
                colors: [Color(0xFF7F5AFF), Color(0xFF00D8A5)],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.add_rounded,
                    label: 'Income',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AmountInputModal(
                          title: 'Income',
                          onTransactionAdded: () {
                            _transactionListKey.currentState?.refresh();
                            _updateBalanceData();
                          },
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.remove_rounded,
                    label: 'Expense',
                    color: Colors.red[400]!,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AmountInputModal(
                          title: 'Expense',
                          onTransactionAdded: () {
                            _transactionListKey.currentState?.refresh();
                            _updateBalanceData();
                          },
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AmountInputModal(
                          title: 'Transfer',
                          onTransactionAdded: () {
                            _transactionListKey.currentState?.refresh();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const HeaderSection(),
                const SizedBox(height: 24),
                BalanceCardsSection(
                  totalBalance: _totalBalance,
                  totalIncome: _totalIncome,
                  totalExpenses: _totalExpenses,
                ),
                const SizedBox(height: 32),
                TransactionList(key: _transactionListKey),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
