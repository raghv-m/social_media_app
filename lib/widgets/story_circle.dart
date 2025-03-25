import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryCircle extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final bool isAddStory;
  final bool hasUnseenStory;

  const StoryCircle({
    super.key,
    this.imageUrl,
    required this.username,
    this.isAddStory = false,
    this.hasUnseenStory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasUnseenStory
                      ? const LinearGradient(
                          colors: [Colors.purple, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: hasUnseenStory ? Colors.transparent : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: isAddStory
                        ? null
                        : (imageUrl != null
                            ? CachedNetworkImageProvider(imageUrl!)
                            : null),
                    child: isAddStory
                        ? const Icon(Icons.add, color: Colors.black)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 