import 'package:logger/logger.dart';
import 'dart:io';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    printEmojis: true,
    printTime: true,
    lineLength: 120,
    colors: stdout.supportsAnsiEscapes,
  ),
);
