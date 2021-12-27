import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_login_ui/pages/login_page.dart';
import 'package:flutter_login_ui/pages/profile_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';




 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var _email = preferences.getString('_email');
  Color _primaryColor = HexColor('#34495e');
  Color _accentColor = HexColor('#0080ff');
  runApp(MaterialApp(

    // Vérification de la session sauv 
      home: _email == null ? LoginPage() : ProfilePage(),
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Colors.grey.shade100, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: _accentColor),
    
      ),
      
    ));
}