import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';

import 'chat_screen.dart';
import '../constants.dart';
import '../components/general_button.dart';
import '../components/custom_toast.dart';
import '../components/input_data.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  bool spinnerProgress = false;
  final toast = FToast();
  TextEditingController _email;
  TextEditingController _password;

  @override
  void initState() {
    super.initState();
    toast.init(context);
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: ModalProgressHUD(
        inAsyncCall: spinnerProgress,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 100),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: const Icon(
                    EvaIcons.messageCircleOutline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24.0),
                InputData(
                  controller: _email,
                  hint: 'Write your email...',
                  icono: Icons.email,
                  tipoInput: TextInputType.emailAddress,
                  oscuro: false,
                ),
                const SizedBox(height: 15),
                InputData(
                  controller: _password,
                  hint: 'Write your password',
                  icono: Icons.lock,
                  tipoInput: TextInputType.visiblePassword,
                  oscuro: true,
                ),
                const SizedBox(height: 32.0),
                GeneralButton(
                  text: 'Login',
                  decoration: kDecorationGreen,
                  color: Colors.lightBlueAccent,
                  function: () async {
                    setState(() => spinnerProgress = true);
                    try {
                      email = _email.text;
                      password = _password.text;
                      if (email == '' || password == '') {
                        showBottomToast(' Please fill all fields', 2);
                        setState(() => spinnerProgress = false);
                        return false;
                      }
                      final bool isValidEmail = EmailValidator.validate(email);
                      if (!isValidEmail) {
                        showBottomToast(' Please enter a correct email', 2);
                        setState(() => spinnerProgress = false);
                        return false;
                      }
                      try {
                        final existinUser =
                            await _auth.signInWithEmailAndPassword(
                                email: email, password: password);
                        if (existinUser != null) {
                          _email.clear();
                          _password.clear();
                          Navigator.pushNamed(context, ChatScreen.id);
                        } else {
                          showBottomToast(
                              ' Error with your info\n User not found', 2);
                        }
                      } on FirebaseAuthException catch (e) {
                        showBottomToast(
                            ' Error with your info\n User not found', 2);
                        setState(() => spinnerProgress = false);
                        print(e);
                      }
                      setState(() => spinnerProgress = false);
                    } on FormatException catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomToast(String message, int value) => toast.showToast(
      child: buildToast(message: message, value: value),
      gravity: ToastGravity.BOTTOM);
}
