# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pointer is a Flutter mobile app that delivers daily non-dual awareness "pointings" from various spiritual traditions. Anti-meditation positioning: direct pointing vs guided meditation. No progress tracking, no gamification.

## Commands

```bash
# Development
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Run on web (for quick testing)

# Testing
flutter test --concurrency=8   # Unit tests (8 parallel)
flutter test --coverage        # With coverage report
flutter test integration_test  # Integration tests

# Build
flutter build apk              # Android APK
flutter build ios              # iOS build
flutter build appbundle        # Android App Bundle (Play Store)

# Utilities
flutter analyze                # Static analysis
flutter pub get                # Install dependencies
```

## Architecture

```
./
├── lib/
│   ├── main.dart              # App entry point, ProviderScope setup
│   ├── router.dart            # GoRouter configuration
│   ├── theme/
│   │   └── app_theme.dart     # AppColors, AppGradients, ThemeData
│   ├── providers/
│   │   └── providers.dart     # Riverpod providers (storage, navigation)
│   ├── screens/
│   │   ├── main_shell.dart    # Bottom navigation shell
│   │   ├── home_screen.dart   # Daily pointing display
│   │   ├── inquiry_screen.dart
│   │   ├── lineages_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── onboarding_screen.dart
│   │   └── paywall_screen.dart
│   ├── widgets/
│   │   ├── animated_gradient.dart  # Background gradient animation
│   │   ├── glass_card.dart         # Glass-morphism card component
│   │   └── tradition_badge.dart    # Tradition indicator badge
│   ├── services/
│   │   ├── storage_service.dart      # SharedPreferences wrapper
│   │   └── notification_service.dart # Local notifications
│   └── data/
│       └── pointings.dart     # Curated pointings across traditions
├── test/                      # Unit tests
├── integration_test/          # Integration tests
└── pubspec.yaml               # Dependencies
```

## Tech Stack

- **Framework**: Flutter 3.x + Dart 3.10
- **Routing**: GoRouter 14.x (declarative routing)
- **State Management**: Riverpod 2.5 (providers pattern)
- **Storage**: SharedPreferences
- **Animations**: flutter_animate + custom gradient animations
- **UI Components**: glassmorphism_ui, Google Fonts
- **Notifications**: flutter_local_notifications
- **Testing**: flutter_test + mocktail (unit), patrol (integration)

## Design System

"Ethereal Liquid Glass" theme defined in `/DESIGN_SYSTEM.md`:
- Glass components: 8% opacity fill (`0x0DFFFFFF`), blur, 1px subtle borders (`0x26FFFFFF`)
- Colors: Deep purples (`#0F0524`, `#1A0A3A`), accent violet (`#8B5CF6`), teal (`#06B6D4`)
- Typography: Inter font via Google Fonts
- Animations: Smooth, subtle gradient morphing

## Key Patterns

**AppTheme** (`lib/theme/app_theme.dart`): Centralized colors (`AppColors`), gradients (`AppGradients`), and Material 3 theme configuration.

**GlassCard** (`lib/widgets/glass_card.dart`): Glassmorphism container with blur effect and subtle borders.

**AnimatedGradient** (`lib/widgets/animated_gradient.dart`): Animated background gradient for immersive feel.

**Riverpod Providers** (`lib/providers/providers.dart`): SharedPreferences instance, router, storage service providers.

**Data model**: `Pointing` has id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source.

## Testing

**Unit tests** (`test/`): Cover services, widgets, providers. Use mocktail for mocking.

**Integration tests** (`integration_test/`): E2E flows using patrol framework.

## TODOs in Codebase

- RevenueCat integration (subscription payments)
- Premium tier gating for unlimited pointings
- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle

## Orchestration Settings

```yaml
# Parallel Implementation Configuration
subagent_concurrency: 8          # Max parallel subagents for feature implementation
worktree_strategy: true          # Use git worktrees for isolation
vault_path: /Volumes/workplace/tools/Obsidian/Projects/Personal/Pointer/Active
playbook_path: ${vault_path}/IMPLEMENTATION_PLAYBOOK.md
roadmap_path: ${vault_path}/ROADMAP.md
```

### Wave Strategy
- Analyze file conflicts before spawning
- Group features by shared files to avoid merge conflicts
- Max 8 concurrent subagents per wave
- Merge sequentially after wave completes

### Git Worktrees for Parallel Execution
Use git worktrees to parallelize tasks and subagents - each subagent operates in an isolated worktree to avoid file conflicts:
```bash
git worktree add ../Pointer-feature-{name} -b feature/{name}  # Create isolated worktree
# Subagent works in worktree independently
git worktree remove ../Pointer-feature-{name}                  # Cleanup after merge
```

## Execution Protocol

### Git Discipline
- **Commit after each task** - atomic commits for easy rollback
- **Commit message format**: `fix/feat(scope): description`
- **Before moving to next task**: verify `flutter test` passes

### Vault Updates
- **Mark checkboxes** as tasks complete: `- [ ]` → `- [x]`
- **Update status** in ROADMAP.md after each wave
- **Log blockers/discoveries** in playbook Implementation Notes

### Reusable Patterns

| Pattern | Location | Use For |
|---------|----------|---------|
| **AppColors** | `lib/theme/app_theme.dart` | All color values |
| **GlassCard** | `lib/widgets/glass_card.dart` | Card components |
| **AppTextStyles** | `lib/theme/app_theme.dart` | Typography |
| **context.colors** | Extension in app_theme.dart | Theme-aware colors |
| **Riverpod Providers** | `lib/providers/providers.dart` | State management |
| **GoRouter** | `lib/router.dart` | Navigation |
| **flutter_animate** | Already in pubspec | Animations |

### Anti-Patterns
- ❌ Don't create new files when existing ones can be extended
- ❌ Don't hardcode colors - use `context.colors`
- ❌ Don't skip tests
- ❌ Don't commit without verifying build

## Reference Docs

- `/DESIGN_SYSTEM.md` - Full design specifications
- `/EXECUTION_PLAN.md` - Implementation roadmap and product decisions
- `/PRFAQ.md` - Product vision and FAQ
- `${vault_path}/ROADMAP.md` - Feature roadmap with priorities
- `${vault_path}/IMPLEMENTATION_PLAYBOOK.md` - Orchestrator execution guide
