import 'package:flutter/material.dart';
import 'pages/My_Plants_Page.dart';

void main() => runApp(const MyApp());

//to compile on to the phone, run:
// flutter run --release

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
      ),
      home:
          HomePage(refreshPlantList: () {  },), //i guess we change this function to have different bodies?
    );
  }
}
