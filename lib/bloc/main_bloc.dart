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
            polyhedron: Polyhedron([], []),
            projection: Matrix.isometric(true, false))) {
    on<PickPolyhedron>(_onPickPolyhedron);
    on<PickProjection>(_onPickProjection);
    on<RotatePolyhedron>(_onRotatePolyhedron);
    on<TranslatePolyhedron>(_onTranslatePolyhedron);
    on<ScalePolyhedron>(_onScalePolyhedron);
    on<MirrorPolyhedron>(_onMirrorPolyhedron);
  }

  void _onPickPolyhedron(PickPolyhedron event, Emitter emit) {
    final newPolyhedron = switch (event.polyhedronType) {
      PolyhedronType.tetrahedron => Polyhedron.tetrahedron,
      PolyhedronType.cube => Polyhedron.cube,
      PolyhedronType.octahedron => Polyhedron.octahedron,
      PolyhedronType.icosahedron => Polyhedron.icosahedron,
      PolyhedronType.dodecahedron => Polyhedron.dodecahedron,
    };
    emit(state.copyWith(polyhedron: newPolyhedron));
  }

  void _onPickProjection(PickProjection event, Emitter emit) {
    emit(state.copyWith(projection: event.matrix));
  }

  void _onRotatePolyhedron(RotatePolyhedron event, Emitter emit) {
    final moved =
        state.polyhedron.getTransformed(Matrix.translation(-event.line.start));
    final vector = event.line.end - event.line.start;
    final scaleRatio =
        sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
    final rotated = moved.getTransformed(
        Matrix.rotation(radians(event.angle), vector / scaleRatio));
    final movedBack =
        rotated.getTransformed(Matrix.translation(event.line.start));
    emit(state.copyWith(polyhedron: movedBack));
  }

  void _onTranslatePolyhedron(TranslatePolyhedron event, Emitter emit) {
    final translated = state.polyhedron.getTransformed(
      Matrix.translation(
        event.translation,
      ),
    );
    emit(state.copyWith(polyhedron: translated));
  }

  void _onScalePolyhedron(ScalePolyhedron event, Emitter emit) {
    final scaled = state.polyhedron.getTransformed(
      Matrix.scaling(
        event.translation,
      ),
    );
    emit(state.copyWith(polyhedron: scaled));
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
    final mirrored = state.polyhedron.getTransformed(
      matrix
    );
    emit(state.copyWith(polyhedron: mirrored));
  }
}
