class Booking {
  final String location;
  final DateTime dateTime;
  final String userId;

  Booking({
    required this.location,
    required this.dateTime,
    required this.userId,
  });
}

// Simple in-memory storage for bookings
class BookingService {
  // Singleton pattern
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<Booking> _bookings = [];

  // Add a new booking
  void addBooking(Booking booking) {
    _bookings.add(booking);
  }

  // Get all bookings
  List<Booking> getAllBookings() {
    return List.from(_bookings);
  }

  // Get bookings for a specific user
  List<Booking> getUserBookings(String userId) {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }
  
  // Delete a booking by matching date and location
  void deleteBooking(String location, DateTime dateTime) {
    _bookings.removeWhere(
      (booking) => booking.location == location && booking.dateTime == dateTime
    );
  }
}