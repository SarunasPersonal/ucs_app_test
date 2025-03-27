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
  
  // Room selection
  RoomType _selectedRoomType = RoomType.quietRoom;
  final Map<RoomFeature, bool> _selectedFeatures = {
    RoomFeature.projector: false,
    RoomFeature.whiteboard: false,
    RoomFeature.videoConferencing: false,
    RoomFeature.computerEquipment: false,
  };

  // Focus nodes for improved keyboard navigation
  final FocusNode _roomTypeFocusNode = FocusNode();
  final FocusNode _featuresFocusNode = FocusNode();
  final FocusNode _dateTimeFocusNode = FocusNode();
  final FocusNode _confirmButtonFocusNode = FocusNode();

  @override
  void dispose() {
    _roomTypeFocusNode.dispose();
    _featuresFocusNode.dispose();
    _dateTimeFocusNode.dispose();
    _confirmButtonFocusNode.dispose();
    super.dispose();
  }

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
          // Wrap DatePicker with Semantics for screen readers
          child: Semantics(
            label: 'Date picker for booking',
            hint: 'Select a date for your booking',
            child: child!,
          ),
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
            // Wrap TimePicker with Semantics for screen readers
            child: Semantics(
              label: 'Time picker for booking',
              hint: 'Select a time for your booking',
              child: child!,
            ),
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
        
        // Announce the selected date and time for screen reader users
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected date and time: $formattedDateTime'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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

    // Get list of selected features
    final List<RoomFeature> features = _selectedFeatures.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: SingleChildScrollView(
            child: Semantics(
              label: 'Booking confirmation details',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Are you sure you want to book a '),
                        TextSpan(
                          text: _selectedRoomType.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        const TextSpan(text: ' at '),
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
                  
                  if (features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'With the following features:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Semantics(
                        label: feature.displayName,
                        child: Row(
                          children: [
                            Icon(feature.icon, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(feature.displayName),
                          ],
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel button',
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
              ),
            ),
            Semantics(
              button: true,
              label: 'Confirm button',
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _confirmBooking();
                },
                child: const Text('CONFIRM', style: TextStyle(color: primaryColor)),
              ),
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
      // Get list of selected features
      final List<RoomFeature> features = _selectedFeatures.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
          
      // Create a new booking
      final newBooking = Booking(
        location: widget.location,
        dateTime: selectedDateTime!,
        userId: CurrentUser.userId ?? 'unknown',
        roomType: _selectedRoomType,
        features: features,
      );
      
      _bookingService.addBooking(newBooking);
      
      // Check if state is still mounted before using its context
      if (!mounted) return;
      
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedRoomType.displayName} booking confirmed at ${widget.location} on $formattedDateTime'),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Semantics(
            label: 'Help dialog',
            child: const Text('Booking Help'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'How to book a room:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildHelpItem('1. Select a room type (Quiet Room, Conference Room, or Study Room)'),
                _buildHelpItem('2. Choose required features for your room (for Conference and Study rooms)'),
                _buildHelpItem('3. Select a date and time for your booking'),
                _buildHelpItem('4. Review and confirm your booking details'),
                const SizedBox(height: 10),
                const Text(
                  'Accessibility Features:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildHelpItem('• All elements are labeled for screen readers'),
                _buildHelpItem('• Use your device\'s screen reader to navigate through the booking process'),
                _buildHelpItem('• Keyboard navigation is fully supported'),
              ],
            ),
          ),
          actions: <Widget>[
            Semantics(
              button: true,
              label: 'Close help dialog',
              child: TextButton(
                child: const Text('CLOSE'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back button',
          hint: 'Return to previous screen',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Booking - ${widget.location}',
          style: const TextStyle(color: primaryColor),
        ),
        actions: [
          // Help button for screen reader users
          Semantics(
            button: true,
            label: 'Help button',
            hint: 'Get help with booking process',
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: primaryColor),
              onPressed: _showHelpDialog,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campus image placeholder
              Semantics(
                label: '${widget.location} Campus image',
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: ExcludeSemantics( // Exclude decorative icon from screen reader
                      child: Icon(
                        _getIconForLocation(widget.location),
                        color: primaryColor,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Location',
                child: Text(
                  '${widget.location} Campus',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                label: 'Address',
                child: Text(
                  _getAddressForLocation(widget.location),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Room Type Selection
              Semantics(
                header: true,
                label: 'Room Type Selection Section',
                child: const Text(
                  'Select Room Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              Focus(
                focusNode: _roomTypeFocusNode,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<RoomType>(
                        title: Semantics(
                          label: 'Quiet Room option',
                          child: Row(
                            children: [
                              Icon(RoomType.quietRoom.icon, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(RoomType.quietRoom.displayName),
                            ],
                          ),
                        ),
                        subtitle: const Text('Individual space for focused work'),
                        value: RoomType.quietRoom,
                        groupValue: _selectedRoomType,
                        activeColor: primaryColor,
                        onChanged: (RoomType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRoomType = value;
                              // Clear features when switching to quiet room
                              if (value == RoomType.quietRoom) {
                                _resetFeatures();
                              }
                            });
                            
                            // Announce selection for screen readers
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${value.displayName}'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                      
                      RadioListTile<RoomType>(
                        title: Semantics(
                          label: 'Conference Room option',
                          child: Row(
                            children: [
                              Icon(RoomType.conferenceRoom.icon, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(RoomType.conferenceRoom.displayName),
                            ],
                          ),
                        ),
                        subtitle: const Text('Meeting space for groups'),
                        value: RoomType.conferenceRoom,
                        groupValue: _selectedRoomType,
                        activeColor: primaryColor,
                        onChanged: (RoomType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRoomType = value;
                            });
                            
                            // Announce selection for screen readers
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${value.displayName}'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                      
                      RadioListTile<RoomType>(
                        title: Semantics(
                          label: 'Study Room option',
                          child: Row(
                            children: [
                              Icon(RoomType.studyRoom.icon, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(RoomType.studyRoom.displayName),
                            ],
                          ),
                        ),
                        subtitle: const Text('Collaborative space for study groups'),
                        value: RoomType.studyRoom,
                        groupValue: _selectedRoomType,
                        activeColor: primaryColor,
                        onChanged: (RoomType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRoomType = value;
                            });
                            
                            // Announce selection for screen readers
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${value.displayName}'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Room Features (only visible for conference and study rooms)
              if (_selectedRoomType != RoomType.quietRoom) ...[
                const SizedBox(height: 25),
                Semantics(
                  header: true,
                  label: 'Room Features Section',
                  child: const Text(
                    'Room Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                Focus(
                  focusNode: _featuresFocusNode,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Semantics(
                            label: 'Projector feature',
                            child: Row(
                              children: [
                                Icon(RoomFeature.projector.icon, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(RoomFeature.projector.displayName),
                              ],
                            ),
                          ),
                          value: _selectedFeatures[RoomFeature.projector],
                          activeColor: primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _selectedFeatures[RoomFeature.projector] = value;
                              });
                              
                              // Announce change for screen readers
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value 
                                    ? 'Added Projector' 
                                    : 'Removed Projector'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        
                        CheckboxListTile(
                          title: Semantics(
                            label: 'Whiteboard feature',
                            child: Row(
                              children: [
                                Icon(RoomFeature.whiteboard.icon, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(RoomFeature.whiteboard.displayName),
                              ],
                            ),
                          ),
                          value: _selectedFeatures[RoomFeature.whiteboard],
                          activeColor: primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _selectedFeatures[RoomFeature.whiteboard] = value;
                              });
                              
                              // Announce change for screen readers
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value 
                                    ? 'Added Whiteboard' 
                                    : 'Removed Whiteboard'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        
                        CheckboxListTile(
                          title: Semantics(
                            label: 'Video conferencing feature',
                            child: Row(
                              children: [
                                Icon(RoomFeature.videoConferencing.icon, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(RoomFeature.videoConferencing.displayName),
                              ],
                            ),
                          ),
                          value: _selectedFeatures[RoomFeature.videoConferencing],
                          activeColor: primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _selectedFeatures[RoomFeature.videoConferencing] = value;
                              });
                              
                              // Announce change for screen readers
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value 
                                    ? 'Added Video Conferencing' 
                                    : 'Removed Video Conferencing'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        
                        CheckboxListTile(
                          title: Semantics(
                            label: 'Computer equipment feature',
                            child: Row(
                              children: [
                                Icon(RoomFeature.computerEquipment.icon, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(RoomFeature.computerEquipment.displayName),
                              ],
                            ),
                          ),
                          value: _selectedFeatures[RoomFeature.computerEquipment],
                          activeColor: primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _selectedFeatures[RoomFeature.computerEquipment] = value;
                              });
                              
                              // Announce change for screen readers
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value 
                                    ? 'Added Computer Equipment' 
                                    : 'Removed Computer Equipment'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              Semantics(
                header: true,
                label: 'Date and Time Selection Section',
                child: const Text(
                  'Select Date & Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
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
              Focus(
                focusNode: _dateTimeFocusNode,
                child: Semantics(
                  button: true,
                  label: 'Select date and time button',
                  hint: 'Tap to open date and time pickers',
                  child: ElevatedButton.icon(
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
                ),
              ),
              if (selectedDateTime != null) ...[
                const SizedBox(height: 30),
                Semantics(
                  header: true,
                  label: 'Selected Date and Time Section',
                  child: const Text(
                    'Selected Date & Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Currently selected date and time',
                  value: formattedDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor.withAlpha(128)),
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
                ),
              ],
              const SizedBox(height: 40),
              Focus(
                focusNode: _confirmButtonFocusNode,
                child: Semantics(
                  button: true,
                  label: 'Confirm booking button',
                  hint: 'Tap to review and confirm your booking details',
                  enabled: !_isLoading,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: secondaryColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : _showConfirmationDialog,
                    label: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: secondaryColor,
                              strokeWidth: 2,
                              semanticsLabel: 'Loading indicator',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _resetFeatures() {
    _selectedFeatures.forEach((key, value) {
      _selectedFeatures[key] = false;
    });
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