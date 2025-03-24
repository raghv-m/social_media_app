class AppConfig {
  static const String appName = 'Chattr';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A privacy-first, creator-focused social platform';
  
  // API endpoints
  static const String baseUrl = 'https://api.chattr.app';
  static const String mediaUrl = 'https://media.chattr.app';
  
  // Storage paths
  static const String postsPath = 'posts';
  static const String storiesPath = 'stories';
  static const String profilesPath = 'profiles';
  static const String mediaPath = 'media';
  
  // Cache settings
  static const int cacheMaxAge = 7; // days
  static const int maxCachedImages = 100;
  
  // Media settings
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // Story settings
  static const int storyDuration = 5; // seconds
  static const int maxStoriesPerUser = 10;
  
  // Feed settings
  static const int postsPerPage = 10;
  static const int maxFeedItems = 100;
  
  // Privacy settings
  static const bool defaultProfilePublic = false;
  static const bool defaultActivityVisible = true;
  static const bool defaultLocationEnabled = false;
  
  // Creator settings
  static const bool defaultAutoCaptionEnabled = false;
  static const bool defaultContentCalendarEnabled = false;
  static const bool defaultAnalyticsEnabled = true;
  
  // Theme settings
  static const String defaultFontFamily = 'Poppins';
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration storyTransitionDuration = Duration(milliseconds: 500);
  
  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String mediaError = 'Failed to process media. Please try again.';
  
  // Success messages
  static const String postSuccess = 'Post created successfully!';
  static const String storySuccess = 'Story added successfully!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  
  // Validation messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String invalidUsername = 'Username must be at least 3 characters';
  
  // Rate limiting
  static const int maxPostsPerDay = 50;
  static const int maxStoriesPerDay = 20;
  static const int maxCommentsPerPost = 100;
  static const int maxLikesPerPost = 1000;
} 