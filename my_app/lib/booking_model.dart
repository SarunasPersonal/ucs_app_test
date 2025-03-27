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
  quietRoom,
  conferenceRoom,
  studyRoom;

  String get displayName {
    switch (this) {
      case RoomType.quietRoom:
        return 'Quiet Room';
      case RoomType.conferenceRoom:
        return 'Conference Room';
      case RoomType.studyRoom:
        return 'Study Room';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomType.quietRoom:
        return Icons.volume_off;
      case RoomType.conferenceRoom:
        return Icons.groups;
      case RoomType.studyRoom:
        return Icons.menu_book;
    }
  }
}

// Enum for room features (expandable)
enum RoomFeature {
  projector,
  whiteboard,
  videoConferencing,
  computerEquipment;

  String get displayName {
    switch (this) {
      case RoomFeature.projector:
        return 'Projector';
      case RoomFeature.whiteboard:
        return 'Whiteboard';
      case RoomFeature.videoConferencing:
        return 'Video Conferencing';
      case RoomFeature.computerEquipment:
        return 'Computer Equipment';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomFeature.projector:
        return Icons.video_file;
      case RoomFeature.whiteboard:
        return Icons.edit_square;
      case RoomFeature.videoConferencing:
        return Icons.video_call;
      case RoomFeature.computerEquipment:
        return Icons.computer;
    }
  }
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