import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
List  data =[
  {   "label": "airplane",
    "description": "An aeroplane is a flying vehichle.It runs by pilot.It has wings. It flies like abird. It travells faster"
  },
  {
    "label": "car",
    "description": "It is vehicle that has four wheels. It runs on road. It can carry 4 or more people. It runs on fuel. . It has lights and horn."
  },
  {
    "label": "dog",
    "description": "Dog is an animal. It can barks. It has 4 legs. It wags it tail. Dog is a companion of man."
  },
  {
    "label": "flower",
    "description": "Flower is a part of a plant. It has petals. It smells good. it looks beautiful. It is found in garden. It attracts flies"
  }
];

class Tensorflow extends StatefulWidget {
  @override
  _TensorflowState createState() => _TensorflowState();
}

class _TensorflowState extends State<Tensorflow> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/graph.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }
  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0, 
        imageStd: 255.0, 
        numResults: 2, 
        threshold: 0.2, 
        asynch: true
        );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }
  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
      }
      findIndex(String abc)
      {
        for(int i =0 ;i<data.length;i++)
        {
          if(data[i]['label']==abc)
          {
            print(i);
            print(data[i]['description']);
            return i;
          }
        }

      }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Essentia",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _loading ? Container(
              height: 300,
              width: 300,
            ): 
            Container(
              margin: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  RaisedButton(
                    child:Text("Capture") ,
                    onPressed: pickImage,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _image == null ? Container() : Image.file(_image),
                  SizedBox(
                    height: 20,
                  ),
                  _image == null ? Container() : _outputs != null ? 
                  Text(_outputs[0]["label"],style: TextStyle(color: Colors.black,fontSize: 20),
                  ) : Container(child: Text("")),

                      SizedBox(
                        height: 20.0
                      ),
                  _image == null ? Container() : _outputs != null ?
                  Text(data[findIndex(_outputs[0]["label"])]['description'],style: TextStyle(color: Colors.black,fontSize: 20),
                  ) : Container(child: Text(""))
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
