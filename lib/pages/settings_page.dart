import 'package:flutter/material.dart';
import 'package:plant_tracker/plant_db.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback refreshPlantList;

  const SettingsPage({Key? key, required this.refreshPlantList})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  // ignore: non_constant_identifier_names
  final _plant_db = plant_db();
   bool _isDarkMode = false; 

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Wrap Scaffold with MaterialApp
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Add this line
      debugShowCheckedModeBanner: false, // Add this line
      home: Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: const Color.fromARGB(255, 156, 232, 94),
          centerTitle: true,
          titleTextStyle: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0), fontSize: 22)),
      body: settingsBody(),
      ),
    );
  }

  Widget settingsBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          removePlant(),
          buildSettingsTile(
            icon: Icons.import_export,
            label: "Import",
            onPressed: () {},
          ),
          buildSettingsTile(
            icon: Icons.import_export,
            label: "Export",
            onPressed: () {},
          ),
        ],
      ),
    );
  }


  Widget removePlant() {
    return buildSettingsTile(
      icon: Icons.mood_bad_outlined,
      label: "Remove all plants",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Remove all plants?"),
              content: const Text("Are you sure you want to remove all plants?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Remove"),
                  onPressed: () {
                    _plant_db.removeAllPlants();
                    Navigator.of(context).pop();
                    widget.refreshPlantList();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All plants removed'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget buildSettingsTile({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey[200],
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  }
