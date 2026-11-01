import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/gallery_image.dart';
import 'sample_data.dart';

/// Central state manager for the Image Gallery App.
/// Uses Flutter's built-in ChangeNotifier for reactive, beginner-friendly state management.
class GalleryState extends ChangeNotifier {
  final List<GalleryImage> _images = [];
  final List<Album> _albums = [];
  String _searchQuery = '';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = false;

  GalleryState() {
    // Automatically load starter sample images so the project looks amazing immediately.
    _initSampleData();
  }

  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  String get searchQuery => _searchQuery;

  List<GalleryImage> get allImages {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_images);
    final query = _searchQuery.toLowerCase().trim();
    return _images
        .where((img) => img.name.toLowerCase().contains(query))
        .toList();
  }

  List<GalleryImage> get rawImages => List.unmodifiable(_images);

  List<GalleryImage> get favoriteImages {
    final favs = _images.where((img) => img.isFavorite);
    if (_searchQuery.trim().isEmpty) return favs.toList();
    final query = _searchQuery.toLowerCase().trim();
    return favs
        .where((img) => img.name.toLowerCase().contains(query))
        .toList();
  }

  List<Album> get albums {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_albums);
    final query = _searchQuery.toLowerCase().trim();
    return _albums
        .where((album) => album.name.toLowerCase().contains(query))
        .toList();
  }

  List<Album> get rawAlbums => List.unmodifiable(_albums);

  int get totalImagesCount => _images.length;
  int get favoritesCount => _images.where((img) => img.isFavorite).length;
  int get albumsCount => _albums.length;

  Future<void> _initSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final samples = await SampleDataHelper.generateSampleImages();
      _images.addAll(samples);

      // Create default starter albums
      final natureAlbum = Album(
        id: 'album_nature',
        name: 'Landscapes & Nature',
      );
      final neonAlbum = Album(
        id: 'album_art',
        name: 'Digital Art & Sci-Fi',
      );

      _albums.add(natureAlbum);
      _albums.add(neonAlbum);

      // Assign some images to starter albums
      if (_images.length >= 4) {
        _images[0].albumIds.add(natureAlbum.id);
        _images[1].albumIds.add(natureAlbum.id);
        _images[2].albumIds.add(neonAlbum.id);
        _images[3].albumIds.add(neonAlbum.id);
      }
    } catch (e) {
      debugPrint('Error generating sample images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reloads fresh sample photos
  Future<void> reloadSamplePhotos() async {
    _isLoading = true;
    notifyListeners();
    try {
      final samples = await SampleDataHelper.generateSampleImages();
      for (final sample in samples) {
        _images.insert(0, sample);
      }
    } catch (e) {
      debugPrint('Error reloading sample images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Allows picking JPG, JPEG, PNG, and WEBP images from the browser.
  Future<int> pickImages() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (files.isEmpty) {
        return 0;
      }

      int addedCount = 0;
      final now = DateTime.now();

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final bytes = await file.readAsBytes();
        final size = file.lengthSync() ?? await file.length() ?? bytes.lengthInBytes;

        if (bytes.isNotEmpty) {
          final newImage = GalleryImage(
            id: 'img_${now.millisecondsSinceEpoch}_$i',
            name: file.name,
            bytes: bytes,
            sizeInBytes: size,
            dateAdded: now,
          );
          _images.insert(0, newImage);
          addedCount++;
        }
      }

      if (addedCount > 0) {
        notifyListeners();
      }
      return addedCount;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return 0;
    }
  }

  /// Toggles favorite status for an image.
  void toggleFavorite(String imageId) {
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index].isFavorite = !_images[index].isFavorite;
      notifyListeners();
    }
  }

  /// Permanently deletes an image from the gallery and cleans album associations.
  void deleteImage(String imageId) {
    _images.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  /// Creates a new album with the provided name.
  Album? createAlbum(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final newAlbum = Album(
      id: 'album_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
    );
    _albums.add(newAlbum);
    notifyListeners();
    return newAlbum;
  }

  /// Deletes an album. Note: does NOT delete images from the gallery!
  void deleteAlbum(String albumId) {
    _albums.removeWhere((a) => a.id == albumId);
    // Remove album references from all images safely
    for (final img in _images) {
      img.albumIds.remove(albumId);
    }
    notifyListeners();
  }

  /// Associates an image with an album.
  void addImageToAlbum(String imageId, String albumId) {
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index].albumIds.add(albumId);
      notifyListeners();
    }
  }

  /// Removes an image from an album without deleting it from the main gallery.
  void removeImageFromAlbum(String imageId, String albumId) {
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index].albumIds.remove(albumId);
      notifyListeners();
    }
  }

  /// Retrieves all images currently assigned to an album.
  List<GalleryImage> getImagesForAlbum(String albumId) {
    return _images.where((img) => img.albumIds.contains(albumId)).toList();
  }

  /// Updates the active search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears the active search filter.
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Toggles between Light and Dark mode.
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// Sets specific theme mode.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Provides [GalleryState] down the widget tree using Flutter's built-in InheritedNotifier.
class GalleryScope extends InheritedNotifier<GalleryState> {
  const GalleryScope({
    super.key,
    required GalleryState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static GalleryState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GalleryScope>();
    assert(scope != null, 'No GalleryScope found in context');
    return scope!.notifier!;
  }
}
