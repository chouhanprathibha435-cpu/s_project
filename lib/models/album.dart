/// Represents an album created by the user to organize photos.
class Album {
  final String id;
  String name;
  final DateTime createdAt;

  Album({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Returns user-friendly formatted date (YYYY-MM-DD).
  String get formattedDate {
    final y = createdAt.year;
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
