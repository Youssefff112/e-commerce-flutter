import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../services/mock_data_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;
  const MovieDetailScreen({required this.movieId, super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  int _selectedTimeSlot = 0;
  final Set<int> _selectedSeats = {};

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context, listen: false);

    return StreamBuilder<List<Movie>>(
      stream: dataService.moviesStream,
      builder: (context, snapshot) {
        final movie = dataService.getMovie(widget.movieId);
        if (movie == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Movie Details')),
            body: const Center(child: Text('Movie not found')),
          );
        }

        final bookedSeatsForSlot =
            movie.timeSlots[_selectedTimeSlot].bookedSeats;

        return Scaffold(
          appBar: AppBar(title: Text(movie.title)),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(movie.description,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time Slots
                  const Text('Select Time Slot:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: List.generate(movie.timeSlots.length, (i) {
                      final slot = movie.timeSlots[i];
                      final bookedCount = slot.bookedSeats.length;
                      return ChoiceChip(
                        label: Text('${slot.time}\n$bookedCount/47 booked',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12)),
                        selected: _selectedTimeSlot == i,
                        onSelected: (_) => setState(() {
                          _selectedTimeSlot = i;
                          _selectedSeats.clear();
                        }),
                        selectedColor: Colors.blue.shade200,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                          Colors.white, 'Available', Colors.black26),
                      _buildLegendItem(
                          Colors.green, 'Your Selection', Colors.green),
                      _buildLegendItem(Colors.grey, 'Booked', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Screen indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('SCREEN',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),

                  // Seats Grid
                  _buildSeatsGrid(bookedSeatsForSlot),
                  const SizedBox(height: 16),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () async {
                              final success = await dataService.bookSeats(
                                  widget.movieId,
                                  _selectedTimeSlot,
                                  _selectedSeats.toList());
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Successfully booked ${_selectedSeats.length} seat(s)!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setState(() => _selectedSeats.clear());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Booking failed! Some seats already taken.'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            },
                      icon: const Icon(Icons.check_circle),
                      label: Text('Book ${_selectedSeats.length} Seat(s)',
                          style: const TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, Color borderColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatsGrid(List<int> booked) {
    // Layout: Rows 1-4: 4 seats + aisle + 5 seats = 9 seats per row (36 total)
    // Last row: seats 37-47 (11 seats) without any gaps

    // Calculate responsive seat size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 32.0;
    final seatSize = ((screenWidth - padding) / 14)
        .clamp(24.0, 40.0); // Fit 11 seats + aisle + spacing
    final aisleWidth = seatSize * 1.8;
    final seatSpacing = seatSize * 0.12;
    return Column(
      children: [
        // Rows 1-4 with 4-gap-5 pattern
        ...List.generate(4, (rowIndex) {
          final startSeat = rowIndex * 9;
          return Padding(
            padding: EdgeInsets.only(bottom: seatSpacing * 1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left 4 seats
                ...List.generate(4, (colIndex) {
                  final seatIndex = startSeat + colIndex;
                  return _buildSeatWidget(
                      seatIndex, booked, seatSize, seatSpacing);
                }),
                // Aisle - width of 2 seats
                SizedBox(width: aisleWidth),
                // Right 5 seats
                ...List.generate(5, (colIndex) {
                  final seatIndex = startSeat + colIndex + 4;
                  return _buildSeatWidget(
                      seatIndex, booked, seatSize, seatSpacing);
                }),
              ],
            ),
          );
        }),
        // Last row: seats 37-47 (11 seats) no gaps
        Padding(
          padding: EdgeInsets.only(bottom: seatSpacing * 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(11, (colIndex) {
              final seatIndex = 36 + colIndex; // seats 37-47 (index 36-46)
              return _buildSeatWidget(seatIndex, booked, seatSize, seatSpacing);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatWidget(
      int index, List<int> booked, double seatSize, double seatSpacing) {
    final isBooked = booked.contains(index);
    final isSelected = _selectedSeats.contains(index);
    Color color;
    Color borderColor;

    if (isBooked) {
      color = Colors.grey.shade400;
      borderColor = Colors.grey.shade600;
    } else if (isSelected) {
      color = Colors.green.shade400;
      borderColor = Colors.green.shade700;
    } else {
      color = Colors.white;
      borderColor = Colors.blue.shade200;
    }

    return Padding(
      padding: EdgeInsets.only(right: seatSpacing),
      child: GestureDetector(
        onTap: isBooked
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedSeats.remove(index);
                  } else {
                    _selectedSeats.add(index);
                  }
                });
              },
        child: Container(
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: seatSize * 0.3,
                fontWeight: FontWeight.bold,
                color: isBooked ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
