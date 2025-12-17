# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pointer is a React Native mobile app (Expo) that delivers daily non-dual awareness "pointings" from various spiritual traditions. Anti-meditation positioning: direct pointing vs guided meditation. No progress tracking, no gamification.

## Commands

```bash
# Development
cd app
npm start              # Expo dev server (Metro bundler)
npm run ios            # Run on iOS
npm run android        # Run on Android

# Testing
npm test               # Jest unit tests
npm run test:watch     # Watch mode
npm run test:coverage  # Coverage report
npm run e2e            # All Maestro E2E tests
npm run e2e:smoke      # Smoke tests only (critical path)
npm run e2e:studio     # Interactive Maestro test builder

# Single test file
npx jest __tests__/notifications.test.ts
```

## Architecture

```
app/                          # Expo Router file-based routing
├── (tabs)/                   # Bottom tab navigator (home, inquiry, lineages, settings)
├── onboarding/               # Multi-step onboarding flow
├── paywall.tsx               # Premium subscription modal
└── _layout.tsx               # Root stack with providers

src/
├── components/ui/            # Glass-morphism UI kit (GlassButton, GlassCard, Icons)
├── components/               # AnimatedGradient (Skia GPU canvas), FloatingParticles
├── contexts/                 # SubscriptionContext (premium tier tracking)
├── data/pointings.ts         # 100+ curated pointings across 5 traditions
├── services/                 # storage.ts, notifications.ts (async storage, push notifs)
└── store/                    # Reserved for Zustand stores
```

**Path alias**: `@/*` → `src/*`

## Tech Stack

- **Framework**: React Native 0.81 + Expo 54 + TypeScript
- **Routing**: Expo Router 6 (file-based)
- **Styling**: NativeWind (Tailwind for RN)
- **Animations**: React Native Reanimated + Skia (GPU canvas)
- **State**: React Context (Zustand available but unused)
- **Storage**: AsyncStorage
- **Testing**: Jest + Testing Library RN (unit), Maestro (E2E)

## Design System

"Ethereal Liquid Glass" theme defined in `/DESIGN_SYSTEM.md`:
- Glass components: 8% opacity fill, 30px blur, 1px subtle borders
- Colors: Deep purples (#0F0524, #240046), teals, white text
- Animations: Smooth, subtle (60s gradient morphing cycles)
- Icons: Minimalist white outline SVGs in `src/components/ui/Icons.tsx`

## Key Patterns

**AnimatedGradient** (`src/components/AnimatedGradient.tsx`): Skia-powered GPU canvas with 60s color morphing. Has static fallback for reduced motion.

**GlassButton** (`src/components/ui/GlassButton.tsx`): BlurView + spring animations + haptic feedback. All buttons follow this pattern.

**Services layer**: Storage and notifications abstracted. Notification service handles Android channels, permission requests, daily scheduling at configurable times.

**Data model**: `Pointing` has id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source.

## Testing

**Unit tests** (`__tests__/`): Cover services (storage, notifications, pointings). Use mocked Platform/AsyncStorage.

**E2E tests** (`e2e/maestro/`): 14 Maestro flows. Use accessibility labels for element selection (robust against UI changes). Tags: smoke, visual, navigation, sessions, settings, premium, onboarding.

## TODOs in Codebase

- RevenueCat integration (subscription payments) - currently mocked in SubscriptionContext
- Premium tier gating for unlimited pointings
- Backend API (Bun + SQLite planned per EXECUTION_PLAN.md)

## Reference Docs

- `/DESIGN_SYSTEM.md` - Full design specifications
- `/EXECUTION_PLAN.md` - Implementation roadmap and product decisions
- `/PRFAQ.md` - Product vision and FAQ
