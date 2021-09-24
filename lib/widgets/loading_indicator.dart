import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 16.0),
          const Text('@.capitalize:keywords.loading').tr(),
        ],
      ),
    );
  }
}
