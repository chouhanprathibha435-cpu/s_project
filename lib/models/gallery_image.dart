import 'dart:typed_data';

/// Represents a single image stored in the gallery.
class GalleryImage {
  final String id;
  final String name;
  final Uint8List bytes;
  final int sizeInBytes;
  final DateTime dateAdded;
  bool isFavorite;
  final Set<String> albumIds;

  GalleryImage({
    required this.id,
    required this.name,
    required this.bytes,
    required this.sizeInBytes,
    required this.dateAdded,
    this.isFavorite = false,
    Set<String>? albumIds,
  }) : albumIds = albumIds ?? <String>{};

  /// Returns user-friendly formatted file size (e.g. 1.2 MB or 450 KB).
  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Returns user-friendly formatted date (YYYY-MM-DD).
  String get formattedDate {
    final y = dateAdded.year;
    final m = dateAdded.month.toString().padLeft(2, '0');
    final d = dateAdded.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
