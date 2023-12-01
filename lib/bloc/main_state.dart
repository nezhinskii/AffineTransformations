part of 'main_bloc.dart';

@immutable
sealed class MainState {
  final Model model;
  final Camera camera;
  final String? message;
  const MainState({
    required this.model,
    required this.camera,
    this.message
  });

  MainState copyWith({
    Model? model,
    Camera? camera,
    String? message
  });
}

class CommonState extends MainState {
  const CommonState({
    required super.model,
    required super.camera,
    super.message
  });

  @override
  CommonState copyWith({
    Model? model,
    Camera? camera,
    String? message
  }) => CommonState(
      model: model ?? this.model,
      camera: camera ?? this.camera,
      message: message
  );
}

class CurveDrawingState extends MainState {
  const CurveDrawingState({
    required super.model,
    required super.camera,
    super.message,
    required this.path,
    required this.points
  });

  final Path path;
  final List<Offset> points;

  @override
  CurveDrawingState copyWith({
    Model? model,
    Camera? camera,
    String? message,
    Path? path,
    List<Offset>? points
  }) => CurveDrawingState(
      model: model ?? this.model,
      camera: camera ?? this.camera,
      message: message,
      path: path ?? this.path,
      points: points ?? this.points
  );
}

class CurveReadyState extends MainState{
  const CurveReadyState({
    required super.model,
    required super.camera,
    super.message,
    required this.points
  });

  final List<Point3D> points;

  @override
  CurveReadyState copyWith({
    Model? model,
    Camera? camera,
    String? message,
    List<Point3D>? points
  }) => CurveReadyState(
      model: model ?? this.model,
      camera: camera ?? this.camera,
      message: message,
      points: points ?? this.points
  );
}

class FloatingHorizonState extends MainState {
  const FloatingHorizonState({
    required super.model,
    required super.camera,
    required this.func,
    required this.min,
    required this.max,
    required this.step,
    required this.pixelRatio,
    super.message
  });

  final double Function(double, double) func;
  final double min, max, step, pixelRatio;

  @override
  FloatingHorizonState copyWith({
    Model? model,
    Camera? camera,
    String? message,
    double Function(double, double)? func,
    double? min,
    double? max,
    double? step,
    double? pixelRatio
  }) => FloatingHorizonState(
      func: func ?? this.func,
      max: max ?? this.max,
      min: min ?? this.min,
      step: step ?? this.step,
      model: model ?? this.model,
      camera: camera ?? this.camera,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      message: message,
  );
}