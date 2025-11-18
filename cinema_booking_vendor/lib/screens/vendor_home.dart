import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/movie.dart';
import '../models/time_slot.dart';
import '../services/mock_data_service.dart';
import '../services/notification_service.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _time1Ctl = TextEditingController(text: '12:00 PM');
  final _time2Ctl = TextEditingController(text: '15:00 PM');
  final _time3Ctl = TextEditingController(text: '18:00 PM');
  final _searchController = TextEditingController();
  XFile? _pickedImage;
  int _previousTotalBookings = 0;
  String _searchQuery = '';
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    final dataService = Provider.of<MockDataService>(context, listen: false);

    // Calculate initial total bookings
    _previousTotalBookings = _getTotalBookings(dataService);

    // Listen for booking changes and show notifications
    dataService.moviesStream.listen((movies) {
      if (!mounted) return;
      final currentTotal = _getTotalBookings(dataService);

      if (currentTotal > _previousTotalBookings) {
        final newBookings = currentTotal - _previousTotalBookings;
        _showBookingNotification(newBookings, currentTotal);
      }
      _previousTotalBookings = currentTotal;
    });
  }

  int _getTotalBookings(MockDataService service) {
    return service.getMovies().fold<int>(
        0, (sum, movie) => sum + service.getTotalBookedSeats(movie.id));
  }

  void _showNotificationPanel() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications,
                      color: Colors.purple.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Text('Booking Notifications',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: _notificationService.notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No notifications yet',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notificationService.notifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              _notificationService.notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Icon(Icons.event_seat,
                                    color: Colors.purple.shade700),
                              ),
                              title: Text(notification.movieTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${notification.seatsBooked} seat(s) booked • Total: ${notification.totalSeats} seats'),
                              trailing: Text(
                                _formatTime(notification.timestamp),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_notificationService.notifications.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() => _notificationService.clearAll());
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showBookingNotification(int newBookings, int totalBookings) {
    final dataService = Provider.of<MockDataService>(context, listen: false);
    final movies = dataService.getMovies();
    final latestMovie = movies.isNotEmpty ? movies.first : null;

    if (latestMovie != null) {
      _notificationService.addNotification(
        BookingNotification(
          movieTitle: latestMovie.title,
          seatsBooked: newBookings,
          totalSeats: totalBookings,
          timestamp: DateTime.now(),
          movieId: latestMovie.id,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Booking!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                      '$newBookings seat(s) just booked • Total: $totalBookings seats'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => _showNotificationPanel(),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() => _pickedImage = img);
  }

  void _addMovie() {
    if (!_formKey.currentState!.validate()) return;

    final dataService = Provider.of<MockDataService>(context, listen: false);
    final timeSlots = <TimeSlot>[];

    if (_time1Ctl.text.isNotEmpty)
      timeSlots.add(TimeSlot(time: _time1Ctl.text, bookedSeats: []));
    if (_time2Ctl.text.isNotEmpty)
      timeSlots.add(TimeSlot(time: _time2Ctl.text, bookedSeats: []));
    if (_time3Ctl.text.isNotEmpty)
      timeSlots.add(TimeSlot(time: _time3Ctl.text, bookedSeats: []));

    if (timeSlots.isEmpty) {
      timeSlots.add(TimeSlot(time: '18:00 PM', bookedSeats: []));
    }

    final movie = Movie(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      imagePath: _pickedImage?.path,
      timeSlots: timeSlots,
      createdAt: DateTime.now(),
    );

    dataService.addMovie(movie);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Movie added successfully!'),
          backgroundColor: Colors.green),
    );

    _titleCtl.clear();
    _descCtl.clear();
    _time1Ctl.text = '12:00 PM';
    _time2Ctl.text = '15:00 PM';
    _time3Ctl.text = '18:00 PM';
    setState(() => _pickedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Vendor Dashboard'),
        elevation: 2,
      ),
      body: Row(
        children: [
          // Left Panel - Add Movie
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add New Movie',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleCtl,
                        decoration: InputDecoration(
                          labelText: 'Movie Title *',
                          prefixIcon: const Icon(Icons.movie),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtl,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Time Slots (up to 3):',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _time1Ctl,
                        decoration: InputDecoration(
                          labelText: 'Time Slot 1',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _time2Ctl,
                        decoration: InputDecoration(
                          labelText: 'Time Slot 2',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _time3Ctl,
                        decoration: InputDecoration(
                          labelText: 'Time Slot 3',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_pickedImage != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Image selected'),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _pickedImage = null),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _addMovie,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Movie',
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right Panel - Movies List
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 4)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_filter, size: 28),
                      const SizedBox(width: 12),
                      const Text('Movies & Bookings',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: Badge(
                          label: Text(
                              '${_notificationService.notifications.length}'),
                          isLabelVisible:
                              _notificationService.notifications.isNotEmpty,
                          child: const Icon(Icons.notifications),
                        ),
                        onPressed: _showNotificationPanel,
                        tooltip: 'View Notifications',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search movies',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Movie>>(
                    stream: dataService.moviesStream,
                    initialData: dataService.getMovies(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.movie_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No movies yet',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                              SizedBox(height: 8),
                              Text('Add your first movie!',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      var movies = snapshot.data!;

                      // Filter movies by search query
                      if (_searchQuery.isNotEmpty) {
                        movies = movies
                            .where((m) => m.title
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                            .toList();
                      }

                      if (movies.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No movies found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final totalBooked =
                              dataService.getTotalBookedSeats(movie.id);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.purple.shade100,
                                child: Icon(Icons.movie,
                                    color: Colors.purple.shade700, size: 32),
                              ),
                              title: Text(movie.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(movie.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: totalBooked > 20
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$totalBooked/47 seats booked',
                                          style: TextStyle(
                                            color: totalBooked > 20
                                                ? Colors.green.shade900
                                                : Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                          '${movie.timeSlots.length} time slots',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blue),
                                    onPressed: () => _showSeatsDialog(movie),
                                    tooltip: 'View seats',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteMovie(movie.id),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMovie(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Movie'),
        content: const Text('Are you sure you want to delete this movie?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final dataService =
                  Provider.of<MockDataService>(context, listen: false);
              dataService.deleteMovie(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Movie deleted'),
                    backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSeatsDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (_) => _SeatsDialogWidget(movie: movie),
    );
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _time1Ctl.dispose();
    _time2Ctl.dispose();
    _time3Ctl.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _SeatsDialogWidget extends StatefulWidget {
  final Movie movie;

  const _SeatsDialogWidget({required this.movie});

  @override
  State<_SeatsDialogWidget> createState() => _SeatsDialogWidgetState();
}

class _SeatsDialogWidgetState extends State<_SeatsDialogWidget> {
  int _selectedSlotIndex = 0;

  @override
  Widget build(BuildContext context) {
    final slot = widget.movie.timeSlots[_selectedSlotIndex];

    return AlertDialog(
      title: Text('${widget.movie.title} - Bookings'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // Time slot tabs
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.movie.timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = widget.movie.timeSlots[index];
                  final isSelected = index == _selectedSlotIndex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSlotIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.purple.shade700
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple.shade900
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              timeSlot.time,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${timeSlot.bookedSeats.length}/47',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Selected time slot info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${slot.time}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                  Text(
                    '${slot.bookedSeats.length} seats booked',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Seat grid for selected time slot
            Expanded(
              child: SingleChildScrollView(
                child: _buildSeatsGridForSlot(slot.bookedSeats),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSeatsGridForSlot(List<int> bookedSeats) {
    return Column(
      children: [
        // Rows 1-4 with 4-gap-5 pattern
        ...List.generate(4, (rowIndex) {
          final startSeat = rowIndex * 9;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left 4 seats
                ...List.generate(4, (colIndex) {
                  final seatIndex = startSeat + colIndex;
                  return _buildSeatWidget(seatIndex, bookedSeats);
                }),
                // Aisle - width of 2 seats
                const SizedBox(width: 88),
                // Right 5 seats
                ...List.generate(5, (colIndex) {
                  final seatIndex = startSeat + colIndex + 4;
                  return _buildSeatWidget(seatIndex, bookedSeats);
                }),
              ],
            ),
          );
        }),
        // Last row: seats 37-47 (11 seats) no gaps
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(11, (colIndex) {
              final seatIndex = 36 + colIndex;
              return _buildSeatWidget(seatIndex, bookedSeats);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatWidget(int index, List<int> bookedSeats) {
    final isBooked = bookedSeats.contains(index);

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isBooked ? Colors.grey.shade400 : Colors.white,
          border: Border.all(
            color: isBooked ? Colors.grey.shade600 : Colors.blue.shade200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isBooked ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
