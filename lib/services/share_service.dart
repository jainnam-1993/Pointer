import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/pointings.dart';
import '../providers/providers.dart';

/// Available share card templates
enum ShareTemplate {
  minimal('Minimal', 'Clean, text-focused design'),
  gradient('Gradient', 'App gradient background'),
  tradition('Tradition', 'Colors matching the tradition');

  const ShareTemplate(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Available share formats (aspect ratios)
enum ShareFormat {
  square('Square', '1:1 for feeds', 1080, 1080),
  story('Story', '9:16 for stories', 1080, 1920);

  const ShareFormat(this.displayName, this.description, this.width, this.height);
  final String displayName;
  final String description;
  final int width;
  final int height;

  double get aspectRatio => width / height;
}

/// Provider for share template preference (persisted)
final shareTemplateProvider = StateNotifierProvider<ShareTemplateNotifier, ShareTemplate>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShareTemplateNotifier(prefs);
});

class ShareTemplateNotifier extends StateNotifier<ShareTemplate> {
  final SharedPreferences _prefs;
  static const _storageKey = 'pointer_share_template';

  ShareTemplateNotifier(this._prefs) : super(ShareTemplate.gradient) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = _prefs.getString(_storageKey);
    if (saved != null) {
      state = ShareTemplate.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => ShareTemplate.gradient,
      );
    }
  }

  void setTemplate(ShareTemplate template) {
    state = template;
    _prefs.setString(_storageKey, template.name);
  }
}

/// Provider for share format preference (persisted)
final shareFormatProvider = StateNotifierProvider<ShareFormatNotifier, ShareFormat>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShareFormatNotifier(prefs);
});

class ShareFormatNotifier extends StateNotifier<ShareFormat> {
  final SharedPreferences _prefs;
  static const _storageKey = 'pointer_share_format';

  ShareFormatNotifier(this._prefs) : super(ShareFormat.square) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = _prefs.getString(_storageKey);
    if (saved != null) {
      state = ShareFormat.values.firstWhere(
        (f) => f.name == saved,
        orElse: () => ShareFormat.square,
      );
    }
  }

  void setFormat(ShareFormat format) {
    state = format;
    _prefs.setString(_storageKey, format.name);
  }
}

/// Provider for share service
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

/// Service for creating and sharing quote cards
class ShareService {
  final ScreenshotController screenshotController = ScreenshotController();

  /// Capture a widget as an image
  Future<Uint8List?> captureWidget(Widget widget, {double pixelRatio = 3.0}) async {
    return await screenshotController.captureFromWidget(
      widget,
      pixelRatio: pixelRatio,
      delay: const Duration(milliseconds: 100),
    );
  }

  /// Share captured image via system share sheet
  Future<void> shareImage(Uint8List imageBytes, String text) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/pointer_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
    );
  }

  /// Share to Instagram Stories (iOS only)
  Future<bool> shareToInstagramStories(Uint8List imageBytes) async {
    if (!Platform.isIOS) return false;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pointer_story.png');
      await file.writeAsBytes(imageBytes);

      // Instagram Stories URL scheme
      final uri = Uri.parse('instagram-stories://share');
      if (await canLaunchUrl(uri)) {
        // Note: For full Instagram Stories integration, would need
        // UIPasteboard on iOS. Using share sheet as fallback.
        await Share.shareXFiles([XFile(file.path)]);
        return true;
      }
    } catch (e) {
      // Fallback to regular share
    }
    return false;
  }

  /// Copy pointing as formatted text to clipboard
  Future<void> copyToClipboard(Pointing pointing) async {
    final text = _formatForClipboard(pointing);
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Share plain text (existing behavior)
  Future<void> shareText(Pointing pointing) async {
    final text = _formatForShare(pointing);
    await Share.share(text);
  }

  /// Export to Day One journal (iOS)
  Future<bool> exportToDayOne(Pointing pointing) async {
    final text = Uri.encodeComponent(_formatForJournal(pointing));
    final uri = Uri.parse('dayone://post?entry=$text');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Export to Apple Notes via share sheet
  Future<void> exportToNotes(Pointing pointing) async {
    final text = _formatForJournal(pointing);
    await Share.share(text);
  }

  /// Get tradition display name
  String _getTraditionName(Tradition tradition) {
    return traditions[tradition]?.name ?? tradition.name;
  }

  /// Format pointing for clipboard (markdown)
  String _formatForClipboard(Pointing pointing) {
    final buffer = StringBuffer();
    buffer.writeln('> "${pointing.content}"');
    if (pointing.teacher != null) {
      buffer.writeln('>');
      buffer.writeln('> — ${pointing.teacher}');
    }
    buffer.writeln();
    buffer.writeln('*${_getTraditionName(pointing.tradition)}*');
    return buffer.toString();
  }

  /// Format pointing for plain text share
  String _formatForShare(Pointing pointing) {
    final buffer = StringBuffer();
    buffer.writeln('"${pointing.content}"');
    if (pointing.teacher != null) {
      buffer.writeln('\n— ${pointing.teacher}');
    }
    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Here Now - Daily Awareness Pointings');
    buffer.writeln('Download: https://pointer.app/download');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    return buffer.toString();
  }

  /// Format pointing for journal export
  String _formatForJournal(Pointing pointing) {
    final buffer = StringBuffer();
    buffer.writeln('# ${_getTraditionName(pointing.tradition)} Pointing');
    buffer.writeln();
    buffer.writeln('"${pointing.content}"');
    buffer.writeln();
    if (pointing.teacher != null) {
      buffer.writeln('— ${pointing.teacher}');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Saved from Here Now on ${DateFormat.yMMMd().format(DateTime.now())}');
    return buffer.toString();
  }
}
