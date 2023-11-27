import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/polyhedron_type.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:graphics_lab6/widgets/mirroring_picker.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(CommonState(
      model: Model([], []),
      camera: Camera(
        eye: Point3D(5, 5, 5),
        target: Point3D(0, 0, 0),
        up: Point3D(0, 1, 0),
      )
    )
  ) {
    on<ShowMessageEvent>((event, emit){
      emit(state.copyWith(message: event.message));
    });
    on<PickPolyhedron>(_onPickPolyhedron);
    on<UpdateCamera>(_onUpdateCamera);
    on<CameraRotationEvent>(_onCameraRotation);
    on<CameraScaleEvent>(_onCameraScale);
    on<PickFunction>(_onPickFunction);
    on<PickRFigure>(_onPickRFigure);
    on<RotatePolyhedron>(_onRotatePolyhedron);
    on<TranslatePolyhedron>(_onTranslatePolyhedron);
    on<ScalePolyhedron>(_onScalePolyhedron);
    on<MirrorPolyhedron>(_onMirrorPolyhedron);
    on<CurvePanEvent>(_onCurvePanEvent);
    on<SaveObjEvent>((event, emit) async {
      final res = await state.model.saveFile();
      final message = res ? "Файл сохранён" : "Файл не сохранён";
      emit(state.copyWith(message: message));
    });
    on<LoadObjEvent>((event, emit) async {
      final newModel = await Model.fromFile();
      // int len = state.model.points.length;
      // for (int i = 0; i < len; i++) {
      //   if (newModel!.points[i].x != state.model.points[i].x) {
      //     print(i);
      //   }
      // }
      if (newModel != null) {
        emit(
          CommonState(
            model: newModel,
            camera: state.camera,
            message: state.message,
          ),
        );
      } else {
        emit(state.copyWith(message: "Файл не загружен"));
      }
    });
  }

  static const _pixelRatio = 100;

  static Offset point3DToOffset(Point3D point3d, Size size) {
    return Offset((point3d.x / point3d.h * _pixelRatio + size.width / 2).roundToDouble(),
        (-point3d.y / point3d.h * _pixelRatio + size.height / 2).roundToDouble());
  }

  static Point3D offsetToPoint3D(Offset offset, Size size) {
    return Point3D((offset.dx - size.width / 2) / _pixelRatio,
        -(offset.dy - size.height / 2) / _pixelRatio, 0);
  }

  void _onPickPolyhedron(PickPolyhedron event, Emitter emit) {
    final newPolyhedron = switch (event.polyhedronType) {
      PolyhedronType.tetrahedron => Model.tetrahedron,
      PolyhedronType.cube => Model.cube,
      PolyhedronType.octahedron => Model.octahedron,
      PolyhedronType.icosahedron => Model.icosahedron,
      PolyhedronType.dodecahedron => Model.dodecahedron,
    };
    emit(state.copyWith(model: newPolyhedron));
  }

  void _onUpdateCamera(UpdateCamera event, Emitter emit) {
    emit(state.copyWith(camera: event.camera));
  }

  void _onRotatePolyhedron(RotatePolyhedron event, Emitter emit) {
    final moved =
        state.model.getTransformed(Matrix.translation(-event.line.start));
    final vector = event.line.end - event.line.start;
    final scaleRatio =
        sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
    final rotated = moved.getTransformed(
        Matrix.rotation(radians(event.angle), vector / scaleRatio));
    final movedBack =
        rotated.getTransformed(Matrix.translation(event.line.start));
    emit(state.copyWith(model: movedBack));
  }

  void _onTranslatePolyhedron(TranslatePolyhedron event, Emitter emit) {
    final translated = state.model.getTransformed(
      Matrix.translation(
        event.translation,
      ),
    );
    emit(state.copyWith(model: translated));
  }

  void _onScalePolyhedron(ScalePolyhedron event, Emitter emit) {
    final scaled = state.model.getTransformed(
      Matrix.scaling(
        event.translation,
      ),
    );
    emit(state.copyWith(model: scaled));
  }

  void _onMirrorPolyhedron(MirrorPolyhedron event, Emitter emit) {
    late Matrix matrix;
    switch (event.plane) {
      case Planes.xy:
        matrix = Matrix.mirrorXY();
      case Planes.xz:
        matrix = Matrix.mirrorXZ();
      case Planes.yz:
        matrix = Matrix.mirrorYZ();
    }
    final mirrored = state.model.getTransformed(matrix);
    emit(state.copyWith(model: mirrored));
  }

  void _onPickFunction(PickFunction event, Emitter emit) {
    final values = event.restrictions.split(' ');
    if (values.length != 3) {
      emit(state.copyWith(message: 'Неправильно введены ограничения или шаг'));
      return;
    }
    final min = double.tryParse(values[0]),
        max = double.tryParse(values[1]),
        step = double.tryParse(values[2]);
    if (min == null || max == null || step == null || min > max) {
      emit(state.copyWith(message: 'Неправильно введены ограничения или шаг'));
      return;
    }
    final points = <Point3D>[];
    var length = 0;
    for (var x = min; x <= max; x += step) {
      length++;
      for (var z = min; z <= max; z += step) {
        points.add(Point3D(x, event.func(x, z), z));
      }
    }
    final polygonsByIndexes = <List<int>>[];
    for (var i = 0; i < length - 1; ++i) {
      for (var j = 0; j < length - 1; ++j) {
        polygonsByIndexes.add(
            [i * length + j, i * (length) + (j + 1), (i + 1) * length + j]);
        polygonsByIndexes.add([
          i * (length) + (j + 1),
          (i + 1) * length + (j + 1),
          (i + 1) * length + j
        ]);
      }
    }
    final function = Model(points, polygonsByIndexes);
    emit(state.copyWith(model: function));
  }

  void _onCurvePanEvent(CurvePanEvent event, Emitter emit) {
    if (event.position != null) {
      final drawingState = (state as CurveDrawingState);
      if (drawingState.points.isEmpty) {
        drawingState.path.moveTo(event.position!.dx, event.position!.dy);
      } else {
        drawingState.path.lineTo(event.position!.dx, event.position!.dy);
      }
      drawingState.points.add(event.position!);
      emit(drawingState.copyWith());
    } else {
      if (state is CommonState) {
        emit(CurveDrawingState(
            model: state.model,
            camera: state.camera,
            path: Path(),
            points: []));
      } else {
        final drawingState = (state as CurveDrawingState);
        emit(CurveReadyState(
            model: drawingState.model,
            points: drawingState.points
                .map((point) => offsetToPoint3D(point, event.size!))
                .toList(),
            camera: drawingState.camera));
      }
    }
  }

  void _onPickRFigure(PickRFigure event, Emitter emit) {
    List<String> vectorStr = event.vectorStr.split(' ');
    int divisionsNumber;
    Point3D rotationAxis;
    if (vectorStr.length != 3) {
      emit(CommonState(
          model: state.model,
          camera: state.camera,
          message: 'Неверное количество точек'));
    }
    try {
      rotationAxis = Point3D(double.parse(vectorStr[0]),
          double.parse(vectorStr[1]), double.parse(vectorStr[2]));
      divisionsNumber = int.parse(event.divisionsStr);
    } catch (_) {
      emit(CommonState(
          model: state.model,
          camera: state.camera,
          message: ';?:№%!*;№%:?!:(*?;!)(*№;()!№'));
      return;
    }

    final selectedPoints = <Point3D>[];
    for (int i = 0; i < event.points.length; i += 30) {
      selectedPoints.add(event.points[i]);
    }
    List<Point3D> points = selectedPoints;

    double angle = 360 / divisionsNumber;

    var model = Model(points, [
      List.generate(points.length, (index) => index),
    ]);

    final scaleRatio = sqrt(rotationAxis.x * rotationAxis.x +
        rotationAxis.y * rotationAxis.y +
        rotationAxis.z * rotationAxis.z);

    var curAngle = angle;

    List<Point3D> finalPoints = [];
    List<List<int>> finalIndices = [];

    finalPoints.addAll(model.points.map((e) => e.copy()));

    for (var i = 1; i < divisionsNumber; i++) {
      final rotated = model.getTransformed(
          Matrix.rotation(radians(curAngle), rotationAxis / scaleRatio));
      finalPoints.addAll(rotated.points.map((e) => e.copy()));
      curAngle += angle;
    }
    int len = model.points.length;
    for (var i = 1; i < divisionsNumber + 1; i++) {
      for (var j = 0; j < len - 1; j++) {
        finalIndices.add([
          len * ((i - 1) % divisionsNumber) + j,
          len * ((i - 1) % divisionsNumber) + 1 + j,
          len * (i % divisionsNumber) + j
        ]);
        finalIndices.add([
          len * ((i - 1) % divisionsNumber) + 1 + j,
          len * (i % divisionsNumber) + j,
          len * (i % divisionsNumber) + 1 + j
        ]);
      }
    }
    emit(CommonState(
        model: Model(finalPoints, finalIndices), camera: state.camera));
  }

  static const double sensitivity = 0.003;
  void _onCameraRotation(CameraRotationEvent event, Emitter emit){
    final camera = state.camera;
    Point3D direction = camera.target - camera.eye;
    double radius = direction.length();

    double theta = atan2(direction.z, direction.x);
    double phi = acos(direction.y / radius);

    theta += event.delta.dx * sensitivity;
    phi += event.delta.dy * sensitivity;
    phi = max(0.1, min(pi - 0.1, phi));
    direction.x = radius * sin(phi) * cos(theta);
    direction.y = radius * cos(phi);
    direction.z = radius * sin(phi) * sin(theta);

    final eye = camera.target - direction;
    emit(state.copyWith(camera: camera.copyWith(eye: eye)));
  }

  void _onCameraScale(CameraScaleEvent event, Emitter emit){
    final camera = state.camera;
    Point3D direction = camera.target - camera.eye;
    double distance = direction.length();
    distance += event.delta * sensitivity;

    final eye = camera.target - direction.normalized() * distance;
    emit(state.copyWith(camera: camera.copyWith(eye: eye)));
  }
}
