import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int color;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
      icon: map['icon'] as String,
    );
  }
}
