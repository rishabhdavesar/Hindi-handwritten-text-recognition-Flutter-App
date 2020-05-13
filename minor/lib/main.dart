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
      debugShowCheckedModeBanner: false,
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

  getImageCamera() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Minor Project"),
      ),
      body: Center(
        child: SingleChildScrollView(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              image == null
                  ? Text('No image selected')
                  : Container(
                  //  color: Colors.blue,
                    height: 400,
                    width: 400,
                      margin: EdgeInsets.all(10), child: Image.file(image)),
              SizedBox(
                height: 40,
              ),
              Text(
                "Select Image from",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.green,width: 3)

),
                    onPressed: getImage,
                    child: Text('Gallery'),
                  ),
                  SizedBox(width: 50),
                  RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.green,width: 3)
),
                    onPressed: getImage,
                    child: Text('Camera'),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Predict Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.red,width: 3)
),
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
                  final responseData = json.decode(response.body);

                  setState(() {
                    prediction = responseData['result'];
                  });

                  showAlertDialog(context,prediction);
                },
                child: Text('Predict'),
              ),
              Text(
                prediction == null ? '' : prediction,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
    showAlertDialog(BuildContext context,String x) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
  
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,

      elevation: 0,

     title: Text("Predicted Text"),
      content: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          //     color: Colors.blue,
          height: h,
          width: w,
          child: Text(x, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)
        ),
      ),

      actions: [
        // okButton,
      ],
    );

  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 10), () {
          Navigator.of(context).pop(true);
        });
        return alert;
      },
    );
  }
}
