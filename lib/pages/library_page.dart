// lib/pages/library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';
import '../providers/player_provider.dart';
import 'player_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    // Only call loadFavorites once in initState
    _loadingFuture = Provider.of<LibraryProvider>(context, listen: false).loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the LibraryProvider for state changes
    final library = Provider.of<LibraryProvider>(context);
    final player = Provider.of<PlayerProvider>(context, listen: false);

    return FutureBuilder(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (library.favorites.isEmpty) {
          return const Center(child: Text("No Favorites Yet", style: TextStyle(color: Colors.white54)));
        }

        return ListView.builder(
          itemCount: library.favorites.length,
          itemBuilder: (context, index) {
            final song = library.favorites[index];
            return SongTile(
              song: song,
              onTap: () {
                player.playSong(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayerPage(song: song)),
                );
              },
            );
          },
        );
      },
    );
  }
}