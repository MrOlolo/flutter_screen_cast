import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_screen_cast/page/translator.dart';
import 'package:flutter_screen_cast/service/storage_service.dart';
import 'package:flutter_screen_cast/widget/loading_container.dart';
import 'package:rxdart/rxdart.dart';

import 'settings.dart';

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome> {
  BehaviorSubject<bool> isAdminMode;
  BehaviorSubject<bool> isLoading;

  // Create a tab controller
  @override
  void initState() {
    super.initState();
    isLoading = BehaviorSubject<bool>();

    isAdminMode = BehaviorSubject<bool>();
  }

  @override
  void dispose() {
    isLoading?.close();
    isAdminMode?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          // Appbar
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Polytech Wireless VGA'),
                  decoration:
                      BoxDecoration(color: Theme.of(context).accentColor),
                ),
                StreamBuilder<bool>(
                    stream: isAdminMode.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Admin mode'),
                            Switch(
                                value: snapshot.data,
                                onChanged: (v) {
                                  changeAdminStatus();
                                })
                          ],
                        ),
                        onTap: () {
                          changeAdminStatus();
                          Navigator.pop(context);
                        },
                      );
                    }),
                ListTile(
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Settings()));
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            // Title
            title: Text("Polytech Wireless VGA"),
            // Set the background color of the App Bar
            backgroundColor: Colors.green,
          ),
          // Set the TabBar view as the body of the Scaffold
          body: TranslatorTab(adminModeIsOn: isAdminMode.stream,),
          // Set the bottom navigation bar
        ),
        StreamBuilder<bool>(
            stream: isLoading.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data)
                return Container(
                  child: Center(
                    child: LoadingContainer(),
                  ),
                  color: Colors.black26,
                );
              return Container();
            })
      ],
    );
  }

  void changeAdminStatus() {
    if (isAdminMode?.value ?? false) {
      logout();
    } else {
      var password = TextEditingController();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: Text('Введите пароль'),
              content: TextField(
                keyboardType: TextInputType.multiline,
                controller: password,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Отмена'),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                    child: Text('ОК'),
                    onPressed: () {
                      login(password.text.trim());
                      Navigator.pop(context);
                    }),
              ],
            );
          });
    }
  }

  login(String password) async {
    isLoading.add(true);
    //TODO request to server for admin
    var success = false;
    var msg = '';

    await Future.delayed(Duration(seconds: 3));
    success = true;
    msg = 'Неверный пароль';
    var token = '';
    isLoading.add(false);
    if (success) {
      //TODO when we get admin
      await StorageService.setToken(token);
      isAdminMode.add(true);
    } else {
      ///SHOW DIALOG IF ERROR
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Ошибка'),
                content: Text(msg),
                actions: <Widget>[
                  FlatButton(
                      child: Text('ОК'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ));
    }
  }

  void logout() async {
    isLoading.add(true);
    //TODO Logout
    var success = false;
    await Future.delayed(Duration(seconds: 3));
    success = true;
    isAdminMode.add(false);
    isLoading.add(false);
  }
}
