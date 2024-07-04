import 'package:appcombustible/connectivity/connectivity_icon.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'admin_page.dart';
import 'home_page.dart';

class LoginPageSecondary extends StatefulWidget {
  const LoginPageSecondary({super.key});

  @override
  State<LoginPageSecondary> createState() => _LoginPageSecondaryState();
}

class _LoginPageSecondaryState extends State<LoginPageSecondary> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String? _loggedInUsername;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String identifier = _identifierController.text;
      String password = _passwordController.text;

      // Limpia el RUT si contiene un guion
      if (identifier.contains('-')) {
        identifier = identifier.split('-')[0];
      }

      var user = await _dbHelper.getUser(identifier, password);
      if (user != null) {
        setState(() {
          _loggedInUsername = identifier == '12930995' ? 'root' : identifier;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre de usuario, RUT o contraseña incorrectos')),
        );
      }
    }
  }

  Future<void> _updateData() async {
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
        SnackBar(content: Text('Error al actualizar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_loggedInUsername == 'root')
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Text('Administrar base de datos'),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _identifierController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario o RUT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu nombre de usuario o RUT';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
