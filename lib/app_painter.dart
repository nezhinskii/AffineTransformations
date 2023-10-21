import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphics_lab6/matrix.dart';
import 'package:graphics_lab6/primtives.dart';
import 'package:vector_math/vector_math.dart' as vm;

class AppPainter extends CustomPainter{
  final Polyhedron polyhedron;
  final Matrix projection;
  final bool secretFeature;

  static const _pixelRatio = 100;
  static final _axisPaint = Paint()..strokeWidth = 1..color = Colors.deepPurple;
  static final _polyhedronPaint = Paint()..strokeWidth = 2..color = Colors.black;
  static const _labelStyle = TextStyle(color: Colors.black, fontSize: 16);
  static final _xLabel = TextPainter(
    text: const TextSpan(
      style: _labelStyle,
      text: "X",
    )
  )..textDirection = TextDirection.ltr..layout(
    maxWidth: 0,
    minWidth: 0
  );
  static final _yLabel = TextPainter(
    text: const TextSpan(
      style: _labelStyle,
      text: "Y",
    )
  )..textDirection = TextDirection.ltr..layout(
    maxWidth: 0,
    minWidth: 0
  );
  static final _zLabel = TextPainter(
    text: const TextSpan(
      style: _labelStyle,
      text: "Z",
    )
  )..textDirection = TextDirection.ltr..layout(
    maxWidth: 0,
    minWidth: 0
  );

  const AppPainter({
    required this.polyhedron,
    required this.projection,
    required this.secretFeature,
  });

  Offset _point3DToOffset(Point3D point3d, Size size){
    return Offset(point3d.x / point3d.h * _pixelRatio + size.width / 2, -point3d.y / point3d.h * _pixelRatio + size.height / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _axisPaint.strokeWidth = secretFeature ? (Random().nextDouble() * 2 + 1.5) : 1;
    _axisPaint.color = secretFeature ? Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6) : Colors.deepPurple;
    final l = secretFeature ? (Random().nextDouble() * 3 + 2) : 2.0;
    final m = Matrix.rotation(vm.radians(Random().nextDouble() * 360), Point3D(1/sqrt(3), 1/sqrt(3), 1/sqrt(3)));
    final xAxis = Edge(Point3D(0, 0, 0), Point3D(l, 0, 0));
    final yAxis = Edge(Point3D(0, 0, 0), Point3D(0, l, 0));
    final zAxis = Edge(Point3D(0, 0, 0), Point3D(0, 0, l));
    for (var el in <IPoints>[xAxis, yAxis, zAxis]){
      for (var point in el.points){
        if (secretFeature) {
          point.updateWithVector(Matrix.point(point) * m);
        }
        point.updateWithVector(Matrix.point(point) * projection);
      }
    }
    final projectedPolyhedron = polyhedron.getTransformed(projection);

    canvas.drawLine(_point3DToOffset(xAxis.start, size), _point3DToOffset(xAxis.end, size), _axisPaint);
    _xLabel.paint(canvas, _point3DToOffset(xAxis.end, size));
    canvas.drawLine(_point3DToOffset(yAxis.start, size), _point3DToOffset(yAxis.end, size), _axisPaint);
    _yLabel.paint(canvas, _point3DToOffset(yAxis.end, size));
    canvas.drawLine(_point3DToOffset(zAxis.start, size), _point3DToOffset(zAxis.end, size), _axisPaint);
    _zLabel.paint(canvas, _point3DToOffset(zAxis.end, size));


    for (var polygon in projectedPolyhedron.polygons){
      for (var i = 1; i < polygon.points.length; ++i){
        canvas.drawLine(_point3DToOffset(polygon.points[i - 1], size), _point3DToOffset(polygon.points[i], size), _polyhedronPaint);
      }
      canvas.drawLine(_point3DToOffset(polygon.points.first, size), _point3DToOffset(polygon.points.last, size), _polyhedronPaint);
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}