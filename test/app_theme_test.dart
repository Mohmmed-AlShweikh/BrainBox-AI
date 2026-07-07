import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainbox_ai/core/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme should be available and use light brightness', () {
    final theme = AppTheme.lightTheme;

    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.brightness, Brightness.light);
  });
}
