// lib/widgets/lyrics_widget.dart
import 'package:flutter/material.dart';

class LyricsWidget extends StatelessWidget {
  final String? lyrics;
  const LyricsWidget({super.key, this.lyrics});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    if (lyrics == null || lyrics!.trim().isEmpty) {
      return SizedBox(
        height: mediaQuery.size.height * 0.3,
        child: Center(
          child: Text(
            "No Lyrics Available for this track.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      height: mediaQuery.size.height * 0.9, 
      padding: EdgeInsets.only(top: mediaQuery.padding.top + 16, bottom: 16),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2.5),
            ),
            margin: const EdgeInsets.only(bottom: 20),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lyrics",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    lyrics!,
                    style: const TextStyle(
                      fontSize: 28, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}