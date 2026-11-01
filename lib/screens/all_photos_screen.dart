import 'package:flutter/material.dart';
import '../services/gallery_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_card.dart';

/// Screen displaying all images in the gallery with responsive grid layout.
class AllPhotosScreen extends StatelessWidget {
  const AllPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final images = gallery.allImages;
    final isSearching = gallery.searchQuery.trim().isNotEmpty;

    if (gallery.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating sample laboratory images...'),
          ],
        ),
      );
    }

    if (images.isEmpty) {
      if (isSearching) {
        return EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Matching Photos',
          description:
              'No images found matching "${gallery.searchQuery}". Try searching with a different term.',
          primaryButtonText: 'Clear Search',
          onPrimaryPressed: () => gallery.clearSearch(),
        );
      }

      return EmptyStateWidget(
        icon: Icons.photo_library_outlined,
        title: 'Your Gallery is Empty',
        description:
            'Upload JPG, PNG, or WEBP images from your device, or load sample laboratory photos to explore all features instantly.',
        primaryButtonText: 'Add Images',
        onPrimaryPressed: () => gallery.pickImages(),
        secondaryButtonText: 'Load Sample Photos',
        onSecondaryPressed: () => gallery.reloadSamplePhotos(),
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
              Text(
                isSearching
                    ? 'Search Results: "${gallery.searchQuery}"'
                    : 'All Photos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${images.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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

        // Responsive Photos Grid
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ImageCard(image: images[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
