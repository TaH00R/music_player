// lib/models/songs.dart
class Song {
  final String title;
  final String artist;
  final String path;
  final String album;
  final String? lyrics; 

  Song({
    required this.title,
    required this.artist,
    required this.path,
    required this.album,
    this.lyrics, 
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'path': path,
      'album': album,
      'lyrics': lyrics,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      title: map['title'],
      artist: map['artist'],
      path: map['path'],
      album: map['album'],
      lyrics: map['lyrics'],
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}