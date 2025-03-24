import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/widgets/post_card.dart';
import 'package:social_media_app/providers/feed_provider.dart';
import 'package:social_media_app/providers/theme_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    final feedProvider = context.watch<FeedProvider>();
    final exploreContent = feedProvider.exploreContent;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[800],
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (value) {
            // Implement search
          },
        ),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('all', 'All'),
                _buildCategoryChip('photos', 'Photos'),
                _buildCategoryChip('videos', 'Videos'),
                _buildCategoryChip('text', 'Text'),
                _buildCategoryChip('blogs', 'Blogs'),
              ],
            ),
          ),
          // Trending hashtags
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Hashtags',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: feedProvider.discoverySettings['trending_hashtags'].length,
                    itemBuilder: (context, index) {
                      final hashtag = feedProvider.discoverySettings['trending_hashtags'][index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('#$hashtag'),
                          backgroundColor: Colors.grey[800],
                          onDeleted: () {
                            // Remove hashtag from preferences
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Explore content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await feedProvider.updateTrendingHashtags();
                await feedProvider.updateNearbyContent();
              },
              child: ListView.builder(
                itemCount: exploreContent.length,
                itemBuilder: (context, index) {
                  return PostCard(post: exploreContent[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    );
  }
} 