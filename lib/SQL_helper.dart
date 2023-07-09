import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  // Creating the tables
  static Future<void> createTables(sql.Database database) async {
    await database.execute(""" CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price FLOAT
    )""");
  }

// Creating the database
  static Future<sql.Database> db() async {
    return sql.openDatabase('revenuemanager1.db', version: 1,
        onCreate: (sql.Database database, int verison) async {
      await createTables(database);
      debugPrint('Database successfully created !');
    });
  }

/////////////////////////// CRUD Operations //////////////////////////

// Post
  static Future<int> createItem(String name, double price) async {
    final db = await SQLHelper.db();
    final entry = {'name': name, 'price': price};

    final id = db.insert('items', entry,
        //Preventing duplicate entry
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

// Get ALL
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id');
  }

// Get single item
  static Future<List<Map<String, dynamic>>> getOneItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: 'id = ?', whereArgs: [id]);
  }

// Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('$err');
    }
  }

// Update
  static Future<int> updateItem(int id, String name, double price) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'price': price};
    final res = db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return res;
  }
}
