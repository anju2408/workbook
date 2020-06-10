import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final String labelText;
  final String errorText;
  final bool validate;
  final TextEditingController controller;

  const PasswordInput(
      {Key key, this.labelText, this.errorText, this.validate, this.controller})
      : super(key: key);
  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          controller: widget.controller,
          style: TextStyle(
            color: Colors.white,
          ),
          obscureText: !isVisible,
          decoration: InputDecoration(
            errorText: widget.validate ? widget.errorText : null,
            suffixIcon: IconButton(
                color: Colors.white,
                icon: isVisible
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                }),
            border: InputBorder.none,
            labelText: widget.labelText,
            labelStyle: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
