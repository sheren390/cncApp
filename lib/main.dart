// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as Io;

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
// This widget is the home page of your application.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final XFile? pickedImage;
  late final bytes;
  late Future<int> myLength;
  uploadImage() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://localhost:4000/flutter"));
    final headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile(
        'image', pickedImage!.readAsBytes().asStream(), 20,
        filename: pickedImage!.name));

    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Successful'),
                content: Text(resJson['message']),
                actions: [
                  TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context))
                ]));

    setState(() {});
  }

  Future<void> _imagePicker() async {
    final ImagePicker _picker = ImagePicker();
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    myLength = pickedImage!.length();
    bytes = await pickedImage!.readAsBytes();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Successful'),
                content: Text('Your image was successfully picked'),
                actions: [
                  TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context))
                ]));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _imagePicker method above.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically.

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Click upload after selecting an image',
            ),
            TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                onPressed: uploadImage,
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text("Upload", style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _imagePicker,
        tooltip: 'pick an image',
        child: const Icon(Icons.image_search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
