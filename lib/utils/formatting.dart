/// Shared formatting utilities used across audio/video players and share cards.
library;

/// Formats a [Duration] as M:SS or H:MM:SS.
///
/// Used by audio/video player widgets for position and duration labels.
String formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours}:$minutes:$seconds';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Calculates font size for share card pointing text based on content length
/// and whether the card is in story (tall) or square format.
///
/// Longer content gets smaller text to fit within the card.
double calculateShareFontSize(int charCount, bool isStory) {
  if (charCount < 50) return isStory ? 48 : 40;
  if (charCount < 100) return isStory ? 40 : 34;
  if (charCount < 200) return isStory ? 32 : 28;
  return isStory ? 26 : 24;
}
