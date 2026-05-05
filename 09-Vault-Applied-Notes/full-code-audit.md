# AUDITORÍA COMPLETA DE CÓDIGO — MARIS
## Backend (9,550 LOC Python) + iOS (7,071 LOC Swift)
## Fecha: Abril 2026

---

## RESUMEN EJECUTIVO

| Métrica | Backend | iOS |
|---------|---------|-----|
| Archivos auditados | 28 | 22 |
| LOC total | 9,550 | 7,071 |
| God objects | 2 (Engine, WarmthGuard) | 3 (ChatViewModel, SessionManager, DashboardView) |
| Tests | 0 automatizados | 0 |
| Analytics events | 0 | 0 |
| Protocols/DI | 0 | 0 |
| Thread safety gaps | 5 módulos | 3 módulos |
| Pasos por mensaje | 51 | N/A |
| Monetización | N/A | DESHABILITADA |

---

## BACKEND: FLOW DE UN MENSAJE (51 pasos)

```
POST /chat → Main.py
  1-7: fast_check (x2 DUPLICADO), auth, rate limit, sanitize, repetition
    ├── EXIT: lexical crisis
    ├── EXIT: repetition
    └── CONTINUE

→ understand.py :: listen() [388 LOC, 1 FUNCIÓN, 40 if/else]
  8-30: warmth → friction → memory → search → embeddings
        → crisis_classifier → lethal_means → frontal
        → psychosis → mania → selector → temporal
        → eip.evaluate → physics → circadian → warmth
        → indirect_signals → resolve_state → positive
        → crisis_gradient → build_prompt → prepare_msgs
  OUTPUT: Understanding (30+ campos)

→ respond.py :: respond() [175 LOC]
  31-42: Route LLM → stream → 5 post-processors → VETO gate
         → identity → sovereignty → clean → spanish
  43: yield SSE text
  44-51: friction, deformation, temporal, insight, takeaway,
         background tasks (brain, msg_count, save_mode, anchor)
```

## BACKEND: SCORES POR ARCHIVO

| Archivo | LOC | Read | Test | Mod | Simp |
|---------|-----|------|------|-----|------|
| models.py | 194 | 5 | 5 | 5 | 5 |
| engine.py | 231 | 4 | 1 | 1 | 3 |
| Main.py | 243 | 3 | 2 | 2 | 2 |
| respond.py | 277 | 3 | 2 | 3 | 2 |
| understand.py | 498 | 3 | 1 | 2 | 1 |

## BACKEND: SCORES POR MÓDULO (top issues)

| Módulo | LOC | Issue |
|--------|-----|-------|
| eip.py | 961 | Más grande. 250 líneas datos inline |
| warmth.py | 569 | GOD OBJECT: 9 detectores en 1 clase |
| clinical_detectors | 548 | Duplica patrón de safety_detectors |
| safety_detectors | 520 | _build_semantic_index copy-pasteado |
| Storage.py | 347 | GOD OBJECT: auth+analytics+memory+session |
| temporal.py | 216 | MEJOR DISEÑADO: state separado de logic |

## BACKEND: 7 HALLAZGOS CRÍTICOS

1. **Engine = God Object** — 22 imports, 20+ atributos. Nada testeable sin Engine completo
2. **listen() = 388 líneas** — 1 función, 40 if/else, magic numbers
3. **Duplicación masiva en detectores** — 11 detectores con el mismo patrón copy-pasteado
4. **~800 líneas datos inline** — strings Python que deberían ser JSON externo
5. **Thread safety gaps** — 5 módulos con estado mutable sin locks
6. **/api/chat = pipeline paralelo** — duplica lógica con diferencias sutiles
7. **Bounded context violations** — session.py importa de los 3 contextos

---

## iOS: USER FLOW COMPLETO

```
App Launch → ContentView gates:
  ├── No consent → ConsentView ("Boe: una presencia que escucha")
  ├── No onboarding → EmotionalOnboarding (feeling→need→"Habla")
  └── Ready → MainTabView
        ├── Tab 0: DashboardView (greeting, plans, night review, actions)
        └── Tab 1: ChatView (loadGreeting→send→SSE→done→persist)
              ├── Menu → Ayuda, Notas, Sobre ti, Info, Ajustes
              └── Premium → Packs $4.99/$14.99 (DESHABILITADO)
```

## iOS: SCORES POR ARCHIVO

| Archivo | LOC | Read | Test | Mod |
|---------|-----|------|------|-----|
| MainTabView | 31 | 5 | 4 | 5 |
| ContentView | 17 | 5 | 3 | 4 |
| ConsentView | 113 | 4 | 3 | 4 |
| EmotionalOnboarding | 150 | 4 | 3 | 4 |
| StoreManager | 79 | 4 | 3 | 4 |
| NotificationService | 220 | 4 | 2 | 3 |
| LocalVault | 415 | 3 | 2 | 3 |
| PhysicsEngine | 378 | 3 | 1 | 2 |
| **ChatViewModel** | **459** | **1** | **1** | **1** |
| **DashboardView** | **578** | **2** | **1** | **1** |
| **SessionManager** | **150** | **2** | **2** | **2** |
| APIClient | 108 | 2 | 1 | 2 |
| MessageBubble | 395 | 2 | 1 | 1 |
| SettingsView | 471 | 2 | 1 | 1 |

## iOS: HALLAZGOS CRÍTICOS

### 1. ANALYTICS = CERO
No existe un solo evento trackeado. Cero frameworks importados. No Mixpanel, Firebase, Amplitude. Volando 100% ciego.

Eventos que DEBERÍAN existir: ~50+ categorizados en onboarding (7), engagement (6), safety (7), features (11), dashboard (10), monetización (7), retención (2).

### 2. ONBOARDING FALLA EL GRUNT TEST
- ConsentView: "Una presencia que escucha" — NO dice qué es la app, qué hace, ni por qué importa
- EmotionalOnboarding: calibra emoción pero no explica QUÉ hará Boe con esa información
- Valor hasta mensaje 1: requiere consent + onboarding + navegar a chat + escribir + esperar API = **5 acciones mínimo antes del primer valor**
- No hay: explicación del producto, ejemplo de conversación, social proof, ni credibilidad

### 3. MONETIZACIÓN DESHABILITADA
- `hasMessages` retorna `true` siempre (línea 122: "Limits disabled during development")
- El paywall nunca se activa
- Precios hardcodeados en dólares (no usa product.displayPrice)
- Sin validación server-side de compras
- Si el usuario reinstala, pierde mensajes comprados

### 4. ChatViewModel = GOD OBJECT (459 LOC)
16 responsabilidades: mensajes, greeting, name detection, intent routing, 12 comandos locales, muletillas, semantic cache, message limits, API, SSE processing, done-event side effects, error handling, conversion timing, account banner, connection status, persistence.
8 singletons directos. `send()` = 275 líneas con 6+ niveles de nesting.

### 5. 11+ SINGLETONS (.shared)
SessionManager, APIClient, LocalVault, StoreManager, PhysicsEngine, SemanticCache, NotificationService, IntentRouter, ReminderService, VoiceOutput, WeatherService, CalendarService, HealthKitService. Zero dependency injection. Zero protocols. Imposible de testear.

### 6. CONCURRENCY ISSUES
- PhysicsEngine: `@MainActor` parcial, `saveToDisk` captura self strongly en non-Sendable
- SemanticCache: read fuera de queue, write dentro — race condition
- LocalVault: `queue.sync` desde MainActor callers — potencial deadlock

---

## DEPENDENCIAS CRUZADAS (BACKEND)

```
Engine (GOD) ─imports→ 22 modules
  ├── CONVERSATION: identity, llm, Integrity, warmth, calibrator, Processor, Brain
  ├── CLINICAL: eip, clinical_detectors, safety_detectors, crisis_classifier, audit, auth
  ├── FLOW: intent, selector, search
  └── MEMORY: Storage, _db, long_term, dream, temporal, summarizer, session

Boundary violations:
  - eip.py (Safety) → Processor.detect_lang (Conversation)
  - session.py (Memory) → selector + temporal + eip (3 contextos)
  - dream.py (Memory) → Brain._lock privado (Conversation)
  - audit.py (Clinical) → _db (Memory)
  - clinical_detectors → safety_detectors._is_spanish (cross-file private)
```

---

## LO QUE ESTÁ BIEN (no todo es malo)

### Backend fortalezas:
- **temporal.py** — Mejor diseñado: state (dataclass) separado de logic (monitor). Modelo a seguir.
- **models.py** — Limpio, hoja sin dependencias, bien tipado
- **identity.py** — Puro, sin estado, testeable
- **summarizer.py** — Limpio, recibe dependencias por constructor
- **search.py** — Pequeño, enfocado, bien nombrado
- **Pipeline de safety es REAL** — 248 vectores, 15 clusters semánticos, C-SSRS grade. Esto es genuinamente difícil de replicar.
- **Physics brain es único** — Momentum, energy, weight, load con derivadas. No existe en ningún competidor.

### iOS fortalezas:
- **MainTabView** — Simple, limpio, hace una cosa
- **ContentView** — Gate logic clara y mínima
- **ConsentView** — Flujo funcional con crisis resources siempre accesibles
- **EmotionalOnboarding** — Rápido (3 taps), no invasivo
- **SemanticCache** — Concepto correcto (NLEmbedding local para ahorrar API calls)
- **La app FUNCIONA en el iPhone** — Para un solo dev, tener 39 archivos Swift funcionando con SSE streaming, HealthKit, widget, y onboarding es significativo
