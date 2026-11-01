import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/gallery_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImageGalleryApp());
}

/// Root widget for the Image Gallery Laboratory Application.
class ImageGalleryApp extends StatefulWidget {
  const ImageGalleryApp({super.key});

  @override
  State<ImageGalleryApp> createState() => _ImageGalleryAppState();
}

class _ImageGalleryAppState extends State<ImageGalleryApp> {
  // Central state instance holding all photos, albums, and theme settings
  late final GalleryState _galleryState;

  @override
  void initState() {
    super.initState();
    _galleryState = GalleryState();
  }

  @override
  void dispose() {
    _galleryState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder listens to state updates (e.g. theme toggle, new photos, albums)
    return ListenableBuilder(
      listenable: _galleryState,
      builder: (context, _) {
        return GalleryScope(
          notifier: _galleryState,
          child: MaterialApp(
            title: 'Image Gallery App',
            debugShowCheckedModeBanner: false,
            // Dynamic Theme Mode (Light / Dark)
            themeMode: _galleryState.themeMode,

            // Clean Modern Light Theme
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F46E5), // Modern Indigo
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Sleek Modern Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.dark,
                surface: const Color(0xFF0F172A), // Slate 900
              ),
              scaffoldBackgroundColor: const Color(0xFF090D16),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F172A),
                centerTitle: false,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Main Application Screen
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
