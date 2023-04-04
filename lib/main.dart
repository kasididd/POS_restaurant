import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String qrcode = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await Scan.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Plugin example app'),
              ),
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Running on: $_platformVersion\n'),
                    Wrap(
                      children: [
                        ElevatedButton(
                          child: Text("parse from image"),
                          onPressed: () async {
                            XFile? res = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (res != null) {
                              String? str = await Scan.parse(res.path);
                              if (str != null) {
                                setState(() {
                                  qrcode = str;
                                });
                              }
                            }
                          },
                        ),
                        ElevatedButton(
                          child: Text('go scan page'),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ScanPage();
                            }));
                          },
                        ),
                      ],
                    ),
                    Text('scan result is $qrcode'),
                  ],
                ),
              ),
            ),
      },
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ScanController controller = ScanController();
  String qrcode = 'Unknown';
  bool isStop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          print("object");
          return Future(() => true);
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    controller.toggleTorchMode();
                  },
                  icon: Icon(Icons.flash_on_rounded),
                  label: Text("Flash")),
              Text(qrcode.toString()),
              SizedBox(
                width: 250,
                height: 250,
                child: ScanView(
                  controller: controller,
                  scanAreaScale: .7,
                  scanLineColor: Colors.green.shade400,
                  onCapture: (data) async {
                    setState(() {
                      if (data.isNotEmpty) {
                        qrcode = data;
                        controller.pause();
                        isStop = true;
                      }
                    });
                  },
                ),
              ),
              if (isStop)
                IconButton(
                    onPressed: () {
                      controller.resume();

                      isStop = false;
                    },
                    icon: Icon(Icons.play_arrow_rounded)),
            ],
          ),
        ),
      ),
    );
  }
}
