import 'package:flutter/material.dart';
import '../services/gallery_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_card.dart';

/// Screen displaying only images marked as favorite.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final favImages = gallery.favoriteImages;
    final isSearching = gallery.searchQuery.trim().isNotEmpty;

    if (favImages.isEmpty) {
      if (isSearching) {
        return EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Matching Favorites',
          description:
              'No favorite images found matching "${gallery.searchQuery}".',
          primaryButtonText: 'Clear Search',
          onPrimaryPressed: () => gallery.clearSearch(),
        );
      }

      return const EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: 'No Favorites Yet',
        description:
            'Tap the heart icon on any photo in your gallery to keep your most loved memories saved here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header stats bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                isSearching
                    ? 'Favorites Matching: "${gallery.searchQuery}"'
                    : 'Favorite Photos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${favImages.length}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (isSearching)
                TextButton.icon(
                  onPressed: () => gallery.clearSearch(),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear search'),
                ),
            ],
          ),
        ),

        // Grid of Favorite Images
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemCount: favImages.length,
                itemBuilder: (context, index) {
                  return ImageCard(image: favImages[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
