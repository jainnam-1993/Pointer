import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _previousIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isZenMode = ref.watch(zenModeProvider);
    final currentIndex = widget.navigationShell.currentIndex;

    // Track direction for slide animation
    final slideFromRight = currentIndex > _previousIndex;
    if (currentIndex != _previousIndex) {
      _previousIndex = currentIndex;
    }

    // Wrap content with horizontal swipe gesture and slide transition
    final content = GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left (negative velocity) -> next tab
        if (details.primaryVelocity! < -200 && currentIndex < 3) {
          widget.navigationShell.goBranch(currentIndex + 1);
        }
        // Swipe right (positive velocity) -> previous tab
        else if (details.primaryVelocity! > 200 && currentIndex > 0) {
          widget.navigationShell.goBranch(currentIndex - 1);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          // Slide from right when going forward, from left when going back
          final offsetBegin = slideFromRight
              ? const Offset(0.1, 0.0)
              : const Offset(-0.1, 0.0);
          return SlideTransition(
            position: Tween<Offset>(
              begin: offsetBegin,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: widget.navigationShell,
        ),
      ),
    );

    // In zen mode, hide bottom nav bar
    if (isZenMode) {
      return Scaffold(
        body: Stack(
          children: [
            // Global particles effect (behind content)
            const Positioned.fill(child: FloatingParticles()),
            content,
          ],
        ),
        extendBody: true,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Global particles effect (behind content)
          const Positioned.fill(child: FloatingParticles()),
          content,
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == currentIndex,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  static const int _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = context.colors;
    final isDark = context.isDarkMode;

    // Responsive sizing for different screen sizes
    final horizontalMargin = (screenWidth * 0.05).clamp(16.0, 48.0);
    final isTablet = screenWidth > 600;
    final navBarHeight = isTablet ? 72.0 : 64.0;

    // Enhanced iOS-style glass gradient
    final glassGradient = isDark
        ? LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderGradient = isDark
        ? LinearGradient(
            colors: [
              colors.glassBorder,
              colors.glassBorder.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: bottomPadding + 16,
        ),
        decoration: isDark
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: Container(
              height: navBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: glassGradient,
                borderRadius: BorderRadius.circular(24),
                border: GradientBoxBorder(
                  gradient: borderGradient,
                  width: isDark ? 1.5 : 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Each nav item takes equal width (Expanded ensures this)
                  final itemWidth = constraints.maxWidth / _itemCount;
                  final indicatorWidth = 48.0;
                  // Center indicator under each item
                  final indicatorLeft = (widget.currentIndex * itemWidth) + (itemWidth - indicatorWidth) / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated sliding indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: indicatorLeft,
                        bottom: 6,
                        child: Container(
                          width: indicatorWidth,
                          height: 3,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Nav items row - use Expanded for equal-width columns
                      Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              icon: Icons.spa_outlined,
                              activeIcon: Icons.spa,
                              label: 'Home',
                              isActive: widget.currentIndex == 0,
                              onTap: () => widget.onTap(0),
                              isTablet: isTablet,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: Icons.self_improvement_outlined,
                              activeIcon: Icons.self_improvement,
                              label: 'Inquiry',
                              isActive: widget.currentIndex == 1,
                              onTap: () => widget.onTap(1),
                              isTablet: isTablet,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: Icons.menu_book_outlined,
                              activeIcon: Icons.menu_book,
                              label: 'Library',
                              isActive: widget.currentIndex == 2,
                              onTap: () => widget.onTap(2),
                              isTablet: isTablet,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings,
                              label: 'Settings',
                              isActive: widget.currentIndex == 3,
                              onTap: () => widget.onTap(3),
                              isTablet: isTablet,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isTablet;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = colors.textPrimary;
    final inactiveColor = colors.textMuted;

    // Scale icon and font size for tablets
    final iconSize = isTablet ? 26.0 : 24.0;
    final fontSize = isTablet ? 11.0 : 10.0;

    return Semantics(
      button: true,
      selected: isActive,
      label: '$label tab${isActive ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor,
                size: iconSize,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
