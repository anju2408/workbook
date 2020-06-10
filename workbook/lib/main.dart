import 'package:flutter/material.dart';
import 'package:workbook/screens/landing_page.dart';
import 'package:workbook/screens/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: LoginPage(),
    );
  }
}
