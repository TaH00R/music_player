
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/songs.dart';
import 'dart:math'; 

class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer(); 
  List<Song> songs = [];
  Song? currentSong;

  bool isPlaying = false;
  bool isShuffle = false;
  bool isRepeat = false;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  PlayerProvider() {
    _loadInitialSong(); 
    
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        nextSong();
      }
    });
  }
  
  void _loadInitialSong() {
    final testSong = Song(
        title: "Single Test Song - Ready to Go",
        artist: "Demo Artist",
        album: "Starter Album",
        path: "/path/to/your/music/single_test.mp3", 
        lyrics: "This is a single test lyric line.\nNow test the lyrics modal.",
    );
    
    songs = [testSong];
    currentSong = testSong; 
    notifyListeners();
  }

  void setSongs(List<Song> newSongs) {
    songs = newSongs;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    currentSong = song;
    try {
      await _audioPlayer.setFilePath(song.path);
      _audioPlayer.play();
      isPlaying = true;
    } catch (e) {
      print("Error loading or playing song (Check path): $e");
      isPlaying = false;
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (currentSong == null) return;
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
      isPlaying = false;
    } else {
      _audioPlayer.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  void stop() {
    _audioPlayer.stop();
    isPlaying = false;
    currentSong = null;
    notifyListeners();
  }

  void nextSong() {
    if (currentSong == null || songs.isEmpty) return;

    if (isShuffle) {
      final random = Random();
      playSong(songs[random.nextInt(songs.length)]);
    } else {
      int index = songs.indexOf(currentSong!);
      if (index + 1 < songs.length) {
        playSong(songs[index + 1]);
      } else if (isRepeat) {
        playSong(songs[0]); 
      } else {
        stop(); 
      }
    }
  }

  void previousSong() {
    if (currentSong == null || songs.isEmpty) return;

    int index = songs.indexOf(currentSong!);
    if (isShuffle) {
      final random = Random();
      playSong(songs[random.nextInt(songs.length)]);
    } else {
      if (index - 1 >= 0) {
        playSong(songs[index - 1]);
      } else if (isRepeat) {
        playSong(songs.last); 
      }
    }
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    isRepeat = !isRepeat;
    notifyListeners();
  }
}