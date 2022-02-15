import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:tflite/tflite.dart';

class Camera extends StatefulWidget {
  const Camera({
    Key? key,
    required this.cameras,
    required this.setRecognitions,
  }) : super(key: key);

  final List<CameraDescription> cameras;
  final void Function(List<dynamic>? list, int h, int w) setRecognitions;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isEmpty) {
      debugPrint('No camera found!');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );

      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            final startTime = DateTime.now().millisecondsSinceEpoch;

            Tflite.runModelOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 2,
            ).then((recognitions) {
              final endTime = DateTime.now().millisecondsSinceEpoch;
              debugPrint('Detection took ${endTime - startTime}');

              widget.setRecognitions(recognitions, img.height, img.width);

              isDetecting = false;
            });

            // Tflite.detectObjectOnFrame(
            //   bytesList: img.planes.map((plane) {
            //     return plane.bytes;
            //   }).toList(),
            //   model: 'SSDMobileNet',
            //   imageHeight: img.height,
            //   imageWidth: img.width,
            //   imageMean: 127.5,
            //   imageStd: 127.5,
            //   numResultsPerClass: 1,
            //   threshold: 0.4,
            // ).then((recognitions) {
            //   final endTime = DateTime.now().millisecondsSinceEpoch;
            //   debugPrint('Detection took ${endTime - startTime}');

            //   widget.setRecognitions(recognitions, img.height, img.width);

            //   isDetecting = false;
            // });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox();
    }

    var tmp = MediaQuery.of(context).size;
    final screenH = math.max(tmp.height, tmp.width);
    final screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize ?? tmp;
    final previewH = math.max(tmp.height, tmp.width);
    final previewW = math.min(tmp.height, tmp.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
