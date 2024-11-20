import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final String currency;
  final int color;
  final String? icon;
  final int orderNum;

  const Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.color,
    this.icon,
    required this.orderNum,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'color': color,
      'icon': icon,
      'orderNum': orderNum,
    };
  }

  static Account fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      currency: map['currency'] as String,
      color: map['color'] as int,
      icon: map['icon'] as String?,
      orderNum: map['orderNum'] as int? ?? 0,
    );
  }
}
