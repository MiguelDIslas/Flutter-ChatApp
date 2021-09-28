import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool spinner = false;
  String email = "";
  String password = "";
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
        inAsyncCall: spinner,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100),
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  text: 'Register',
                  color: Colors.blueAccent,
                  decoration: kDecorationBlue,
                  function: () async {
                    try {
                      email = _email.text;
                      password = _password.text;
                      setState(() => spinner = true);
                      final bool isValidEmail = EmailValidator.validate(email);
                      if (!isValidEmail) {
                        showBottomToast(' Please enter a correct email', 2);
                        setState(() => spinner = false);
                        return false;
                      }
                      if (password.length < 6) {
                        showBottomToast(' Password needs more than 6 chars', 2);
                        setState(() => spinner = false);
                        return false;
                      }
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          _email.clear();
                          _password.clear();
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case "invalid-email":
                            showBottomToast(' Invalid email', 2);
                            setState(() => spinner = false);
                            break;
                          case "email-already-in-use":
                            showBottomToast(' Email already in use', 2);
                            setState(() => spinner = false);
                            break;
                        }
                      }
                      setState(() => spinner = false);
                    } on FirebaseAuthException catch (e) {
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
