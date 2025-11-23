// lib/widgets/song_tile.dart
import 'package:flutter/material.dart';
import '../models/songs.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    final isFav = library.isFavorite(song);

    return ListTile(
      leading: const Icon(Icons.music_note, color: Colors.white70),
      title: Text(song.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(song.artist, style: TextStyle(color: Colors.grey[400])),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : Colors.white70),
        onPressed: () => library.toggleFavorite(song),
      ),
      onTap: onTap,
    );
  }
}