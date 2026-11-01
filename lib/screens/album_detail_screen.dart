import 'package:flutter/material.dart';
import '../models/album.dart';
import '../services/gallery_state.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/image_card.dart';

/// Screen displaying the photos contained within a specific album.
class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get live images for this album from gallery state
    final albumImages = gallery.getImagesForAlbum(album.id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.folder_open_rounded, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                album.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${albumImages.length}',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Add Photos to Album button
          FilledButton.icon(
            onPressed: () {
              showSelectImagesForAlbumDialog(context, album: album);
            },
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: const Text('Add Photos'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete Album button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Delete Album (photos remain safe in gallery)',
            onPressed: () async {
              final confirm = await showDeleteAlbumDialog(
                context,
                albumName: album.name,
              );
              if (confirm && context.mounted) {
                gallery.deleteAlbum(album.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Album "${album.name}" deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: albumImages.isEmpty
          ? EmptyStateWidget(
              icon: Icons.photo_library_outlined,
              title: 'Album is Empty',
              description:
                  'There are currently no photos in "${album.name}". You can add photos from your main gallery at any time.',
              primaryButtonText: 'Add Photos to Album',
              onPrimaryPressed: () {
                showSelectImagesForAlbumDialog(context, album: album);
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                  child: Text(
                    'Photos in this collection (Removing a photo from an album does not delete it from your gallery)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: albumImages.length,
                        itemBuilder: (context, index) {
                          return ImageCard(
                            image: albumImages[index],
                            currentAlbumId: album.id,
                            currentAlbumName: album.name,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
