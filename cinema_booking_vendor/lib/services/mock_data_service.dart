import 'dart:async';

import '../models/movie.dart';
import '../models/time_slot.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<Movie> _movies = [];
  final _moviesController = StreamController<List<Movie>>.broadcast();

  Stream<List<Movie>> get moviesStream => _moviesController.stream;

  void initialize() {
    // Start with some sample movies
    _movies.addAll([
      Movie(
        id: '1',
        title: 'Avengers: Endgame',
        description: 'Epic conclusion to the Infinity Saga',
        timeSlots: [
          TimeSlot(time: '12:00 PM', bookedSeats: [5, 12, 23]),
          TimeSlot(time: '15:30 PM', bookedSeats: [8]),
          TimeSlot(time: '18:00 PM', bookedSeats: []),
          TimeSlot(time: '21:00 PM', bookedSeats: [1, 2, 3]),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Movie(
        id: '2',
        title: 'The Dark Knight',
        description: 'Batman faces the Joker in Gotham City',
        timeSlots: [
          TimeSlot(time: '14:00 PM', bookedSeats: [15, 16]),
          TimeSlot(time: '19:00 PM', bookedSeats: []),
          TimeSlot(time: '22:00 PM', bookedSeats: [7, 8, 9, 10]),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
    _notifyListeners();
  }

  List<Movie> getMovies() => List.unmodifiable(_movies);

  Movie? getMovie(String id) {
    try {
      return _movies.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    _notifyListeners();
  }

  void deleteMovie(String id) {
    _movies.removeWhere((m) => m.id == id);
    _notifyListeners();
  }

  int getTotalBookedSeats(String movieId) {
    final movie = getMovie(movieId);
    if (movie == null) return 0;
    return movie.timeSlots
        .fold<int>(0, (sum, slot) => sum + slot.bookedSeats.length);
  }

  void _notifyListeners() {
    _moviesController.add(List.unmodifiable(_movies));
  }

  void dispose() {
    _moviesController.close();
  }
}
