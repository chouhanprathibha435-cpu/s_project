import 'package:flutter/material.dart';
import '../models/album.dart';
import '../services/gallery_state.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import 'album_detail_screen.dart';

/// Screen listing all user albums with creation and deletion capabilities.
class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final albums = gallery.albums;
    final isSearching = gallery.searchQuery.trim().isNotEmpty;

    if (albums.isEmpty) {
      if (isSearching) {
        return EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Matching Albums',
          description:
              'No albums found matching "${gallery.searchQuery}".',
          primaryButtonText: 'Clear Search',
          onPrimaryPressed: () => gallery.clearSearch(),
        );
      }

      return EmptyStateWidget(
        icon: Icons.folder_copy_outlined,
        title: 'No Albums Created',
        description:
            'Organize your photos into neat albums (e.g. Vacation, Lab Work, Nature). Deleting albums never deletes your photos!',
        primaryButtonText: 'Create First Album',
        onPrimaryPressed: () async {
          final name = await showCreateAlbumDialog(context);
          if (name != null) {
            gallery.createAlbum(name);
          }
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header stats & Create button bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              const Icon(Icons.folder_special_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                isSearching
                    ? 'Albums Matching: "${gallery.searchQuery}"'
                    : 'Photo Albums',
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
                  '${albums.length}',
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
                )
              else
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final name = await showCreateAlbumDialog(context);
                    if (name != null) {
                      gallery.createAlbum(name);
                    }
                  },
                  icon: const Icon(Icons.create_new_folder_rounded, size: 18),
                  label: const Text('New Album'),
                ),
            ],
          ),
        ),

        // Grid of Albums
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  return _AlbumCard(album: albums[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlbumCard extends StatefulWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final gallery = GalleryScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final albumImages = gallery.getImagesForAlbum(widget.album.id);
    final hasImages = albumImages.isNotEmpty;
    final coverImage = hasImages ? albumImages.first : null;

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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(album: widget.album),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Preview or Placeholder
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImages && coverImage != null)
                      Image.memory(
                        coverImage.bytes,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: colorScheme.primaryContainer.withAlpha(60),
                        child: Center(
                          child: Icon(
                            Icons.folder_rounded,
                            size: 64,
                            color: colorScheme.primary.withAlpha(150),
                          ),
                        ),
                      ),

                    // Top Action Overlay: Delete Album button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 18,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Delete Album',
                          onPressed: () async {
                            final confirm = await showDeleteAlbumDialog(
                              context,
                              albumName: widget.album.name,
                            );
                            if (confirm && context.mounted) {
                              gallery.deleteAlbum(widget.album.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Album "${widget.album.name}" deleted',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    // Count Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(170),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${albumImages.length} ${albumImages.length == 1 ? 'photo' : 'photos'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Info: Album Name & Created Date
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.album.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Created ${widget.album.formattedDate}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
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
