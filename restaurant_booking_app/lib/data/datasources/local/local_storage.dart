import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';

@singleton
class LocalStorage {
  Box<String>? _authBox;
  Box<Map>? _userBox;
  Box<List>? _favoritesBox;

  Future<void> init() async {
    _authBox = await Hive.openBox<String>('auth');
    _userBox = await Hive.openBox<Map>('user');
    _favoritesBox = await Hive.openBox<List>('favorites');
  }

  // Auth tokens
  Future<void> saveAuthToken(String token) async {
    await _authBox?.put(AppConstants.authTokenKey, token);
  }

  String? getAuthToken() {
    return _authBox?.get(AppConstants.authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _authBox?.put(AppConstants.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _authBox?.get(AppConstants.refreshTokenKey);
  }

  Future<void> clearAuthTokens() async {
    await _authBox?.delete(AppConstants.authTokenKey);
    await _authBox?.delete(AppConstants.refreshTokenKey);
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userBox?.put(AppConstants.userDataKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    final data = _userBox?.get(AppConstants.userDataKey);
    return data?.cast<String, dynamic>();
  }

  Future<void> clearUserData() async {
    await _userBox?.delete(AppConstants.userDataKey);
  }

  // Favorites
  Future<void> saveFavorites(List<String> venueIds) async {
    await _favoritesBox?.put(AppConstants.favoritesKey, venueIds);
  }

  List<String> getFavorites() {
    final favorites = _favoritesBox?.get(AppConstants.favoritesKey);
    return favorites?.cast<String>() ?? [];
  }

  Future<void> addToFavorites(String venueId) async {
    final favorites = getFavorites();
    if (!favorites.contains(venueId)) {
      favorites.add(venueId);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFromFavorites(String venueId) async {
    final favorites = getFavorites();
    favorites.remove(venueId);
    await saveFavorites(favorites);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _authBox?.clear();
    await _userBox?.clear();
    await _favoritesBox?.clear();
  }
}