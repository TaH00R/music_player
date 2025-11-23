// lib/pages/home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:provider/provider.dart';
import '../models/songs.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import 'library_page.dart';
import 'player_page.dart'; 

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<void> pickSongs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.audio,
      );

      if (result == null) return;

      List<Song> songs = [];
      
      for (var file in result.files) {
        try {
          if (file.path != null) {
            final metadata = await MetadataRetriever.fromFile(File(file.path!));
            
            songs.add(Song(
              title: metadata.trackName ?? file.name,
              artist: metadata.albumArtistName ?? 'Unknown',
              album: metadata.albumName ?? 'Unknown',
              path: file.path!,
              //lyrics: metadata.trackLyrics, 
            ));
          }
        } catch (e) {
          print("Error processing file ${file.name}: $e - Skipping.");
        }
      }
      
      if (songs.isNotEmpty) {

        Provider.of<PlayerProvider>(context, listen: false).setSongs(songs);
      }
    } catch (e) {
      print("FATAL ERROR during file pick attempt: $e"); 
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Music Player"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 0
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: pickSongs,
                          icon: const Icon(Icons.folder_open),
                          label: const Text("Pick Songs"),
                        ),
                      ),
                      if (provider.songs.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Use 'Pick Songs' to add music.",
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.songs.length,
                            itemBuilder: (context, index) {
                              final song = provider.songs[index];
                              return SongTile(
                                song: song,
                                onTap: () {
                                  provider.playSong(song);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerPage(song: song),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  )
                : const LibraryPage(),
          ),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, 
        unselectedItemColor: Colors.white54,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}
