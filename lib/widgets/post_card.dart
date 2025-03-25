import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/feed_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/providers/theme_provider.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    final feedProvider = context.watch<FeedProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post['userProfilePic'] != null
                  ? CachedNetworkImageProvider(post['userProfilePic'])
                  : null,
              child: post['userProfilePic'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post['username'] ?? ''),
            subtitle: post['location'] != null
                ? Text(post['location'])
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show post options
              },
            ),
          ),
          // Post content
          if (post['content']?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post['content']),
            ),
          // Post media
          if (post['mediaUrls']?.isNotEmpty ?? false)
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                itemCount: post['mediaUrls'].length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: post['mediaUrls'][index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
          // Post actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post['isLiked'] ?? false
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post['isLiked'] ?? false ? Colors.red : null,
                  ),
                  onPressed: () {
                    // Toggle like
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    // Navigate to comments
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Share post
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    post['isSaved'] ?? false
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    if (post['isSaved'] ?? false) {
                      feedProvider.unsavePost(post['id']);
                    } else {
                      feedProvider.savePost(post);
                    }
                  },
                ),
              ],
            ),
          ),
          // Post stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post['likes'] ?? 0} likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (post['comments']?.isNotEmpty ?? false)
                  TextButton(
                    onPressed: () {
                      // Navigate to comments
                    },
                    child: Text(
                      'View all ${post['comments']?.length ?? 0} comments',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 