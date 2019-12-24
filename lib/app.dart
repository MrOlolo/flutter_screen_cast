import 'package:flutter/material.dart';

import 'page/my_home.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WirelessVGA',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHome(),
    );
  }
}