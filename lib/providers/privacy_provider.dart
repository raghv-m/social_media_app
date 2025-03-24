import 'package:flutter/material.dart';

class PrivacyProvider with ChangeNotifier {
  bool _isProfilePublic = true;
  bool _isActivityVisible = true;
  bool _isLocationEnabled = false;
  bool _isAnalyticsEnabled = false;
  bool _isAdTrackingEnabled = false;
  bool _isMessageEncryptionEnabled = true;
  bool _isDataCollectionEnabled = false;
  bool _isThirdPartySharingEnabled = false;
  String _dataRetentionPeriod = '30 days';
  List<String> _blockedUsers = [];

  // Getters
  bool get isProfilePublic => _isProfilePublic;
  bool get isActivityVisible => _isActivityVisible;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;
  bool get isAdTrackingEnabled => _isAdTrackingEnabled;
  bool get isMessageEncryptionEnabled => _isMessageEncryptionEnabled;
  bool get isDataCollectionEnabled => _isDataCollectionEnabled;
  bool get isThirdPartySharingEnabled => _isThirdPartySharingEnabled;
  String get dataRetentionPeriod => _dataRetentionPeriod;
  List<String> get blockedUsers => _blockedUsers;

  // Setters with privacy-first approach
  void setProfileVisibility(bool value) {
    _isProfilePublic = value;
    notifyListeners();
  }

  void setActivityVisibility(bool value) {
    _isActivityVisible = value;
    notifyListeners();
  }

  void setLocationEnabled(bool value) {
    _isLocationEnabled = value;
    notifyListeners();
  }

  void setAnalyticsEnabled(bool value) {
    _isAnalyticsEnabled = value;
    notifyListeners();
  }

  void setAdTrackingEnabled(bool value) {
    _isAdTrackingEnabled = value;
    notifyListeners();
  }

  void setMessageEncryptionEnabled(bool value) {
    _isMessageEncryptionEnabled = value;
    notifyListeners();
  }

  void setDataCollectionEnabled(bool value) {
    _isDataCollectionEnabled = value;
    notifyListeners();
  }

  void setThirdPartySharingEnabled(bool value) {
    _isThirdPartySharingEnabled = value;
    notifyListeners();
  }

  void setDataRetentionPeriod(String period) {
    _dataRetentionPeriod = period;
    notifyListeners();
  }

  void addBlockedUser(String userId) {
    if (!_blockedUsers.contains(userId)) {
      _blockedUsers.add(userId);
      notifyListeners();
    }
  }

  void removeBlockedUser(String userId) {
    _blockedUsers.remove(userId);
    notifyListeners();
  }

  // Privacy-focused data management
  void clearUserData() {
    // Implement secure data clearing
    _blockedUsers.clear();
    notifyListeners();
  }

  void exportUserData() {
    // Implement secure data export
  }

  // Privacy-focused analytics
  void trackPrivacyEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (_isAnalyticsEnabled) {
      // Implement privacy-focused event tracking
    }
  }

  // Privacy-focused location handling
  void updateLocation() {
    if (_isLocationEnabled) {
      // Implement privacy-focused location updates
    }
  }
} 