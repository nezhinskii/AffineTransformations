part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}

class PickPolyhedron extends MainEvent{
  final PolyhedronType polyhedronType;
  const PickPolyhedron(this.polyhedronType);
}

class PickProjection extends MainEvent{
  final Matrix matrix;
  const PickProjection(this.matrix);
}

class RotatePolyhedron extends MainEvent{
  final Edge line;
  final double angle;
  const RotatePolyhedron(this.line, this.angle);
}