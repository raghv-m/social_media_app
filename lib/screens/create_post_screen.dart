import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/services/chattr_backend.dart';
import 'package:social_media_app/providers/media_provider.dart';
import 'package:social_media_app/providers/theme_provider.dart';
import 'package:social_media_app/providers/creator_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<String> _selectedMedia = [];
  bool _isProcessing = false;
  String _selectedFilter = 'normal';
  File? _imageFile;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    final mediaProvider = context.watch<MediaProvider>();
    final creatorProvider = context.watch<CreatorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _createPost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Media preview
          Expanded(
            flex: 3,
            child: _selectedMedia.isEmpty
                ? _buildMediaSelector()
                : _buildMediaPreview(),
          ),
          // Caption and options
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption input
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filters
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('normal', 'Normal'),
                        _buildFilterChip('clarendon', 'Clarendon'),
                        _buildFilterChip('gingham', 'Gingham'),
                        _buildFilterChip('moon', 'Moon'),
                        _buildFilterChip('lark', 'Lark'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Creator tools
                  if (creatorProvider.isAutoCaptionEnabled)
                    TextButton.icon(
                      onPressed: _generateCaption,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Caption'),
                    ),
                  if (creatorProvider.isContentCalendarEnabled)
                    TextButton.icon(
                      onPressed: _schedulePost,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Post'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickMedia,
          ),
          const Text('Select Media'),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureMedia,
          ),
          const Text('Take Photo'),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    return PageView.builder(
      itemCount: _selectedMedia.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _selectedMedia[index],
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedMedia.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Future<void> _pickMedia() async {
    // Implement media picking
  }

  Future<void> _captureMedia() async {
    // Implement media capture
  }

  Future<void> _generateCaption() async {
    if (_selectedMedia.isEmpty) return;
    
    setState(() => _isProcessing = true);
    try {
      final caption = await context.read<CreatorProvider>().generateCaption(
        _selectedMedia.first,
      );
      _captionController.text = caption;
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _schedulePost() async {
    // Implement post scheduling
  }

  Future<void> _createPost() async {
    if (_selectedMedia.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      // Process media with selected filter
      final processedMedia = await context.read<MediaProvider>().applyFilter(
        _selectedFilter,
      );

      // Create post
      final post = {
        'mediaUrls': processedMedia,
        'caption': _captionController.text,
        'filter': _selectedFilter,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // TODO: Save post to backend
      
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }
} 