import 'package:flutter/material.dart';
import 'package:flutter_screen_cast/widget/set_fps.dart';
import 'package:flutter_screen_cast/widget/set_name.dart';
import 'package:flutter_screen_cast/widget/set_qual.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

// SingleTickerProviderStateMixin is used for animation
class SettingsState extends State<Settings>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
          padding: EdgeInsets.all(8),
          children: <Widget>[
            Container(
              height: 72,
              color: Colors.white,
              child : SetName(),
            ),
            Container(
                height: 90,
                color: Colors.white,
                child : SetFps()),
            Container(
                height: 290,
                color: Colors.white,
                child : SetQual()),
          ]
      ),
    );
  }
}
