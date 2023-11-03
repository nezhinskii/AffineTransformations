import 'package:flutter/material.dart';
import 'package:graphics_lab6/widgets/hiding_panel.dart';
import 'package:graphics_lab6/widgets/model_picker/model_picker.dart';
import 'package:graphics_lab6/widgets/projcetion_picker/projection_picker.dart';
import 'package:graphics_lab6/widgets/rotation_picker.dart';
import 'package:graphics_lab6/widgets/scaling_picker.dart';
import 'package:graphics_lab6/widgets/translation_picker.dart';

import 'mirroring_picker.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          HidingPanel(
            title: Text("Тип проекции"),
            child: ProjectionPicker()
          ),
          HidingPanel(
            title: Text("Модель"),
            child: ModelPicker()
          ),
          HidingPanel(
            title: Text("Вращение"),
            child: RotationPicker()
          ),
          HidingPanel(
              title: Text("Перемещение"),
              child: TranslationPicker(),
          ),
          HidingPanel(
              title: Text("Масштабирование"),
              child: ScalingPicker(),
          ),
          HidingPanel(
            title: Text("Отражение"),
            child: MirroringPicker(),
          ),
        ],
      )
    );
  }
}
