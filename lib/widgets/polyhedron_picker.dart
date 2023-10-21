import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/polyhedron_type.dart';

class PolyhedronPicker extends StatefulWidget {
  const PolyhedronPicker({Key? key}) : super(key: key);

  @override
  State<PolyhedronPicker> createState() => _PolyhedronPickerState();
}

class _PolyhedronPickerState extends State<PolyhedronPicker> {
  PolyhedronType _selectedPolyhedron = PolyhedronType.cube;

  @override
  void initState() {
    super.initState();
    context.read<MainBloc>().add(PickPolyhedron(_selectedPolyhedron));
  }

  void _pickPolyhedron(PolyhedronType? newPolyhedron){
    if (newPolyhedron == null){
      return;
    }
    setState(() {
      _selectedPolyhedron = newPolyhedron;
    });
    context.read<MainBloc>().add(PickPolyhedron(_selectedPolyhedron));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          title: const Text("Тетраэдр"),
          value: PolyhedronType.tetrahedron,
          groupValue: _selectedPolyhedron,
          onChanged: _pickPolyhedron,
        ),
        RadioListTile(
          title: const Text("Куб"),
          value: PolyhedronType.cube,
          groupValue: _selectedPolyhedron,
          onChanged: _pickPolyhedron,
        ),
        RadioListTile(
          title: const Text("Октаэдр"),
          value: PolyhedronType.octahedron,
          groupValue: _selectedPolyhedron,
          onChanged: _pickPolyhedron,
        ),
        RadioListTile(
          title: const Text("Икосаэдр"),
          value: PolyhedronType.icosahedron,
          groupValue: _selectedPolyhedron,
          onChanged: _pickPolyhedron,
        ),
        RadioListTile(
          title: const Text("Додекаэдр"),
          value: PolyhedronType.dodecahedron,
          groupValue: _selectedPolyhedron,
          onChanged: _pickPolyhedron,
        ),
      ],
    );
  }
}
