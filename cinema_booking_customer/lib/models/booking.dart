class Booking {
  final String id;
  final String movieId;
  final String movieTitle;
  final String timeSlot;
  final List<int> seats;
  final DateTime bookedAt;

  Booking({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.timeSlot,
    required this.seats,
    required this.bookedAt,
  });
}
