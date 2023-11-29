import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:vector_math/vector_math.dart' as vm;

class AppPainter extends CustomPainter {
  final Model polyhedron;
  final Camera camera;
  final bool secretFeature;
  late List<List<double>> _zBuffer;
  late List<List<Color?>> _pixels;

  static final _colors = List.generate(
      50,
      (_) =>
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
  static final _axisPaint = Paint()
    ..strokeWidth = 1
    ..color = Colors.deepPurple;
  static final _polyhedronPaint = Paint()
    ..strokeWidth = 2
    ..color = Colors.white;
  static const _labelStyle = TextStyle(color: Colors.white, fontSize: 16);
  static final _xLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "X",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);
  static final _yLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "Y",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);
  static final _zLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "Z",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);

  AppPainter({
    required this.polyhedron,
    required this.camera,
    required this.secretFeature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _zBuffer = List.generate(size.height.toInt(),
        (_) => List.filled(size.width.toInt(), double.negativeInfinity));
    _pixels = List.generate(
        size.height.toInt(), (_) => List.filled(size.width.toInt(), null));

    _axisPaint.strokeWidth =
        secretFeature ? (Random().nextDouble() * 2 + 1.5) : 1;
    _axisPaint.color = secretFeature
        ? Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6)
        : Colors.deepPurple;
    final l = secretFeature ? (Random().nextDouble() * 3 + 2) : 2.0;
    final m = Matrix.rotation(vm.radians(Random().nextDouble() * 360),
        Point3D(1 / sqrt(3), 1 / sqrt(3), 1 / sqrt(3)));
    final xAxis = Edge(Point3D(0, 0, 0), Point3D(l, 0, 0));
    final yAxis = Edge(Point3D(0, 0, 0), Point3D(0, l, 0));
    final zAxis = Edge(Point3D(0, 0, 0), Point3D(0, 0, l));
    for (var el in <IPoints>[xAxis, yAxis, zAxis]) {
      for (var point in el.points) {
        if (secretFeature) {
          point.updateWithVector(Matrix.point(point) * m);
        }
        point.updateWithVector(Matrix.point(point) * camera.view);
        point.updateWithVector(Matrix.point(point) * camera.projection);
      }
    }
    final projectedPolyhedron = polyhedron
        .getTransformed(camera.view)
        .getTransformed(camera.projection);
    canvas.drawLine(MainBloc.point3DToOffset(xAxis.start, size),
        MainBloc.point3DToOffset(xAxis.end, size), _axisPaint);
    _xLabel.paint(canvas, MainBloc.point3DToOffset(xAxis.end, size));
    canvas.drawLine(MainBloc.point3DToOffset(yAxis.start, size),
        MainBloc.point3DToOffset(yAxis.end, size), _axisPaint);
    _yLabel.paint(canvas, MainBloc.point3DToOffset(yAxis.end, size));
    canvas.drawLine(MainBloc.point3DToOffset(zAxis.start, size),
        MainBloc.point3DToOffset(zAxis.end, size), _axisPaint);
    _zLabel.paint(canvas, MainBloc.point3DToOffset(zAxis.end, size));
    print('${projectedPolyhedron.polygons[0].points[0]}  ${polyhedron.polygons[0].points[0]}');
    for (int i = 0; i < projectedPolyhedron.polygons.length; ++i) {
      var curPolygon = polyhedron.polygons[i];
      var camVector = curPolygon.center - camera.eye;
      if (curPolygon.normal.dot(camVector) < 0) continue;

      drawTriangle(
          size: size,
          canvas: canvas,
          point3d0: projectedPolyhedron.polygons[i].points[0],
          point3d1: projectedPolyhedron.polygons[i].points[1],
          point3d2: projectedPolyhedron.polygons[i].points[2],
          color1: _colors[i % _colors.length],
          color2: _colors[i % _colors.length],
          color3: _colors[i % _colors.length]);
      // for (var j = 1; j < projectedPolyhedron.polygons[i].points.length; ++j) {
      //   canvas.drawLine(
      //       MainBloc.point3DToOffset(
      //           projectedPolyhedron.polygons[i].points[j - 1], size),
      //       MainBloc.point3DToOffset(
      //           projectedPolyhedron.polygons[i].points[j], size),
      //       _polyhedronPaint);
      // }
      // canvas.drawLine(
      //     MainBloc.point3DToOffset(
      //         projectedPolyhedron.polygons[i].points.first, size),
      //     MainBloc.point3DToOffset(
      //         projectedPolyhedron.polygons[i].points.last, size),
      //     _polyhedronPaint);
    }
    for (int i = 0; i < _pixels.length; ++i) {
      for (int j = 0; j < _pixels[i].length; ++j) {
        if (_pixels[i][j] != null) {
          canvas.drawPoints(
              PointMode.points,
              [Offset(j.toDouble(), i.toDouble())],
              _paint..color = _pixels[i][j]!);
        }
      }
    }
  }

  static final _paint = Paint()
    ..strokeWidth = 2
    ..blendMode = BlendMode.src
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.fill;

  void drawTriangle({
    required Size size,
    required Canvas canvas,
    required Point3D point3d0,
    required Point3D point3d1,
    required Point3D point3d2,
    required Color color1,
    required Color color2,
    required Color color3,
  }) {
    Offset p0 = MainBloc.point3DToOffset(point3d0, size);
    Offset p1 = MainBloc.point3DToOffset(point3d1, size);
    Offset p2 = MainBloc.point3DToOffset(point3d2, size);

    if (p0.dy < p1.dy) {
      (point3d0, point3d1) = (point3d1, point3d0);
      (p0, p1) = (p1, p0);
    }
    if (p0.dy < p2.dy) {
      (point3d0, point3d2) = (point3d2, point3d0);
      (p0, p2) = (p2, p0);
    }
    if (p1.dy < p2.dy) {
      (point3d1, point3d2) = (point3d2, point3d1);
      (p1, p2) = (p2, p1);
    }

    int totalHeight = (p0.dy - p2.dy).ceil();
    for (int i = 0; i < totalHeight; i++) {
      bool secondHalf = i > p0.dy - p1.dy || p1.dy == p0.dy;
      int segmentHeight =
          (secondHalf ? p1.dy - p2.dy : p0.dy - p1.dy).ceil() + 1;
      double alpha = i.toDouble() / totalHeight.toDouble();
      double beta =
          (i - (secondHalf ? p0.dy - p1.dy : 0)).toDouble() / segmentHeight;
      Offset l = p0 + (p2 - p0) * alpha;
      Offset left = Offset(l.dx.floorToDouble(), l.dy.floorToDouble());
      Offset r = secondHalf ? p1 + (p2 - p1) * beta : p0 + (p1 - p0) * beta;
      Offset right = Offset(r.dx.floorToDouble(), r.dy.floorToDouble());
      double leftZ = (point3d0 + (point3d2 - point3d0) * alpha).z;
      double rightZ = secondHalf
          ? (point3d1 + (point3d2 - point3d1) * beta).z
          : (point3d0 + (point3d1 - point3d0) * beta).z;
      if (left.dx > right.dx) {
        (left, right) = (right, left);
        (leftZ, rightZ) = (rightZ, leftZ);
      }
      for (int j = left.dx.floor(); j <= right.dx.ceil(); j++) {
        double ratio = (left.dx - right.dx).abs() < 1
            ? 1
            : (j - left.dx.toInt()).toDouble() / (right.dx - left.dx);
        Offset p = left + (right - left) * ratio;
        Offset point = Offset(p.dx.floorToDouble(), p.dy.floorToDouble());
        double z = leftZ + (rightZ - leftZ) * ratio;
        if (point.dy.toInt() > 0 &&
            point.dy.toInt() < _zBuffer.length &&
            point.dx.toInt() > 0 &&
            point.dx.toInt() < _zBuffer[0].length &&
            _zBuffer[point.dy.toInt()][point.dx.toInt()] < z) {
          _zBuffer[point.dy.toInt()][point.dx.toInt()] = z;
          _pixels[point.dy.floor()][point.dx.floor()] = color1;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
