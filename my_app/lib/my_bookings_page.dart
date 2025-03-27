import 'package:flutter/material.dart';
import 'package:flutter_ucs_app/constants.dart';
import 'package:flutter_ucs_app/booking_model.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final BookingService _bookingService = BookingService();
  late List<Booking> userBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    if (CurrentUser.userId != null) {
      userBookings = _bookingService.getUserBookings(CurrentUser.userId!);
    } else {
      userBookings = [];
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
  }

  IconData _getIconForLocation(String location) {
    switch (location) {
      case 'Taunton':
        return Icons.school;
      case 'Bridgwater':
        return Icons.account_balance;
      case 'Cannington':
        return Icons.park;
      default:
        return Icons.location_on;
    }
  }

  void _deleteBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('NO', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _bookingService.deleteBooking(booking.location, booking.dateTime);
                Navigator.of(context).pop();
                setState(() {
                  _loadBookings();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('YES', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(color: primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userBookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No bookings found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You haven\'t made any bookings yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Book Now',
                        style: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: userBookings.length,
                itemBuilder: (context, index) {
                  final booking = userBookings[index];
                  final formattedDateTime = _formatDateTime(booking.dateTime);
                  final isUpcoming = booking.dateTime.isAfter(DateTime.now());
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isUpcoming ? primaryColor.withAlpha(77) : Colors.grey.withAlpha(77), // 0.3 opacity
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isUpcoming
                                      ? primaryColor.withAlpha(26) // 0.1 opacity
                                      : Colors.grey.withAlpha(26), // 0.1 opacity
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getIconForLocation(booking.location),
                                  color: isUpcoming ? primaryColor : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${booking.location} Campus',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isUpcoming ? primaryColor : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDateTime,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isUpcoming ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUpcoming)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteBooking(booking),
                                ),
                            ],
                          ),
                          if (isUpcoming) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(26), // 0.1 opacity
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Upcoming Booking',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(26), // 0.1 opacity
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Past Booking',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: userBookings.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.add, color: secondaryColor),
            )
          : null,
    );
  }
}