import 'package:flutter/material.dart';
//import 'package:note_pad/screens/note_list.dart';
import 'package:note_pad/screens/note_detail.dart';
import 'package:note_pad/screens/note_list.dart';

void main() {
  runApp(MyApplication());
}

class MyApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NotePad",
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
         primarySwatch: Colors.amber,
       ),
      home: NoteList(),
    );
  }
}


