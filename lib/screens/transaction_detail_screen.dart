import 'package:flutter/material.dart';
import '../widgets/category_selection_modal.dart';
import '../models/account.dart';
import '../database/database_helper.dart';
import '../widgets/create_account_modal.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onTransactionUpdated;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.onTransactionUpdated,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late String type;
  late String selectedAccount;
  late String? selectedCategory;
  late String? description;
  late DateTime selectedDateTime;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  bool isEditing = false;
  Map<String, dynamic>? accountData;
  Map<String, dynamic>? categoryData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Get account data from accountId
    final accounts = await DatabaseHelper.instance.getAllAccounts();
    final account = accounts.firstWhere(
      (acc) => acc['id'] == widget.transaction['accountId'],
    );

    // Get category data from categoryId
    final categories = await DatabaseHelper.instance.getAllCategories();
    final category = categories.firstWhere(
      (cat) => cat['id'] == widget.transaction['categoryId'],
    );

    setState(() {
      type = widget.transaction['type'];
      selectedAccount = account['name'];
      accountData = account;
      selectedCategory = category['name'];
      categoryData = category;
      description = widget.transaction['description'];
      selectedDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.transaction['dateTime']);

      _titleController =
          TextEditingController(text: widget.transaction['title']);

      // Handle the amount properly - always store positive value
      final amount = widget.transaction['amount'].abs().toStringAsFixed(2);
      _amountController = TextEditingController(text: amount);
    });
  }

  String _getFormattedDateTime() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = selectedDateTime.hour > 12
        ? selectedDateTime.hour - 12
        : selectedDateTime.hour == 0
            ? 12
            : selectedDateTime.hour;
    final minute = selectedDateTime.minute.toString().padLeft(2, '0');
    final period = selectedDateTime.hour >= 12 ? 'PM' : 'AM';
    return '${months[selectedDateTime.month - 1]} ${selectedDateTime.day}, ${selectedDateTime.year} at $hour:$minute $period';
  }

  void _showEditScreen() {
    setState(() {
      isEditing = true;
    });
  }

  void _toggleTransactionType() {
    setState(() {
      type = type == 'INCOME' ? 'EXPENSE' : 'INCOME';
    });
  }

  void _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTransaction(widget.transaction['id']);
      widget.onTransactionUpdated?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _updateTransaction() async {
    try {
      // Get account ID from selected account name
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      final selectedAccountData = accounts.firstWhere(
        (account) => account['name'] == selectedAccount,
      );

      // Get category ID from selected category name
      final categories = await DatabaseHelper.instance.getAllCategories();
      final selectedCategoryData = categories.firstWhere(
        (category) => category['name'] == selectedCategory,
      );

      // Always store amount as positive
      final amount =
          double.parse(_amountController.text.replaceAll(' INR', '')).abs();

      // Create updated transaction map
      final updatedTransaction = {
        'id': widget.transaction['id'],
        'accountId': selectedAccountData['id'],
        'type': type,
        'amount': amount, // Always store positive amount
        'title': _titleController.text.isEmpty ? type : _titleController.text,
        'dateTime': selectedDateTime.millisecondsSinceEpoch,
        'categoryId': selectedCategoryData['id'],
        'description': description,
      };

      // Update transaction in database
      await DatabaseHelper.instance.updateTransaction(updatedTransaction);

      // Call the callback to refresh the transaction list
      widget.onTransactionUpdated?.call();

      // Show success message and pop back to home screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully'),
            backgroundColor: Color(0xFF00D8A5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating transaction: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  void _showAccountSelection() async {
    final accounts = await DatabaseHelper.instance.getAllAccounts();
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  ...accounts.map((accountMap) {
                    final account = Account.fromMap(accountMap);
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(account.color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          account.icon == 'cash'
                              ? Icons.account_balance_wallet
                              : Icons.account_balance,
                          color: Color(account.color),
                        ),
                      ),
                      title: Text(
                        account.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: selectedAccount == account.name
                          ? Icon(
                              Icons.check_circle,
                              color: type == 'INCOME'
                                  ? const Color(0xFF00D8A5)
                                  : Colors.red[400],
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedAccount = account.name;
                          accountData = accountMap;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                  // Add new account option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      'Add new account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const CreateAccountModal(),
                      );

                      if (result == true && mounted) {
                        final accounts =
                            await DatabaseHelper.instance.getAllAccounts();
                        if (accounts.isNotEmpty) {
                          final newAccount = accounts.last;
                          setState(() {
                            selectedAccount = newAccount['name'];
                            accountData = newAccount;
                          });
                        }
                      }
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

  void _showDateTimePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showDescriptionModal() {
    final TextEditingController descriptionController =
        TextEditingController(text: description);
    final FocusNode focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        focusNode.unfocus();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: descriptionController,
                    focusNode: focusNode,
                    maxLines: null,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter any details here',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        focusNode.unfocus();
                        setState(() {
                          description = descriptionController.text;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type == 'INCOME'
                            ? const Color(0xFF00D8A5)
                            : Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: title == 'Add description' && description != null
            ? Text(
                description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        trailing: trailing != null
            ? Text(
                trailing,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: 24,
              ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (accountData == null || categoryData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isIncome = type == 'INCOME';
    final accentColor = isIncome ? const Color(0xFF00D8A5) : Colors.red[400];

    final amountDisplay = '${_amountController.text} INR';

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (isEditing) {
                      setState(() {
                        isEditing = false;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(isEditing ? Icons.arrow_back : Icons.close,
                      size: 28),
                ),
                GestureDetector(
                  onTap: isEditing ? _toggleTransactionType : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isIncome ? Icons.download : Icons.upload,
                          size: 20,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _deleteTransaction,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with underline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _titleController,
                      enabled: isEditing,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton.icon(
                      onPressed: isEditing
                          ? () async {
                              final result = await showModalBottomSheet<String>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const CategorySelectionModal(),
                              );

                              if (result != null) {
                                final categories = await DatabaseHelper.instance
                                    .getAllCategories();
                                final category = categories.firstWhere(
                                  (cat) => cat['name'] == result,
                                );
                                setState(() {
                                  selectedCategory = result;
                                  categoryData = category;
                                });
                              }
                            }
                          : null,
                      icon: Icon(
                        IconData(
                          int.parse(categoryData!['icon'], radix: 16),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                      ),
                      label: Text(
                        selectedCategory!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.notes_outlined,
                          title: 'Add description',
                          onTap: isEditing ? _showDescriptionModal : null,
                        ),
                        const SizedBox(height: 16),
                        _buildListTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Created on',
                          trailing: _getFormattedDateTime(),
                          onTap: isEditing ? _showDateTimePicker : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay with section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay with',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: isEditing ? _showAccountSelection : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Color(accountData!['color']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  accountData!['icon'] == 'cash'
                                      ? Icons.account_balance_wallet
                                      : Icons.account_balance,
                                  color: Color(accountData!['color']),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedAccount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isEditing) ...[
                                  const Spacer(),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom amount section
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isIncome)
                              Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: isEditing
                                    ? SizedBox(
                                        width: 150,
                                        child: TextField(
                                          controller: _amountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: accentColor,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _amountController.text,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                              ),
                            ),
                            const Text(
                              ' INR',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isIncome
                            ? 'Added to $selectedAccount'
                            : 'Subtracted from $selectedAccount',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isEditing ? _updateTransaction : _showEditScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save' : 'Edit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
