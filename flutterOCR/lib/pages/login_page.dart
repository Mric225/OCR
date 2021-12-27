import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login_ui/common/theme_helper.dart';
import 'profile_page.dart';
import 'widgets/header_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _headerHeight = 250;
  // Key _formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  bool _scanning = false;

// Controlleur permettant de récuperer les valeurs des champs saisis

  TextEditingController _email = TextEditingController();
  TextEditingController _motdepasse = TextEditingController();

// -----------------------------------------------------------------------------
// Fonction API de login
  void login() async {
    final url = Uri.parse("https://geeksp3.com/pene/ocr/login.php");

    final response = await http.post(url, body: {
      "email": _email.text,
      "motdepasse": _motdepasse.text,
    });

    var data = json.decode(response.body);
    if (data == "Success") {
      // Enregistrement de la session avec l'email
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString(
        '_email',
        _email.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true,
                  Icons.login_rounded), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.fromLTRB(
                      20, 10, 20, 10), // This will be the login form
                  child: Column(
                    children: [
                      Text(
                        'Hello',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Connectez-vous à votre session',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextFormField(
                                  controller: _email,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Adresse email',
                                      'Entrez votre adresse email'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir votre adresse email';
                                    }
                                    return null;
                                  },
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 30.0),
                              Container(
                                child: TextFormField(
                                  controller: _motdepasse,
                                  obscureText: true,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Mot de passe',
                                      'Entrez votre mot de passe'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir votre mot de passe';
                                    }
                                    return null;
                                  },
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 25.0),
                              _scanning
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blueGrey),
                                    ))
                                  : Icon(
                                      Icons.done,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                              SizedBox(height: 10.0),
                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text(
                                      'se connecter'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _scanning = true;
                                      });
                                      login();
                                    }
                                  },
                                ),
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
