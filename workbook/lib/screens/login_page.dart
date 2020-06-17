import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/home_screen.dart';
import 'dart:convert';
import 'package:workbook/widget/first.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/textLogin.dart';
import 'package:workbook/widget/verticalText.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole;
  User user = User();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;
  bool _loading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);

      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '91512',
      'Workbook',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  void initState() {
    getFCMToken();

    super.initState();
    registerNotification();
    configLocalNotification();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void getFCMToken() async {
    fcmToken = await _firebaseMessaging.getToken();
    setState(() {
      User.userFcmToken = fcmToken;
    });
    print('fcm');
    print(fcmToken);
  }

  Future loginUser() async {
    var response =
        await http.post('https://app-workbook.herokuapp.com/login', body: {
      "userID": _emailController.text,
      "password": _passwordController.text,
      "fcmToken": fcmToken
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {
      _loading = false;
    });
    var resp = json.decode(response.body)['payload'];
    if (resp['approved'] == true) {
      var tempo = resp['user'];
      List<int> _imageData = (tempo['instituteImage']['data']).cast<int>();
      print(_imageData.runtimeType);
      setState(() {
//        User.userPhotoData = base64Encode(_imageData);
        User.userName = tempo['userName'] ?? null;
        User.userID = tempo['_id'] ?? null;
        User.userRole = tempo['role'] ?? null;
        User.userEmail = tempo['userID'] ?? null;
        User.instituteName = tempo['instituteName'] ?? null;
        User.instituteImage = tempo['instituteImage'] ?? null;
        User.userInstituteType = tempo['instituteType'] ?? null;
        User.numberOfMembers = tempo['numberOfMembers'] ?? null;
        User.state = tempo['state'] ?? null;
        User.city = tempo['city'] ?? null;
        User.mailAddress = tempo['mailAddress'] ?? null;
        User.aadharNumber = tempo['adharNumber'] ?? null;
        User.grade = tempo['grade'] ?? null;
        User.division = tempo['division'] ?? null;
        User.contactNumber = tempo['contactNumber'] ?? null;
      });
      Navigator.push(
        context,
        PageTransition(
            child: HomeScreen(), type: PageTransitionType.rightToLeft),
      );
    } else {
      popDialog(
        onPress: () {
          Navigator.pop(context);
        },
        context: context,
        title: 'Request Pending',
        content: 'Please wait while the request is approved',
        buttonTitle: 'Close',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(teal2),
          backgroundColor: Colors.transparent,
        ),
        opacity: 0.5,
        color: Colors.white,
        dismissible: false,
        inAsyncCall: _loading,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [teal1, teal2]),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(children: <Widget>[
                    VerticalText(),
                    TextLogin(),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InputField(
                      validation: (String arg) {
                        if (arg.isEmpty) {
                          return 'This can not be empty';
                        } else
                          return null;
                      },
                      captial: TextCapitalization.none,
                      errorText: 'Please enter a valid email ID',
                      controller: _emailController,
                      labelText: 'Email',
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: PasswordInput(
                      errorText: 'This field can\'t be empty',
                      controller: _passwordController,
                      validation: (String arg) {},
                      labelText: 'Password',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: GestureDetector(
                      onTap: () {
                        print('working');
                      },
                      child: Text(
                        'Trouble logging in? Click here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40, right: 20, left: 250),
                    child: Container(
                      alignment: Alignment.bottomRight,
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: FlatButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            print('working');
                            await loginUser();
                          }
//                        setState(() {
//                          (_emailController.text.isEmpty ||
//                                  !validator.email(_emailController.text))
//                              ? _validateEmail = true
//                              : _validateEmail = false;
//                          _passwordController.text.isEmpty
//                              ? _validatePassword = true
//                              : _validatePassword = false;
//                        });
//
//                        if (!_validatePassword && !_validateEmail) {
//                          setState(() {
//                            _loading = true;
//                          });
//                          await loginUser();
//                          _passwordController.clear();
//                          _emailController.clear();
//                          _selectedRole = null;
//                        }
                        },
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FirstTime(),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
