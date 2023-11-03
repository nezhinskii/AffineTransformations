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
