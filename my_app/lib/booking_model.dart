import 'package:flutter/material.dart';

class Booking {
  final String location;
  final DateTime dateTime;
  final String userId;
  final RoomType roomType;
  final List<RoomFeature> features;

  Booking({
    required this.location,
    required this.dateTime,
    required this.userId,
    required this.roomType,
    this.features = const [],
  });
}

// Enum for room types
enum RoomType {
  quietRoom('Quiet Room', Icons.volume_off),
  conferenceRoom('Conference Room', Icons.groups),
  studyRoom('Study Room', Icons.menu_book);

  final String displayName;
  final IconData icon;
  
  const RoomType(this.displayName, this.icon);
}

// Enum for room features
enum RoomFeature {
  projector('Projector', Icons.video_file),
  whiteboard('Whiteboard', Icons.edit_square),
  videoConferencing('Video Conferencing', Icons.video_call),
  computerEquipment('Computer Equipment', Icons.computer);

  final String displayName;
  final IconData icon;
  
  const RoomFeature(this.displayName, this.icon);
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
  void deleteBooking(String location, DateTime dateTime, RoomType roomType) {
    _bookings.removeWhere(
      (booking) => booking.location == location && 
                  booking.dateTime == dateTime &&
                  booking.roomType == roomType
    );
  }
}