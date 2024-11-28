import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'MenuItem.dart';
import 'OrderPlan.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_ordering.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_item TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        target_cost REAL NOT NULL,
        menu_items TEXT NOT NULL
      )
    ''');

    print('Database schema created successfully');
  }

  Future<void> insertInitialData() async {
    final db = await instance.database;

    // Check if the data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM food_items'),
    );

    if (count == 0) {
      print('Inserting initial data...');
    List<Map<String, dynamic>> initialData = [
      {"menu_item": "Pizza", "cost": 8.99},
      {"menu_item": "Burger", "cost": 5.49},
      {"menu_item": "Pasta", "cost": 7.99},
      {"menu_item": "Salad", "cost": 4.99},
      {"menu_item": "Fries", "cost": 2.99},
      {"menu_item": "Sushi", "cost": 10.99},
      {"menu_item": "Steak", "cost": 15.99},
      {"menu_item": "Tacos", "cost": 6.49},
      {"menu_item": "Ice Cream", "cost": 3.49},
      {"menu_item": "Coffee", "cost": 2.99},
      {"menu_item": "Smoothie", "cost": 4.49},
      {"menu_item": "Sandwich", "cost": 5.99},
      {"menu_item": "Wrap", "cost": 6.99},
      {"menu_item": "Soup", "cost": 4.99},
      {"menu_item": "Pizza Roll", "cost": 3.49},
      {"menu_item": "Nachos", "cost": 5.99},
      {"menu_item": "Hot Dog", "cost": 4.49},
      {"menu_item": "Waffle", "cost": 3.99},
      {"menu_item": "Brownie", "cost": 2.99},
      {"menu_item": "Muffin", "cost": 2.49},
    ];

    for (var item in initialData) {
      // Check if the item already exists in the database
      final List<Map<String, dynamic>> result = await db.query(
        'food_items',
        where: 'menu_item = ?',
        whereArgs: [item['menu_item']],
      );

      // Insert only if the item does not exist
      if (result.isEmpty) {
        print("inserting $item");
        await db.insert('food_items', item);
      }
      else {
        print("$item already in database");
      }
    }
    }
  }

  Future<void> initializeDB() async {
    await database; // Ensures the database is initialized
  }

  // 1. Add a new food item
  Future<void> addFoodItem(MenuItem item) async {
    final db = await instance.database;
    // Insert a new food item into the food_items table
    await db.insert('food_items', item.toMap());
  }

  // 2. Delete a food item by id
  Future<void> deleteFoodItem(int id) async {
    final db = await instance.database;
    // Delete the food item from the food_items table
    await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 3. Update an existing food item
  Future<void> updateFoodItem(MenuItem item) async {
    final db = await instance.database;
    // Update the food item in the food_items table
    await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // 4. Fetch all food items from the database
  Future<List<MenuItem>> fetchFoodItems() async {
    final db = await instance.database;
    final result = await db.query('food_items');
    return result.map((item) => MenuItem.fromMap(item)).toList();
  }

  // 5. Fetch a single food item by its ID
  Future<MenuItem?> fetchFoodItemById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return MenuItem.fromMap(result.first);
    }
    return null;
  }

  // Add an OrderPlan (already provided in previous response)
  Future<void> addOrderPlan(OrderPlan orderPlan) async {
    final db = await instance.database;

    // Insert the order plan into the 'order_plans' table
    await db.insert(
      'order_plans',
      orderPlan.toMap(),
    );
  }


  // Fetch OrderPlan by date (already provided in previous response)
  /*
  Future<OrderPlan?> fetchOrderPlanByDate(String date) async {

    final db = await instance.database;
    final orderPlanMapList = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (orderPlanMapList.isNotEmpty) {
      final orderPlanMap = orderPlanMapList.first;
      final orderPlanId = orderPlanMap['id'];

      final foodItems = await db.query(
        'food_items',
        where: 'id IN (SELECT food_item_id FROM order_plan_items WHERE order_plan_id = ?)',
        whereArgs: [orderPlanId],
      );

      List<MenuItem> menuItems = foodItems.map((map) => MenuItem.fromMap(map)).toList();

      return OrderPlan.fromMap(orderPlanMap, menuItems);
    }

    return null;
  }
  */
  // Fetch an OrderPlan by its date
  // Fetch an OrderPlan by its date
  Future<OrderPlan?> fetchOrderPlan(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isNotEmpty) {
      return OrderPlan.fromMap(result.first);
    } else {
      return null;
    }
  }



  Future<void> debugPrintDatabase() async {
    final db = await database;

    // Print all rows in the `food_items` table
    final foodItems = await db.query('food_items');
    print('Food Items: $foodItems');

    // Print all rows in the `order_plans` table (if you have this table)
    final orderPlans = await db.query('order_plans');
    print('Order Plans: $orderPlans');
  }


}
