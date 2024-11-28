import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseManager.dart';
import 'MenuItem.dart';
import 'OrderPlan.dart';

class OrderPlanScreen extends StatefulWidget {
  @override
  _OrderPlanScreenState createState() => _OrderPlanScreenState();
}

class _OrderPlanScreenState extends State<OrderPlanScreen> {
  List<MenuItem> _foodItems = [];
  List<MenuItem> _selectedItems = [];
  double _targetCost = 0.0;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  // Load the food items from the database
  Future<void> _loadFoodItems() async {
    final items = await DatabaseManager.instance.fetchFoodItems();
    setState(() {
      _foodItems = items;
    });
  }

  // Add an item to the selected items list
  void _toggleItemSelection(MenuItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  // Calculate the total cost of selected items
  double _calculateTotalCost() {
    return _selectedItems.fold(0,
            (sum, item) => sum + item.cost);
  }

  // Save the order plan to the database
  Future<void> _saveOrderPlan() async {
    if (_dateController.text.isEmpty || _selectedItems.isEmpty) {
      _showSnackbar('Please select a date and at least one food item.');
      return;
    }

    double totalCost = _calculateTotalCost();
    if (totalCost > _targetCost) {
      _showSnackbar(
          'Total cost exceeds the target cost.');
      return;
    }

    // Create the OrderPlan instance with targetCost
    final orderPlan = OrderPlan(
      date: _dateController.text,
      targetCost: _targetCost, // Pass target cost
      menuItems: _selectedItems,
    );

    await DatabaseManager.instance.addOrderPlan(orderPlan);

    _showSnackbar('Order plan saved successfully!');
  }


  // Display a Snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // View the order plan for a specific date
  Future<void> _viewOrderPlan() async {
    if (_dateController.text.isEmpty) {
      _showSnackbar('Please enter a date.');
      return;
    }

    OrderPlan? orderPlan =
    await DatabaseManager.instance.fetchOrderPlan(
        _dateController.text);

    if (orderPlan != null) {
      _showOrderPlanDialog(orderPlan);
    } else {
      _showSnackbar('No order plan found for the selected date.');
    }
  }

  void _showOrderPlanDialog(OrderPlan orderPlan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Plan for ${orderPlan.date}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target Cost: \$${orderPlan.targetCost}'),
                SizedBox(height: 10),
                Text('Menu Items:'),
                for (var item in orderPlan.menuItems)
                  Text('${item.menuItem} - \$${item.cost}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date input
            TextField(
              controller: _dateController,
              readOnly: true, // Prevents manual editing
              decoration: InputDecoration(
                labelText: 'Enter Date',
                hintText: 'Select a date (e.g., 2024-11-26)',
                suffixIcon: Icon(Icons.calendar_today), // Adds a calendar icon
              ),
              onTap: () async {
                // Open the DatePicker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  // Format the selected date to 'yyyy-MM-dd' and update the controller
                  _dateController.text = pickedDate.toIso8601String().split('T').first;
                }
              },
            ),
            SizedBox(height: 10),
            // Target cost input
            TextField(
              onChanged: (value) {
                setState(() {
                  _targetCost = double.tryParse(value) ?? 0.0;
                });
              },
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Enter Target Cost'),
            ),
            SizedBox(height: 20),
            // Food items list
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  return ListTile(
                    title: Text(item.menuItem),
                    subtitle: Text('\$${item.cost}'),
                    trailing: IconButton(
                      icon: Icon(
                        _selectedItems.contains(item) ? Icons.check_box : Icons.check_box_outline_blank,
                      ),
                      onPressed: () => _toggleItemSelection(item),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Total cost display
            Text('Total Cost: \$${_calculateTotalCost().toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveOrderPlan,
                  child: Text('Save Order Plan'),
                ),
                ElevatedButton(
                  onPressed: _viewOrderPlan,
                  child: Text('View Order Plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
