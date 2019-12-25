import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_cast/service/storage_service.dart';
import 'package:flutter_screen_cast/widget/loading_container.dart';

import 'settings.dart';

class TranslatorTab extends StatefulWidget {
  final Stream<bool> adminModeIsOn;

  const TranslatorTab({Key key, this.adminModeIsOn}) : super(key: key);

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
    return isLoading
        ? Center(child: LoadingContainer())
        : Scaffold(
            body: Center(
              child: Text(status,
                  style: TextStyle(fontSize: 20.0, color: Colors.black38),
                  textAlign: TextAlign.center),
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: widget.adminModeIsOn,
                    initialData: false,
                    builder: (context, snapshot) {
                      if (snapshot.data)
                        return FloatingActionButton.extended(
                          heroTag: 'admin',
                          backgroundColor: Colors.redAccent,
                          onPressed: banCurrentStream,
                          label: Text('Disconnect user'),
                          icon: Icon(Icons.videocam_off),
                        );
                      return Container();
                    }),
                Container(
                  height: 20,
                ),
                FloatingActionButton.extended(
                  onPressed: startStream,
                  label: Text(buttonText[streaming ? 0 : 1]),
                  icon: Icon(streaming
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_outline),
                  backgroundColor:
                      streaming ? Colors.red : Theme.of(context).accentColor,
                ),
              ],
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
        var ip = await StorageService.getIp() ?? defaultIp;
        var resolution = await StorageService.getResolution() ?? '720';
        final String result =
            await platform.invokeMethod('start', {'ip': ip, 'res': resolution});
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

  void banCurrentStream() async {
    setState(() {
      isLoading = true;
    });

    var token = await StorageService.getToken();
    if (streaming) {
      ///IF WE STREAMING NOW
      ///DISABLE OUT STREAM
      await startStream();
    } else {
      //TODO DISABLE ANOTHER STREAM
      ///DISABLE ANOTHER STREAM
    }

    setState(() {
      isLoading = false;
    });
  }
}
