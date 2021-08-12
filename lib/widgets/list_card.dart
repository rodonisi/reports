// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - ListCard Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a card containing a list of widget. By default a divider is
/// inserted between each element of the list.
class ListCard extends StatelessWidget {
  const ListCard({Key? key, required this.children, this.insertDividers = true})
      : super(key: key);

  final List<Widget> children;
  final bool insertDividers;

  void _insertDividers() {
    final divider = const Divider(height: 0.0);

    for (var i = children.length - 1; i > 0; i -= 2) {
      children.insert(i, divider);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (insertDividers) _insertDividers();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
