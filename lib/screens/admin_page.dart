import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _tables = [];
  Map<String, List<Map<String, dynamic>>> _data = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    var tables = await _dbHelper.getTables();
    setState(() {
      _tables = tables;
    });
  }

  Future<void> _fetchTableData(String tableName) async {
    var data = await _dbHelper.getTableData(tableName, searchQuery: _searchQuery);
    setState(() {
      _data[tableName] = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                // Update table data with search query
                for (var table in _tables) {
                  _fetchTableData(table);
                }
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: _tables.map((table) {
                var filteredData = _data[table] ?? [];

                return ExpansionTile(
                  title: Text('$table (${filteredData.length} registros)'),
                  children: [
                    ElevatedButton(
                      onPressed: () => _fetchTableData(table),
                      child: const Text('Cargar Datos'),
                    ),
                    if (_data.containsKey(table))
                      Column(
                        children: filteredData
                            .map((row) => ListTile(
                                  title: Text(row.toString()),
                                ))
                            .toList(),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
