import 'package:flutter/material.dart';
import 'package:flutter_ucs_app/constants.dart';
import 'package:flutter_ucs_app/booking_page.dart';
import 'package:flutter_ucs_app/login_screen.dart';
import 'package:flutter_ucs_app/my_bookings_page.dart';
import 'package:flutter_ucs_app/settings_screen.dart';
import 'package:flutter_ucs_app/theme_provider.dart';
import 'package:flutter_ucs_app/chat_bot_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to use and modify theme settings
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', width: 30),
        ),
        title: const Text(
          'UCS Booking',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Compact accessibility toolbar
          _buildCompactAccessibilityToolbar(context, themeProvider),
          
          IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () => _showMenu(context),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                Text(
                  'Welcome to UCS Booking',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a campus to book your space',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                
                // Campus selection heading
                Text(
                  'Choose a Campus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campus cards
                _buildCampusList(context),
                
                // Help and Contact section
                const SizedBox(height: 32),
                _buildHelpSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAccessibilityToolbar(BuildContext context, ThemeProvider themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dark mode toggle
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: primaryColor,
          ),
          onPressed: () => themeProvider.toggleDarkMode(),
          tooltip: 'Toggle Dark Mode',
        ),
        
        // Font size options
        IconButton(
          icon: const Icon(Icons.text_fields, color: primaryColor),
          onPressed: () => _showFontSizePopup(context, themeProvider),
          tooltip: 'Change Text Size',
        ),
        
        // High contrast toggle
        IconButton(
          icon: const Icon(Icons.contrast, color: primaryColor),
          onPressed: () {
            // Show message since high contrast is not fully implemented
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('High contrast mode coming soon')),
            );
            // When implemented:
            // themeProvider.toggleHighContrast();
          },
          tooltip: 'Toggle High Contrast',
        ),
      ],
    );
  }

  void _showFontSizePopup(BuildContext context, ThemeProvider themeProvider) {
    final double currentSize = themeProvider.fontSize;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 0),
      items: [
        _buildFontSizeMenuItem(0.8, 'Small', currentSize, themeProvider),
        _buildFontSizeMenuItem(1.0, 'Normal', currentSize, themeProvider),
        _buildFontSizeMenuItem(1.2, 'Large', currentSize, themeProvider),
      ],
    );
  }

  PopupMenuItem _buildFontSizeMenuItem(double size, String label, double currentSize, ThemeProvider themeProvider) {
    return PopupMenuItem(
      value: size,
      child: Row(
        children: [
          Text('A', style: TextStyle(fontSize: size * 18)),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          if (currentSize == size) const Icon(Icons.check, color: primaryColor),
        ],
      ),
      onTap: () => themeProvider.setFontSize(size),
    );
  }

  Widget _buildCampusList(BuildContext context) {
    final campuses = [
      {'name': 'Taunton', 'address': 'Wellington Road, Taunton', 'icon': Icons.school},
      {'name': 'Bridgwater', 'address': 'Bath Road, Bridgwater', 'icon': Icons.account_balance},
      {'name': 'Cannington', 'address': 'Rodway, Cannington', 'icon': Icons.park},
    ];

    return Column(
      children: campuses.map((campus) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildCampusCard(
            context, 
            campus['name'] as String, 
            campus['address'] as String, 
            campus['icon'] as IconData
          ),
        )
      ).toList(),
    );
  }

  Widget _buildCampusCard(
    BuildContext context,
    String location,
    String address,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => navigateToLocation(context, location),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you need assistance with booking or have questions about our services, please contact us.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                context,
                Icons.email,
                'Email',
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email...')),
                ),
              ),
              _buildContactButton(
                context,
                Icons.phone,
                'Call',
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling support...')),
                ),
              ),
              _buildContactButton(
                context,
                Icons.chat,
                'Chat',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: secondaryColor, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: secondaryColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  void navigateToLocation(BuildContext context, String location) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingPage(location)),
    );
  }

 void _showMenu(BuildContext context) {
  // Get the position for the menu to appear from the top right
  final RenderBox? appBar = context.findRenderObject() as RenderBox?;
  final appBarHeight = appBar?.size.height ?? kToolbarHeight;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: appBarHeight, right: 10),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    context,
                    'My Profile',
                    Icons.person,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile feature coming soon')),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    'My Bookings',
                    Icons.calendar_today,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    'Accessibility Settings',
                    Icons.settings_accessibility,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    'Chat Assistant',
                    Icons.chat_bubble_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                    ),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    'Help & Support',
                    Icons.help_outline,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help center coming soon')),
                    ),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    'Logout',
                    Icons.logout,
                    () {
                      CurrentUser.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}