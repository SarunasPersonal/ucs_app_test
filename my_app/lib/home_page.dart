import 'package:flutter/material.dart';
import 'package:flutter_ucs_app/constants.dart';
import 'package:flutter_ucs_app/booking_page.dart';
import 'package:flutter_ucs_app/login_screen.dart';
import 'package:flutter_ucs_app/my_bookings_page.dart';
import 'package:flutter_ucs_app/settings_screen.dart';
import 'package:flutter_ucs_app/theme_provider.dart';
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
          // Accessibility quick toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: primaryColor,
            ),
            onPressed: () {
              themeProvider.toggleDarkMode();
            },
            tooltip: 'Toggle Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () {
              _showMenu(context);
            },
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
                // Welcome Text - uses TextStyle from the current theme
                Text(
                  'Welcome to UCS Booking',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a campus to book your appointment',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),

                // Accessibility Info Card
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.accessibility_new, 
                              color: primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Accessibility Options',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This app supports accessibility features to make it easier to use.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dark mode toggle with switch
                            Row(
                              children: [
                                Icon(
                                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Dark Mode',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleDarkMode();
                              },
                              activeColor: primaryColor,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text size label
                            Row(
                              children: [
                                const Icon(
                                  Icons.text_fields,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Text Size',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            // Text size dropdown
                            DropdownButton<double>(
                              value: themeProvider.fontSize,
                              items: const [
                                DropdownMenuItem(
                                  value: 0.8,
                                  child: Text('Small'),
                                ),
                                DropdownMenuItem(
                                  value: 1.0,
                                  child: Text('Normal'),
                                ),
                                DropdownMenuItem(
                                  value: 1.2,
                                  child: Text('Large'),
                                ),
                                DropdownMenuItem(
                                  value: 1.4,
                                  child: Text('Extra Large'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  themeProvider.setFontSize(value);
                                }
                              },
                              underline: Container(
                                height: 2,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.settings_accessibility,
                            color: primaryColor,
                          ),
                          label: Text(
                            'More Accessibility Settings',
                            style: TextStyle(color: primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
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
                _buildCampusCard(
                  context,
                  'Taunton',
                  'Wellington Road, Taunton',
                  Icons.school,
                ),
                const SizedBox(height: 12),
                _buildCampusCard(
                  context,
                  'Bridgwater',
                  'Bath Road, Bridgwater',
                  Icons.account_balance,
                ),
                const SizedBox(height: 12),
                _buildCampusCard(
                  context,
                  'Cannington',
                  'Rodway, Cannington',
                  Icons.park,
                ),
                
                // Help and Contact section
                const SizedBox(height: 32),
                Container(
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
                            () {
                              // Email action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening email...')),
                              );
                            },
                          ),
                          _buildContactButton(
                            context,
                            Icons.phone,
                            'Call',
                            () {
                              // Call action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Calling support...')),
                              );
                            },
                          ),
                          _buildContactButton(
                            context,
                            Icons.chat,
                            'Chat',
                            () {
                              // Chat action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening chat...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: primaryColor),
                title: Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: primaryColor),
                title: Text(
                  'My Bookings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_accessibility, color: primaryColor),
                title: Text(
                  'Accessibility Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline, color: primaryColor),
                title: Text(
                  'Help & Support',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help center coming soon')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: primaryColor),
                title: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  // Clear current user
                  CurrentUser.logout();
                  
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}