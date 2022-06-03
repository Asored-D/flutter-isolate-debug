import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DebugFlutterIsolate(),
    );
  }
}

class DebugFlutterIsolate extends StatelessWidget {
  const DebugFlutterIsolate({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: _runIsolate,
            child: const Text("Run Isolate",
                style: TextStyle(color: Colors.black, fontSize: 30))),
      ),
    );
  }

  // Run Isolate Function
  Future<void> _runIsolate() async {
    print('Spawning Isolate');
    final flutterIsolate =
        await FlutterIsolate.spawn(spawnIsolate, "test") as FlutterIsolate;

    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    IsolateNameServer.registerPortWithName(sendPort, 'main');

    receivePort.listen((dynamic message) {
      print("Done");
      print(message);

      flutterIsolate.kill();
    });

    // Needed also in this place. Otherwise the app will crash on Hot Restart. Can be solved with the following pull request: https://github.com/rmawatson/flutter_isolate/pull/78/files
    flutterIsolate.kill();
  }
}

// Isolate Function
Future<void> spawnIsolate(String data) async {
  final port = IsolateNameServer.lookupPortByName('main');
  if (port != null) {
    port.send(data);
  } else {
    print('port is null');
  }
}
