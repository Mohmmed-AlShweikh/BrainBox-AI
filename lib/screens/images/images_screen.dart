import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/images_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/image_card.dart';
import '../../widgets/empty_state.dart';
import 'image_detail_screen.dart';

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageDetailScreen(sourcePath: picked.path),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.translate('error')}: $e')),
        );
      }
    }
  }

  void _showPickDialog(BuildContext context) {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.imagesColor),
              title: Text(l.translate('pickFromGallery'),
                  style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.imagesColor),
              title: Text(l.translate('takePhoto'),
                  style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteImage(BuildContext context, String id) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.translate('delete')),
        content: Text(l.translate('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ImagesProvider>().deleteImage(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final images = context.watch<ImagesProvider>().images;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.translate('images')),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            onPressed: () => _showPickDialog(context),
          ),
        ],
      ),
      body: images.isEmpty
          ? EmptyState(
              icon: Icons.photo_library_outlined,
              title: l.translate('noImages'),
              subtitle: l.translate('noImagesSub'),
              iconColor: AppColors.imagesColor,
            )
          : AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 2,
                    duration: const Duration(milliseconds: 350),
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: Dismissible(
                          key: Key(image.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error),
                          ),
                          confirmDismiss: (_) async {
                            await _deleteImage(context, image.id);
                            return false;
                          },
                          child: ImageCard(
                            image: image,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ImageDetailScreen(existingImage: image),
                              ),
                            ),
                            onFavorite: () => context
                                .read<ImagesProvider>()
                                .toggleFavorite(image),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPickDialog(context),
        child: const Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }
}
