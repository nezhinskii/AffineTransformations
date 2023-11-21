part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}

class PickPolyhedron extends MainEvent {
  final PolyhedronType polyhedronType;
  const PickPolyhedron(this.polyhedronType);
}

class PickProjection extends MainEvent {
  final Matrix matrix;
  const PickProjection(this.matrix);
}

class PickFunction extends MainEvent {
  final double Function(double, double) func;
  final String restrictions;
  const PickFunction(this.func, this.restrictions);
}

class PickRFigure extends MainEvent {
  final List<Point3D> points;
  final String vectorStr, divisionsStr;
  const PickRFigure(this.points, this.vectorStr, this.divisionsStr);
}

class RotatePolyhedron extends MainEvent {
  final Edge line;
  final double angle;
  const RotatePolyhedron(this.line, this.angle);
}

class TranslatePolyhedron extends MainEvent {
  final Point3D translation;
  const TranslatePolyhedron(this.translation);
}

class ScalePolyhedron extends MainEvent {
  final Point3D translation;
  const ScalePolyhedron(this.translation);
}

class MirrorPolyhedron extends MainEvent {
  final Planes plane;
  const MirrorPolyhedron(this.plane);
}

class CurvePanEvent extends MainEvent{
  final Offset? position;
  final Size? size;
  const CurvePanEvent(this.position, [this.size]);
}
