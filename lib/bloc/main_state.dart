part of 'main_bloc.dart';

@immutable
sealed class MainState {
  final Model model;
  final Matrix projection;
  final String? message;
  const MainState({
    required this.model,
    required this.projection,
    this.message
  });

  MainState copyWith({
    Model? model,
    Matrix? projection,
    String? message
  });
}

class CommonState extends MainState {
  const CommonState({
    required super.model,
    required super.projection,
    super.message
  });

  @override
  CommonState copyWith({
    Model? model,
    Matrix? projection,
    String? message
  }) => CommonState(
      model: model ?? this.model,
      projection: projection ?? this.projection,
      message: message
  );
}

class CurveDrawingState extends MainState {
  const CurveDrawingState({
    required super.model,
    required super.projection,
    super.message,
    required this.path,
    required this.points
  });

  final Path path;
  final List<Offset> points;

  @override
  CurveDrawingState copyWith({
    Model? model,
    Matrix? projection,
    String? message,
    Path? path,
    List<Offset>? points
  }) => CurveDrawingState(
      model: model ?? this.model,
      projection: projection ?? this.projection,
      message: message,
      path: path ?? this.path,
      points: points ?? this.points
  );
}

class CurveReadyState extends MainState{
  const CurveReadyState({
    required super.model,
    required super.projection,
    super.message,
    required this.points
  });

  final List<Point3D> points;

  @override
  CurveReadyState copyWith({
    Model? model,
    Matrix? projection,
    String? message,
    List<Point3D>? points
  }) => CurveReadyState(
      model: model ?? this.model,
      projection: projection ?? this.projection,
      message: message,
      points: points ?? this.points
  );
}