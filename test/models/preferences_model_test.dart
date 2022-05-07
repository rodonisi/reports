import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:reports/models/preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_model_test.mocks.dart';

class MockNotifyCallback extends Mock {
  call();
}

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockNotifyCallback mockNotifyCallback;
  late PreferencesModel target;
  setUpAll(() {
    mockSharedPreferences = MockSharedPreferences();
    mockNotifyCallback = MockNotifyCallback();
    target = PreferencesModel(mockSharedPreferences);
    target.addListener(mockNotifyCallback);
  });

  tearDownAll(() {
    reset(mockSharedPreferences);
    reset(mockNotifyCallback);
  });

  test('initialize', () async {
    WidgetsFlutterBinding.ensureInitialized();
    await target.initialize();
    verify(mockNotifyCallback.call());
  });

  group('getters', () {
    group('getBol', () {
      test('returns value', () {
        final expectedValue = true;
        when(mockSharedPreferences.getBool(any)).thenReturn(expectedValue);

        final value = target.getBool('test');

        verify(mockSharedPreferences.getBool('test'));
        expect(value, expectedValue);
      });
      test('returns default', () {
        final expectedValue = true;
        when(mockSharedPreferences.getBool(any)).thenReturn(null);
        when(mockSharedPreferences.setBool(any, any))
            .thenAnswer((_) async => true);

        final value = target.getBool('test', defaultValue: expectedValue);

        verify(mockSharedPreferences.getBool('test'));
        verifyNever(mockSharedPreferences.setBool('test', expectedValue));
        expect(value, expectedValue);
      });

      test('ensure initialized', () {
        final expectedValue = true;
        when(mockSharedPreferences.getBool(any)).thenReturn(null);
        when(mockSharedPreferences.setBool(any, any))
            .thenAnswer((_) async => true);

        final value = target.getBool('test',
            defaultValue: expectedValue, ensureInitialized: true);

        verify(mockSharedPreferences.getBool('test'));
        verify(mockSharedPreferences.setBool('test', expectedValue));
        expect(value, expectedValue);
      });
    });

    group('getInt', () {
      test('returns value', () {
        final expectedValue = 1;
        when(mockSharedPreferences.getInt(any)).thenReturn(expectedValue);

        final value = target.getInt('test');

        verify(mockSharedPreferences.getInt('test'));
        expect(value, expectedValue);
      });
      test('returns default', () {
        final expectedValue = 1;
        when(mockSharedPreferences.getInt(any)).thenReturn(null);
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        final value = target.getInt('test', defaultValue: expectedValue);

        verify(mockSharedPreferences.getInt('test'));
        verifyNever(mockSharedPreferences.setInt('test', expectedValue));
        expect(value, expectedValue);
      });
      test('returns default', () {
        final expectedValue = 1;
        when(mockSharedPreferences.getInt(any)).thenReturn(null);
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        final value = target.getInt(
          'test',
          defaultValue: expectedValue,
          ensureInitialized: true,
        );

        verify(mockSharedPreferences.getInt('test'));
        verify(mockSharedPreferences.setInt('test', expectedValue));
        expect(value, expectedValue);
      });
    });

    group('getString', () {
      test('returns value', () {
        final expectedValue = 'test';
        when(mockSharedPreferences.getString(any)).thenReturn(expectedValue);

        final value = target.getString('test');

        verify(mockSharedPreferences.getString('test'));
        expect(value, expectedValue);
      });
      test('returns default', () {
        final expectedValue = 'test';
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final value = target.getString('test', defaultValue: expectedValue);

        verify(mockSharedPreferences.getString('test'));
        verifyNever(mockSharedPreferences.setString('test', expectedValue));
        expect(value, expectedValue);
      });
      test('ensure initialized', () {
        final expectedValue = 'test';
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final value = target.getString(
          'test',
          defaultValue: expectedValue,
          ensureInitialized: true,
        );

        verify(mockSharedPreferences.getString('test'));
        verify(mockSharedPreferences.setString('test', expectedValue));
        expect(value, expectedValue);
      });
    });
  });

  group('setters', () {
    group('setBol', () {
      test('successful', () async {
        final expectedValue = true;
        when(mockSharedPreferences.setBool(any, any))
            .thenAnswer((_) async => true);

        await target.setBool('test', expectedValue);

        verify(mockSharedPreferences.setBool('test', expectedValue));
        verify(mockNotifyCallback.call());
      });
      test('throws', () {
        final expectedValue = true;
        when(mockSharedPreferences.setBool(any, any))
            .thenAnswer((_) async => false);

        expect(() async => await target.setBool('test', expectedValue),
            throwsException);
        verifyNever(mockNotifyCallback.call());
      });
    });

    group('setInt', () {
      test('successful', () async {
        final expectedValue = 1;
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => true);

        await target.setInt('test', expectedValue);

        verify(mockSharedPreferences.setInt('test', expectedValue));
        verify(mockNotifyCallback.call());
      });
      test('throws', () {
        final expectedValue = 1;
        when(mockSharedPreferences.setInt(any, any))
            .thenAnswer((_) async => false);

        expect(() async => await target.setInt('test', expectedValue),
            throwsException);
        verifyNever(mockNotifyCallback.call());
      });
    });

    group('setString', () {
      test('successful', () async {
        final expectedValue = 'test';
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        await target.setString('test', expectedValue);

        verify(mockSharedPreferences.setString('test', expectedValue));
        verify(mockNotifyCallback.call());
      });
      test('throws', () {
        final expectedValue = 'test';
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => false);

        expect(() async => await target.setString('test', expectedValue),
            throwsException);
        verifyNever(mockNotifyCallback.call());
      });
    });
  });
}
