import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/app_painter.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/disco_model.dart';
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

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _discoModel = DiscoModel();

  @override
  void dispose() async {
    await _discoModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: RepositoryProvider.value(
          value: _discoModel,
          child: BlocConsumer<MainBloc, MainState>(
            listener: (context, state) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  width: 700,
                  content: Text(
                    state.message!,
                    textAlign: TextAlign.center,
                  ),
                ));
              }
            },
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 300,
                    child: ToolBar()
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          child: CustomPaint(
                            foregroundPainter: AppPainter(
                              projection: state.projection,
                              polyhedron: state.model,
                              secretFeature: context.read<DiscoModel>().isEnabled
                            ),
                            child: Container(
                              color: context.watch<DiscoModel>().isEnabled ?
                                context.watch<DiscoModel>().color : Colors.white,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Visibility(
                            visible: context.read<DiscoModel>().isEnabled,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2 - 100,
                              width: MediaQuery.of(context).size.width / 2 - 200,
                              child: Image.asset('assets/gifs/dance.gif', fit: BoxFit.contain,)
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Visibility(
                            visible: context.read<DiscoModel>().isEnabled,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2 - 100,
                              width: MediaQuery.of(context).size.width / 2  - 200,
                              child: Image.asset('assets/gifs/spongebob.gif', fit: BoxFit.contain,)
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Visibility(
                            visible: context.read<DiscoModel>().isEnabled,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2 - 100,
                              width: MediaQuery.of(context).size.width / 2  - 200,
                              child: Image.asset('assets/gifs/patrick.gif', fit: BoxFit.contain,)
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Visibility(
                            visible: context.read<DiscoModel>().isEnabled,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2 - 100,
                              width: MediaQuery.of(context).size.width / 2  - 200,
                              child: Image.asset('assets/gifs/lizard.gif', fit: BoxFit.contain,)
                            ),
                          ),
                        )
                      ],
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
