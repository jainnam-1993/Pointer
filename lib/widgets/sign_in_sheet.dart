import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Shows a modal bottom sheet for signing in with Apple or Google.
///
/// Used from:
/// - Restore Purchases flow (when user is anonymous)
/// - Settings screen Account section
///
/// Returns true if sign-in was successful, false otherwise.
Future<bool> showSignInSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SignInSheet(),
  );
  return result ?? false;
}

/// Sign-in sheet with Apple and Google options.
class SignInSheet extends ConsumerWidget {
  const SignInSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final authState = ref.watch(authActionProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        intensity: GlassIntensity.heavy,
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Sign in to sync your purchases across devices',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (authState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Apple Sign-In button (iOS only, but show on both for consistency)
              _SignInButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                backgroundColor: colors.textPrimary,
                textColor: colors.background,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading
                    ? null
                    : () => _signInWithApple(context, ref),
              ),
              const SizedBox(height: 12),

              // Google Sign-In button
              _SignInButton(
                icon: null, // Custom Google logo
                customIcon: _buildGoogleLogo(),
                label: 'Continue with Google',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading
                    ? null
                    : () => _signInWithGoogle(context, ref),
              ),
              const SizedBox(height: 24),

              // Privacy note
              Text(
                'We only use your account to sync purchases.\nNo personal data is stored.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed:
                    authState.isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  Future<void> _signInWithApple(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    ref.read(authActionProvider.notifier).clearError();

    final success = await ref.read(authActionProvider.notifier).signInWithApple();

    if (success && context.mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    ref.read(authActionProvider.notifier).clearError();

    final success = await ref.read(authActionProvider.notifier).signInWithGoogle();

    if (success && context.mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
    }
  }
}

/// Sign-in button with icon and loading state
class _SignInButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SignInButton({
    this.icon,
    this.customIcon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(icon, size: 24)
                  else if (customIcon != null)
                    customIcon!,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom painter for Google's multi-color logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc (top-right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.5,
      true,
      paint,
    );

    // Green arc (bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.0,
      1.0,
      true,
      paint,
    );

    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.0,
      1.0,
      true,
      paint,
    );

    // Red arc (top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.0,
      0.5,
      true,
      paint,
    );

    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);

    // Blue horizontal bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.45,
        size.height * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
