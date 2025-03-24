import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryCircle extends StatelessWidget {
  final String? imageUrl;
  final String? username;
  final bool isViewed;
  final VoidCallback? onTap;

  const StoryCircle({
    super.key,
    this.imageUrl,
    this.username,
    this.isViewed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isViewed ? Colors.grey : Colors.blue,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person),
                    ),
            ),
          ),
          if (username != null) ...[
            const SizedBox(height: 4),
            Text(
              username!,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
} 