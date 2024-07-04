import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String baseURL = 'https://www.toro-sa.cl/Intranet/web_service/';

String getFullURL(String endpoint) {
  return baseURL + endpoint;
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'combustible.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_usuario TEXT NOT NULL,
        password TEXT NOT NULL,
        estado INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        rut TEXT NOT NULL,
        licencia_numero TEXT NOT NULL
      )
    ''');
    // Insertar el usuario root
    await db.insert('usuarios', {
      'nom_usuario': 'root',
      'password': '1809',
      'estado': 0, // Activo
      'nombre': 'Administrador',
      'rut': '12930995-4',
      'licencia_numero': '18927663'
    });
  }

  Future<void> updateUsersFromServer() async {
    try {
      var response = await http.get(Uri.parse(getFullURL('ws_Tabla_Usuario.php')));
      if (response.statusCode == 200) {
        var datos = json.decode(response.body);
        Database db = await database;
        await db.delete('usuarios', where: 'nom_usuario != ?', whereArgs: ['root']); // Eliminar todos menos el usuario root
        for (var usuario in datos) {
          await db.insert('usuarios', {
            'nom_usuario': usuario['nom_usuario'],
            'password': usuario['password'],
            'estado': usuario['estado'],
            'nombre': usuario['nombre'],
            'rut': usuario['rut'],
            'licencia_numero': usuario['licencia_numero']
          });
        }
      } else {
        throw Exception('Error al actualizar datos: ${response.statusCode}');
      }
    } catch (e) {
      String errorMessage = 'Error al actualizar datos. Por favor, verifica tu conexión a Internet e inténtalo de nuevo.';
      if (e is SocketException) {
        errorMessage = 'Error de conexión. Verifica tu conexión a Internet.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>?> getUser(String identifier, String password) async {
    Database db = await database;
    String cleanRut = identifier.contains('-') ? identifier.split('-')[0] : identifier;

    List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: '(nom_usuario = ? OR rut LIKE ? || \'%\') AND password = ?',
      whereArgs: [identifier, cleanRut, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByLicense(String licenseNumber) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: 'licencia_numero = ?',
      whereArgs: [licenseNumber],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<String>> getTables() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    List<String> tables = result.map((row) => row['name'] as String).toList();
    return tables;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName, {String? searchQuery}) async {
    Database db = await database;
    List<Map<String, dynamic>> result;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = await db.query(
        tableName,
        where: await _generateLikeClause(tableName),
        whereArgs: List.filled(await _getColumnCount(db, tableName), '%$searchQuery%'),
      );
    } else {
      result = await db.query(tableName);
    }

    return result;
  }

  Future<String> _generateLikeClause(String tableName) async {
    // This function generates a LIKE clause for all columns of the table
    // Modify this function based on your table structure
    // Example: "column1 LIKE ? OR column2 LIKE ? OR column3 LIKE ?"
    // Ensure it fits your specific table structure
    return (await _getColumnNames(tableName)).map((column) => "$column LIKE ?").join(" OR ");
  }

  Future<int> _getColumnCount(Database db, String tableName) async {
    // Get the number of columns in the table
    List<Map<String, dynamic>> result = await db.rawQuery("PRAGMA table_info($tableName)");
    return result.length;
  }

  Future<List<String>> _getColumnNames(String tableName) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery("PRAGMA table_info($tableName)");
    List<String> columns = result.map((row) => row['name'] as String).toList();
    return columns;
  }
}
