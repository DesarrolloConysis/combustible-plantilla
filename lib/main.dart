import 'package:appcombustible/connectivity/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
// import 'screens/home_page.dart';
import 'adaptador/qr_scanner_page.dart';
import 'screens/login_page_secondary.dart'; // Asegúrate de que este archivo exista

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConnectivityProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Control Combustible',
        theme: ThemeData(
          primaryColor: const Color(0xFF3B4AA2),
          appBarTheme: const AppBarTheme(
            color: Color(0xFF3B4AA2),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), 
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B4AA2)),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Combustible'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'logout':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPageSecondary()),
                  );
                  break;
                case 'scan':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRScannerPage()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
              const PopupMenuItem<String>(
                value: 'scan',
                child: Text('Escanear licencia'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text('Bienvenido, ${user['nombre']}!'),
      ),
    );
  }
}
