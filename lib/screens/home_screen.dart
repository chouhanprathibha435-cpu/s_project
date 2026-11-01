import 'package:flutter/material.dart';
import '../services/gallery_state.dart';
import '../widgets/dialogs.dart';
import 'all_photos_screen.dart';
import 'albums_screen.dart';
import 'favorites_screen.dart';

/// Main scaffold managing the primary tabs, responsive navigation, search bar, and app bar actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpandedOnMobile = false;

  final List<Widget> _screens = const [
    AllPhotosScreen(),
    FavoritesScreen(),
    AlbumsScreen(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, GalleryState gallery) {
    gallery.setSearchQuery(value);
  }

  void _clearSearch(GalleryState gallery) {
    _searchController.clear();
    gallery.clearSearch();
    setState(() {
      _isSearchExpandedOnMobile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = gallery.themeMode == ThemeMode.dark ||
        (gallery.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Keep search field text synchronized if cleared from inside screen
    if (gallery.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 750;

        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            titleSpacing: 16,
            title: _isSearchExpandedOnMobile && !isWideScreen
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search photos or albums...',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => _clearSearch(gallery),
                      ),
                    ),
                    onChanged: (val) => _onSearchChanged(val, gallery),
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Image Gallery',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
            actions: [
              // Search Field on Wide Screen
              if (isWideScreen)
                Container(
                  width: 280,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => _clearSearch(gallery),
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(120),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => _onSearchChanged(val, gallery),
                  ),
                )
              else if (!_isSearchExpandedOnMobile)
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                  onPressed: () {
                    setState(() {
                      _isSearchExpandedOnMobile = true;
                    });
                  },
                ),

              // Add Image button (Desktop / Wide screen)
              if (isWideScreen)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final count = await gallery.pickImages();
                      if (count > 0 && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully added $count photo${count > 1 ? 's' : ''} to gallery!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                    label: const Text('Add Image'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // Quick Actions Menu (Sample Data & Create Album)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'More options',
                onSelected: (value) async {
                  if (value == 'sample_data') {
                    await gallery.reloadSamplePhotos();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Loaded fresh laboratory sample photos!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else if (value == 'new_album') {
                    final name = await showCreateAlbumDialog(context);
                    if (name != null) {
                      gallery.createAlbum(name);
                      setState(() {
                        _selectedIndex = 2; // Jump to Albums tab
                      });
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sample_data',
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 20),
                        SizedBox(width: 10),
                        Text('Reload Sample Photos'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_album',
                    child: Row(
                      children: [
                        Icon(Icons.create_new_folder_rounded, size: 20),
                        SizedBox(width: 10),
                        Text('Create New Album'),
                      ],
                    ),
                  ),
                ],
              ),

              // Theme Mode Toggle Button
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => gallery.toggleTheme(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Responsive Layout Body
          body: isWideScreen
              ? Row(
                  children: [
                    // Desktop Navigation Sidebar (NavigationRail)
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -0.8,
                      destinations: [
                        NavigationRailDestination(
                          icon: Badge(
                            label: Text('${gallery.totalImagesCount}'),
                            child: const Icon(Icons.photo_library_outlined),
                          ),
                          selectedIcon: Badge(
                            label: Text('${gallery.totalImagesCount}'),
                            child: const Icon(Icons.photo_library_rounded),
                          ),
                          label: const Text('All Photos'),
                        ),
                        NavigationRailDestination(
                          icon: Badge(
                            backgroundColor: Colors.redAccent,
                            label: Text('${gallery.favoritesCount}'),
                            child: const Icon(Icons.favorite_border_rounded),
                          ),
                          selectedIcon: Badge(
                            backgroundColor: Colors.redAccent,
                            label: Text('${gallery.favoritesCount}'),
                            child: const Icon(Icons.favorite_rounded),
                          ),
                          label: const Text('Favorites'),
                        ),
                        NavigationRailDestination(
                          icon: Badge(
                            backgroundColor: Colors.blueAccent,
                            label: Text('${gallery.albumsCount}'),
                            child: const Icon(Icons.folder_outlined),
                          ),
                          selectedIcon: Badge(
                            backgroundColor: Colors.blueAccent,
                            label: Text('${gallery.albumsCount}'),
                            child: const Icon(Icons.folder_rounded),
                          ),
                          label: const Text('Albums'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    // Selected Page Content
                    Expanded(
                      child: _screens[_selectedIndex],
                    ),
                  ],
                )
              : _screens[_selectedIndex],

          // Floating Action Button for Mobile/Narrow window
          floatingActionButton: !isWideScreen
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final count = await gallery.pickImages();
                    if (count > 0 && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $count photo(s) to gallery!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded),
                  label: const Text('Add Image'),
                )
              : null,

          // Bottom Navigation for Mobile / Narrow screens
          bottomNavigationBar: !isWideScreen
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Badge(
                        label: Text('${gallery.totalImagesCount}'),
                        child: const Icon(Icons.photo_library_outlined),
                      ),
                      selectedIcon: Badge(
                        label: Text('${gallery.totalImagesCount}'),
                        child: const Icon(Icons.photo_library_rounded),
                      ),
                      label: 'All Photos',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        backgroundColor: Colors.redAccent,
                        label: Text('${gallery.favoritesCount}'),
                        child: const Icon(Icons.favorite_border_rounded),
                      ),
                      selectedIcon: Badge(
                        backgroundColor: Colors.redAccent,
                        label: Text('${gallery.favoritesCount}'),
                        child: const Icon(Icons.favorite_rounded),
                      ),
                      label: 'Favorites',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        backgroundColor: Colors.blueAccent,
                        label: Text('${gallery.albumsCount}'),
                        child: const Icon(Icons.folder_outlined),
                      ),
                      selectedIcon: Badge(
                        backgroundColor: Colors.blueAccent,
                        label: Text('${gallery.albumsCount}'),
                        child: const Icon(Icons.folder_rounded),
                      ),
                      label: 'Albums',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
