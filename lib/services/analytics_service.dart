import '../config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Events
  Future<void> logUserSignUp(String userId, String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      await _analytics.setUserId(id: userId);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logUserLogin(String userId, String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.setUserId(id: userId);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logUserLogout(String userId) async {
    try {
      await _analytics.logEvent(name: 'user_logout');
      await _analytics.setUserId(id: null);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Content Events
  Future<void> logPostCreated(String postId, String type) async {
    try {
      await _analytics.logEvent(
        name: 'post_created',
        parameters: {
          'post_id': postId,
          'post_type': type,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logPostViewed(String postId, int duration) async {
    try {
      await _analytics.logEvent(
        name: 'post_viewed',
        parameters: {
          'post_id': postId,
          'view_duration': duration,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logPostInteraction(String postId, String action) async {
    try {
      await _analytics.logEvent(
        name: 'post_interaction',
        parameters: {
          'post_id': postId,
          'action': action,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Story Events
  Future<void> logStoryViewed(String storyId, int duration) async {
    try {
      await _analytics.logEvent(
        name: 'story_viewed',
        parameters: {
          'story_id': storyId,
          'view_duration': duration,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logStoryInteraction(String storyId, String action) async {
    try {
      await _analytics.logEvent(
        name: 'story_interaction',
        parameters: {
          'story_id': storyId,
          'action': action,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Feed Events
  Future<void> logFeedScroll(int itemCount) async {
    try {
      await _analytics.logEvent(
        name: 'feed_scroll',
        parameters: {
          'items_viewed': itemCount,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> logFeedRefresh() async {
    try {
      await _analytics.logEvent(name: 'feed_refresh');
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Search Events
  Future<void> logSearch(String query, String category) async {
    try {
      await _analytics.logSearch(
        searchTerm: query,
        parameters: {
          'category': category,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Error Tracking
  Future<void> logError(String error, StackTrace stackTrace) async {
    try {
      await _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      print('Failed to log error: $e');
    }
  }

  // Performance Tracking
  Future<void> logPerformanceMetric(String metric, int value) async {
    try {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'metric': metric,
          'value': value,
        },
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // User Properties
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Screen Tracking
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Custom Events
  Future<void> logCustomEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // User Analytics
  Future<void> trackUserEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _firestore.collection('user_events').add({
        'userId': userId,
        'eventName': eventName,
        'parameters': parameters ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track user event: $e');
    }
  }

  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final QuerySnapshot eventsSnapshot = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, int> eventCounts = {};
      for (var doc in eventsSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String eventName = data['eventName'];
        eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
      }

      return {
        'totalEvents': eventsSnapshot.docs.length,
        'eventCounts': eventCounts,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get user analytics: $e');
    }
  }

  // Content Analytics
  Future<void> trackContentInteraction({
    required String contentId,
    required String userId,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('content_interactions').add({
        'contentId': contentId,
        'userId': userId,
        'interactionType': interactionType,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track content interaction: $e');
    }
  }

  Future<Map<String, dynamic>> getContentAnalytics(String contentId) async {
    try {
      final QuerySnapshot interactionsSnapshot = await _firestore
          .collection('content_interactions')
          .where('contentId', isEqualTo: contentId)
          .get();

      final Map<String, int> interactionCounts = {};
      for (var doc in interactionsSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String interactionType = data['interactionType'];
        interactionCounts[interactionType] = (interactionCounts[interactionType] ?? 0) + 1;
      }

      return {
        'totalInteractions': interactionsSnapshot.docs.length,
        'interactionCounts': interactionCounts,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get content analytics: $e');
    }
  }

  // Feed Analytics
  Future<void> trackFeedInteraction({
    required String userId,
    required String feedType,
    required String interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('feed_interactions').add({
        'userId': userId,
        'feedType': feedType,
        'interactionType': interactionType,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track feed interaction: $e');
    }
  }

  Future<Map<String, dynamic>> getFeedAnalytics(String userId) async {
    try {
      final QuerySnapshot interactionsSnapshot = await _firestore
          .collection('feed_interactions')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, Map<String, int>> feedInteractionCounts = {};
      for (var doc in interactionsSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String feedType = data['feedType'];
        final String interactionType = data['interactionType'];

        if (!feedInteractionCounts.containsKey(feedType)) {
          feedInteractionCounts[feedType] = {};
        }
        feedInteractionCounts[feedType]![interactionType] =
            (feedInteractionCounts[feedType]![interactionType] ?? 0) + 1;
      }

      return {
        'totalInteractions': interactionsSnapshot.docs.length,
        'feedInteractionCounts': feedInteractionCounts,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get feed analytics: $e');
    }
  }

  // Performance Analytics
  Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('performance_metrics').add({
        'metricName': metricName,
        'value': value,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track performance metric: $e');
    }
  }

  Future<Map<String, dynamic>> getPerformanceAnalytics({
    required String metricName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final QuerySnapshot metricsSnapshot = await _firestore
          .collection('performance_metrics')
          .where('metricName', isEqualTo: metricName)
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .where('timestamp', isLessThanOrEqualTo: endTime)
          .get();

      final List<double> values = [];
      for (var doc in metricsSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        values.add(data['value']);
      }

      if (values.isEmpty) {
        return {
          'metricName': metricName,
          'averageValue': 0.0,
          'minValue': 0.0,
          'maxValue': 0.0,
          'totalSamples': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      values.sort();
      final double average = values.reduce((a, b) => a + b) / values.length;
      final double min = values.first;
      final double max = values.last;

      return {
        'metricName': metricName,
        'averageValue': average,
        'minValue': min,
        'maxValue': max,
        'totalSamples': values.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get performance analytics: $e');
    }
  }

  // App Usage Analytics
  Future<void> trackAppUsage({
    required String userId,
    required String screenName,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('app_usage').add({
        'userId': userId,
        'screenName': screenName,
        'durationInSeconds': duration.inSeconds,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track app usage: $e');
    }
  }

  Future<Map<String, dynamic>> getAppUsageAnalytics(String userId) async {
    try {
      final QuerySnapshot usageSnapshot = await _firestore
          .collection('app_usage')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, int> screenVisitCounts = {};
      final Map<String, int> screenDurationSeconds = {};
      for (var doc in usageSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String screenName = data['screenName'];
        final int duration = data['durationInSeconds'];

        screenVisitCounts[screenName] = (screenVisitCounts[screenName] ?? 0) + 1;
        screenDurationSeconds[screenName] =
            (screenDurationSeconds[screenName] ?? 0) + duration;
      }

      final Map<String, double> averageScreenDurations = {};
      screenVisitCounts.forEach((screen, count) {
        averageScreenDurations[screen] =
            screenDurationSeconds[screen]! / count;
      });

      return {
        'totalScreensVisited': screenVisitCounts.length,
        'screenVisitCounts': screenVisitCounts,
        'averageScreenDurations': averageScreenDurations,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get app usage analytics: $e');
    }
  }
} 