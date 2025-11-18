class BookingNotification {
  final String movieTitle;
  final int seatsBooked;
  final int totalSeats;
  final DateTime timestamp;
  final String movieId;

  BookingNotification({
    required this.movieTitle,
    required this.seatsBooked,
    required this.totalSeats,
    required this.timestamp,
    required this.movieId,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<BookingNotification> _notifications = [];

  List<BookingNotification> get notifications =>
      List.unmodifiable(_notifications);

  void addNotification(BookingNotification notification) {
    _notifications.insert(0, notification); // Newest first
  }

  void clearAll() {
    _notifications.clear();
  }
}
