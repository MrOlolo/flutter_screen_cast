import 'package:flutter/material.dart';

class SetFps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetFpsState();
  }
}

class SetFpsState extends State<SetFps> {
  List _fps = ["60", "30", "24"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedFPS;

  @override
  void initState() {
    _dropDownMenuItems = buildAndGetDropDownMenuItems(_fps);
    _selectedFPS = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List fps) {
    List<DropdownMenuItem<String>> items = List();
    for (String fps in fps) {
      items.add(DropdownMenuItem(value: fps, child: Text(fps)));
    }
    return items;
  }

  void changedDropDownItem(String selectedFPS) {
    setState(() {
      _selectedFPS = selectedFPS;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("Выберите частоту кадров: "),
            DropdownButton(
              value: _selectedFPS,
              items: _dropDownMenuItems,
              onChanged: changedDropDownItem,
            )
          ],
        ));
  }
}