import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_login_ui/pages/profile_page.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newocr extends StatefulWidget {
  final String? image;
  const Newocr({key, this.image}) : super(key: key);

  String get imagePath => image.toString();

  @override
  _NewocrState createState() => _NewocrState();
}

class _NewocrState extends State<Newocr> {
  // déclaration des variables
  String textOcr = "";
  String imagePath = "";
  String _email = "";


// --------------------------------------------------------------------------------------------
  // fonction de récupération session sauv
  Future getEmail()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
     setState(() {
       _email = preferences.getString('_email')!;
     });
  }


  // -----------------------------------------------------------------------

  final _formKey = GlobalKey<FormState>();
  TextEditingController _id = TextEditingController();

// widget du champ de saisi du titre
  Widget _buildnom() {
    return new TextFormField(
      controller: _id,
      decoration: new InputDecoration(
        labelText: ' Veuillez saisir un titre',
        // border: new OutlineInputBorder(),
      ),
      maxLength: 50,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '  Veuillez saisir un titre';
        }
        return null;
      },
    );
  }

// -----------------------------------------------------------------------------
// fonction de récupération du texte scanné
  Future getData() async {
    var url = 'http://192.168.0.100/image2text/out.php';
    http.Response response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    // print(data);
    textOcr = data.toString();
  }

// -----------------------------------------------------------------------------
// fonction de sauvegarde des différentes informations
  Future enreg() async {
    final url = Uri.parse("https://geeksp3.com/pene/ocr/save.php");

    var request = http.MultipartRequest('POST', url);

    request.fields['titre'] = _id.text;
    request.fields['textOcr'] = textOcr;
    request.fields['datecreation'] = DateTime.now().toString();
    request.fields['email'] = _email;

    String? imgPath = widget.image;

    var pic = await http.MultipartFile.fromPath("image", imgPath!);
    request.files.add(pic);
    var response = await request.send();

    if (response.statusCode == 200) {
      print("Enregistré !");
    } else {
      print("Non enregistré");
    }
  }

  // ---------------------------------------------------------------------------
  // toast de confirmation d'enregistrement
  void showsave() => Fluttertoast.showToast(
        msg: 'Enregistré !',
        gravity: ToastGravity.BOTTOM,
        fontSize: 12.0,
        backgroundColor: Colors.grey[700],
        toastLength: Toast.LENGTH_SHORT,
      );

  // ---------------------------------------------------------------------------
// initialisation des fonction de récupération des informations de session et login
  @override
  void initState() {
    super.initState();
    setState(() {
      getData();
      getEmail();
    });
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.grey[350],
        appBar: AppBar(
          backgroundColor: const Color(0xFF34495E),
          title: Text('Aperçu numérisé'),
          
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    _buildnom(),
                    Container(
                      width: 400,
                      height: 180,
                      margin: EdgeInsets.all(1),
                      padding: EdgeInsets.all(5),
                      child: Image.file(File(widget.imagePath)),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 3,
                          )),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: width * 0.98,
                      height: height * 0.33,
                      margin: EdgeInsets.all(1),
                      padding: EdgeInsets.all(2),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(textOcr),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 3,
                          )),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blueGrey),
                          ),
                          child: Text(
                            'Afficher le texte',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            setState(() {
                              getData();
                            });
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.green),
                          ),
                          child: Text(
                            'Enreg.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                             
                              enreg();
                              
                                showDialog(context: context, builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text("Enregistré !", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green,)),
                                  // content: Text("Enregistré !"),
                                  actions: <Widget>[
            
                              new TextButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                   builder: (BuildContext context) =>
                                    ProfilePage(),
                              ),
                              (route) => false,
                            );
                                },
                              ),
                            ],
                                );
                                });
                              // showsave();
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProfilePage(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                        // Center(child: _email == '' ? Text('') : Text(_email)),
                      ],
                      alignment: MainAxisAlignment.center,
                    ),
                    // Center(child: _email == '' ? Text('') : Text(_email)),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
