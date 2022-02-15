import 'package:avengers_detector/widgets/boundary_box.dart';
import 'package:avengers_detector/widgets/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> _loadModel() async {
    return await Tflite.loadModel(
      model: 'assets/avengers.tflite',
      labels: 'assets/avengers.txt',
    );
  }

  void _setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avengers Detector'),
      ),
      body: FutureBuilder(
        future: _loadModel(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                Camera(
                  cameras: widget.cameras,
                  setRecognitions: _setRecognitions,
                ),
                BoundaryBox(
                  results: _recognitions,
                  previewH: math.max(_imageHeight, _imageWidth),
                  previewW: math.min(_imageHeight, _imageWidth),
                  screenH: screen.height,
                  screenW: screen.width,
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
