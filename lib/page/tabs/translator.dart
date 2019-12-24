import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslatorTab extends StatefulWidget {
  @override
  TranslatorTabState createState() {
    return TranslatorTabState();
  }
}

class TranslatorTabState extends State<TranslatorTab> {
  static const platform = const MethodChannel('ivt.black/stream_controller');
  bool isLoading = false;
  int currentDevice;
  bool streaming = false;
  int counter = 0;
  String status = '';
  List<String> buttonText = ['Stop videostream', 'Start videostream'];
  Color butColors = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(status,
            style: TextStyle(fontSize: 20.0, color: Colors.black38),
            textAlign: TextAlign.center),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: startStream,
        label: Text(buttonText[streaming ? 0 : 1]),
        icon: Icon(
            streaming ? Icons.pause_circle_filled : Icons.play_circle_outline),
        backgroundColor: streaming ? Colors.red : Theme.of(context).accentColor,
      ),
    );
  }

  Future startStream() async {
    setState(() {
      isLoading = true;
    });
    if (!streaming) {
      try {
        print('START RECORDING');
        var ip = '10.0.0.1';
        final String result = await platform.invokeMethod('start', {'ip': ip});
        print('RESULT:' + result);
        setState(() {
          streaming = !streaming;
        });
      } on PlatformException catch (e) {
        print("Failed to send event: '${e.message}'.");
      } catch (e) {
        print(e);
      }
    } else {
      try {
        print('STOP RECORDING');
        final String result = await platform.invokeMethod('stop', {'g': 'g'});
        print('RESULT:' + result);
        setState(() {
          streaming = !streaming;
        });
      } on PlatformException catch (e) {
        print("Failed RESULT: '${e.message}'.");
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
