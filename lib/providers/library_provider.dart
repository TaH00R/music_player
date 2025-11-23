// lib/providers/library_provider.dart

import 'package:flutter/material.dart';
import '../models/songs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryProvider with ChangeNotifier {
  List<Song> favorites = [];

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    favorites = favs.map((e) => Song.fromMap(jsonDecode(e))).toList();
    // ⭐️ No notifyListeners here, it will be handled by the consuming widgets later
  }

  Future<void> toggleFavorite(Song song) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 1. Update the local list
    if (favorites.any((s) => s.path == song.path)) {
      favorites.removeWhere((s) => s.path == song.path);
    } else {
      favorites.add(song);
    }
    
    // 2. Persist the change
    final favs = favorites.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('favorites', favs);
    
    // 3. Notify all listening widgets (HomePage & LibraryPage)
    notifyListeners(); 
    // ⭐️ This is crucial: it tells LibraryPage and SongTile to rebuild immediately!
  }

  bool isFavorite(Song song) {
    return favorites.any((s) => s.path == song.path);
  }
}