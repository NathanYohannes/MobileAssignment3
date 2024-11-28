class MenuItem {
  final int? id;
  final String menuItem;
  final double cost;

  MenuItem({this.id, required this.menuItem, required this.cost});

  // Convert a Map into a MenuItem
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      menuItem: map['menu_item'],
      cost: map['cost'],
    );
  }

  // Convert a MenuItem into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_item': menuItem,
      'cost': cost,
    };
  }
}
