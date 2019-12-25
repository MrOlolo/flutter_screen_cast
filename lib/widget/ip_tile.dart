import 'package:flutter/material.dart';

class IpTile extends StatelessWidget {

  final TextEditingController controller;
  final String defaultIp;
  final Function(String text) validator;
  const IpTile({Key key, this.controller, this.defaultIp, this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('IP'),
          TextFormField(
            validator: validator,
            decoration: InputDecoration(
                hintText: "10.0.0.1"),
            autofocus: false,
            controller: controller,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}