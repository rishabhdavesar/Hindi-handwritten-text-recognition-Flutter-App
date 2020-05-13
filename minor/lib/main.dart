import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String query;
  String prediction;
  var data;
  File image;
  getImage() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image==null?Text('No image selected'):
            Image.file(image),
            
            RaisedButton(
              onPressed: getImage,
              child: Text('Click image'),
            ),
            RaisedButton(
              onPressed: () async {
                Uri apiUrl = Uri.parse("http://192.168.43.175:5000/predict");
                final imageUploadRequest =
                    http.MultipartRequest('POST', apiUrl);
                final mimeTypeData =
                    lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])
                        .split('/');
                final file = await http.MultipartFile.fromPath(
                    'image', image.path,
                    contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                imageUploadRequest.files.add(file);
                imageUploadRequest.fields['name'] = 'Kartik';
                final streamedResponse = await imageUploadRequest.send();
                final response =
                    await http.Response.fromStream(streamedResponse);
                if (response.statusCode != 200) {
                  return null;
                }
                final responseData =
                    json.decode(response.body);
                
                setState(() {
                  prediction = responseData['result'];
                });
              },
              child: Text('predict'),
            ),
            Text(prediction==null?'predict image':prediction),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
