import 'package:flutter/material.dart';
import '../models/gallery_image.dart';
import '../services/gallery_state.dart';
import 'dialogs.dart';

/// Full-screen modal viewer with InteractiveViewer (pan & zoom) and control bar.
class ImageViewerModal extends StatelessWidget {
  final GalleryImage image;

  const ImageViewerModal({
    super.key,
    required this.image,
  });

  static void show(BuildContext context, GalleryImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withAlpha(220),
        pageBuilder: (context, _, _) => ImageViewerModal(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    // Find current updated image state from gallery
    final currentImage = gallery.rawImages.firstWhere(
      (img) => img.id == image.id,
      orElse: () => image,
    );

    // Get album names that this image belongs to
    final albumNames = gallery.rawAlbums
        .where((a) => currentImage.albumIds.contains(a.id))
        .map((a) => a.name)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Image with Pan & Zoom support
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70, bottom: 80, left: 16, right: 16),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'image_${currentImage.id}',
                    child: Image.memory(
                      currentImage.bytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Top Bar with filename and actions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(200),
                      Colors.black.withAlpha(0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      tooltip: 'Back to Gallery',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentImage.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${currentImage.formattedSize} • Added on ${currentImage.formattedDate}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Favorite Toggle
                    IconButton(
                      icon: Icon(
                        currentImage.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: currentImage.isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      tooltip: currentImage.isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                      onPressed: () {
                        gallery.toggleFavorite(currentImage.id);
                      },
                    ),
                    // Add to Album button
                    IconButton(
                      icon: const Icon(Icons.drive_file_move_outlined, color: Colors.white),
                      tooltip: 'Add to Album',
                      onPressed: () {
                        showAssignImageToAlbumsDialog(context, image: currentImage);
                      },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      tooltip: 'Delete Image',
                      onPressed: () async {
                        final shouldDelete = await showDeleteImageDialog(
                          context,
                          imageName: currentImage.name,
                        );
                        if (shouldDelete && context.mounted) {
                          gallery.deleteImage(currentImage.id);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${currentImage.name}"'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar with Albums indicator tags
            if (albumNames.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.folder_outlined, color: Colors.white70, size: 16),
                        ...albumNames.map(
                          (name) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
