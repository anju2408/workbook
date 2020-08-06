import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/otp_verification.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:http/http.dart' as http;

class DriverForm extends StatefulWidget {
  @override
  _DriverFormState createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  bool _isLoading = false;
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateRePassword = false;
  bool _validateInstitution = false;
  bool _validateCar = false;

  bool _validateAadhar = false;
  bool _validatePhoneNumber = false;
  String _selectedInstitution;
  String _selectedCar;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();

  Future _sendEmailVerification(String email) async {
    var response = await http.get('$baseUrl/sendVerification/$email');
    print(response.body);

    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Email sent', gravity: ToastGravity.CENTER);
      Navigator.push(
        context,
        PageTransition(
            child: OTPVerification(
              carNumber: _selectedCar,
              role: 'driver',
              name: _nameController.text,
              password: _passwordController.text,
              instituteName: _selectedInstitution,
              fcm: User.userFcmToken,
              aadhar: _aadharController.text.toString(),
              phone: _phoneController.text.toString(),
              otp: json.decode(response.body)['payload']['token'].toString(),
              isEmailVerify: true,
              email: _emailController.text,
            ),
            type: PageTransitionType.fade),
      );
    } else if (json.decode(response.body)['statusCode'] == 400) {
      popDialog(
          title: 'Error',
          content: 'There was some error,please try again!',
          buttonTitle: 'Okay',
          onPress: () {
            Navigator.pop(context);
          },
          context: context);
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      setState(() {});
    });
    print(User.userFcmToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _isLoading,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2]),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  'Driver Registration',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: InputField(
                    validate: _validateName,
                    errorText: 'This field can\'t be empty',
                    controller: _nameController,
                    labelText: 'Name',
                  ),
                ),
                InputField(
                  validate: _validateEmail,
                  capital: TextCapitalization.none,
                  controller: _emailController,
                  errorText: 'Please enter a valid email ID',
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                PasswordInput(
                  validate: _validatePassword,
                  controller: _passwordController,
                  labelText: 'Password',
                  errorText: 'Min Length = 8 and Max length = 15,\nShould have atleast 1 number, 1 capital letter\nand 1 Special Character',
                ),
                PasswordInput(
                  validate: _validateRePassword,
                  controller: _passwordReController,
                  labelText: 'Re-enter Password',
                  errorText: 'Passwords don\'t match',
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: violet1),
                    child: DropdownButtonFormField(
                      onTap: () {
                        setState(() {
                          _validateInstitution = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateInstitution ? 'Please choose an option' : null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconDisabledColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      iconSize: 24,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                      hint: Text(
                        'Select Institution',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedInstitution,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedInstitution = newValue;
                        });
                      },
                      items: institutes.map((type) {
                        return DropdownMenuItem(
                          child: Text(type),
                          value: type,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: violet1),
                    child: DropdownButtonFormField(
                      onTap: () {
                        setState(() {
                          _validateCar = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateCar ? 'Please choose an option' : null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconDisabledColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      iconSize: 24,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                      hint: Text(
                        'Select Car Number',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedCar,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCar = newValue;
                        });
                      },
                      items: carNumber.map((type) {
                        return DropdownMenuItem(
                          child: Text(type),
                          value: type,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                InputField(
                  validate: _validateAadhar,
                  controller: _aadharController,
                  errorText: 'Please enter you 12 digit Aadhar Card number',
                  textInputType: TextInputType.number,
                  labelText: 'Aadhar Card Number',
                ),
                InputField(
                  validate: _validatePhoneNumber,
                  errorText: 'Please enter a valid 10 digit mobile number',
                  controller: _phoneController,
                  textInputType: TextInputType.phone,
                  labelText: 'Contact Number',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 64),
                  child: Builder(
                    builder: (context) => registerButton(
                      role: 'Submit',
                      context: context,
                      onPressed: () async {
                        setState(() {
                          _nameController.text.isEmpty ? _validateName = true : _validateName = false;
                          (_emailController.text.isEmpty || !validator.email(_emailController.text)) ? _validateEmail = true : _validateEmail = false;
                          (_passwordController.text.isEmpty || !validator.password(_passwordController.text)) ? _validatePassword = true : _validatePassword = false;
                          (_passwordReController.text.isEmpty || !validator.password(_passwordController.text)) ? _validateRePassword = true : _validateRePassword = false;

                          (_aadharController.text.isEmpty || _aadharController.text.length != 12) ? _validateAadhar = true : _validateAadhar = false;
                          (_phoneController.text.isEmpty || _phoneController.text.length != 10) ? _validatePhoneNumber = true : _validatePhoneNumber = false;

                          if (_selectedCar == null) {
                            _validateCar = true;
                          }
                          if (_selectedInstitution == null) {
                            _validateInstitution = true;
                          }
                          if (_passwordController.text != _passwordReController.text) {
                            _validateRePassword = true;
                          }
                        });
                        if (!_validateName &&
                            !_validateEmail &&
                            !_validatePhoneNumber &&
                            !_validateCar &&
                            !_validateInstitution &&
                            !_validateAadhar &&
                            !_validatePassword &&
                            !_validateRePassword) {
                          setState(() {
                            _isLoading = true;
                          });
                          await _sendEmailVerification(_emailController.text.toString());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
