import 'package:flutter_test/flutter_test.dart';
import 'package:cinema_booking_vendor/services/mock_data_service.dart';
import 'package:cinema_booking_vendor/models/movie.dart';
import 'package:cinema_booking_vendor/models/time_slot.dart';

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

  test('MockDataService can add movies', () {
    final dataService = MockDataService();
    dataService.initialize();

    final initialCount = dataService.getMovies().length;

    // Create a new movie
    final testMovie = Movie(
      id: 'test-1',
      title: 'Test Movie',
      description: 'Test description',
      timeSlots: [
        TimeSlot(time: '12:00 PM', bookedSeats: []),
      ],
      createdAt: DateTime.now(),
    );

    // Add the movie
    dataService.addMovie(testMovie);

    // Verify movie was added
    final movies = dataService.getMovies();
    expect(movies.length, initialCount + 1);
    expect(movies.any((m) => m.title == 'Test Movie'), true);
  });
}
