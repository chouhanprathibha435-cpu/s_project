import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/gallery_image.dart';
import '../services/gallery_state.dart';

/// Shows confirmation dialog for deleting an image from the gallery.
Future<bool> showDeleteImageDialog(
  BuildContext context, {
  required String imageName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 36),
        title: const Text('Delete Photo?'),
        content: Text(
          'Are you sure you want to permanently delete "$imageName"?\n\nIt will also be removed from any albums.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Shows dialog to create a new album.
Future<String?> showCreateAlbumDialog(BuildContext context) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final albumName = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: const Icon(Icons.create_new_folder_rounded, size: 36),
        title: const Text('New Album'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter a title for your new photo collection:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Album Name',
                  hintText: 'e.g. Vacation 2026, Architecture...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.photo_library_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an album name';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(controller.text.trim());
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Create Album'),
          ),
        ],
      );
    },
  );

  controller.dispose();
  return albumName;
}

/// Shows confirmation dialog for deleting an album (photos remain in gallery).
Future<bool> showDeleteAlbumDialog(
  BuildContext context, {
  required String albumName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: const Icon(Icons.folder_delete_rounded, color: Colors.red, size: 36),
        title: const Text('Delete Album?'),
        content: Text(
          'Are you sure you want to delete the album "$albumName"?\n\n'
          'Important: The photos inside this album will NOT be deleted from your main gallery.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Album'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Shows confirmation dialog for removing an image from an album.
Future<bool> showRemoveFromAlbumDialog(
  BuildContext context, {
  required String imageName,
  required String albumName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.orange, size: 36),
        title: const Text('Remove from Album?'),
        content: Text(
          'Remove "$imageName" from the album "$albumName"?\n\n'
          'The image will remain in your main photo gallery.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Dialog allowing the user to select which existing gallery images to add to the target album.
void showSelectImagesForAlbumDialog(
  BuildContext context, {
  required Album album,
}) {
  final gallery = GalleryScope.of(context);
  final allImages = gallery.rawImages;
  final Set<String> selectedIds = <String>{};

  // Find images not yet in this album
  final availableImages = allImages
      .where((img) => !img.albumIds.contains(album.id))
      .toList();

  if (availableImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All gallery photos are already in this album!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Add Photos to "${album.name}"'),
            content: SizedBox(
              width: 550,
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select photos from your gallery to include in this album:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: availableImages.length,
                      itemBuilder: (context, index) {
                        final img = availableImages[index];
                        final isSelected = selectedIds.contains(img.id);

                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedIds.remove(img.id);
                              } else {
                                selectedIds.add(img.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  img.bytes,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  color: isSelected
                                      ? Colors.blue.withAlpha(100)
                                      : Colors.transparent,
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black.withAlpha(120),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check
                                          : Icons.circle_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        for (final id in selectedIds) {
                          gallery.addImageToAlbum(id, album.id);
                        }
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${selectedIds.length} photo(s) to "${album.name}"',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                child: Text('Add (${selectedIds.length})'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Dialog allowing user to assign a specific image to one or more albums.
void showAssignImageToAlbumsDialog(
  BuildContext context, {
  required GalleryImage image,
}) {
  final gallery = GalleryScope.of(context);
  final albums = gallery.rawAlbums;

  if (albums.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No albums created yet. Create an album first!'),
        action: SnackBarAction(
          label: 'Create',
          onPressed: () async {
            final name = await showCreateAlbumDialog(context);
            if (name != null) {
              final newAlbum = gallery.createAlbum(name);
              if (newAlbum != null) {
                gallery.addImageToAlbum(image.id, newAlbum.id);
              }
            }
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Manage Albums'),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select which albums contain "${image.name}":',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ...albums.map((album) {
                    final isInAlbum = image.albumIds.contains(album.id);
                    return CheckboxListTile(
                      value: isInAlbum,
                      title: Text(album.name),
                      secondary: const Icon(Icons.photo_library_outlined),
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            gallery.addImageToAlbum(image.id, album.id);
                          } else {
                            gallery.removeImageFromAlbum(image.id, album.id);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
}
