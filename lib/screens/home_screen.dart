import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/widgets/post_card.dart';
import 'package:social_media_app/widgets/story_circle.dart';
import 'package:social_media_app/providers/feed_provider.dart';
import 'package:social_media_app/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialFeed() async {
    setState(() => _isLoading = true);
    await context.read<FeedProvider>().refreshFeed();
    setState(() => _isLoading = false);
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      await context.read<FeedProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    final feedProvider = context.watch<FeedProvider>();
    final feed = feedProvider.feed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chattr',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: themeColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {
              // Navigate to messages
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialFeed,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stories section
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: 10, // Replace with actual stories count
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: StoryCircle(),
                    );
                  },
                ),
              ),
            ),
            // Feed section
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= feed.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return PostCard(post: feed[index]);
                  },
                  childCount: feed.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 