import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primtives.dart';

class Camera{
  final Point3D eye, target, up;
  final double fov, nearPlane, farPlane;
  final Matrix view, projection;
  final bool isPerspective;

  Camera({
    required this.eye,
    required this.target,
    required this.up,
    this.nearPlane = 1,
    this.farPlane = 1000,
    this.fov = 20,
    this.isPerspective = true
  }):view = Matrix.view(eye, target, up),
    projection = isPerspective ?
      Matrix.cameraPerspective(fov, nearPlane, farPlane)
      : Matrix.cameraOrthographic(nearPlane, farPlane);

  Camera copyWith({
    Point3D? eye,
    Point3D? target,
    Point3D? up,
    double? aspectRatio,
    double? nearPlane,
    double? farPlane,
    double? fov,
    bool? isPerspective
  }) => Camera(
    eye: eye ?? this.eye,
    target: target ?? this.target,
    up: up ?? this.up,
    nearPlane: nearPlane ?? this.nearPlane,
    farPlane: farPlane ?? this.farPlane,
    fov: fov ?? this.fov,
    isPerspective: isPerspective ?? this.isPerspective
  );
}