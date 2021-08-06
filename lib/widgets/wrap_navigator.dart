// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - WrapNavigator Widget Implementation
// -----------------------------------------------------------------------------

/// Wrap the given child in a navigator widget.
class WrapNavigator extends StatelessWidget {
  const WrapNavigator({Key? key, required this.child, this.onPopPage})
      : super(key: key);

  final MaterialPage child;
  final bool Function(Route<dynamic> route, dynamic result)? onPopPage;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Navigator(
        pages: [child],
        onPopPage: onPopPage ?? (route, result) => route.didPop(result),
      ),
    );
  }
}
