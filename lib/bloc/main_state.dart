part of 'main_bloc.dart';

@immutable
sealed class MainState {
  final Polyhedron polyhedron;
  final Matrix projection;
  const MainState({
    required this.polyhedron,
    required this.projection
  });

  MainState copyWith({
    Polyhedron? polyhedron,
    Matrix? projection
  });
}

class CommonState extends MainState {
  const CommonState({
    required super.polyhedron,
    required super.projection,
  });

  @override
  CommonState copyWith({
    Polyhedron? polyhedron,
    Matrix? projection
  }) => CommonState(polyhedron: polyhedron ?? this.polyhedron, projection: projection ?? this.projection);
}
