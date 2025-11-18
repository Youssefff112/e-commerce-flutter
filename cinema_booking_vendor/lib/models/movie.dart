import 'time_slot.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String? imagePath;
  final List<TimeSlot> timeSlots;
  final DateTime createdAt;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    required this.timeSlots,
    required this.createdAt,
  });
}
