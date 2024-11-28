import 'package:flutter/material.dart';
import 'DatabaseManager.dart';
import 'MenuItem.dart';

class FoodItemScreen extends StatefulWidget {
  @override
  _FoodItemScreenState createState() => _FoodItemScreenState();
}

class _FoodItemScreenState extends State<FoodItemScreen> {
  List<MenuItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseManager.instance.fetchFoodItems();
    print("Fetched items: $items");  // Debugging print
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    await DatabaseManager.instance.addFoodItem(MenuItem(menuItem: 'Sandwich', cost: 4.99));
    _loadItems();  // Refresh the list after adding an item
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseManager.instance.deleteFoodItem(id);
    _loadItems();  // Refresh the list after deleting an item
  }

  @override
  Widget build(BuildContext context) {
    print("");
    print("printing database");
    DatabaseManager.instance.debugPrintDatabase();
    return Scaffold(
      appBar: AppBar(title: Text('Food Items')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.menuItem),
            subtitle: Text("\$${item.cost}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteItem(item.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
