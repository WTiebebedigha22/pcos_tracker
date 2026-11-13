import 'package:flutter/material.dart';

/// TODO: notifications, theme, units, privacy, export, delete account, support.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(children: const [
      ListTile(leading: Icon(Icons.download), title: Text('Export my data')),
      ListTile(leading: Icon(Icons.delete_forever), title: Text('Delete account')),
    ]),
  );
}
