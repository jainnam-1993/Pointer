import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../data/teachers.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../services/audio_pointing_service.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/typography.dart';
import '../utils/motion.dart';
import '../widgets/shared_ambient.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/commentary_section.dart';
import '../widgets/glass_card.dart';
import '../widgets/share_preview_helper.dart';
import '../widgets/teacher_sheet.dart';
import 'library_screen.dart';

/**
 * Daily pointing home screen with auto-advance timer and swipe navigation.
 *
 * The pointing owns the screen: one quiet glass plate holds the sentence, its
 * attribution and any media; everything else (inquiry link, next, swipe hint) is
 * demoted to quiet text below it. Supports:
 * - Vertical swipe that follows the finger and settles back on a spring. The drag
 *   offset lives in a [ValueNotifier], so a pointer move repaints only the card.
 * - Auto-advance (default 60 s, [autoAdvanceDelayProvider]) that runs only while Home
 *   is visible, the app is resumed, and no pointing audio is playing.
 * - Long-press to save, double-tap for focus (zen) mode, share sheet.
 * - Screen reader custom actions: next, previous, focus mode, save, share.
 *
 * Layout is width-driven (no phone-width breakpoints) so adaptive layouts can extend it.
 */
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  /**
   * Static flag to disable auto-advance in tests.
   * Set to `true` in test `setUp` to prevent timer issues.
   */
  static bool disableAutoAdvanceForTesting = false;

  /** The swipe hint is taught during this many sessions, then trusted to be known. */
  static const int swipeHintSessions = 3;

  /** SharedPreferences key counting Home sessions (one per app launch; the shell keeps Home alive). */
  static const String sessionCountKey = 'home_session_count_v1';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  /** Whether a pointing transition animation is in progress. */
  bool _isAnimating = false;

  /** Whether the user is currently mid-swipe (suppresses auto-advance). */
  bool _isSwipeInProgress = false;

  /** Hides the swipe hint once the user has swiped in this session. */
  bool _hasSwipedThisSession = false;

  /** Whether this session is one of the first [HomeScreen.swipeHintSessions]; only then is the swipe hint shown. */
  bool _isEarlySession = true;

  /** Vertical card offset while dragging and settling; listened to by the card only. */
  final ValueNotifier<double> _dragOffset = ValueNotifier<double>(0);

  /** Drives the spring settle of [_dragOffset] back to rest. */
  late final AnimationController _settle;

  /** Periodic timer that auto-advances to the next pointing. */
  Timer? _autoAdvanceTimer;

  void _toggleZenMode() {
    final current = ref.read(zenModeProvider);
    final newValue = !current;
    ref.read(settingsProvider.notifier).setZenMode(newValue);
    if (newValue) Haptics.light();
  }

  @override
  void initState() {
    super.initState();
    _settle = AnimationController.unbounded(vsync: this)..addListener(() => _dragOffset.value = _settle.value);
    _countSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pointing = ref.read(currentPointingProvider);
      _announcePointingContent(context, pointing);
      _startAutoAdvanceTimer();
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _settle.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  /** Counts this Home session and decides whether the swipe hint still teaches. */
  void _countSession() {
    final prefs = ref.read(sharedPreferencesProvider);
    final seen = prefs.getInt(HomeScreen.sessionCountKey) ?? 0;
    _isEarlySession = seen < HomeScreen.swipeHintSessions;
    if (seen <= HomeScreen.swipeHintSessions) prefs.setInt(HomeScreen.sessionCountKey, seen + 1);
  }

  /** Starts or restarts the auto-advance timer based on settings. */
  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    if (HomeScreen.disableAutoAdvanceForTesting) return;
    if (!ref.read(autoAdvanceProvider)) return;
    final delaySeconds = ref.read(autoAdvanceDelayProvider);
    _autoAdvanceTimer = Timer.periodic(Duration(seconds: delaySeconds), (_) => _handleAutoAdvance());
  }

  /**
   * True when Home is what the user sees: its tab is active and nothing covers it
   * (inactive shell branches and covered routes run under `TickerMode(enabled: false)`),
   * and the app is in the foreground.
   */
  bool get _isHomeVisible {
    if (!mounted || !TickerMode.of(context)) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  /** True while a pointing's guided audio is playing, so auto-advance never cuts it off. */
  bool get _isMediaPlaying => ref.read(audioPointingServiceProvider).currentState == AudioPlaybackState.playing;

  /**
   * Core advance logic shared by auto-advance and manual next.
   *
   * [userInitiated] adds haptics and records tradition affinity; timer-driven
   * advances are passive and must not skew personalization.
   */
  Future<void> _advancePointing({bool userInitiated = false}) async {
    if (userInitiated) Haptics.light();

    setState(() => _isAnimating = true);

    ref.read(currentPointingProvider.notifier).nextPointing();
    ref.read(dailyUsageProvider.notifier).recordView();

    await Future.delayed(300.ms);
    if (!mounted) return;
    setState(() => _isAnimating = false);

    final newPointing = ref.read(currentPointingProvider);
    _announcePointingContent(context, newPointing);

    await ref.read(storageServiceProvider).markPointingAsViewed(newPointing.id);
    if (!mounted) return;

    if (userInitiated) {
      await ref.read(affinityServiceProvider).recordView(newPointing.tradition);
      if (!mounted) return;
    }

    // Restart timer for the new pointing (gives the full delay with new content)
    _startAutoAdvanceTimer();
  }

  /** Handles automatic advancement to next pointing. */
  Future<void> _handleAutoAdvance() async {
    if (_isAnimating || _isSwipeInProgress) return;
    if (!ref.read(autoAdvanceProvider)) {
      _autoAdvanceTimer?.cancel();
      return;
    }
    // Pause, do not advance, while Home is hidden or audio plays.
    if (!_isHomeVisible || _isMediaPlaying) return;
    await _advancePointing();
  }

  /** Announces pointing content to screen readers. */
  void _announcePointingContent(BuildContext context, Pointing pointing) {
    final traditionInfo = traditions[pointing.tradition]!;
    final announcement = StringBuffer();
    announcement.write('New pointing from ${traditionInfo.name}. ');
    announcement.write(pointing.content);
    if (pointing.teacher != null) announcement.write('. By ${pointing.teacher}');
    if (pointing.source != null) announcement.write('. From ${pointing.source}');
    SemanticsService.sendAnnouncement(View.of(context), announcement.toString(), TextDirection.ltr);
  }

  /** Handles manual advance to the next pointing. */
  Future<void> _handleNext() async {
    if (_isAnimating) return;
    await _advancePointing(userInitiated: true);
  }

  /** Handles navigation to the previous pointing. */
  Future<void> _handlePrevious() async {
    if (_isAnimating) return;
    Haptics.light();
    setState(() => _isAnimating = true);
    ref.read(currentPointingProvider.notifier).previousPointing();

    await Future.delayed(300.ms);
    if (!mounted) return;
    setState(() => _isAnimating = false);

    _announcePointingContent(context, ref.read(currentPointingProvider));
    _startAutoAdvanceTimer();
  }

  /** Opens the share preview for the current pointing. */
  Future<void> _handleShare() async {
    final pointing = ref.read(currentPointingProvider);
    Haptics.light();
    showSharePreview(context, pointing);
  }

  /** Saves the current pointing to favorites (saves are weighted 3x in affinity). */
  Future<void> _handleSave() async {
    final pointing = ref.read(currentPointingProvider);
    if (ref.read(favoritesProvider).contains(pointing.id)) return;

    Haptics.light();
    await ref.read(favoritesProvider.notifier).toggle(pointing.id);
    if (!mounted) return;
    await ref.read(widgetServiceProvider).updateFavorites(ref.read(favoritesProvider).toSet());
    if (!mounted) return;
    await ref.read(affinityServiceProvider).recordSave(pointing.tradition);
  }

  /** Toggles the favorite state of the current pointing from the heart button. */
  Future<void> _handleToggleFavorite() async {
    final pointing = ref.read(currentPointingProvider);
    if (!ref.read(favoritesProvider).contains(pointing.id)) {
      await _handleSave();
      return;
    }
    Haptics.light();
    await ref.read(favoritesProvider.notifier).toggle(pointing.id);
    if (!mounted) return;
    await ref.read(widgetServiceProvider).updateFavorites(ref.read(favoritesProvider).toSet());
  }

  // ---------------------------------------------------------------------------
  // Swipe: follows the finger, settles on a spring
  // ---------------------------------------------------------------------------

  void _onDragStart(DragStartDetails _) {
    _settle.stop();
    _isSwipeInProgress = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Light resistance so the card tracks the finger without running away from it.
    _dragOffset.value += details.delta.dy * 0.6;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final offset = _dragOffset.value;
    _isSwipeInProgress = false;
    _settleBack(velocity);

    final goNext = velocity < -200 || offset < -50;
    final goPrevious = !goNext && (velocity > 200 || offset > 50);
    if (!goNext && !goPrevious) return;
    if (!_hasSwipedThisSession) setState(() => _hasSwipedThisSession = true);
    goNext ? _handleNext() : _handlePrevious();
  }

  void _settleBack(double velocity) {
    if (Motion.reduce(context)) {
      _dragOffset.value = 0;
      return;
    }
    final from = _dragOffset.value;
    _settle.value = from;
    _settle.animateWith(SpringSimulation(Motion.settle, from, 0, velocity * 0.6));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  /** Quiet tradition label for the card header. */
  Widget _buildTraditionLabel(Tradition tradition, PointerColors colors, {Key? key}) {
    final traditionInfo = traditions[tradition]!;
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: Icon(traditionInfo.lineIcon, size: 14, color: colors.textMuted)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            traditionInfo.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: AppType.caption, fontWeight: FontWeight.w500, letterSpacing: 0.4),
          ),
        ),
      ],
    );
  }

  /** Minimal focus (zen) mode view with only the pointing text. */
  Widget _buildZenModeView(Pointing pointing) {
    return GestureDetector(
      onTap: _toggleZenMode,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -200) {
          _handleNext();
        } else if (velocity > 200) {
          _handlePrevious();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        key: const ValueKey('zen-mode'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: SingleChildScrollView(
            child: Text(smartPunctuation(pointing.content), style: AppTextStyles.pointingText(context), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Pointing pointing, PointerColors colors, {required Size size, required bool isSquareAspect}) {
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(pointing.id)));
    final cardPadding = (size.width * 0.06).clamp(20.0, 28.0);
    final teacher = getTeacher(pointing.teacher);

    return Semantics(
      sortKey: const OrdinalSortKey(1.0),
      label: 'Current pointing: ${pointing.content}${pointing.teacher != null ? ' by ${pointing.teacher}' : ''}',
      hint: 'Actions available: next, previous, focus mode, save, share',
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Next pointing'): _handleNext,
        const CustomSemanticsAction(label: 'Previous pointing'): _handlePrevious,
        const CustomSemanticsAction(label: 'Enter focus mode'): _toggleZenMode,
        const CustomSemanticsAction(label: 'Save to favorites'): _handleSave,
        const CustomSemanticsAction(label: 'Share pointing'): _handleShare,
      },
      child: GestureDetector(
        onLongPress: _handleSave,
        onDoubleTap: _toggleZenMode,
        child: GlassCard(
          padding: EdgeInsets.fromLTRB(cardPadding, 12, cardPadding, 24),
          borderRadius: 32,
          minHeight: isSquareAspect ? size.height * 0.25 : size.height * 0.15,
          maxHeight: isSquareAspect ? size.height * 0.40 : size.height * 0.58,
          enableScrolling: true,
          enableBreathingAnimation: true,
          // Height changes between pointings ease instead of snapping.
          child: AnimatedSize(
            duration: Motion.of(context, Motion.standard),
            curve: Motion.inOut,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: quiet tradition label, then heart and share as plain glyphs.
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Semantics(
                            label: traditions[pointing.tradition]!.name,
                            excludeSemantics: true,
                            child: AnimatedSwitcher(
                              duration: Motion.of(context, Motion.quick),
                              switchInCurve: Motion.enter,
                              switchOutCurve: Motion.exit,
                              // Enters with a fade and a slight lift, never from scale 0.
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(scale: Tween<double>(begin: 0.94, end: 1).animate(animation), child: child),
                              ),
                              child: _buildTraditionLabel(pointing.tradition, colors, key: ValueKey('${pointing.id}-badge')),
                            ),
                          ),
                        ),
                      ),
                      _QuietIconButton(
                        icon: isFavorite ? PhosphorIconsFill.heart : AppIcons.heart,
                        color: isFavorite ? colors.accent : colors.textSecondary,
                        label: isFavorite ? 'Remove from favorites' : 'Save to favorites',
                        onTap: _handleToggleFavorite,
                      ),
                      _QuietIconButton(icon: AppIcons.share, color: colors.textSecondary, label: 'Share this pointing', onTap: _handleShare),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Motion.of(context, const Duration(milliseconds: 400)),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    child: child,
                  ),
                  child: Text(
                    smartPunctuation(pointing.content),
                    key: ValueKey(pointing.id),
                    style: AppTextStyles.pointingText(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (pointing.instruction != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(smartPunctuation(pointing.instruction!), style: AppTextStyles.instructionText(context), textAlign: TextAlign.center),
                ],
                if (pointing.teacher != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedSwitcher(
                    duration: Motion.of(context, Motion.quick),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: _AttributionLink(
                      key: ValueKey('${pointing.id}-teacher'),
                      text: '— ${pointing.teacher}',
                      style: AppTextStyles.teacherText(context),
                      semanticsLabel: pointing.teacher!,
                      hint: 'Opens teacher profile',
                      onTap: teacher == null ? null : () => showTeacherSheet(context, teacher),
                    ),
                  ),
                ],
                if (pointing.source != null) _SourceCitation(source: pointing.source!, teacher: pointing.teacher),
                if (pointing.commentary != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  CommentarySection(commentary: pointing.commentary, pointingId: pointing.id),
                ],
                // Keyed per pointing so a new pointing never inherits the previous player's State.
                if (pointing.audioUrl != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AudioPlayerWidget(key: ValueKey('audio-${pointing.id}'), pointingId: pointing.id, audioUrl: pointing.audioUrl),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointing = ref.watch(currentPointingProvider);
    final isZenMode = ref.watch(zenModeProvider);
    final size = MediaQuery.sizeOf(context);
    final colors = context.colors;

    // Square-ish aspect (foldables, tablets) has more width than height to spare.
    final isSquareAspect = size.height / size.width < 1.3;
    final navBarSpace = isSquareAspect ? 80.0 : (size.height * 0.08).clamp(80.0, 120.0);

    return PopScope(
      canPop: !isZenMode,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !mounted) return;
        ref.read(settingsProvider.notifier).setZenMode(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: RouteAmbient()),
            if (isZenMode)
              SafeArea(
                child: AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 500), child: _buildZenModeView(pointing)),
              )
            else
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: 20, bottom: navBarSpace),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              // Width-driven measure: the plate never grows past a readable line length.
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: ValueListenableBuilder<double>(
                                valueListenable: _dragOffset,
                                builder: (context, offset, child) => Transform.translate(offset: Offset(0, offset), child: child),
                                child: _buildCard(context, pointing, colors, size: size, isSquareAspect: isSquareAspect),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSquareAspect ? AppSpacing.sm : AppSpacing.lg),
                        // Secondary actions, demoted to quiet text.
                        Semantics(
                          sortKey: const OrdinalSortKey(2.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.md,
                            children: [
                              _QuietTextAction(
                                label: 'Take a moment',
                                semanticsLabel: 'Take a moment - start guided inquiry',
                                color: colors.accent,
                                onTap: () {
                                  Haptics.light();
                                  context.push('/inquiry/random');
                                },
                              ),
                              _QuietTextAction(
                                label: 'Next',
                                semanticsLabel: 'Show next pointing',
                                color: colors.textSecondary,
                                trailing: AppIcons.chevronDown,
                                onTap: _handleNext,
                              ),
                            ],
                          ),
                        ),
                        if (!isSquareAspect && _isEarlySession && !_hasSwipedThisSession) ...[
                          const SizedBox(height: AppSpacing.sm),
                          ExcludeSemantics(child: Text('Swipe for another invitation to look', style: AppTextStyles.footerText(context))),
                        ],
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

/** A plain glyph with a 48 pt hit target and button semantics; no tinted chip. */
class _QuietIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuietIconButton({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(dimension: 48, child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}

/** A quiet text action with a 48 pt minimum target, used for demoted secondary actions. */
class _QuietTextAction extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final Color color;
  final IconData? trailing;
  final VoidCallback onTap;

  const _QuietTextAction({required this.label, required this.semanticsLabel, required this.color, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontSize: AppType.callout, fontWeight: FontWeight.w500),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 4), Icon(trailing, size: 16, color: color)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * Attribution line (teacher or source): quiet text, no underline, a 48 pt target,
 * and link semantics when it navigates. Plain text when [onTap] is null.
 */
class _AttributionLink extends StatelessWidget {
  final String text;
  final TextStyle style;
  final String semanticsLabel;
  final String hint;
  final VoidCallback? onTap;

  const _AttributionLink({super.key, required this.text, required this.style, required this.semanticsLabel, required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: style, textAlign: TextAlign.center);
    if (onTap == null) return Padding(padding: const EdgeInsets.only(top: 4), child: label);
    void activate() {
      Haptics.light();
      onTap!();
    }

    return Semantics(
      link: true,
      label: semanticsLabel,
      hint: hint,
      onTap: activate,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activate,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(widthFactor: 1, heightFactor: 1, child: ExcludeSemantics(child: label)),
        ),
      ),
    );
  }
}

/**
 * Source citation:
 * 1. If an article title matches the source, it opens that article.
 * 2. Else if the teacher has articles, it opens the teacher's teachings.
 * 3. Else plain text.
 */
class _SourceCitation extends StatelessWidget {
  final String source;
  final String? teacher;

  const _SourceCitation({required this.source, this.teacher});

  @override
  Widget build(BuildContext context) {
    final match = _resolveSource();
    final style = TextStyle(fontSize: AppType.caption, fontStyle: FontStyle.italic, color: context.colors.textMuted);
    return _AttributionLink(
      text: source,
      style: style,
      semanticsLabel: 'Source: $source',
      hint: match is _ArticleMatch ? 'Opens the article' : 'Opens related teachings',
      onTap: match == null ? null : () => match.navigate(context),
    );
  }

  _SourceMatch? _resolveSource() {
    final lowerSource = source.toLowerCase();
    final directMatch = articles.cast<Article?>().firstWhere((a) => a!.title.toLowerCase() == lowerSource, orElse: () => null);
    if (directMatch != null) return _ArticleMatch(directMatch);
    if (teacher != null && getArticlesByTeacher(teacher!).isNotEmpty) return _TeacherMatch(teacher!);
    return null;
  }
}

/** Sealed class representing a resolved source citation target. */
sealed class _SourceMatch {
  /** Navigates to the matched content (article or teacher screen). */
  void navigate(BuildContext context);
}

/** Source citation that matched a specific [Article] by title. */
class _ArticleMatch extends _SourceMatch {
  final Article article;
  _ArticleMatch(this.article);

  @override
  void navigate(BuildContext context) => context.push('/article/${article.id}');
}

/** Source citation that matched a teacher who has articles in the library. */
class _TeacherMatch extends _SourceMatch {
  final String teacher;
  _TeacherMatch(this.teacher);

  @override
  void navigate(BuildContext context) {
    // Root navigator: a pushed reading screen covers the dock (design finding 22).
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TeacherTeachingsScreen(teacher: teacher, filter: ContentFilter.articles),
      ),
    );
  }
}
