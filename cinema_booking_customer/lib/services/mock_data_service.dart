import 'dart:async';

import '../models/movie.dart';
import '../models/time_slot.dart';
import '../models/booking.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<Movie> _movies = [];
  final List<Booking> _bookings = [];
  final _moviesController = StreamController<List<Movie>>.broadcast();
  final _bookingsController = StreamController<List<Booking>>.broadcast();

  Stream<List<Movie>> get moviesStream => _moviesController.stream;
  Stream<List<Booking>> get bookingsStream => _bookingsController.stream;

  void initialize() {
    // Add some sample movies for demo
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

  Movie? getMovie(String id) => _movies.firstWhere((m) => m.id == id);

  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    _notifyListeners();
  }

  void deleteMovie(String id) {
    _movies.removeWhere((m) => m.id == id);
    _notifyListeners();
  }

  Future<bool> bookSeats(
      String movieId, int timeSlotIndex, List<int> seats) async {
    final movie = _movies.firstWhere((m) => m.id == movieId);
    final slot = movie.timeSlots[timeSlotIndex];

    // Check if any seats already booked
    for (final seat in seats) {
      if (slot.bookedSeats.contains(seat)) {
        return false; // Booking failed
      }
    }

    // Book seats
    slot.bookedSeats.addAll(seats);

    // Save to booking history
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movieId: movieId,
      movieTitle: movie.title,
      timeSlot: slot.time,
      seats: List.from(seats),
      bookedAt: DateTime.now(),
    );
    _bookings.insert(0, booking);

    _notifyListeners();
    return true;
  }

  List<Booking> getBookings() => List.unmodifiable(_bookings);

  List<Movie> searchMovies(String query) {
    return _movies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _notifyListeners() {
    _moviesController.add(List.unmodifiable(_movies));
    _bookingsController.add(List.unmodifiable(_bookings));
  }

  void dispose() {
    _moviesController.close();
    _bookingsController.close();
  }
}
