import 'package:flutter/material.dart';

class ResolutionTile extends StatefulWidget {
  final List<String> resolution;
  final ValueChanged<String> changed;
  final String defaultResolution;

  const ResolutionTile(
      {Key key,
      @required this.resolution,
      @required this.changed,
      @required this.defaultResolution})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResolutionTileState();
  }
}

class ResolutionTileState extends State<ResolutionTile> {
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedResolution;

  @override
  void initState() {
    _dropDownMenuItems = buildAndGetDropDownMenuItems(widget?.resolution);
    _selectedResolution =
        widget?.defaultResolution ?? _dropDownMenuItems[0].value;
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
      _selectedResolution = selectedQual;
    });
    widget?.changed(selectedQual);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text("Resolution: "),
        DropdownButton(
          value: _selectedResolution,
          items: _dropDownMenuItems,
          onChanged: changedDropDownItem,
        )
      ],
    ));
  }
}
