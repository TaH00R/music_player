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
  }

  Future<void> toggleFavorite(Song song) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (favorites.any((s) => s.path == song.path)) {
      favorites.removeWhere((s) => s.path == song.path);
    } else {
      favorites.add(song);
    }
    

    final favs = favorites.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('favorites', favs);
    

    notifyListeners(); 

  }

  bool isFavorite(Song song) {
    return favorites.any((s) => s.path == song.path);
  }
}
