import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';

class RFigureRadio extends StatefulWidget {
  const RFigureRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onRadioUpdate,
  }) : super(key: key);
  final int groupValue;
  final int value;
  final Function(int?) onRadioUpdate;

  @override
  State<RFigureRadio> createState() => _RFigureRadioState();
}

class _RFigureRadioState extends State<RFigureRadio> {
  double _pulse(double x, double z) {
    var r = x * x + z * z + 1;
    return 5 * (cos(r) / r + 0.1);
  }

  double _sqr(double x, double z) {
    return x * x + z * z - 2;
  }

  double _trigonometry(double x, double z) {
    return sin(x) * cos(z);
  }

  late double Function(double, double) _selectedFunction = _pulse;
  final _tController = TextEditingController(text: '-2 2 1e-1');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Radio(
              value: widget.value,
              groupValue: widget.groupValue,
              onChanged: (value) {
                if (widget.value == value) {
                  context.read<MainBloc>().add(PickRFigure([]));
                }
                widget.onRadioUpdate(value);
              },
            ),
            const Text("Фигура вращения"),
          ],
        ),
        ElevatedButton(onPressed: () {}, child: const Text("Применить")),
        SizedBox(
          height: 65,
          width: 220,
          child: TextField(
            controller: _tController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero, label: Text('Min Max Step')),
          ),
        )
      ],
    );
  }
}
