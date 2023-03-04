import 'dart:io';

import 'package:app_updater/updater/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Windows appli updater..'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double percent = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'ONLINE UPDATER ii',
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: CircularProgressIndicator(
                value: percent / 100,
                semanticsValue: (percent / 100).toString(),
                semanticsLabel: percent.toString(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AppConfig.downloadAndInstallNewVersion((val) {
            setState(() {
              percent = val;
            });
          }).then(
            (value) => showMessage(value),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showMessage(msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Updating process"),
          content: Text(msg),
          actions: [
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                setState(() {
                  percent = 0;
                });
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
