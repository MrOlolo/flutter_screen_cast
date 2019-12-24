import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('ivt.black/stream_controller');
  bool isLoading = false;
  int currentDevice;
  bool streaming = false;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: '192.168.0.1'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startStream,
        tooltip: 'Start Stream',
        backgroundColor: streaming ? Colors.red : Theme.of(context).accentColor,
        child: Icon(
            streaming ? Icons.pause_circle_filled : Icons.play_circle_outline),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future startStream() async {
    setState(() {
      isLoading = true;
    });
    if (!streaming) {
      try {
        print('START RECORDING');
        var ip =
        controller.text.trim().isNotEmpty ? controller.text.trim() : '10.0.0.1';
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
