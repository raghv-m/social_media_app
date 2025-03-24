import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/widgets/theme_selector.dart';
import 'package:social_media_app/providers/theme_provider.dart';
import 'package:social_media_app/providers/privacy_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    final privacyProvider = context.watch<PrivacyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          ThemeSelector(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Privacy Settings',
            icon: Icons.security,
            themeColor: themeColor,
            children: [
              _buildSwitchTile(
                title: 'Public Profile',
                subtitle: 'Make your profile visible to everyone',
                value: privacyProvider.isProfilePublic,
                onChanged: privacyProvider.setProfileVisibility,
              ),
              _buildSwitchTile(
                title: 'Activity Visibility',
                subtitle: 'Show your activity to other users',
                value: privacyProvider.isActivityVisible,
                onChanged: privacyProvider.setActivityVisibility,
              ),
              _buildSwitchTile(
                title: 'Location Services',
                subtitle: 'Allow location access for nearby features',
                value: privacyProvider.isLocationEnabled,
                onChanged: privacyProvider.setLocationEnabled,
              ),
              _buildSwitchTile(
                title: 'Message Encryption',
                subtitle: 'Enable end-to-end encryption for messages',
                value: privacyProvider.isMessageEncryptionEnabled,
                onChanged: privacyProvider.setMessageEncryptionEnabled,
              ),
              _buildSwitchTile(
                title: 'Data Collection',
                subtitle: 'Allow collection of usage data',
                value: privacyProvider.isDataCollectionEnabled,
                onChanged: privacyProvider.setDataCollectionEnabled,
              ),
              _buildSwitchTile(
                title: 'Third-Party Sharing',
                subtitle: 'Allow sharing data with third parties',
                value: privacyProvider.isThirdPartySharingEnabled,
                onChanged: privacyProvider.setThirdPartySharingEnabled,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data Management',
            icon: Icons.storage,
            themeColor: themeColor,
            children: [
              ListTile(
                title: Text(
                  'Data Retention',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Current: ${privacyProvider.dataRetentionPeriod}',
                  style: GoogleFonts.poppins(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Show data retention options
                },
              ),
              ListTile(
                title: Text(
                  'Export Data',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Download your personal data',
                  style: GoogleFonts.poppins(),
                ),
                trailing: const Icon(Icons.download),
                onTap: privacyProvider.exportUserData,
              ),
              ListTile(
                title: Text(
                  'Clear Data',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Delete all your personal data',
                  style: GoogleFonts.poppins(),
                ),
                trailing: const Icon(Icons.delete),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Data'),
                      content: const Text(
                        'Are you sure you want to delete all your personal data? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            privacyProvider.clearUserData();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Appearance',
            icon: Icons.palette,
            themeColor: themeColor,
            children: [
              ListTile(
                title: Text(
                  'Theme Color',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Customize app appearance',
                  style: GoogleFonts.poppins(),
                ),
                trailing: const ThemeSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color themeColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: themeColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.grey[900],
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
} 