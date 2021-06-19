// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - AppBarTextField Widget Declaration
// -----------------------------------------------------------------------------

/// A text field with no decorations and a clear button.
class AppBarTextField extends StatefulWidget {
  AppBarTextField({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;
  @override
  _AppBarTextFieldState createState() => _AppBarTextFieldState();
}

class _AppBarTextFieldState extends State<AppBarTextField> {
  bool isEditing = false;
  @override
  Widget build(BuildContext context) {
    final bodyColor = Theme.of(context).textTheme.bodyText1!.color;
    return Focus(
      onFocusChange: (hasFocus) => setState(() => isEditing = hasFocus),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: isEditing
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: bodyColor,
                  ),
                  onPressed: () => widget.controller.clear(),
                )
              : null,
        ),
        style: TextStyle(
          color: bodyColor,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
