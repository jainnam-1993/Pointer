import 'dart:ui';

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
  Uint8List? _previewImage;
  bool _isGeneratingPreview = false;

  // Track current template/format to detect changes
  ShareTemplate? _lastTemplate;
  ShareFormat? _lastFormat;

  @override
  void initState() {
    super.initState();
    // Generate initial preview after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePreview();
    });
  }

  Future<void> _generatePreview() async {
    final template = ref.read(shareTemplateProvider);
    final format = ref.read(shareFormatProvider);

    setState(() => _isGeneratingPreview = true);

    try {
      final shareService = ref.read(shareServiceProvider);
      final card = ShareCard(
        pointing: widget.pointing,
        template: template,
        format: format,
      );

      // Use lower pixelRatio for preview (faster, still looks good)
      final bytes = await shareService.captureWidget(card, pixelRatio: 1.0);

      if (mounted) {
        setState(() {
          _previewImage = bytes;
          _isGeneratingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPreview = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final template = ref.watch(shareTemplateProvider);
    final format = ref.watch(shareFormatProvider);

    // Regenerate preview when template or format changes
    if (template != _lastTemplate || format != _lastFormat) {
      _lastTemplate = template;
      _lastFormat = format;
      // Schedule regeneration after this frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generatePreview();
      });
    }

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
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.textPrimary),
            onPressed: () => _showExportSheet(context),
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
    final colors = context.colors;
    final aspectRatio = format.width / format.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate preview size that fits within constraints while maintaining aspect ratio
        final maxWidth = constraints.maxWidth * 0.85;
        final maxHeight = constraints.maxHeight * 0.85;

        double previewWidth;
        double previewHeight;

        // Fit within bounds while preserving aspect ratio
        if (maxWidth / maxHeight > aspectRatio) {
          // Constrained by height
          previewHeight = maxHeight;
          previewWidth = previewHeight * aspectRatio;
        } else {
          // Constrained by width
          previewWidth = maxWidth;
          previewHeight = previewWidth / aspectRatio;
        }

        return Container(
          width: previewWidth,
          height: previewHeight,
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
          clipBehavior: Clip.antiAlias,
          child: _isGeneratingPreview || _previewImage == null
              ? Container(
                  color: colors.glassBackground,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colors.textMuted),
                    ),
                  ),
                )
              : Image.memory(
                  _previewImage!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // Prevents flickering during updates
                ),
        );
      },
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
        // Get screen bounds for iPad popover positioning
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;
        await shareService.shareImage(
          imageBytes,
          '',
          sharePositionOrigin: sharePositionOrigin,
        );
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

  void _showExportSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = context.colors;
    final isDark = context.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.92),
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _ExportOption(
                  icon: Icons.copy,
                  label: 'Copy Text',
                  onTap: () {
                    Navigator.pop(context);
                    _handleExportOption('clipboard');
                  },
                ),
                _ExportOption(
                  icon: Icons.text_fields,
                  label: 'Share as Text',
                  onTap: () {
                    Navigator.pop(context);
                    _handleExportOption('text');
                  },
                ),
                _ExportOption(
                  icon: Icons.book,
                  label: 'Export to Day One',
                  onTap: () {
                    Navigator.pop(context);
                    _handleExportOption('dayone');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExportOption(String option) async {
    final shareService = ref.read(shareServiceProvider);
    HapticFeedback.lightImpact();

    // Get screen bounds for iPad popover positioning
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

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
        await shareService.shareText(
          widget.pointing,
          sharePositionOrigin: sharePositionOrigin,
        );
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

/// Export option item for the glass bottom sheet
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colors.textSecondary),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
