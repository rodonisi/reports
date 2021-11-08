import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/utilities/io_utils.dart';

/// Store a custom statistics rule.
class Rule {
  static const String kId = 'id';
  static const String kName = 'name';
  static const String kFieldType = 'field_type';
  static const String kOperation = 'operation';
  static const String kThreshold = 'threshold';

  // The supported rule operations.
  static const Map<String, String> operations = {
    'gt': 'settings.statistics.gt',
    'gte': 'settings.statistics.gte',
    'lt': 'settings.statistics.lt',
    'lte': 'settings.statistics.lte',
  };

  // The supported rule fields.
  static const List<String> supportedFields = [
    FieldTypes.textField,
    FieldTypes.dateRange,
  ];

  String id;
  String name;
  String? fieldType;
  String? operation;
  double? threshold;

  Rule({
    this.name = '',
    this.fieldType,
    this.operation,
    this.threshold,
  }) : id = UniqueKey().toString();

  /// Iinitialize a rule from a json object.
  Rule.fromJson(Map<String, dynamic> json)
      : id = json[kId] ?? '',
        name = json[kName] ?? '',
        fieldType = json[kFieldType],
        operation = json[kOperation],
        threshold = json[kThreshold] as double?;

  /// Convert a Rule object to json.
  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kName: name,
      kFieldType: fieldType,
      kOperation: operation,
      kThreshold: threshold,
    };
  }

  /// Encode a Rule object as a json string.
  String encode() {
    return jsonEncode(toJson());
  }

  /// Write this Rule object to the rules json file.
  void write(BuildContext context) {
    writeStatsRule(context, this);
  }

  /// Remove this Rule object from the rules json file.
  void remove(BuildContext context) {
    removeStatsRule(context, this);
  }

  /// Get the operation function for this rule.
  bool Function(dynamic lhs, dynamic rhs) get operationFunction {
    switch (operation) {
      case 'gt':
        return (lhs, rhs) => lhs > rhs;
      case 'lt':
        return (lhs, rhs) => lhs < rhs;
      case 'gte':
        return (lhs, rhs) => lhs >= rhs;
      case 'lte':
        return (lhs, rhs) => lhs <= rhs;
      default:
        return (lhs, rhs) => false;
    }
  }

  /// Get the adjustment function for this rule.
  dynamic Function(dynamic lhs, dynamic rhs) get adjustmentFunction {
    switch (operation) {
      case 'gt':
      case 'gte':
        return (lhs, rhs) => lhs - rhs;
      default:
        return (lhs, rhs) => lhs;
    }
  }
}
