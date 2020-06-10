import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';

MaterialButton registerButton(
    {String role, Widget page, BuildContext context}) {
  return MaterialButton(
      padding: EdgeInsets.all(16),
      minWidth: 250,
      color: Colors.white,
      child: Text(
        role,
        style:
            TextStyle(fontWeight: FontWeight.bold, color: teal2, fontSize: 18),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageTransition(child: page, type: PageTransitionType.rightToLeft),
        );
      });
}
