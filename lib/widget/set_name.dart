import 'package:flutter/material.dart';

class SetName extends StatefulWidget {
  @override
  SetNameState createState() => SetNameState();
}

class SetNameState extends State<SetName> {
  String results = "";

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                hintText: "Введите имя устройства..."),
            autofocus: false,
            onSubmitted: (String str) {
              setState(() {});
            },
            controller: controller,
          ),
          Text(results)
        ],
      ),
    );
  }
}