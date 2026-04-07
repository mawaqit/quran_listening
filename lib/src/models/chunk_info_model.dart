import 'dart:io';

class ChunkInfo {
  final int index;
  final int start;
  int end;
  final File file;
  final int existingBytes;

  ChunkInfo({
    required this.index,
    required this.start,
    required this.end,
    required this.file,
    required this.existingBytes,
  });

  int get expectedSize => end - start + 1;
  void clampEnd(int newEnd) => end = newEnd;
}
