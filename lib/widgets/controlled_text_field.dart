import 'package:flutter/material.dart';

/// A textfield with embedded editing controller which accepts an initial value.
class ControlledTextField extends StatefulWidget {
  ControlledTextField({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.enabled,
    this.style,
    this.keyboardType,
    this.maxLines,
  }) : super(key: key);

  final String? initialValue;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool? enabled;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  _ControlledTextFieldState createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: widget.decoration,
      enabled: widget.enabled,
      style: widget.style,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
