import 'package:flutter/material.dart';

class FeedProvider with ChangeNotifier {
  // Feed preferences
  Map<String, dynamic> _feedPreferences = {
    'algorithm_type': 'community', // 'community' or 'personalized'
    'content_types': ['photos', 'videos', 'text', 'blogs'],
    'excluded_hashtags': [],
    'included_hashtags': [],
    'muted_accounts': [],
    'boosted_accounts': [],
    'location_based': false,
    'radius_km': 50,
    'sort_by': 'recent',
    'filter_nsfw': true,
  };

  // Feed state
  List<Map<String, dynamic>> _feed = [];
  List<Map<String, dynamic>> _savedPosts = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _exploreContent = [];
  Map<String, dynamic> _feedStats = {
    'total_posts': 0,
    'viewed_posts': 0,
    'engagement_rate': 0.0,
    'content_diversity': 0.0,
  };

  // Discovery settings
  Map<String, dynamic> _discoverySettings = {
    'trending_hashtags': [],
    'suggested_accounts': [],
    'nearby_content': [],
    'interests': [],
    'content_quality_score': 0.0,
  };

  bool _isLoading = false;
  String? _lastDocumentId;
  static const int _pageSize = 10;

  // Getters
  Map<String, dynamic> get feedPreferences => _feedPreferences;
  List<Map<String, dynamic>> get feed => _feed;
  List<Map<String, dynamic>> get savedPosts => _savedPosts;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get exploreContent => _exploreContent;
  Map<String, dynamic> get feedStats => _feedStats;
  Map<String, dynamic> get discoverySettings => _discoverySettings;
  bool get isLoading => _isLoading;

  // Feed preference methods
  void updateFeedPreferences(Map<String, dynamic> preferences) {
    _feedPreferences = {..._feedPreferences, ...preferences};
    notifyListeners();
  }

  void toggleContentType(String type, bool enabled) {
    if (enabled) {
      _feedPreferences['content_types'].add(type);
    } else {
      _feedPreferences['content_types'].remove(type);
    }
    notifyListeners();
  }

  void updateLocationSettings(bool enabled, {double? radius}) {
    _feedPreferences['location_based'] = enabled;
    if (radius != null) {
      _feedPreferences['radius_km'] = radius;
    }
    notifyListeners();
  }

  // Feed management methods
  Future<void> refreshFeed() async {
    _feed = [];
    _lastDocumentId = null;
    await loadMorePosts();
  }

  Future<bool> loadMorePosts() async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final posts = await _fetchPosts();
      if (posts.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _feed.addAll(posts);
      _lastDocumentId = posts.last['id'];
      _isLoading = false;
      notifyListeners();
      return posts.length >= _pageSize;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    try {
      // TODO: Implement actual Firebase query
      // For now, return dummy data
      return List.generate(_pageSize, (index) {
        final id = _lastDocumentId != null 
            ? '${_lastDocumentId}_$index'
            : 'post_$index';
        return {
          'id': id,
          'username': 'user_$index',
          'userProfilePic': 'https://picsum.photos/200?random=$index',
          'content': 'This is a sample post content $index',
          'mediaUrls': ['https://picsum.photos/800/800?random=$index'],
          'likes': index * 10,
          'comments': List.generate(3, (i) => {
            'id': 'comment_${index}_$i',
            'username': 'user_$i',
            'content': 'Comment $i on post $index',
          }),
          'timestamp': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
          'isLiked': false,
          'isSaved': false,
        };
      });
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<void> loadStories() async {
    try {
      // TODO: Implement actual Firebase query
      // For now, return dummy data
      _stories = List.generate(5, (index) {
        return {
          'id': 'story_$index',
          'username': 'user_$index',
          'imageUrl': 'https://picsum.photos/200?random=$index',
          'hasUnseenStory': index % 2 == 0,
          'timestamp': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
        };
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load stories: $e');
    }
  }

  void savePost(Map<String, dynamic> post) {
    if (!_savedPosts.any((p) => p['id'] == post['id'])) {
      _savedPosts.add(post);
      notifyListeners();
    }
  }

  void unsavePost(String postId) {
    _savedPosts.removeWhere((post) => post['id'] == postId);
    notifyListeners();
  }

  // Discovery methods
  Future<void> updateTrendingHashtags() async {
    // Implement trending hashtags update
    notifyListeners();
  }

  Future<void> updateNearbyContent() async {
    // Implement nearby content update
    notifyListeners();
  }

  Future<void> updateSuggestedAccounts() async {
    // Implement suggested accounts update
    notifyListeners();
  }

  // Content quality methods
  Future<double> calculateContentQualityScore(Map<String, dynamic> post) async {
    // Implement content quality scoring
    return 0.0;
  }

  Future<Map<String, dynamic>> getFeedInsights() async {
    // Implement feed insights generation
    return {
      'content_diversity': 0.0,
      'engagement_metrics': {},
      'user_preferences': _feedPreferences,
      'recommendations': [],
    };
  }

  // Feed transparency methods
  Future<Map<String, dynamic>> explainPostRanking(String postId) async {
    // Implement post ranking explanation
    return {
      'post_id': postId,
      'ranking_factors': [],
      'community_impact': 0.0,
      'personal_relevance': 0.0,
    };
  }

  // Feed export
  Future<Map<String, dynamic>> exportFeedPreferences() async {
    return {
      'preferences': _feedPreferences,
      'stats': _feedStats,
      'saved_posts': _savedPosts.map((post) => post['id']).toList(),
    };
  }
} 