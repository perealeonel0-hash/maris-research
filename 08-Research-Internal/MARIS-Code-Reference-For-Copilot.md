# MARIS — Technical Reference for External Code Review

---

## What is MARIS?

MARIS is an AI-powered "focus shield" — an iOS app that replaces doomscrolling with meaningful conversation. Users open MARIS instead of Instagram/TikTok, talk about what's on their mind, and get redirected toward real-life activities.

**Stack:** FastAPI (Python 3.12) backend on Railway + SwiftUI iOS app + Supabase (Postgres) + Claude API (Anthropic)

---

## Architecture Overview

### Backend (9,550 LOC Python)

```
Desktop/MiProyecto/
├── Main.py              ← FastAPI entry point, /chat and /api/chat routes
├── engine.py            ← Engine class (god object, holds all 22 subsystems)
├── understand.py        ← "Listening" phase: crisis detection, emotional reading, state resolution
├── respond.py           ← "Responding" phase: LLM routing, post-processing, streaming
├── models.py            ← Data models (MessageContext, Understanding, ChatRequest)
├── endpoints_auth.py    ← Auth routes (register, login, iOS register, token refresh)
├── endpoints_admin.py   ← Admin routes
├── startup.py           ← Pre-boot: downloads safety files from Supabase Storage
├── identity.py          ← System prompt (MARIS personality)
├── ui.py                ← Web frontend (embedded HTML)
│
├── modules/
│   ├── core/
│   │   ├── Brain.py             ← PyTorch neural layer (TRSLayer), friction measurement, 684 neurons
│   │   ├── Processor.py         ← sentence-transformers MiniLM embeddings (384d)
│   │   ├── Integrity.py         ← Response veto system (banned phrases, identity leaks)
│   │   ├── identity.py          ← System prompt builder
│   │   ├── warmth.py            ← 9 warmth detectors (frustration, crack, gradient, etc.) — 569 LOC
│   │   ├── session.py           ← In-memory session manager with 2hr TTL
│   │   ├── llm.py               ← Claude/DeepSeek SSE streaming wrappers
│   │   ├── clinical_detectors.py ← Psychosis + Mania semantic detectors — 548 LOC
│   │   ├── safety_detectors.py  ← Lethal means + Indirect signal detectors — 520 LOC
│   │   ├── crisis_classifier.py ← Crisis severity 0-5 classification — 366 LOC
│   │   ├── response_calibrator.py ← Clinical post-processing of crisis responses — 403 LOC
│   │   ├── auth.py              ← PBKDF2 auth, rate limiting (3-layer)
│   │   ├── audit.py             ← Crisis event logging (Supabase + JSONL fallback)
│   │   └── cleaner.py           ← Code block cleaning
│   │
│   ├── flow/
│   │   ├── intent.py            ← FrontalLobe: session analysis, recurrence, Hurst exponent
│   │   ├── selector.py          ← Mode classification (presencia/exploracion/arquitecto/construccion)
│   │   └── search.py            ← Tavily web search with semantic intent detection
│   │
│   ├── memory/
│   │   ├── Storage.py           ← User storage (auth, messages, scars, summaries) — 347 LOC
│   │   ├── _db.py               ← Supabase client singleton (16 LOC)
│   │   ├── long_term.py         ← Semantic anchors (pattern crystallization)
│   │   ├── dream.py             ← Neural consolidation (merges redundant neurons)
│   │   ├── temporal.py          ← Temporal session telemetry (friction decay, rumination)
│   │   └── summarizer.py        ← Summary/anchor/takeaway generation via Haiku
│   │
│   └── safety/
│       └── eip.py               ← EIP Monitor: 15 semantic clusters, C-SSRS grade — 961 LOC (LARGEST)
```

### iOS App (7,071 LOC Swift)

```
Documents/AIDA-iOS/AIDA/
├── AIDAApp.swift                ← Entry point, light mode forced
├── ContentView.swift            ← Root: consent → onboarding → main
│
├── Core/
│   ├── Models.swift             ← ChatMessage, ChatRequest, DoneEvent, PlanItem
│   ├── APIClient.swift          ← actor, SSE streaming, all endpoints
│   ├── ChatViewModel.swift      ← Chat brain (459 LOC, GOD OBJECT, 16 responsibilities)
│   ├── SessionManager.swift     ← User state, auth, 20+ @Published properties
│   ├── LocalVault.swift         ← On-device JSON persistence (conversations, scars, anchors)
│   ├── StoreManager.swift       ← StoreKit 2 consumable packs
│   ├── PhysicsEngine.swift      ← Energy/Load/Weight/Momentum from HealthKit + calendar
│   ├── SemanticCache.swift      ← NLEmbedding-based local cache
│   ├── IntentRouter.swift       ← CoreML intent classification
│   ├── NotificationService.swift ← Smart notifications (morning/night/weekly)
│   ├── HealthKitService.swift
│   ├── CalendarService.swift
│   ├── SpeechService.swift
│   ├── ReminderService.swift
│   ├── SharedData.swift         ← App Group bridge for widget
│   ├── StabilityScore.swift
│   └── VoiceOutput.swift
│
├── Views/
│   ├── Chat/
│   │   ├── ChatView.swift       ← Main chat UI (335 LOC)
│   │   ├── InputBar.swift       ← Text input + voice
│   │   └── MessageBubble.swift  ← Markdown rendering + crisis UI (395 LOC)
│   ├── Components/
│   │   ├── ConsentView.swift
│   │   ├── EmotionalOnboarding.swift
│   │   ├── MenuView.swift
│   │   ├── PremiumView.swift    ← Paywall (packs, hardcoded prices)
│   │   ├── SettingsView.swift   ← 471 LOC
│   │   ├── InfoView.swift
│   │   ├── TakeawayView.swift
│   │   ├── ResonanceView.swift
│   │   ├── AccountBanner.swift
│   │   ├── SendButton.swift
│   │   └── TypingIndicator.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift  ← 578 LOC (LARGEST, GOD VIEW)
│   │   ├── DashboardViewModel.swift ← 413 LOC
│   │   ├── BrainDumpView.swift
│   │   └── VoiceTaskView.swift
│   └── MainTabView.swift
│
├── BoeWidget/                   ← Widget extension
└── project.yml                  ← XcodeGen config
```

---

## Message Flow (51 steps)

```
POST /chat
  │
  Main.py: fast_check(x2), auth, rate limit, sanitize, repetition check
  │ ├── EXIT: lexical crisis → direct SSE
  │ ├── EXIT: repetition → hardcoded msg
  │ └── CONTINUE
  │
  understand.py :: listen() [388 LOC, SINGLE FUNCTION]
  │ Steps 8-30: warmth → friction → memory → search → embeddings
  │   → crisis_classifier → lethal_means → frontal → psychosis
  │   → mania → selector → temporal → eip.evaluate → physics
  │   → circadian → indirect_signals → resolve_state → build_prompt
  │ OUTPUT: Understanding (30+ fields)
  │
  respond.py :: respond() [175 LOC]
  │ Steps 31-51: route LLM → stream → 5 post-processors
  │   → VETO gate → identity → sovereignty → clean
  │   → yield SSE → friction/deformation/temporal → background tasks
```

---

## Known Issues from Audit

### Critical (blocks launch)
1. **0 analytics events** — entire app, both backend and iOS. Cannot measure anything.
2. **Monetization disabled** — `hasMessages` returns `true` always. Revenue = $0.
3. **Onboarding fails grunt test** — "Una presencia que escucha" doesn't communicate what the app does.

### Architectural
4. **Engine = god object** — 22 module imports, 20+ attributes, every function depends on `e`
5. **listen() = 388 LOC single function** — 40 if/else, magic numbers, untesteable
6. **ChatViewModel = god object** — 459 LOC, 16 responsibilities, 8 singleton dependencies
7. **/api/chat duplicates the pipeline** — 83 lines that mirror listen()+respond() with subtle differences
8. **11 detectors share identical pattern** — copy-pasted `_build_semantic_index` across files
9. **~800 lines of inline data** — example strings hardcoded in Python modules
10. **0 tests, 0 protocols, 0 dependency injection** — nothing is testeable in isolation

### Thread Safety
11. **RateGuard._limit** — no lock on defaultdict in concurrent server
12. **WarmthGuard._prev_temperature** — no lock on physics state
13. **SemanticCache (iOS)** — read outside queue, write inside queue
14. **CrisisState mutation** — no lock in eip.py.evaluate()

### Bounded Context Violations
15. **session.py** imports from all 3 contexts (Flow, Memory, Safety)
16. **eip.py** (Safety) imports detect_lang from Processor (Conversation)
17. **dream.py** (Memory) accesses Brain._lock private (Conversation)

---

## Infrastructure

| Component | Detail |
|-----------|--------|
| Backend hosting | Railway (single instance) |
| Database | Supabase (Postgres, port 5432 — should be 6543 PgBouncer) |
| Primary LLM | claude-sonnet-4-20250514 |
| Summary LLM | claude-haiku-4-5-20251001 |
| Technical LLM | deepseek-chat |
| Embeddings | paraphrase-multilingual-MiniLM-L12-v2 (on Railway) |
| Web search | Tavily API |
| iOS target | iOS 16.0+ |
| Bundle ID | com.leonelperea.aida |
| Cold start | ~6.5 seconds |

---

## What Works Well

- **Safety pipeline is production-grade** — 248 semantic vectors, 15 clusters (C-SSRS, DSM-5, ICD-11), psychosis/mania/lethal means detectors. This is months of work and genuinely hard to replicate.
- **Physics Brain is unique** — Exponential decay, derivatives, cross-tensor. No competitor has this.
- **temporal.py is the best-designed module** — Clean separation of state (dataclass) from logic (monitor). Model to follow for refactoring.
- **models.py is clean** — Leaf node, no dependencies, well-typed.
- **The app runs on a real iPhone** — 39 Swift files with SSE streaming, HealthKit, widget, semantic cache, for a solo developer.
- **Backend responds in 410ms** (excluding LLM latency).

---

## Market Context (for prioritization)

MARIS has pivoted from "mental health companion" to "focus shield / digital detox." The core insight: the chat exists as the place where you TALK instead of scrolling. The enemy is Instagram/TikTok, not anxiety.

**3 pillars:** Chat (talk instead of scroll) + Plans (what to do instead) + Widget (reminder on home screen)

**Target:** Professionals 25-35 in LATAM losing 3+ hrs/day to social media. Spanish-first.

**Business model:** Subscription $9.99/month. Break-even at ~205 users. Path to $1M ARR in 18-24 months.

---

## What Copilot Should Evaluate

1. **Architecture refactor priority** — What to fix first given solo dev constraints? Engine decomposition vs listen() breakup vs iOS DI?
2. **Pipeline optimization** — 51 steps is too many for a scroll-redirect use case. Where to create a fast-path (8-10 steps)?
3. **Testing strategy** — With 0 tests, what's the minimum viable test suite? Boundary tests only?
4. **Analytics implementation** — Best framework for iOS (Mixpanel vs Amplitude vs PostHog)? Event schema?
5. **Monetization rehabilitation** — Packs vs subscription? How to re-enable limits without breaking UX?
6. **Onboarding redesign** — How to pass the StoryBrand grunt test while keeping crisis resources accessible?
