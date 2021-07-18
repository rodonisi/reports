import 'package:flutter/material.dart';

class ControlledTextField extends StatelessWidget {
  ControlledTextField({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.enabled,
    this.style,
    this.keyboardType,
  })  : controller = TextEditingController(),
        super(key: key) {
    if (initialValue != null) controller.text = initialValue!;
  }

  final TextEditingController controller;
  final String? initialValue;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool? enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: decoration,
      enabled: enabled,
      style: style,
      keyboardType: keyboardType,
    );
  }
}
