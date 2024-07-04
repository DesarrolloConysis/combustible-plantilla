import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_provider.dart';

class ConnectivityIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var connectivityStatus = Provider.of<ConnectivityProvider>(context).connectionStatus;

    Color iconColor;
    if (connectivityStatus == ConnectivityResult.none) {
      iconColor = Colors.grey;
    } else {
      iconColor = Colors.green;
    }

    return Icon(
      Icons.wifi,
      color: iconColor,
    );
  }
}
