// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - AppBarTextField Widget Declaration
// -----------------------------------------------------------------------------
class AppBarTextField extends StatelessWidget {
  const AppBarTextField({Key? key, required this.controller}) : super(key: key);
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      // textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
