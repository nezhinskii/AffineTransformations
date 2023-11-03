import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:graphics_lab6/matrix.dart';
import 'package:graphics_lab6/polyhedron_type.dart';
import 'package:graphics_lab6/primtives.dart';
import 'package:graphics_lab6/widgets/mirroring_picker.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc()
      : super(CommonState(
            model: Model([], []),
            projection: Matrix.isometric(true, false))) {
    on<PickPolyhedron>(_onPickPolyhedron);
    on<PickProjection>(_onPickProjection);
    on<PickFunction>(_onPickFunction);
    on<RotatePolyhedron>(_onRotatePolyhedron);
    on<TranslatePolyhedron>(_onTranslatePolyhedron);
    on<ScalePolyhedron>(_onScalePolyhedron);
    on<MirrorPolyhedron>(_onMirrorPolyhedron);
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

  void _onPickProjection(PickProjection event, Emitter emit) {
    emit(state.copyWith(projection: event.matrix));
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
    final mirrored = state.model.getTransformed(
      matrix
    );
    emit(state.copyWith(model: mirrored));
  }

  void _onPickFunction(PickFunction event, Emitter emit){
    final values = event.restrictions.split(' ');
    if (values.length != 3){
      emit(state.copyWith(message: 'Неправильно введены ограничения или шаг'));
      return;
    }
    final min = double.tryParse(values[0]),
        max = double.tryParse(values[1]),
        step = double.tryParse(values[2]);
    if (min == null || max == null || step == null || min > max){
      emit(state.copyWith(message: 'Неправильно введены ограничения или шаг'));
      return;
    }
    final points = <Point3D>[];
    var length = 0;
    for(var x = min; x <= max; x += step){
      length ++;
      for (var z = min; z <= max; z += step){
        points.add(Point3D(x, event.func(x, z), z));
      }
    }
    final polygonsByIndexes = <List<int>>[];
    for (var i = 0; i < length - 1; ++i){
      for (var j = 0; j < length - 1; ++j){
        polygonsByIndexes.add([i * length + j, i * (length) + (j + 1), (i + 1) * length + j]);
        polygonsByIndexes.add([i * (length) + (j + 1), (i + 1) * length + (j + 1), (i + 1) * length + j]);
      }
    }
    final function = Model(points, polygonsByIndexes);
    emit(
      state.copyWith(
        model: function
      )
    );
  }
}
