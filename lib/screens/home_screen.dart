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
  bool _hasMore = true;
  static const int _pageSize = 10;
  static const double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialFeed();
    _loadStories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialFeed() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await context.read<FeedProvider>().refreshFeed();
      setState(() => _hasMore = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStories() async {
    try {
      await context.read<FeedProvider>().loadStories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stories: $e')),
        );
      }
    }
  }

  Future<void> _onScroll() async {
    if (_isLoading || !_hasMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      setState(() => _isLoading = true);
      try {
        final hasMore = await context.read<FeedProvider>().loadMorePosts();
        setState(() => _hasMore = hasMore);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading more posts: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: feedProvider.stories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const StoryCircle(
                        isAddStory: true,
                        username: 'Your Story',
                      );
                    }
                    final story = feedProvider.stories[index - 1];
                    return StoryCircle(
                      imageUrl: story['imageUrl'],
                      username: story['username'],
                      hasUnseenStory: story['hasUnseenStory'] ?? false,
                    );
                  },
                ),
              ),
            ),
            // Feed posts
            if (feed.isEmpty && !_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No posts yet. Be the first to post!'),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= feed.length) {
                      if (!_hasMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No more posts'),
                          ),
                        );
                      }
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