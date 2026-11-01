import 'package:flutter/material.dart';
import '../models/gallery_image.dart';
import '../services/gallery_state.dart';
import 'dialogs.dart';
import 'image_viewer.dart';

/// Interactive card widget displaying a photo thumbnail with action buttons.
class ImageCard extends StatefulWidget {
  final GalleryImage image;
  final String? currentAlbumId;
  final String? currentAlbumName;

  const ImageCard({
    super.key,
    required this.image,
    this.currentAlbumId,
    this.currentAlbumName,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary
                : colorScheme.outlineVariant.withAlpha(80),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isHovered ? 35 : 12),
              blurRadius: _isHovered ? 16 : 6,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ImageViewerModal.show(context, widget.image),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Thumbnail with floating overlay buttons
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'image_${widget.image.id}',
                      child: Image.memory(
                        widget.image.bytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: colorScheme.error,
                            ),
                          );
                        },
                      ),
                    ),

                    // Top Action Badges (Favorite & Quick Menu)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Favorite Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                widget.image.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: widget.image.isFavorite
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                              tooltip: widget.image.isFavorite
                                  ? 'Unfavorite'
                                  : 'Favorite',
                              onPressed: () {
                                gallery.toggleFavorite(widget.image.id);
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          // More Actions Popup Menu
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              shape: BoxShape.circle,
                            ),
                            child: PopupMenuButton<String>(
                              iconSize: 20,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white,
                              ),
                              tooltip: 'More actions',
                              onSelected: (value) async {
                                if (value == 'view') {
                                  ImageViewerModal.show(context, widget.image);
                                } else if (value == 'album') {
                                  showAssignImageToAlbumsDialog(
                                    context,
                                    image: widget.image,
                                  );
                                } else if (value == 'remove_from_album') {
                                  if (widget.currentAlbumId != null &&
                                      widget.currentAlbumName != null) {
                                    final confirm =
                                        await showRemoveFromAlbumDialog(
                                      context,
                                      imageName: widget.image.name,
                                      albumName: widget.currentAlbumName!,
                                    );
                                    if (confirm) {
                                      gallery.removeImageFromAlbum(
                                        widget.image.id,
                                        widget.currentAlbumId!,
                                      );
                                    }
                                  }
                                } else if (value == 'delete') {
                                  final confirm = await showDeleteImageDialog(
                                    context,
                                    imageName: widget.image.name,
                                  );
                                  if (confirm) {
                                    gallery.deleteImage(widget.image.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Deleted "${widget.image.name}"',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.fullscreen_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text('View Fullscreen'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'album',
                                  child: Row(
                                    children: [
                                      Icon(Icons.folder_open_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text('Manage Albums'),
                                    ],
                                  ),
                                ),
                                if (widget.currentAlbumId != null)
                                  const PopupMenuItem(
                                    value: 'remove_from_album',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle_outline_rounded,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Remove from Album'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Delete Photo',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Info Bar with File Name and Quick Delete Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.image.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.image.formattedSize} • ${widget.image.formattedDate}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick Delete button
                    IconButton(
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error.withAlpha(190),
                      ),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final confirm = await showDeleteImageDialog(
                          context,
                          imageName: widget.image.name,
                        );
                        if (confirm) {
                          gallery.deleteImage(widget.image.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${widget.image.name}"'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
