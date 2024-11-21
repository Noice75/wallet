import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:uuid/uuid.dart';

import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;

enum TransactionType {
  INCOME,

  EXPENSE,
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wallet.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''

      CREATE TABLE categories(

        id TEXT PRIMARY KEY,

        name TEXT NOT NULL,

        color INTEGER NOT NULL,

        icon TEXT NOT NULL

      )

    ''');

    // Insert default categories

    await _insertDefaultCategories(db);

    await db.execute('''

      CREATE TABLE accounts(

        id TEXT PRIMARY KEY,

        name TEXT NOT NULL,

        currency TEXT NOT NULL,

        color INTEGER NOT NULL,

        icon TEXT,

        orderNum INTEGER

      )

    ''');

    // Insert default accounts

    await _insertDefaultAccounts(db);

    // Create transactions table

    await db.execute('''

      CREATE TABLE transactions(

        id TEXT PRIMARY KEY,

        accountId TEXT NOT NULL,

        type TEXT NOT NULL,

        amount REAL NOT NULL,

        title TEXT,

        dateTime INTEGER NOT NULL,

        categoryId TEXT NOT NULL,

        description TEXT,

        FOREIGN KEY (accountId) REFERENCES accounts (id),

        FOREIGN KEY (categoryId) REFERENCES categories (id)

      )

    ''');
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final uuid = const Uuid();

    final defaultCategories = [
      {
        'id': uuid.v4(),
        'name': 'Food & Drinks',
        'color': const Color(0xFF2AC89E).value,
        'icon': Icons.restaurant.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Bills & Fees',
        'color': Colors.pink.value,
        'icon': Icons.receipt.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Transport',
        'color': Colors.amber.value,
        'icon': Icons.directions_bus.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Groceries',
        'color': const Color(0xFF2AC89E).value,
        'icon': Icons.shopping_basket.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Entertainment',
        'color': Colors.orange.value,
        'icon': Icons.movie.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Gifts',
        'color': Colors.pink[100]!.value,
        'icon': Icons.card_giftcard.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Shopping',
        'color': Colors.purple.value,
        'icon': Icons.shopping_bag.codePoint.toRadixString(16),
      },
      {
        'id': uuid.v4(),
        'name': 'Cash',
        'color': const Color(0xFF2AC89E).value,
        'icon': Icons.account_balance_wallet.codePoint.toRadixString(16),
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _insertDefaultAccounts(Database db) async {
    final uuid = const Uuid();

    final defaultAccounts = [
      {
        'id': uuid.v4(),
        'name': 'Cash',
        'currency': 'USD',
        'color': const Color(0xFF2AC89E).value,
        'icon': 'cash',
        'orderNum': 0,
      },
      {
        'id': uuid.v4(),
        'name': 'Bank',
        'currency': 'USD',
        'color': const Color(0xFF2AC89E).value,
        'icon': 'bank',
        'orderNum': 1,
      },
    ];

    for (final account in defaultAccounts) {
      await db.insert('accounts', account);
    }
  }

  // CRUD Operations

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;

    return db.query('categories');
  }

  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    final db = await database;

    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;

    if (!category.containsKey('id')) {
      category['id'] = const Uuid().v4();
    }

    return await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;

    return db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;

    return db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    final db = await database;

    return db.query('accounts', orderBy: 'orderNum ASC');
  }

  Future<int> getMaxAccountOrderNum() async {
    final db = await database;

    final result =
        await db.rawQuery('SELECT MAX(orderNum) as maxOrder FROM accounts');

    return (result.first['maxOrder'] as int?) ?? -1;
  }

  Future<int> insertAccount(Map<String, dynamic> account) async {
    final db = await database;

    if (!account.containsKey('id')) {
      account['id'] = const Uuid().v4();
    }

    if (!account.containsKey('orderNum')) {
      account['orderNum'] = await getMaxAccountOrderNum() + 1;
    }

    return await db.insert(
      'accounts',
      account,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;

    if (!transaction.containsKey('id')) {
      transaction['id'] = const Uuid().v4();
    }

    if (!transaction.containsKey('dateTime')) {
      transaction['dateTime'] = DateTime.now().millisecondsSinceEpoch;
    }

    return await db.insert(
      'transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;

    return db.query('transactions', orderBy: 'dateTime DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByAccount(
      String accountId) async {
    final db = await database;

    return db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'dateTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByType(
      TransactionType type) async {
    final db = await database;

    return db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.toString().split('.').last],
      orderBy: 'dateTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByCategory(
      String categoryId) async {
    final db = await database;

    return db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'dateTime DESC',
    );
  }

  Future<Map<String, dynamic>?> getTransactionById(String id) async {
    final db = await database;

    final results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    final db = await database;

    return db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByType(TransactionType type) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type.toString().split('.').last],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalByAccountAndType(
      String accountId, TransactionType type) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE accountId = ? AND type = ?',
      [accountId, type.toString().split('.').last],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getTotalsByCategory(TransactionType type) async {
    final db = await database;

    final results = await db.rawQuery('''

      SELECT categoryId, SUM(amount) as total 

      FROM transactions 

      WHERE type = ? 

      GROUP BY categoryId

    ''', [type.toString().split('.').last]);

    return Map.fromEntries(
      results.map((row) => MapEntry(
            row['categoryId'] as String,
            (row['total'] as num).toDouble(),
          )),
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsGroupedByDate() async {
    final db = await database;
    final List<Map<String, dynamic>> transactions = await db.query(
      'transactions',
      orderBy: 'dateTime DESC',
    );

    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(transaction['dateTime'] as int);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }

      // Convert expense amounts to negative
      if (transaction['type'] == 'EXPENSE') {
        transaction = Map<String, dynamic>.from(transaction);
        transaction['amount'] = -(transaction['amount'] as num).toDouble();
      }

      groupedTransactions[dateKey]!.add(transaction);
    }

    final List<Map<String, dynamic>> result = [];

    groupedTransactions.forEach((date, transactions) {
      // Calculate daily totals
      double dailyTotal = 0;
      for (var transaction in transactions) {
        dailyTotal += transaction['amount'] as double;
      }

      final dateTime = DateTime.parse(date);
      final isToday = _isToday(dateTime);
      final dayName = isToday ? 'Today' : _getDayName(dateTime);

      // Add date header with net total
      result.add({
        'isHeader': true,
        'date': date,
        'displayDate': '${_getMonthName(dateTime.month)} ${dateTime.day}',
        'dayName': dayName,
        'totalAmount': '${dailyTotal.toStringAsFixed(2)}',
      });

      // Add transactions for this date
      result.addAll(transactions);
    });

    return result;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return days[date.weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return months[month - 1];
  }

  Future<Map<String, dynamic>> getCategoryForTransaction(
      String categoryId) async {
    final category = await getCategoryById(categoryId);

    return category ?? {};
  }

  Future<Map<String, dynamic>> getAccountForTransaction(
      String accountId) async {
    final db = await database;

    final results = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );

    return results.isNotEmpty ? results.first : {};
  }
}
