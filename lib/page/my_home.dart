import 'package:flutter/material.dart';

import 'tabs/settings.dart';
import 'tabs/translator.dart';

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = TabController(length: 2, vsync: this); // length: 3 - если будет нужна админка отдельным модулем
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text("Polytech Wireless VGA"),
        // Set the background color of the App Bar
        backgroundColor: Colors.green,
      ),
      // Set the TabBar view as the body of the Scaffold
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[TranslatorTab(), Settings()], //, ThirdTab()
        // set the controller
        controller: controller,
      ),
      // Set the bottom navigation bar
      bottomNavigationBar: TabBar(
        tabs: <Tab>[
          Tab( // возможная вкладка для панели администраторая
            icon: Icon(Icons.cast),
          ),
          Tab(
            icon: Icon(Icons.build),
          ),
//            Tab( // Оставляю на случай если понадобится админка отдельной страницей
//              icon: Icon(Icons.add),
//            ),
        ],
        // setup the controller
        controller: controller,
      ),
    );
  }
}