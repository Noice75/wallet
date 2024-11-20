import 'package:flutter/material.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/category_selection_modal.dart';
import '../models/account.dart';
import '../database/database_helper.dart';
import '../widgets/create_account_modal.dart';

class IncomeScreen extends StatefulWidget {
  final String type;
  final String amount;
  final String account;
  final bool autoOpenCategory;
  final VoidCallback? onTransactionAdded;

  const IncomeScreen({
    super.key,
    required this.type,
    required this.amount,
    required this.account,
    this.autoOpenCategory = false,
    this.onTransactionAdded,
  });

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String? selectedTime;
  String? description;
  String? selectedCategory;
  late String selectedAccount;
  late FocusNode _titleFocusNode;
  late TextEditingController _titleController;
  bool _isInitialCategorySelection = true;
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedAccount = widget.account;
    _titleFocusNode = FocusNode();
    _titleController = TextEditingController();

    if (widget.autoOpenCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCategorySelection();
      });
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showCategorySelection() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategorySelectionModal(),
    );

    if (result != null && mounted) {
      setState(() {
        selectedCategory = result;
      });
    }

    if (_isInitialCategorySelection && mounted) {
      _isInitialCategorySelection = false;
      _titleFocusNode.requestFocus();
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
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF00D8A5))
                          : null,
                      onTap: () {
                        setState(() => selectedAccount = account.name);
                        Navigator.pop(context);
                      },
                    );
                  }),
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
                          final newAccount = Account.fromMap(accounts.last);
                          setState(() => selectedAccount = newAccount.name);
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

  // Add this method to handle time selection
  void _showTimeSelection() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00D8A5),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A1A),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00D8A5),
                onPrimary: Colors.white,
                surface: Color(0xFF1E1E1E),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF1A1A1A),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          final hour = selectedDateTime.hour > 12
              ? selectedDateTime.hour - 12
              : selectedDateTime.hour == 0
                  ? 12
                  : selectedDateTime.hour;
          final minute = selectedDateTime.minute.toString().padLeft(2, '0');
          final period = selectedDateTime.hour >= 12 ? 'PM' : 'AM';
          final month = _getMonthName(selectedDateTime.month);
          selectedTime = '$month ${selectedDateTime.day} $hour:$minute $period';
        });
      }
    }
  }

  // Add this helper method
  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  // Update the _buildListTile method to handle time selection
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
  }) {
    // Get current time in the correct format
    if (selectedTime == null) {
      final now = selectedDateTime;
      final hour = now.hour > 12
          ? now.hour - 12
          : now.hour == 0
              ? 12
              : now.hour;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';
      final month = _getMonthName(now.month);
      selectedTime = '$month ${now.day} $hour:$minute $period';
    }

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
        trailing: title == 'Created on'
            ? Text(
                selectedTime!,
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
        onTap: title == 'Created on' ? _showTimeSelection : onTap,
      ),
    );
  }

  // Add this method to handle description input
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
                        backgroundColor: const Color(0xFF00D8A5),
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

  // Add this method to handle adding the transaction
  void _handleAddIncome() async {
    try {
      // Get the account ID for the selected account name
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      final selectedAccountData = accounts.firstWhere(
        (account) => account['name'] == selectedAccount,
        orElse: () => accounts.first,
      );

      // Get the category ID for the selected category name
      final categories = await DatabaseHelper.instance.getAllCategories();
      final selectedCategoryData = categories.firstWhere(
        (category) => category['name'] == selectedCategory,
        orElse: () => categories.first,
      );

      // Create the transaction
      final transaction = {
        'accountId': selectedAccountData['id'],
        'type': 'INCOME',
        'amount': double.parse(widget.amount.replaceAll(' USD', '')),
        'title':
            _titleController.text.isEmpty ? 'Income' : _titleController.text,
        'dateTime': selectedDateTime.millisecondsSinceEpoch,
        'categoryId': selectedCategoryData['id'],
        'description': description,
      };

      // Insert the transaction
      await DatabaseHelper.instance.insertTransaction(transaction);

      // Call the callback to refresh the home screen
      widget.onTransactionAdded?.call();

      // Close the screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header section - Keep outside ScrollView
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 28),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title input field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Income title',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Category button - Moved up
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton.icon(
                      onPressed: _showCategorySelection,
                      icon: const Icon(Icons.add, size: 24),
                      label: Text(
                        selectedCategory ?? 'Add category',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
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

                  const SizedBox(height: 32),

                  // Account info section - Moved down
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: InkWell(
                      onTap: _showAccountSelection,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B4DFF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF6B4DFF),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Account',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  selectedAccount,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description and date fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.notes_outlined,
                          title: 'Add description',
                          onTap: _showDescriptionModal,
                        ),
                        const SizedBox(height: 16),
                        _buildListTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Created on',
                          trailing: selectedTime,
                        ),
                      ],
                    ),
                  ),

                  // Add bottom padding to ensure content doesn't get hidden
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom amount section - Keep outside ScrollView
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.amount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Add to $selectedAccount',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handleAddIncome,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text(
                    'Add Income',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D8A5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
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