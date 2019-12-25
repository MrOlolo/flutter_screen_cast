import 'package:flutter/material.dart';
import 'package:flutter_screen_cast/service/storage_service.dart';
import 'package:flutter_screen_cast/widget/ip_tile.dart';
import 'package:flutter_screen_cast/widget/loading_container.dart';
import 'package:flutter_screen_cast/widget/resolution_tile.dart';
import 'package:string_validator/string_validator.dart';

const String defaultIp = '10.0.0.1';
const String defaultRes = '720';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

// SingleTickerProviderStateMixin is used for animation
class SettingsState extends State<Settings> {
  final List<String> resolutionsList = ['1080', '720', '480'];

  TextEditingController controller;
  final validateFormKey = GlobalKey<FormState>();
  String currentRes;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadData().whenComplete(() => setState(() => isLoading = false));
    controller = TextEditingController(text: defaultIp);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: LoadingContainer())
        : GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: Form(
            key: validateFormKey,
            child: ListView(padding: EdgeInsets.all(8), children: <Widget>[
              Container(
                color: Colors.white,
                child: IpTile(
                  controller: controller,
                  defaultIp: defaultIp,
                  validator: (s) {
                    print('hello');
                    if (isIP(s, 4)) {
                      return null;
                    } else {
                      return 'invalid IP';
                    }
                  },
                ),
              ),
              Container(
                height: 20,
              ),
              Container(
                  color: Colors.white,
                  child: ResolutionTile(
                    resolution: resolutionsList,
                    defaultResolution: currentRes,
                    changed: onResolutionChanged,
                  )),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: saveSettings,
            child: Icon(Icons.check),
          ),
        ));
  }

  Future loadData() async {
    var ip = await StorageService.getIp() ?? defaultIp;
    controller = TextEditingController(text: ip);
    currentRes = await StorageService.getResolution() ?? defaultRes;
  }

  onResolutionChanged(String res) {
    currentRes = res;
  }

  void saveSettings() async {
    if (validateFormKey.currentState.validate()) {
      await StorageService.setIp(controller.text.trim());
      await StorageService.setResolution(currentRes);
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
    }
  }
}
