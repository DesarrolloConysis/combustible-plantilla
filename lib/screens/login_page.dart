import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_helper.dart';
import '../connectivity/connectivity_icon.dart';
import 'login_page_secondary.dart';
import '../adaptador/qr_scanner_page.dart'; // Actualiza la ruta aquí

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _scanBarcode() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El permiso de la cámara es necesario para escanear')),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );
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
              } else if (result == 'secondary_login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPageSecondary()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update',
                child: Text('Actualizar datos desde el servidor'),
              ),
              const PopupMenuItem<String>(
                value: 'secondary_login',
                child: Text('Iniciar sesión manualmente'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConnectivityIcon(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scanBarcode,
          child: const Text('Escanear licencia de conducir'),
        ),
      ),
    );
  }
}
