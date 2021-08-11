// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - ControlledTextField Widget Implementation
// -----------------------------------------------------------------------------

/// A textfield with embedded editing controller which accepts an initial value.
class ControlledTextField extends StatefulWidget {
  ControlledTextField(
      {Key? key,
      this.initialValue,
      this.onChanged,
      this.decoration = const InputDecoration(),
      this.enabled,
      this.style,
      this.keyboardType,
      this.maxLines,
      this.hasClearButton = false,
      this.focusNode})
      : super(key: key);

  final String? initialValue;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool? enabled;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool hasClearButton;
  final FocusNode? focusNode;

  @override
  _ControlledTextFieldState createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {
  TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

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
    InputDecoration? decoration = widget.decoration;
    if (widget.hasClearButton) {
      final bodyColor = Theme.of(context).textTheme.bodyText1!.color;
      decoration = widget.decoration ?? const InputDecoration();
      decoration = decoration.copyWith(
          suffixIcon: _isEditing
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: bodyColor,
                  ),
                  onPressed: () => _controller.clear(),
                )
              : null);
    }
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isEditing = hasFocus),
      focusNode: widget.focusNode,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: decoration,
        enabled: widget.enabled,
        style: widget.style,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
