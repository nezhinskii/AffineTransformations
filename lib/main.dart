import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/app_painter.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/widgets/rotation_picker.dart';
import 'package:graphics_lab6/widgets/toolbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => MainBloc(),
        child: MainPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: RepositoryProvider(
          create: (context) => SecretModel(),
          child: BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 300,
                    child: ToolBar()
                  ),
                  Expanded(
                    child: ClipRRect(
                      child: CustomPaint(
                        foregroundPainter: AppPainter(
                          projection: state.projection,
                          polyhedron: state.polyhedron,
                          secretFeature: context.read<SecretModel>().secret
                        ),
                        child: Container(
                          color: context.watch<SecretModel>().secret ?
                            Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6) : Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
