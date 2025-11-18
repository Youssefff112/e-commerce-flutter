import 'package:flutter_test/flutter_test.dart';
import 'package:cinema_booking_customer/services/mock_data_service.dart';
import 'package:cinema_booking_customer/services/auth_service.dart';

void main() {
  test('MockDataService singleton works correctly', () {
    final instance1 = MockDataService();
    final instance2 = MockDataService();

    // Both should reference the same instance
    expect(identical(instance1, instance2), true);
  });

  test('MockDataService initializes with movies', () {
    final dataService = MockDataService();
    dataService.initialize();

    // Verify initial movies exist
    final movies = dataService.getMovies();
    expect(movies.isNotEmpty, true);
    expect(movies.length, greaterThan(0));
  });

  test('AuthService singleton works correctly', () {
    final instance1 = AuthService();
    final instance2 = AuthService();

    // Both should reference the same instance
    expect(identical(instance1, instance2), true);
  });

  test('AuthService isLoggedIn returns correct state', () {
    final authService = AuthService();

    // Check the getter works and returns a boolean
    final loggedIn = authService.isLoggedIn;
    expect(loggedIn, isA<bool>());
  });
}
