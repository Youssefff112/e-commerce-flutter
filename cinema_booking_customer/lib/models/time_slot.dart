class TimeSlot {
  final String time;
  final List<int> bookedSeats;

  TimeSlot({required this.time, required this.bookedSeats});

  Map<String, dynamic> toJson() => {'time': time, 'bookedSeats': bookedSeats};

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        time: json['time'],
        bookedSeats: List<int>.from(json['bookedSeats']),
      );
}
