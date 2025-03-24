import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeColor>(
      icon: const Icon(Icons.palette),
      tooltip: 'Select Theme Color',
      onSelected: (ThemeColor color) {
        context.read<ThemeProvider>().setColor(color);
      },
      itemBuilder: (context) => [
        _buildMenuItem(ThemeColor.red, 'Red'),
        _buildMenuItem(ThemeColor.orange, 'Orange'),
        _buildMenuItem(ThemeColor.yellow, 'Yellow'),
        _buildMenuItem(ThemeColor.green, 'Green'),
        _buildMenuItem(ThemeColor.blue, 'Blue'),
        _buildMenuItem(ThemeColor.indigo, 'Indigo'),
        _buildMenuItem(ThemeColor.violet, 'Violet'),
        _buildMenuItem(ThemeColor.gray, 'Gray'),
        _buildMenuItem(ThemeColor.black, 'Black'),
        _buildMenuItem(ThemeColor.white, 'White'),
      ],
    );
  }

  PopupMenuItem<ThemeColor> _buildMenuItem(ThemeColor color, String name) {
    return PopupMenuItem(
      value: color,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }
} 