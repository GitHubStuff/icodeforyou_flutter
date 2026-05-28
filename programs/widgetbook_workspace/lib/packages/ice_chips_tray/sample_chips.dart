// packages/ice_chips_tray/widgetbook/usecases/_sample_chips.dart
import 'package:flutter/material.dart';
import 'package:ice_chips/ice_chips.dart' show IceChipData;

/// Sample chip data for tray usecases — kept in one place so each
/// layout usecase exercises the same dataset.
final List<IceChipData> sampleChips = [
  IceChipData(id: 1, label: 'Coffee', colorInt: Colors.brown.toARGB32()),
  IceChipData(id: 2, label: 'Tea', colorInt: Colors.green.toARGB32()),
  IceChipData(id: 3, label: 'Water', colorInt: Colors.blue.toARGB32()),
  IceChipData(id: 4, label: 'Juice', colorInt: Colors.orange.toARGB32()),
  IceChipData(id: 5, label: 'Milk', colorInt: Colors.grey.toARGB32()),
  IceChipData(id: 6, label: 'Soda', colorInt: Colors.red.toARGB32()),
  IceChipData(id: 7, label: 'Wine', colorInt: Colors.purple.toARGB32()),
  IceChipData(id: 8, label: 'Beer', colorInt: Colors.amber.toARGB32()),
  IceChipData(id: 9, label: 'Whiskey', colorInt: Colors.deepOrange.toARGB32()),
  IceChipData(id: 10, label: 'Vodka', colorInt: Colors.blueGrey.toARGB32()),
  IceChipData(id: 11, label: 'Rum', colorInt: Colors.deepPurple.toARGB32()),
  IceChipData(id: 12, label: 'Gin', colorInt: Colors.teal.toARGB32()),
];
