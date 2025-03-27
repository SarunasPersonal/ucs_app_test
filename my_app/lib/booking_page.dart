import 'package:flutter/material.dart';
import 'package:flutter_ucs_app/constants.dart';
import 'package:flutter_ucs_app/booking_model.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String location;

  const BookingPage(this.location, {super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDateTime;
  String? formattedDateTime;
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  void _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: secondaryColor,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    // Check if the provided context is still mounted
    if (!context.mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor,
                onPrimary: secondaryColor,
                onSurface: primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      // Check again if context is still mounted after second async operation
      if (!context.mounted) return;

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        setState(() {
          selectedDateTime = newDateTime;
          formattedDateTime = _formatDateTime(newDateTime);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
  }

  void _showConfirmationDialog() {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                const TextSpan(text: 'Are you sure you want to book '),
                TextSpan(
                  text: widget.location,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const TextSpan(text: ' for '),
                TextSpan(
                  text: formattedDateTime,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmBooking();
              },
              child: const Text('CONFIRM', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a new booking
      final newBooking = Booking(
        location: widget.location,
        dateTime: selectedDateTime!,
        userId: CurrentUser.userId ?? 'unknown',
      );
      
      _bookingService.addBooking(newBooking);
      
      // Check if state is still mounted before using its context
      if (!mounted) return;
      
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed for ${widget.location} on $formattedDateTime'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to the home page after successful booking
      Future.delayed(const Duration(seconds: 2), () {
        // Check again if state is still mounted
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      // Check if state is still mounted before showing error
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Check mounted state before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking - ${widget.location}',
          style: const TextStyle(color: primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campus image placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(26), // 0.1 opacity is roughly alpha 26
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getIconForLocation(widget.location),
                    color: primaryColor,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${widget.location} Campus',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getAddressForLocation(widget.location),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please select a date and time for your appointment:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, color: secondaryColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => _selectDateTime(context),
                label: Text(
                  selectedDateTime == null ? 'Select Date & Time' : 'Change Date & Time',
                  style: const TextStyle(color: secondaryColor),
                ),
              ),
              if (selectedDateTime != null) ...[
                const SizedBox(height: 30),
                const Text(
                  'Selected Date & Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26), // 0.1 opacity
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor.withAlpha(128)), // 0.5 opacity
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available, color: primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          formattedDateTime!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: secondaryColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _showConfirmationDialog,
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: secondaryColor,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
  
  String _getAddressForLocation(String location) {
    switch (location) {
      case 'Taunton':
        return 'Wellington Road, Taunton, TA1 5AX';
      case 'Bridgwater':
        return 'Bath Road, Bridgwater, TA6 4PZ';
      case 'Cannington':
        return 'Rodway, Cannington, Bridgwater, TA5 2LS';
      default:
        return '';
    }
  }
}