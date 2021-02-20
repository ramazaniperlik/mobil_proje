import 'package:flutter/material.dart';
import 'package:textonimage/caps_olustur_page.dart';

void main() => runApp(CapsOlusturApp());

class CapsOlusturApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CapsYap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CapsOlusturPage(),
    );
  }
}
