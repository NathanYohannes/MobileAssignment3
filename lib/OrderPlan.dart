import 'dart:convert';

import 'MenuItem.dart';

class OrderPlan {
  final int? id;
  final String date;
  final double targetCost;
  final List<MenuItem> menuItems;

  OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.menuItems,
  });

  // Serialize menuItems to JSON
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'target_cost': targetCost,
      'menu_items': jsonEncode(menuItems.map((item) => item.toMap()).toList()),
    };
  }

  // Convert from Map to OrderPlan
  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    var items = map['menu_items'] as String;
    List<MenuItem> menuItemsList = (jsonDecode(items) as List)
        .map((itemMap) => MenuItem.fromMap(itemMap))
        .toList();

    return OrderPlan(
      id: map['id'],
      date: map['date'],
      targetCost: map['target_cost'],
      menuItems: menuItemsList,
    );
  }
}


