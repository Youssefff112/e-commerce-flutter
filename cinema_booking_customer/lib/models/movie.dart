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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imagePath': imagePath,
        'timeSlots': timeSlots.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        imagePath: json['imagePath'],
        timeSlots: (json['timeSlots'] as List)
            .map((e) => TimeSlot.fromJson(e))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
