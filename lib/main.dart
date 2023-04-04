import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String qrcode = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              children: [
                ElevatedButton(
                  child: const Text("parse from image"),
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
                  child: const Text('go scan page'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return const ScanPage();
                    }));
                  },
                ),
              ],
            ),
            Text('scan result is $qrcode'),
          ],
        ),
      ),
    ));
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
          controller.pause();
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
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text("Flash")),
              Text(qrcode.toString()),
              SizedBox(
                width: 250,
                height: 250,
                child: ScanView(
                  controller: controller,
                  scanAreaScale: .7,
                  scanLineColor: Colors.green.shade400,
                  onCapture: (str) async {
                    setState(() {
                      if (str.isNotEmpty) {
                        qrcode = str;
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
                      setState(() {
                        isStop = false;
                      });
                    },
                    icon: const Icon(Icons.play_arrow_rounded)),
            ],
          ),
        ),
      ),
    );
  }
}
