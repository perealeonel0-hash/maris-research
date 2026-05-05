# MARIS — Architecture Map
## For developers joining the project

---

## How to read this map

MARIS processes one message in 5 stages. Each stage uses specific modules.
Follow the flow top to bottom — that's the order code executes.

```
  PERSON
    │  "tengo pastillas en el cajón"
    ▼
┌─────────────────────────────────────────────────────────┐
│                    Main.py (224 lines)                   │
│                    Entry point                          │
│                                                         │
│  Auth → Rate limit → Sanitize history                   │
│  Early exits: repetition, lexical crisis, free limit    │
│                         │                               │
│                         ▼                               │
│              ┌──────────────────┐                       │
│              │  understand.py   │ ← "MARIS listens"     │
│              │   listen(req, e) │                       │
│              └────────┬─────────┘                       │
│                       │ returns Understanding            │
│                       ▼                                  │
│              ┌──────────────────┐                       │
│              │   respond.py     │ ← "MARIS responds"    │
│              │  respond(u,bg,e) │                       │
│              └────────┬─────────┘                       │
│                       │ yields SSE events               │
│                       ▼                                  │
│              StreamingResponse → iPhone                  │
└─────────────────────────────────────────────────────────┘
```

---

## The Engine (engine.py — 228 lines)

One object holds everything MARIS needs. Every function receives `e` (engine).

```
┌─────────────────── engine.Engine ───────────────────────┐
│                                                         │
│  BRAIN (measures friction)                              │
│  ├── e.brain          TRSLayer        86 neurons, 133KB │
│  └── e.proc           AIDAProcessor   sentence-transformers
│                                                         │
│  SAFETY (detects danger)                                │
│  ├── e.eip            EIPMonitor      15 clusters, 75vec│
│  ├── e.crisis_classifier CrisisClassifier  92 vectors   │
│  ├── e.warmth         WarmthGuard     101+ vectors      │
│  ├── e.psychosis_detector             45 vectors        │
│  ├── e.mania_detector                 31 vectors        │
│  ├── e.lethal_means_detector          28 vectors        │
│  ├── e.indirect_signal_handler        27 vectors        │
│  └── e.response_calibrator            post-processing   │
│                                                         │
│  FLOW (understands sessions)                            │
│  ├── e.frontal        FrontalLobe     det, H, session   │
│  ├── e.selector       Selector        4 modes           │
│  └── e.temporal       TemporalMonitor recurrence, decay │
│                                                         │
│  MEMORY (persists state)                                │
│  ├── e.memory         UserMemory      Supabase + JSON   │
│  ├── e.memory_lt      SemanticCerebellum  anchors       │
│  ├── e.sessions       SessionManager  hardware state    │
│  ├── e.dreamer        DreamState      consolidation     │
│  └── e.summarizer     Summarizer      Claude Haiku      │
│                                                         │
│  INTEGRITY (verifies responses)                         │
│  ├── e.defense        DefenseSystem   veto + identity   │
│  └── e.cleaner        CodeCleaner     code blocks       │
│                                                         │
│  LLM (generates text)                                   │
│  ├── e.claude_client  Anthropic       Claude Sonnet     │
│  ├── e.claude_sse_stream              SSE generator     │
│  └── e.deepseek_sse_stream            DeepSeek for code │
│                                                         │
│  CONFIG                                                 │
│  ├── e.rate_guard     RateGuard       20 rpm            │
│  ├── e.searcher       SearchEngine    Tavily web search │
│  ├── e.unlimited_users set            bypass free limit │
│  └── e.access_code    str             admin auth        │
└─────────────────────────────────────────────────────────┘
```

---

## Stage 1: LISTEN (understand.py — 421 lines)

What MARIS observes before responding.

```
message arrives
    │
    ▼
┌─ DETECT ──────────────────────────────────────────────┐
│                                                        │
│  warmth.get_temperature()        → casualness 0-1      │
│  warmth.is_system_frustration()  → feedback, not crisis│
│  brain.friction_history          → accumulated weight   │
│       │                                                │
│       ▼                                                │
│  crisis_classifier.classify()    → severity 0-5        │
│       │                                                │
│       ├── if severity > 0 + arquitecto intent → override to 0
│       │                                                │
│       ├── if severity > 0:                             │
│       │   lethal_means_detector.detect()               │
│       │   indirect_signal_handler.detect()             │
│       │                                                │
│       ▼                                                │
│  psychosis_detector.detect()     → ALWAYS runs         │
│  mania_detector.detect()         → ALWAYS runs         │
│       │                                                │
│       ▼                                                │
│  frontal.analyze_session()       → det, H, inject      │
│  selector.select_mode()          → presencia/explor/   │
│                                    arquitecto/construc  │
│  temporal.get_telemetry()        → recurrence, decay   │
│  eip.evaluate()                  → tier 0-3            │
│       │                                                │
│       ▼                                                │
│  warmth.detect_friction_real()   → gap said vs carried │
│  warmth.detect_encounter_temp()  → truth capacity      │
│  warmth.detect_crack_moment()    → something surfaced  │
│       │                                                │
│       ▼                                                │
│  ┌────────────────────────────────────────────┐        │
│  │         MessageContext (all signals)        │        │
│  │  crisis, psychosis, mania, lethal means,   │        │
│  │  friction, deformation, freefall, hour...  │        │
│  └──────────────────┬─────────────────────────┘        │
│                     │                                   │
│                     ▼                                   │
│            resolve_state(ctx)                           │
│            → tone (crisis/urgent/careful/deep/casual)   │
│            → length (short/medium)                      │
│            → focus (description)                        │
│                     │                                   │
│                     ▼                                   │
│  build_system_prompt()           → heart + data + signals
│       │                                                │
│       ▼                                                │
│  ┌────────────────────────────────────────────┐        │
│  │           Understanding                     │        │
│  │  system prompt, messages, modo, crisis,    │        │
│  │  detections, hw state, temperature...      │        │
│  └────────────────────────────────────────────┘        │
└────────────────────────────────────────────────────────┘
```

---

## Stage 2: RESPOND (respond.py — 258 lines)

MARIS generates, verifies, and sends.

```
Understanding arrives
    │
    ▼
┌─ GENERATE ────────────────────────────────────────────┐
│                                                        │
│  if crisis severity >= 3 → force Claude (not DeepSeek)│
│                                                        │
│  ROUTER:                                               │
│  ├── modo = "construccion" → deepseek_sse_stream       │
│  └── else               → claude_sse_stream            │
│       │                                                │
│       ▼ (full response buffered)                       │
│                                                        │
│  if failed + crisis severity >= 3:                     │
│      → crisis fallback message + resources             │
│                                                        │
└────────────────────────────────────────────────────────┘
    │
    ▼
┌─ POST-PROCESS (6 guards) ────────────────────────────┐
│                                                        │
│  1. response_calibrator.post_calibrate()               │
│     ├── passive: STRIP resources                       │
│     ├── active: MOVE resources to end                  │
│     ├── plan_with_method: PREPEND safety check         │
│     └── imminent: APPEND resources if missing          │
│                                                        │
│  2. lethal_means_detector.post_check()                 │
│     └── BLOCK dangerous method info                    │
│                                                        │
│  3. indirect_signal_handler.post_check()               │
│     └── REPLACE dangerous literal answers              │
│                                                        │
│  4. psychosis_detector.post_check()                    │
│     └── STRIP "not real", "your mind", denial          │
│                                                        │
│  5. mania_detector.post_check()                        │
│     ├── STRIP confrontational phrases                  │
│     └── DETECT compliance without sleep question       │
│                                                        │
│  6. defense.check_integrity()                          │
│     └── VETO if response capitulates                   │
│                                                        │
└────────────────────────────────────────────────────────┘
    │
    ▼
┌─ VERIFY ──────────────────────────────────────────────┐
│                                                        │
│  defense.check_identity()     → vectorial ID filter    │
│  defense.check_abstraction()  → flow corrupto detect   │
│  frontal.deliberate()         → sovereignty correction │
│  warmth.check_aggression()    → tone vs temperature    │
│  _enforce_spanish()           → EN→ES replacement      │
│                                                        │
└────────────────────────────────────────────────────────┘
    │
    ▼
┌─ SEND + LEARN ────────────────────────────────────────┐
│                                                        │
│  yield SSE delta (response text)                       │
│  yield SSE done  (telemetry JSON)                      │
│                                                        │
│  Background tasks:                                     │
│  ├── brain_update (friction, summary)                  │
│  ├── increment_msg_count                               │
│  ├── save_last_mode + deformacion                      │
│  ├── crystallize anchor (if friction > 0.3)            │
│  └── auto_sleep every 100 messages                     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## Data Flow Between Modules

```
                    ┌─────────┐
                    │ Supabase│
                    │   DB    │
                    └────┬────┘
                         │
              ┌──────────┼──────────┐
              │          │          │
         ┌────▼───┐ ┌───▼────┐ ┌──▼──────┐
         │ users  │ │ memory │ │ profiles│
         │        │ │ vault  │ │         │
         └────┬───┘ └───┬────┘ └──┬──────┘
              │         │         │
              └─────────┼─────────┘
                        │
                   ┌────▼────┐
                   │ Storage │ (UserMemory)
                   │  .py    │
                   └────┬────┘
                        │
            ┌───────────┼───────────┐
            │           │           │
       ┌────▼──┐   ┌───▼───┐  ┌───▼────┐
       │engine │   │Session│  │long_   │
       │  .py  │   │Manager│  │term.py │
       └───────┘   └───────┘  └────────┘


            ┌─────────────────────────┐
            │   Supabase Storage      │
            │   bucket: aida-safety   │
            │   ├── eip.py            │
            │   ├── crisis_index.npy  │
            │   └── crisis_library.json│
            └────────────┬────────────┘
                         │
                    startup.py downloads
                         │
                         ▼
                    modules/safety/eip.py
```

---

## Endpoint Map (30 routes)

```
AUTH (endpoints_auth.py)
  POST /register-ios         → create iOS user, return session token
  POST /register             → create email user
  POST /login                → verify credentials, return token
  POST /refresh-token        → renew expired token + msg_count
  POST /auth/google          → Google Sign-In
  POST /auth/apple           → Apple Sign-In

CHAT (Main.py)
  POST /chat                 → SSE stream (main conversation)
  POST /api/chat             → JSON (VERA-MH benchmark)

ADMIN (endpoints_admin.py)
  GET  /                     → web frontend (HTML)
  GET  /bienvenida           → welcome message
  GET  /system_status        → neuron count, friction (auth)
  GET  /brain_map_visual     → full brain state (auth)
  GET  /eip/{user_id}        → EIP state (auth)
  GET  /cicatrices/{user_id} → friction history (auth)
  GET  /temporal/{user_id}   → temporal state
  GET  /validate/{user_id}   → check if user exists
  GET  /greet/{user_id}      → personalized greeting
  POST /save                 → save brain to disk (auth)
  POST /sleep                → consolidate brain (auth)
  POST /ingest               → feed text to brain (auth)
  POST /anchor               → add semantic anchor (auth)
  POST /profile              → save user profile
  GET  /profile/{user_id}    → get user profile
  POST /resonance            → save resonance map
  GET  /resonance/{user_id}  → get resonance map
  DELETE /delete-account/{user_id} → delete user data (auth)
```

---

## Module Dependency Graph (no circular imports)

```
Level 0 (no project imports):
  models.py
  modules/core/Brain.py
  modules/core/Processor.py
  modules/core/Integrity.py
  modules/core/auth.py
  modules/core/llm.py
  modules/core/identity.py
  modules/core/warmth.py
  modules/core/cleaner.py
  modules/core/crisis_classifier.py
  modules/core/response_calibrator.py
  modules/core/clinical_detectors.py
  modules/core/safety_detectors.py
  modules/flow/intent.py
  modules/flow/search.py
  modules/memory/dream.py
  modules/memory/summarizer.py
  modules/memory/_db.py

Level 1 (imports from Level 0 only):
  modules/flow/selector.py      ← (no project imports)
  modules/memory/temporal.py     ← (no project imports)
  modules/memory/Storage.py      ← _db
  modules/memory/long_term.py    ← _db
  modules/core/audit.py          ← _db
  modules/core/session.py        ← selector, temporal, eip

Level 2 (imports from Level 0-1):
  engine.py                      ← ALL modules

Level 3 (imports from Level 0-2):
  understand.py                  ← models, crisis_classifier
  respond.py                     ← models
  endpoints_auth.py              ← models, auth
  endpoints_admin.py             ← models, auth, _db, ui

Level 4 (entry point):
  Main.py                        ← engine, models, understand,
                                    respond, endpoints_*
```

---

## Key Numbers

| Metric | Value |
|--------|-------|
| Total Python files | 31 |
| Total lines (estimate) | ~5,500 |
| Semantic vectors | 248+ |
| PyTorch parameters | 33,454 |
| Brain size on disk | 133 KB |
| API endpoints | 30 |
| Clinical post-checks | 6 |
| Crisis detection layers | 4 |
| Ethical gates | 6 |

---

*Architecture map — March 30, 2026*
*MARIS v4.0 — Leonel Perea Pimentel*
