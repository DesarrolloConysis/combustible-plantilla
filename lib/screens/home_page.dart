import 'package:appcombustible/connectivity/connectivity_icon.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'admin_page.dart';  // Asegúrate de importar AdminPage

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _updateData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No es posible actualizar la base de datos debido a que no contamos con conexión a Internet.')),
      );
      return;
    }

    try {
      await _dbHelper.updateUsersFromServer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No es posible actualizar la base de datos debido a que no contamos con conexión a Internet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.user['nom_usuario'] == 'root';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Combustible'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'update') {
                _updateData();
              } else if (result == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update',
                child: Text('Actualizar datos desde el servidor'),
              ),
              if (isAdmin)
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Text('Administrar Base de Datos'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConnectivityIcon(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Bienvenido, ${widget.user['nombre']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('Usuario: ${widget.user['nom_usuario']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('Estado: ${widget.user['estado'] == 0 ? 'Activo' : 'Inactivo'}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('RUT: ${widget.user['rut']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('Licencia: ${widget.user['licencia_numero']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
