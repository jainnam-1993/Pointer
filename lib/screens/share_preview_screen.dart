import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pointings.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/share_templates/share_card.dart';

/// Share preview screen with template and format selection
class SharePreviewScreen extends ConsumerStatefulWidget {
  final Pointing pointing;

  const SharePreviewScreen({super.key, required this.pointing});

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final template = ref.watch(shareTemplateProvider);
    final format = ref.watch(shareFormatProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Share',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Export menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.textPrimary),
            color: colors.glassBackground,
            onSelected: (value) => _handleExportOption(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clipboard',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20, color: colors.textSecondary),
                    const SizedBox(width: 12),
                    Text('Copy Text', style: TextStyle(color: colors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'text',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 20, color: colors.textSecondary),
                    const SizedBox(width: 12),
                    Text('Share as Text', style: TextStyle(color: colors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dayone',
                child: Row(
                  children: [
                    Icon(Icons.book, size: 20, color: colors.textSecondary),
                    const SizedBox(width: 12),
                    Text('Export to Day One', style: TextStyle(color: colors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.background,
              colors.background.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Preview card
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildPreview(template, format),
                  ),
                ),
              ),

              // Template selector
              _buildTemplateSelector(colors, template),
              const SizedBox(height: 16),

              // Format selector
              _buildFormatSelector(colors, format),
              const SizedBox(height: 24),

              // Share button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSharing ? null : () => _shareImage(template, format),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSharing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Share Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ShareTemplate template, ShareFormat format) {
    // Scale down for preview
    final previewScale = format == ShareFormat.story ? 0.25 : 0.35;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Transform.scale(
          scale: previewScale,
          child: ShareCard(
            pointing: widget.pointing,
            template: template,
            format: format,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(PointerColors colors, ShareTemplate selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'STYLE',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: ShareTemplate.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final template = ShareTemplate.values[index];
              final isSelected = template == selected;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(shareTemplateProvider.notifier).setTemplate(template);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.2)
                        : colors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.glassBorder,
                    ),
                  ),
                  child: Text(
                    template.displayName,
                    style: TextStyle(
                      color: isSelected ? colors.primary : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector(PointerColors colors, ShareFormat selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'FORMAT',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: ShareFormat.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final format = ShareFormat.values[index];
              final isSelected = format == selected;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(shareFormatProvider.notifier).setFormat(format);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.2)
                        : colors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        format == ShareFormat.square ? Icons.crop_square : Icons.crop_portrait,
                        size: 18,
                        color: isSelected ? colors.primary : colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        format.displayName,
                        style: TextStyle(
                          color: isSelected ? colors.primary : colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    );
  }

  Future<void> _shareImage(ShareTemplate template, ShareFormat format) async {
    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();

    try {
      final shareService = ref.read(shareServiceProvider);
      final card = ShareCard(
        pointing: widget.pointing,
        template: template,
        format: format,
      );

      final imageBytes = await shareService.captureWidget(card);
      if (imageBytes != null) {
        await shareService.shareImage(imageBytes, '');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _handleExportOption(String option) async {
    final shareService = ref.read(shareServiceProvider);
    HapticFeedback.lightImpact();

    switch (option) {
      case 'clipboard':
        await shareService.copyToClipboard(widget.pointing);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        }
        break;
      case 'text':
        await shareService.shareText(widget.pointing);
        break;
      case 'dayone':
        final success = await shareService.exportToDayOne(widget.pointing);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Day One app not installed')),
          );
        }
        break;
    }
  }
}
