import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoundaryBox extends StatelessWidget {
  const BoundaryBox({
    Key? key,
    required this.results,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  }) : super(key: key);

  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _renderStrings(),
    );
  }

  List<Widget> _renderBoxes() {
    return results.map((result) {
      final _x = result['rect']['x'];
      final _w = result['rect']['w'];
      final _y = result['rect']['y'];
      final _h = result['rect']['h'];
      double scaleW, scaleH, x, y, w, h;

      if (screenH / screenW > previewH / previewW) {
        scaleW = screenH / previewH * previewW;
        scaleH = screenH;
        var difW = (scaleW - screenW) / scaleW;
        x = (_x - difW / 2) * scaleW;
        w = _w * scaleW;
        if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
        y = _y * scaleH;
        h = _h * scaleH;
      } else {
        scaleH = screenW / previewW * previewH;
        scaleW = screenW;
        var difH = (scaleH - screenH) / scaleH;
        x = _x * scaleW;
        w = _w * scaleW;
        y = (_y - difH / 2) * scaleH;
        h = _h * scaleH;
        if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
      }

      return Positioned(
        left: math.max(0, x),
        top: math.max(0, y),
        width: w,
        height: h,
        child: Container(
          padding: const EdgeInsets.only(top: 5, left: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(37, 213, 253, 1),
              width: 3,
            ),
          ),
          child: Text(
            '${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _renderStrings() {
    double offset = -10;
    return results.map((result) {
      offset = offset + 14;
      return Positioned(
        left: 10,
        top: offset,
        width: screenW,
        height: screenH,
        child: Text(
          '${result['label']} ${(result['confidence'] * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _renderKeypoints() {
    final lists = <Widget>[];
    for (final result in results) {
      final list = result['keypoints'].values.map<Widget>((k) {
        var _x = k['x'];
        var _y = k['y'];
        double scaleW, scaleH, x, y;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          final difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          y = _y * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          final difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          y = (_y - difH / 2) * scaleH;
        }
        return Positioned(
          left: x - 6,
          top: y - 6,
          width: 100,
          height: 12,
          child: Text(
            '● ${k['part']}',
            style: const TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1),
              fontSize: 12,
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    }

    return lists;
  }
}
