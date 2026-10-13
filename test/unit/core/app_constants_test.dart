import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/core/constants/app_constants.dart';
import 'package:wall_gem/core/errors/failure.dart';

void main() {
  test('AppConstants contains expected categories and paths', () {
    expect(AppConstants.appName, equals('Wall Gem'));
    expect(AppConstants.categories, contains('All'));
    expect(AppConstants.categories, contains('Landscape'));
    expect(AppConstants.batchTarget, equals(5));
  });

  test('Failure classes preserve messages', () {
    const failure = NetworkFailure('Connection refused');
    expect(failure.message, equals('Connection refused'));
  });
}
