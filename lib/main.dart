import 'package:flutter/material.dart';
import 'FoodItemScreen.dart';
import 'OrderPlanScreen.dart';
import 'DatabaseManager.dart';  // Import DatabaseManager to initialize it

void main() async {
  // Ensure Flutter bindings are initialized before doing any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database by accessing the database property
  await DatabaseManager.instance.initializeDB();
  await DatabaseManager.instance.insertInitialData();

  // After database initialization, run the app
  runApp(FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Ordering App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodItemScreen()),
                );
              },
              child: Text('Manage Food Items'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPlanScreen()),
                );
              },
              child: Text('Plan Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
