# Pointer - Execution Plan

> Step-by-step guide from zero to launched MVP

---

## Phase 0: Requirements Clarification (Before Writing Code)

### 0.1 Product Decisions

| Decision | Options | Recommendation | Your Choice |
|----------|---------|----------------|-------------|
| **Platform priority** | iOS first / Android first / Both | iOS first (higher LTV users) | [ ] |
| **Monetization model** | Freemium / Paid only / Donation | Freemium ($7.99/mo) | [ ] |
| **Free tier limits** | 1-3 pointings/day | 2 pointings/day | [ ] |
| **Notification style** | Silent / Sound / Vibrate | User configurable | [ ] |
| **Offline support** | Required / Nice-to-have | Required (core UX) | [ ] |
| **User accounts** | Required / Optional / None | Optional (sync across devices) | [ ] |
| **Analytics depth** | Minimal / Standard / Deep | Minimal (privacy-first) | [ ] |

### 0.2 Content Decisions

| Decision | Options | Recommendation | Your Choice |
|----------|---------|----------------|-------------|
| **MVP pointing count** | 50 / 100 / 200 | 100 pointings | [ ] |
| **Traditions to include** | All / Curated subset | 5 core (Advaita, Zen, Dzogchen, Contemporary, Original) | [ ] |
| **Self-inquiry sessions** | 3 / 5 / 10 | 5 for MVP | [ ] |
| **Content licensing** | Original only / Fair use quotes / Licensed | Original + public domain + fair use | [ ] |
| **Teacher partnerships** | MVP / Post-launch | Post-launch | [ ] |

### 0.3 Technical Decisions

| Decision | Options | Recommendation | Your Choice |
|----------|---------|----------------|-------------|
| **Mobile framework** | React Native + Expo / Flutter / Native | React Native + Expo | [ ] |
| **Backend runtime** | Bun | Bun ✓ (confirmed) | [x] |
| **Backend framework** | Hono / Elysia / Bun native | Hono (mature, good DX) | [ ] |
| **Database** | SQLite / Postgres / PlanetScale | SQLite (MVP) → Postgres (scale) | [ ] |
| **Hosting** | Fly.io / Railway / Render / Vercel | Fly.io (edge, Bun support) | [ ] |
| **Auth provider** | Firebase / Supabase / Lucia / Clerk | Supabase (auth + DB backup plan) | [ ] |
| **Push notifications** | Firebase FCM / OneSignal / Expo | Expo Notifications (simplest) | [ ] |
| **Payments** | RevenueCat / Stripe / In-app native | RevenueCat (handles both stores) | [ ] |
| **Repo structure** | Monorepo / Separate repos | Monorepo (Turborepo) | [ ] |
| **CI/CD** | GitHub Actions / None initially | GitHub Actions | [ ] |

### 0.4 Design Decisions

| Decision | Options | Recommendation | Your Choice |
|----------|---------|----------------|-------------|
| **Visual style** | Minimal / Warm / Dark | Minimal with warmth | [ ] |
| **Typography** | Serif / Sans-serif / Mixed | Serif for pointings, sans for UI | [ ] |
| **Color palette** | Monochrome / Earth tones / Vibrant | Muted earth tones | [ ] |
| **Animations** | None / Subtle / Rich | Subtle (spacious feel) | [ ] |
| **App icon style** | Abstract / Symbolic / Text | Abstract (finger pointing?) | [ ] |

---

## Phase 1: Foundation (Week 1)

### 1.1 Branding & Assets

```
□ Define app name variations (Pointer / Pointing / Point)
□ Create brand guidelines doc
  - Color palette (primary, secondary, accent)
  - Typography choices (2-3 fonts max)
  - Spacing/sizing system
□ Design app icon (1024x1024 master)
  - iOS variants
  - Android adaptive icon
□ Create splash screen design
□ Design placeholder illustrations (if any)
□ Choose/create notification sound (optional, subtle)
```

**Asset Checklist:**
| Asset | Size | Format | Status |
|-------|------|--------|--------|
| App Icon (iOS) | 1024x1024 | PNG | [ ] |
| App Icon (Android) | 512x512 + adaptive | PNG | [ ] |
| Splash Screen | 1284x2778 (+ variants) | PNG | [ ] |
| App Store Screenshots | 1284x2778 (6.5") | PNG | [ ] |
| Feature Graphic (Android) | 1024x500 | PNG | [ ] |
| Logo (marketing) | SVG + PNG | Vector | [ ] |

**Tools:**
- Figma (design)
- Midjourney/DALL-E (concept exploration)
- IconKitchen (icon generation)
- AppMockup (store screenshots)

### 1.2 Project Setup

```bash
# Create monorepo structure
mkdir -p pointer/{apps/{mobile,api},packages/{shared,content}}
cd pointer

# Initialize
bun init
# Add workspace config to package.json
```

**Directory Structure:**
```
pointer/
├── apps/
│   ├── mobile/          # React Native + Expo app
│   │   ├── app/         # Expo Router screens
│   │   ├── components/  # UI components
│   │   ├── hooks/       # Custom hooks
│   │   ├── lib/         # Utilities
│   │   └── assets/      # Images, fonts
│   │
│   └── api/             # Bun + Hono backend
│       ├── src/
│       │   ├── routes/  # API endpoints
│       │   ├── db/      # Database schema + migrations
│       │   ├── services/# Business logic
│       │   └── lib/     # Utilities
│       └── drizzle/     # DB migrations
│
├── packages/
│   ├── shared/          # Shared types, constants
│   └── content/         # Pointings database (JSON/Markdown)
│
├── turbo.json           # Turborepo config
├── package.json         # Workspace root
└── README.md
```

### 1.3 Development Environment

```bash
# Prerequisites
□ Bun installed (curl -fsSL https://bun.sh/install | bash)
□ Node.js 18+ (for Expo compatibility)
□ Xcode (iOS development)
□ Android Studio (Android development)
□ Expo CLI (bunx expo)
□ Git + GitHub repo created

# Verify
bun --version    # 1.0+
node --version   # 18+
```

---

## Phase 2: Backend Setup (Week 1-2)

### 2.1 API Scaffold

```bash
cd apps/api
bun init
bun add hono @hono/node-server
bun add drizzle-orm better-sqlite3
bun add -d drizzle-kit @types/better-sqlite3
```

**Initial Files:**
```
□ src/index.ts         # Hono app entry
□ src/routes/health.ts # Health check endpoint
□ src/routes/pointings.ts # Pointings CRUD
□ src/routes/users.ts  # User management
□ src/db/schema.ts     # Drizzle schema
□ src/db/index.ts      # DB connection
□ drizzle.config.ts    # Migration config
```

### 2.2 Database Schema

```typescript
// Core tables needed for MVP
□ users
  - id, email, created_at, subscription_tier
□ pointings
  - id, content, tradition, category, time_context
□ user_preferences
  - user_id, traditions[], notification_times[], frequency
□ user_pointing_history
  - user_id, pointing_id, shown_at, engaged (bool)
```

### 2.3 Core API Endpoints

```
MVP Endpoints:
□ GET  /health                    # Health check
□ GET  /pointings/daily           # Get user's daily pointings
□ GET  /pointings/:id             # Get single pointing
□ GET  /pointings/random          # Random pointing
□ POST /users                     # Create user
□ GET  /users/:id/preferences     # Get preferences
□ PUT  /users/:id/preferences     # Update preferences
□ POST /users/:id/history         # Log pointing view
```

### 2.4 Deployment Setup

```bash
# Fly.io setup
□ Create Fly.io account
□ fly launch (configure app)
□ fly secrets set (env vars)
□ Set up GitHub Actions for auto-deploy
□ Configure custom domain (later)
```

---

## Phase 3: Mobile App Setup (Week 2-3)

### 3.1 Expo Project

```bash
cd apps/mobile
bunx create-expo-app@latest . --template tabs
bun add @react-navigation/native
bun add expo-notifications expo-device
bun add @tanstack/react-query
bun add zustand # State management
```

### 3.2 Screen Structure

```
□ (tabs)/
  □ index.tsx          # Home - today's pointing
  □ explore.tsx        # Browse all pointings
  □ inquiry.tsx        # Self-inquiry sessions
  □ settings.tsx       # Preferences
□ pointing/[id].tsx    # Full pointing view
□ onboarding/          # First-time user flow
  □ welcome.tsx
  □ traditions.tsx     # Pick preferred traditions
  □ schedule.tsx       # Set notification times
□ subscription.tsx     # Paywall
```

### 3.3 Core Components

```
□ PointingCard         # Display a pointing with tradition badge
□ TraditionPicker      # Multi-select tradition preferences
□ TimeScheduler        # Configure notification times
□ InquiryPlayer        # Guided self-inquiry UI
□ PaywallModal         # Subscription prompt
```

### 3.4 Push Notifications Setup

```bash
□ Configure Expo push notifications
□ Request permissions flow
□ Store push tokens in backend
□ Create notification scheduling logic
□ Handle notification tap → deep link to pointing
```

### 3.5 Offline Support

```
□ Cache daily pointings locally (AsyncStorage or MMKV)
□ Queue preference changes when offline
□ Sync on reconnect
□ Show cached content if API unavailable
```

---

## Phase 4: Content Development (Week 2-4, parallel)

### 4.1 Content Structure

```json
// packages/content/pointings/advaita-001.json
{
  "id": "advaita-001",
  "tradition": "advaita",
  "teacher": "ramana_maharshi",
  "content": "Ask yourself: 'Who am I?' Don't answer with a thought. What remains when no answer comes?",
  "context": ["morning", "self_inquiry"],
  "duration_seconds": 15,
  "depth": "intermediate",
  "tags": ["self_inquiry", "who_am_i"]
}
```

### 4.2 Content Creation Checklist

```
Traditions (20 pointings each = 100 total for MVP):
□ Advaita Vedanta (20)
  □ Ramana Maharshi style (5)
  □ Nisargadatta style (5)
  □ Ashtavakra style (5)
  □ Original/modern Advaita (5)
□ Zen (20)
  □ Koan-style (10)
  □ Direct pointing (10)
□ Dzogchen (20)
  □ Pointing-out style (10)
  □ Natural state reminders (10)
□ Contemporary (20)
  □ Spira-influenced (5)
  □ Tolle-influenced (5)
  □ Parsons-influenced (5)
  □ Original contemporary (5)
□ Original/Contextual (20)
  □ Work stress (5)
  □ Morning (5)
  □ Evening (5)
  □ General (5)

Self-Inquiry Sessions (5):
□ Basic "Who Am I?" (5 min)
□ Finding the Looker (7 min)
□ The Space of Awareness (10 min)
□ Investigating Thoughts (8 min)
□ Resting as Awareness (12 min)
```

### 4.3 Content Review Process

```
For each pointing:
□ Write draft
□ Test: Does it invite looking, not thinking?
□ Test: Is it free of spiritual jargon?
□ Test: Can it land in 10 seconds?
□ Review for tradition authenticity
□ Add metadata (context, tags, depth)
□ Final approval
```

---

## Phase 5: Integration & Polish (Week 4-5)

### 5.1 API ↔ Mobile Integration

```
□ API client setup (react-query + fetch)
□ Auth flow (optional account creation)
□ Preferences sync
□ Pointing delivery logic
□ History tracking
□ Error handling + retry logic
```

### 5.2 Subscription Integration

```
□ RevenueCat SDK setup
□ Product configuration (monthly, yearly)
□ Paywall UI implementation
□ Restore purchases flow
□ Premium feature gating
□ Receipt validation (backend)
```

### 5.3 Analytics (Minimal)

```
□ Choose provider (Mixpanel / PostHog / Amplitude)
□ Track only:
  - Daily active users
  - Pointing views
  - Notification open rate
  - Subscription conversions
  - Tradition preferences distribution
□ NO tracking:
  - Individual pointing engagement time
  - Screen recordings
  - Personal data beyond necessary
```

### 5.4 UI Polish

```
□ Loading states (skeleton screens)
□ Error states (friendly messages)
□ Empty states
□ Transitions/animations (subtle)
□ Haptic feedback (notification received)
□ Dark mode support
□ Accessibility audit
  □ VoiceOver/TalkBack support
  □ Font scaling
  □ Sufficient contrast
```

---

## Phase 6: Testing (Week 5-6)

### 6.1 Backend Testing

```
□ Unit tests for core logic
□ API endpoint tests
□ Database migration tests
□ Load testing (basic)
```

### 6.2 Mobile Testing

```
□ Component tests (Jest + React Native Testing Library)
□ E2E tests (Detox or Maestro) for critical flows:
  □ Onboarding flow
  □ Receive + view pointing
  □ Subscription flow
  □ Settings changes
□ Manual testing on devices:
  □ iPhone (oldest supported + latest)
  □ Android (various screen sizes)
```

### 6.3 Beta Testing

```
□ TestFlight setup (iOS)
□ Internal testing track (Android)
□ Recruit 20-50 beta testers
  - Friends interested in non-duality
  - Reddit: r/awakened, r/nonduality
  - Twitter/X spirituality community
□ Feedback collection (Typeform or in-app)
□ 2-week beta period minimum
□ Iterate based on feedback
```

---

## Phase 7: Launch Prep (Week 6-7)

### 7.1 App Store Assets

```
iOS App Store:
□ App name (30 chars): "Pointer: Non-Dual Awareness"
□ Subtitle (30 chars): "Daily Pointings to Wake Up"
□ Keywords (100 chars)
□ Description (4000 chars)
□ Screenshots (6.5" + 5.5")
□ Preview video (optional)
□ Privacy policy URL
□ Support URL
□ App category: Health & Fitness or Lifestyle

Google Play:
□ Title (50 chars)
□ Short description (80 chars)
□ Full description (4000 chars)
□ Feature graphic (1024x500)
□ Screenshots
□ Content rating questionnaire
□ Data safety form
```

### 7.2 Legal & Compliance

```
□ Privacy Policy (what data, how used)
□ Terms of Service
□ GDPR compliance (if EU users)
□ CCPA compliance (if CA users)
□ Copyright clearance for any quoted content
```

### 7.3 Marketing Prep

```
□ Landing page (pointer.app or similar)
  □ Email capture for launch notification
  □ Core value prop
  □ App store badges (after approval)
□ Social media accounts
  □ Twitter/X
  □ Instagram (optional)
□ Launch announcement draft
□ Press kit (logo, screenshots, description)
□ Communities to post in:
  □ r/awakened
  □ r/nonduality
  □ r/meditation
  □ Hacker News (Show HN)
  □ Product Hunt
```

### 7.4 App Store Submission

```
□ App Store Connect setup
□ Google Play Console setup
□ Build production versions
□ Submit for review
  - iOS: 24-48 hours typical
  - Android: Few hours to 2 days
□ Prepare for rejection feedback (iterate)
□ Plan launch date (post-approval)
```

---

## Phase 8: Launch & Iterate (Week 8+)

### 8.1 Launch Day

```
□ Flip app to "available"
□ Post on social media
□ Submit to Product Hunt
□ Post in relevant communities
□ Email waiting list
□ Monitor crash reports (Sentry)
□ Monitor app store reviews
□ Respond to early feedback
```

### 8.2 Week 1 Post-Launch

```
□ Daily metrics review
□ Crash/bug triage
□ User feedback synthesis
□ Quick fixes deployment
□ Thank early reviewers
```

### 8.3 Ongoing Iteration

```
Monthly:
□ Add 20 new pointings
□ Feature based on feedback
□ Conversion optimization

Quarterly:
□ Major feature (community? teachers?)
□ Content partnerships
□ Growth experiments
```

---

## Quick Reference: Tech Stack Summary

| Layer | Technology | Why |
|-------|------------|-----|
| **Runtime** | Bun | Fast, simple, TypeScript-native |
| **API Framework** | Hono | Lightweight, fast, Bun-native |
| **Database** | SQLite (MVP) → Postgres | Start simple, scale later |
| **ORM** | Drizzle | Type-safe, lightweight |
| **Mobile** | React Native + Expo | Cross-platform, fast iteration |
| **State** | Zustand | Simple, minimal boilerplate |
| **Data Fetching** | TanStack Query | Caching, offline, retries |
| **Auth** | Supabase Auth | Simple, includes DB option |
| **Push** | Expo Notifications | Simplest for Expo apps |
| **Payments** | RevenueCat | Handles iOS + Android subs |
| **Hosting** | Fly.io | Edge, Bun support, cheap |
| **CI/CD** | GitHub Actions | Free, integrated |
| **Monitoring** | Sentry | Crash reporting |
| **Analytics** | Mixpanel (minimal) | Just what we need |

---

## Timeline Summary

| Week | Phase | Deliverable |
|------|-------|-------------|
| 1 | Foundation | Project setup, branding, architecture |
| 1-2 | Backend | API running, DB schema, core endpoints |
| 2-3 | Mobile | App scaffold, core screens, navigation |
| 2-4 | Content | 100 pointings written and reviewed |
| 4-5 | Integration | API ↔ Mobile, subscriptions, polish |
| 5-6 | Testing | Beta release, feedback collection |
| 6-7 | Launch Prep | Store assets, legal, marketing |
| 8 | Launch | 🚀 |

---

## Decision Log

Track decisions made during development:

| Date | Decision | Rationale |
|------|----------|-----------|
| | | |

---

## Notes

*Add notes and learnings as you build...*
