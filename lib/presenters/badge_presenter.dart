import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/BadgeItem.dart';
import '../services/ApiConfig.dart';

class BadgePresenter extends ChangeNotifier {
  List<BadgeItem> _allBadges = [];
  bool _isLoading = false;

  List<BadgeItem> get allBadges => _allBadges;
  bool get isLoading => _isLoading;

  int get challengesCompleted =>
      _allBadges.where((b) => b.isCompleted).length;
  int get beautyCoins =>
      _allBadges.fold(0, (sum, b) => sum + b.associatedRecipes);
  int get testedRecipes =>
      _allBadges.fold(0, (sum, b) => sum + b.currentProgress);

  /// Fetch badges from backend
  Future<void> fetchBadges() async {
    _setLoading(true);
    try {
      final response = await http.get(Uri.parse(ApiConfig.badgesUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allBadges =
            data.map((json) => BadgeItem.fromJson(json)).toList();
        notifyListeners();
      } else {
        debugPrint("Failed to fetch badges: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching badges: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Increment badge progress
  Future<void> incrementBadge(BadgeItem badge) async {
    try {
      final url = '${ApiConfig.badgesUrl}/${badge.id}/increment/';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final updatedBadge = BadgeItem.fromJson(jsonDecode(response.body));
        final index = _allBadges.indexWhere((b) => b.id == updatedBadge.id);
        if (index != -1) _allBadges[index] = updatedBadge;
        notifyListeners();
      } else {
        debugPrint('Failed to increment badge');
      }
    } catch (e) {
      debugPrint('Error incrementing badge: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
