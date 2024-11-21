import 'package:flutter/material.dart';

import './income_screen.dart';
import './expense_screen.dart';

import '../database/database_helper.dart';

import '../models/account.dart';

import '../widgets/create_account_modal.dart';

class AmountInputModal extends StatefulWidget {
  final String title;

  final VoidCallback? onTransactionAdded;

  const AmountInputModal({
    super.key,
    required this.title,
    this.onTransactionAdded,
  });

  @override
  State<AmountInputModal> createState() => _AmountInputModalState();
}

class _AmountInputModalState extends State<AmountInputModal> {
  String amount = '0';

  Account? selectedAccount;

  @override
  void initState() {
    super.initState();

    _loadDefaultAccount();
  }

  void _loadDefaultAccount() async {
    final accounts = await DatabaseHelper.instance.getAllAccounts();

    if (accounts.isNotEmpty && mounted) {
      setState(() {
        selectedAccount = Account.fromMap(accounts.first);
      });
    }
  }

  void _addNumber(String number) {
    setState(() {
      if (amount == '0' && number != '.') {
        amount = number;
      } else if (!(amount.contains('.') && number == '.')) {
        amount = amount + number;
      }
    });
  }

  void _deleteNumber() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
    });
  }

  void _handleSubmit() {
    if (amount != '0' && selectedAccount != null) {
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => widget.title == 'Income'
            ? IncomeScreen(
                type: widget.title,
                amount: '$amount INR',
                account: selectedAccount!.name,
                autoOpenCategory: true,
                onTransactionAdded: widget.onTransactionAdded,
              )
            : ExpenseScreen(
                type: widget.title,
                amount: '$amount INR',
                account: selectedAccount!.name,
                autoOpenCategory: true,
                onTransactionAdded: widget.onTransactionAdded,
              ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Close button

          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              padding: const EdgeInsets.all(16),
            ),
          ),

          // Income title

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Amount display

          Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: _handleSubmit,
              child: Text(
                amount,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Account Selection

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 60,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getAllAccounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final accounts =
                    snapshot.data!.map((map) => Account.fromMap(map)).toList();

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...accounts.map((account) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildAccountOption(
                            icon: account.icon == null
                                ? Icons.account_balance_wallet
                                : account.icon == 'cash'
                                    ? Icons.account_balance_wallet
                                    : Icons.account_balance,
                            label: account.name,
                            isSelected: selectedAccount?.id == account.id,
                            onTap: () =>
                                setState(() => selectedAccount = account),
                            color: Color(account.color),
                          ),
                        )),
                    _buildAccountOption(
                      icon: Icons.add_circle_outline,
                      label: 'Add account',
                      isSelected: false,
                      onTap: () async {
                        final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const CreateAccountModal(),
                        );

                        if (result == true) {
                          setState(() {}); // Refresh the list
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const Spacer(),

          // Number pad

          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('.'),
                    _buildNumberButton('0'),
                    _buildDeleteButton(),
                  ],
                ),
              ],
            ),
          ),

          // Enter button

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _addNumber(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _deleteNumber,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4DFF) : Colors.grey[900],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
