import 'package:flutter/material.dart';

class SetQual extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetQualState();
  }
}

class SetQualState extends State<SetQual> {
  List _qual = ["1080", "720", "480", "360", "240"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedQual;

  @override
  void initState() {
    _dropDownMenuItems = buildAndGetDropDownMenuItems(_qual);
    _selectedQual = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List qual) {
    List<DropdownMenuItem<String>> items = List();
    for (String qual in qual) {
      items.add(DropdownMenuItem(value: qual, child: Text(qual)));
    }
    return items;
  }

  void changedDropDownItem(String selectedQual) {
    setState(() {
      _selectedQual = selectedQual;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("Выберите качество: "),
            DropdownButton(
              value: _selectedQual,
              items: _dropDownMenuItems,
              onChanged: changedDropDownItem,
            )
          ],
        ));
  }
}