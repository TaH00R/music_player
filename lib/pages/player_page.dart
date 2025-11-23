// lib/pages/player_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../models/songs.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/lyrics_widget.dart';

class PlayerPage extends StatelessWidget {
  final Song song; 
  const PlayerPage({super.key, required this.song});

  // Helper function to format duration to M:SS (0:00)
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final library = Provider.of<LibraryProvider>(context);
    final displaySong = player.currentSong ?? song;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text("PLAYING FROM LIBRARY", style: TextStyle(fontSize: 10, color: Colors.white70)),
            Text(displaySong.album, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, 
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Album Art
            Container(
              height: MediaQuery.of(context).size.width * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(Icons.album, size: 100, color: primaryColor),
            ),
            
            // 2. Song Info & Favorite Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displaySong.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          displaySong.artist,
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        library.isFavorite(displaySong)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: library.isFavorite(displaySong) ? Colors.red : Colors.white),
                    onPressed: () => library.toggleFavorite(displaySong),
                    iconSize: 28,
                  ),
                ],
              ),
            ),

            // 3. Progress Bar
            Column(
              children: [
                StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, durationSnapshot) {
                    final totalDuration = durationSnapshot.data;
                    return StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, positionSnapshot) {
                        var position = positionSnapshot.data ?? Duration.zero;
                        
                        if (totalDuration != null && position > totalDuration) {
                            position = totalDuration;
                        }
                        
                        double sliderValue = (totalDuration != null && totalDuration.inMilliseconds > 0)
                            ? position.inMilliseconds.toDouble() / totalDuration.inMilliseconds.toDouble()
                            : 0.0;
                        
                        return Slider(
                          min: 0.0,
                          max: 1.0,
                          value: sliderValue,
                          onChanged: (newValue) {
                            if (totalDuration != null) {
                              final newPosition = Duration(milliseconds: (newValue * totalDuration.inMilliseconds).round());
                              // ⭐️ FIX APPLIED HERE: Using the public 'seek' method
                              player.seek(newPosition);
                            }
                          },
                          activeColor: primaryColor,
                          inactiveColor: Colors.white38,
                          thumbColor: Colors.white,
                        );
                      },
                    );
                  },
                ),
                // Time stamps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, snapshot) {
                        return Text(
                          _formatDuration(snapshot.data ?? Duration.zero),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                    StreamBuilder<Duration?>(
                      stream: player.durationStream,
                      builder: (context, snapshot) {
                        return Text(
                          _formatDuration(snapshot.data),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            // 4. Controls Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, color: player.isShuffle ? primaryColor : Colors.white54),
                    onPressed: player.toggleShuffle,
                    iconSize: 28,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: player.previousSong,
                    iconSize: 56,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final processingState = snapshot.data?.processingState;
                      final isPlaying = snapshot.data?.playing ?? false;

                      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(child: CircularProgressIndicator(color: primaryColor)),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                          ),
                          onPressed: player.togglePlayPause,
                          iconSize: 56,
                          padding: const EdgeInsets.all(12),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: player.nextSong,
                    iconSize: 56,
                  ),
                  IconButton(
                    icon: Icon(
                      player.isRepeat ? Icons.repeat_one : Icons.repeat,
                      color: player.isRepeat ? primaryColor : Colors.white54,
                    ),
                    onPressed: player.toggleRepeat,
                    iconSize: 28,
                  ),
                ],
              ),
            ),
            
            // 5. Lyrics & Device Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.subtitles_rounded, color: Colors.white54, size: 28),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, 
                      backgroundColor: Theme.of(context).colorScheme.background,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => LyricsWidget(lyrics: displaySong.lyrics),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music_rounded, color: Colors.white54, size: 28),
                  onPressed: () {}, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}