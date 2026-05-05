# AUDITORÍA: Vault Técnico vs Código Real
**Fecha:** 2026-04-09
**Método:** Cada regla del vault cruzada contra el árbol de arquitectura real

---

## PRIMEAGEN / CODE AESTHETICS — Violations

### REGLA: "Max 20-25 líneas por función"
| Función | LOC | Violación |
|---------|:---:|-----------|
| `listen()` understand.py | ~400 | 16x el límite. 23 responsabilidades en 1 función |
| `send()` ChatViewModel.swift | ~275 | 11x el límite |
| `Engine.__init__()` engine.py | ~100 | 4x el límite. Inicializa 22 módulos |
| `resolve_state()` understand.py | ~60 | 2.4x — aceptable si se lee como tabla de decisión |
| `respond()` respond.py | ~180 | 7x — routing + post-processing + learning + done event |
| `check_identity()` Integrity.py | ~45 | 1.8x — casi acceptable |

### REGLA: "Never Nesting — max 2 levels"
| Archivo:línea | Depth | Ruta |
|---------------|:-----:|------|
| understand.py:302 | 3 | `listen()` → `IF eip is not None` → `IF client_last_tier >= 1` → `IF cstate.hopelessness == 0.0` |
| understand.py:393 | 3 | `listen()` → `IF not gradient` → `AND deformacion > 0.35` → `AND scars < 3` (inline pero conceptualmente anidado) |
| respond.py:127 | 3 | `respond()` → `TRY` → `IF severity >= 1 AND response_calibrator` → `post_calibrate()` |
| resolve_state:51-56 | 2 | `IF is_deep_night` → `IF hour == 3` — aceptable, es una tabla |
| Main.py:47-58 | 3 | `chat()` → `IF Bearer` → `TRY verify` → `EXCEPT` → `IF _quick_crisis` / `ELIF expirada` |
| ChatViewModel send() | 6+ | Nested closures: `onDone` → `Task` → `if let` → `DispatchQueue` |

### REGLA: "Guard clauses — happy path at leftmost indentation"
**VIOLATED in:** `resolve_state()` — usa cascada de if/return (correcto, ES guard clauses). OK.
**VIOLATED in:** `listen()` — no tiene guard clauses. Todo es secuencial con try/except inline. La función debería abortarse temprano si el mensaje está vacío, pero no lo hace.
**VIOLATED in:** `respond()` — el `if failed or not full_text` en línea 112 es el guard, pero está después de 40 líneas de setup.

### REGLA: "Functions = verbs, Booleans = questions"
| Violación | Correcto |
|-----------|----------|
| `_is_casual` (variable, no función) | Aceptable como flag |
| `_skip_others` | Debería ser `_should_skip_secondary_detectors` |
| `_quick_crisis` | Debería ser `is_lexical_crisis` |
| `_has_crisis_words` | OK ✓ |
| `_indirect_with_crisis` | Debería ser `has_indirect_with_crisis` |
| `_classifier_crashed` | OK ✓ |
| `verified` | Debería ser `is_verified` |

### REGLA: "Steps = stateless transforms: step(context) → context"
**MASSIVELY VIOLATED.** `listen()` muta `u` (Understanding) a lo largo de 400 líneas. No hay steps intermedios que transformen un contexto inmutable. Comparar con vault copilot-blackbox que propone 9 cajas con contratos JSON:
- Código real: 1 función monolítica que muta un objeto mutable
- Vault target: 9 módulos cada uno con `IN → OUT` definido

### REGLA: "Don't abstract until 3 cases — Rule of Three"
**NOT VIOLATED.** No hay abstracciones prematuras. De hecho el problema es el opuesto: no hay SUFICIENTE abstracción. Todo está inline.

### REGLA: "Test boundaries, not implementation"
**PARTIALLY VIOLATED.** `test_critical_paths.py` tiene 16 tests pero:
- 0 tests end-to-end (HTTP request → SSE response)
- 0 tests de crisis pipeline completo
- Tests prueban funciones internas (resolve_state, sanitize) no boundaries
- No hay mocks de Claude API para test de respond()

---

## ARJANCODES — Violations

### REGLA: "DI con Protocols — Constructor injection"
**MASSIVELY VIOLATED.** Engine.__init__() crea TODOS los objetos directamente:
```
self.brain = TRSLayer()           # concrete, not Protocol
self.proc = AIDAProcessor()       # concrete, not Protocol
self.defense = DefenseSystem(proc, brain)  # DI exists here!
...22 more direct instantiations
```
- 0 Protocols definidos en todo el backend
- 0 interfaces en todo el proyecto
- Engine es el composition root Y el god object simultáneamente
- Testing requiere inicializar Engine completo (9+ minutos con ML models)

### REGLA: "Protocol at module boundaries"
**ZERO protocols.** Cada módulo importa implementaciones concretas de otros módulos:
- `understand.py` importa `CrisisLevel` de `crisis_classifier.py`
- `respond.py` importa `Understanding` de `models.py` (esto está bien, es un data object)
- `engine.py` importa 22 módulos concretos
- Vault dice: "Modules never import implementations from others, only protocols"

### REGLA: "Strategy Pattern para reemplazar if/else chains"
**TARGET:** `resolve_state()` debería ser un `ModeResolver` con strategies ordenadas.
**REALIDAD:** resolve_state() es un if/elif/elif chain de 60 líneas. Cada condición hardcoded. Agregar un nuevo estado = editar la función, no agregar un strategy.

El vault dice:
> `ModeStrategy` Protocol con `matches()` + `execute()`. `ModeResolver` takes ordered list. Adding a new one = 1 class + 1 line.

El código real:
```python
if ctx.psychosis_detected and not has_crisis:
    return "careful", "short", "posible psicosis"
if ctx.mania_detected and not has_crisis:
    return "careful", "medium", "posible manía"
if ctx.is_deep_night and (...):
    ...12 more conditions
```

### REGLA: "Configuration — Pydantic Settings > dataclasses > raw env vars"
**VIOLATED.** Toda la config es `os.environ.get()` scattered across files:
- engine.py: `ACCESS_CODE`, `UNLIMITED_USERS`, `ALLOWED_ORIGINS`, `ANTHROPIC_API_KEY`, etc.
- auth.py: `SESSION_SECRET`, `GOOGLE_CLIENT_ID`
- startup.py: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`

Vault dice Pydantic Settings. Código usa raw env vars con defaults manuales.

### REGLA: "Modern Python — Type hints on public boundaries"
| Función | Type hints? |
|---------|:-----------:|
| `listen(req, e)` | No. `req` sin tipo, `e` sin tipo |
| `respond(u, background_tasks, e)` | No. `e` sin tipo |
| `resolve_state(ctx)` | Sí ✓ `MessageContext` |
| `build_system_prompt(...)` | Sí ✓ |
| `sanitize(text)` | No return type |
| `Engine.__init__` | No return types en atributos |

---

## BYTEBYTEGO — Violations

### REGLA: "SSE heartbeat every 15s"
**NOT IMPLEMENTED.** Si Claude tarda >15s, el cliente no recibe heartbeats. iOS podría timeout.

### REGLA: "Backpressure: asyncio.Queue(maxsize=100)"
**NOT IMPLEMENTED.** `llm.py` usa `queue.Queue()` (threading, no asyncio) sin maxsize. Si Claude streams faster than the client consumes, memory grows unbounded.

### REGLA: "Rate Limiting — Token Bucket, sliding window"
**PARTIALLY IMPLEMENTED.** RateGuard usa sliding window (good) pero:
- Free: 5 msg/day (not per hour as vault suggests)
- No burst allowance (vault says Token Bucket allows bursts)
- No global Claude API rate limit (vault says max 100/min)

### REGLA: "Timeout cascade: iOS 30s > Gateway 25s > Claude 20s"
**NOT IMPLEMENTED.**
- iOS: `streamConfig.timeoutIntervalForRequest = 30` ✓
- Gateway: No timeout on FastAPI side
- Claude: No timeout on `claude_client.messages.create()` in llm.py
- Vault says inner always < outer. Reality: Claude has NO timeout, could block forever.

### REGLA: "Health check gating — /health returns 503 until ready"
**NOT IMPLEMENTED.** No `/health` endpoint. Railway hits the app immediately on deploy.

### REGLA: "Parallel pipeline steps 9-15"
**NOT IMPLEMENTED.** `listen()` is sequential:
```
temperature → context → web_search → embeddings → crisis → detectors → mode → physics
```
Vault says steps 9-15 (Anchors || History || Health data) should be `asyncio.gather()`.
Only context retrieval uses `asyncio.gather()` (2 calls). The rest is sequential.

### REGLA: "Never SELECT *, cursor pagination, connection pooling"
**CANNOT VERIFY** without reading Supabase queries in Storage.py. But session.py uses `select("*")` in multiple places (violation).

---

## CODELY / HUSSEIN — Violations

### REGLA: "3 Bounded Contexts: Conversation, Clinical, Memory"
**VIOLATED.** Boundaries don't exist:
- `session.py` imports from all 3 contexts (confirmed in audit)
- `understand.py` calls modules from all 3 contexts in one function
- `engine.py` holds references to all 22 modules
- No separation between Conversation (chat flow), Clinical (safety), Memory (anchors)

### REGLA: "Value Objects (immutable) vs Entities (mutable)"
**VIOLATED.**
- `CrisisLevel` is a dataclass but NOT frozen → mutable when it should be immutable
- `MessageContext` is a dataclass but NOT frozen → mutable
- `HardwareState` in selector.py is mutable (deformacion updated in place)
- `Understanding` is mutable (populated field by field in listen())

Vault says: "Value Objects: MoodScore, RiskLevel, EmbeddingVector — immutable, compared by value"

### REGLA: "Idempotency: ULIDs + Redis 5min TTL"
**NOT IMPLEMENTED.** No idempotency keys. If iOS retries a failed request, MARIS processes it twice, calls Claude API twice, bills twice.

### REGLA: "Connection Pooling with PgBouncer port 6543"
**NOT VERIFIED.** Supabase client in `_db.py` — need to check if it uses port 6543 or 5432.

---

## PYTHON CONCURRENCY — Violations

### REGLA: "NEVER run_in_executor for Supabase"
**POTENTIALLY VIOLATED.** `understand.py:131,136` uses `run_in_executor` for `memory.get_context()` and `memory.get_user_by_id()`. If these call Supabase under the hood, this violates the rule. Vault says: use async Supabase client directly.

### REGLA: "Dedicated ThreadPoolExecutor(2) for sentence-transformers"
**NOT IMPLEMENTED.** `run_in_executor(None, ...)` uses the DEFAULT executor (shared). Vault says dedicated pool for ML inference to avoid starving other tasks.

### REGLA: "asyncio.Queue is NOT thread-safe"
**VIOLATED in llm.py.** The Claude streaming in `llm.py` uses `queue.Queue()` (threading) bridged to async via `asyncio.Queue`. But the pattern uses `loop.call_soon_threadsafe(queue.put_nowait, item)` — need to verify. If it uses plain `queue.put()` from a thread into an asyncio.Queue, it's a race condition.

### REGLA: "Per-user lock pattern with UserLockManager"
**NOT IMPLEMENTED.** No per-user locks. Concurrent requests for the same user can cause:
- Race in `warmth._user_physics` (we added per-user dict but no lock)
- Race in `brain._user_physics` (same)
- Race in session state updates

### REGLA: "Circuit Breaker for Claude API"
**NOT IMPLEMENTED.** If Claude is down, every request still tries and fails. No fail-fast. No fallback. Vault says: fail_threshold=3, reset_timeout=30s, fallback to generic response.

### REGLA: "Shared Nothing is best — move state to Supabase/Redis"
**MASSIVELY VIOLATED.** In-memory state everywhere:
- `_hardware_sessions` (lost on restart)
- `brain.friction_history` (in RAM, saved periodically)
- `warmth._user_physics` (in RAM only)
- `rate_guard._limit` (in RAM only)
- `msg_count` (in RAM only)

---

## COPILOT BLACKBOX ARCHITECTURE — Gap Analysis

The vault proposes 9 boxes. Here's what exists vs what's missing:

| Box | Vault Target | Code Reality | Gap |
|-----|-------------|-------------|-----|
| 1. Ingest | Separate module, sanitize, fast_check | Inline in Main.py:37-80 | No separation |
| 2. Embedder | Cacheable, dedicated | `proc.text_to_flow()` called ad-hoc | No cache layer |
| 3. Feature Engine | features struct | Computed inline in listen() | No separation |
| 4. State Engine | TRS + Physics with contract | `brain.forward()` + `brain.physics_state_for()` | Partially exists |
| 5. Safety Classifier | Unified tier output | 6 separate detectors called sequentially | Scattered, no unified output |
| 6. Mode Resolver | Strategy pattern, rules engine | `selector.select_mode()` + `resolve_state()` | Two places for same decision |
| 7. Prompt Builder | Templates, LLM router | Inline in listen():433-506 | No separation |
| 8. Response Calibrator | Unified post-processing | 5 separate post-processors in respond() | Scattered |
| 9. Persistence | Event-driven, observability | `background_tasks.add_task()` scattered | No Message Bus |

### Mode Resolver Rules — Vault vs Code

**Vault says:**
```
CRISIS if tier>=4 OR (friction>=0.8 AND lexical_flag in {suicidal, plan})
ARCHITECT if anchor_scores["arquitecto"]>0.6 AND product_feedback
FAST_PATH if tier==0 AND friction<0.2
PAYWALL if session_turn>=free_limit AND not premium
ESCALATE if llm_error AND tier>=3
EXPLORATION default
```

**Code does:**
- CRISIS decision is split across: `Main.py` (lexical), `understand.py:resolve_state` (tone), `respond.py:100` (routing), `respond.py:205` (event tagging) — 4 different places
- ARCHITECT: `selector.select_mode()` decides, but `understand.py:232` can OVERRIDE it back to 0
- FAST_PATH: doesn't exist as a concept. Casual messages still go through full pipeline
- PAYWALL: `understand.py:224-230` decides, but iOS ALSO decides independently
- ESCALATE: doesn't exist. API failure → generic error for severity 0-2, crisis fallback for 3+
- No unified resolver. The "mode" emerges from 4+ files making independent decisions

---

## RESUMEN: TOP 10 GAPS VAULT → CÓDIGO

| # | Vault Rule | Code Reality | Impact |
|---|-----------|-------------|--------|
| 1 | 9 black boxes con contratos | ✅ 5 sub-funciones extraídas (max 68 LOC) | FIXED |
| 2 | Protocol + DI everywhere | ✅ protocols.py con LLMProvider, EmbeddingProvider, CrisisDetector | FIXED (protocols exist, DI pendiente) |
| 3 | Strategy pattern for mode | if/elif chain in resolve_state | Can't add modes without editing |
| 4 | Stateless transforms step→step | ✅ CrisisLevel + MessageContext frozen | PARTIALLY FIXED |
| 5 | Claude timeout + circuit breaker | ✅ 25s timeout. Circuit breaker pendiente | PARTIALLY FIXED |
| 6 | Per-user locks + shared nothing | In-memory state, no locks | Race conditions, data loss on restart |
| 7 | Parallel pipeline steps | Sequential (except 1 gather) | Slower than necessary |
| 8 | Pydantic Settings for config | ✅ config/settings.py frozen dataclass | FIXED |
| 9 | Idempotency keys | None | Double billing on retry |
| 10 | /health endpoint | ✅ GET /health returns neurons count | FIXED |

---

## PRIORIDAD DE REFACTOR (basado en vault)

### Fase 1: No romper nada, ganar testabilidad
1. Extraer `listen()` en 5 funciones ✅ DONE — `_read_room`, `_classify_crisis`, `_detect_clinical`, `_build_signals`, `_build_prompt`
2. Crear `thresholds.py` ✅ DONE
3. Agregar `/health` endpoint ✅ DONE
4. Agregar timeout a Claude API call ✅ DONE — 25s en llm.py

### Fase 2: Contracts
5. Crear Protocol para `LLMProvider` (Claude, DeepSeek) ✅ DONE — protocols.py
6. Crear Protocol para `EmbeddingProvider` ✅ DONE — protocols.py
7. Crear `Settings` dataclass frozen para toda la config ✅ DONE — config/settings.py, engine.py y auth.py migrados
8. Hacer `CrisisLevel` y `MessageContext` frozen ✅ DONE — frozen=True, slots=True

### Fase 3: Architecture
9. Mode Resolver con Strategy pattern
10. Circuit Breaker para Claude
11. Per-user locks
12. Event Bus para background tasks

### Fase 4: Performance
13. Parallel pipeline con `asyncio.gather()`
14. Embedding cache con sha256 key
15. Dedicated ThreadPoolExecutor para ML
