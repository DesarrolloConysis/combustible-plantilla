import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  ConnectivityProvider() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Asumimos que queremos la primera conexión en la lista
      if (result.isNotEmpty) {
        _connectionStatus = result.first;
      } else {
        _connectionStatus = ConnectivityResult.none;
      }
      notifyListeners();
    });
    _initialize();
  }

  void _initialize() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.isNotEmpty) {
      _connectionStatus = results.first;
    } else {
      _connectionStatus = ConnectivityResult.none;
    }
    notifyListeners();
  }

  ConnectivityResult get connectionStatus => _connectionStatus;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
