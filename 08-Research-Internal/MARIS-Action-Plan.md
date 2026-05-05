# MARIS — Plan de Acción para Siguiente Sesión

---

## CONTEXTO PARA EL SIGUIENTE CLAUDE

### Qué es MARIS
AI "focus shield" — app iOS que reemplaza doomscrolling con conversación + planes de vida real. El usuario abre MARIS en vez de Instagram, habla sobre lo que le pesa, y MARIS le sugiere qué hacer en vez de scrollear.

### Stack
- **Backend:** FastAPI (Python 3.12) en Railway, 9,550 LOC
- **iOS:** SwiftUI, 7,071 LOC, 39 archivos
- **DB:** Supabase (Postgres)
- **LLMs:** Claude Sonnet (principal), Haiku (resúmenes), DeepSeek (construcción)
- **Embeddings:** sentence-transformers MiniLM (384d, on Railway)
- **Safety:** Pipeline de 248 vectores semánticos, C-SSRS grade, 15 clusters

### Vault de Conocimiento
Existe un vault en `research/vault/` con **16 archivos** de frameworks verificados. Cada decisión debe basarse en estos frameworks, NO en suposiciones.

**Negocio:**
- Hormozi ($100M Offers + Leads) — Ecuación de valor, Grand Slam, Core Four, Rule of 100
- Cialdini — 7 principios persuasión + Pre-Suasion
- Chris Voss — 9 técnicas FBI programables en el chat
- SPIN + Challenger — Onboarding de 5 pantallas
- Pink + Tracy — Problem-finding, self-concept, ABCs
- StoryBrand + Godin — BrandScript, one-liner, smallest viable audience
- Berger (Contagious) — STEPPS: triggers, emotion, stories

**Técnico:**
- ArjanCodes — Protocols, Strategy pattern, SOLID, DI
- Primeagen + Code Aesthetics — Never nesting, boring code, 10 reglas
- ByteByteGo — SSE, caching, rate limiting, async queue
- Codely + Hussein — Hexagonal parcial, bounded contexts, Postgres
- Concurrency — asyncio, TaskGroup, run_in_executor, Message Bus, circuit breaker

**Operativo:**
- CRO + A/B Testing — LIFT model, ResearchXL, PIE/ICE, funnel analysis
- Branding — Paleta navy/teal/gold, dark mode, MARIS name validated 7.7/10
- Finanzas — Unit economics ($8.04 gross profit/user), break-even 205 users, OKRs Q2
- Full Code Audit — 51 pasos por mensaje, god objects, 0 analytics, monetización deshabilitada

### Auditoría completada
3 agentes auditaron CADA archivo del código. Resultados en `research/vault/full-code-audit.md`. Hallazgos principales:

**Backend:**
1. Engine = god object (22 imports)
2. listen() = 388 LOC, 1 función, 40 if/else
3. 11 detectores con patrón copy-pasteado
4. ~800 líneas datos inline
5. 5 thread safety gaps
6. /api/chat duplica pipeline
7. Bounded context violations

**iOS:**
1. 0 analytics events
2. Monetización deshabilitada (hasMessages = true siempre)
3. Onboarding falla grunt test
4. ChatViewModel = god object (459 LOC, 16 responsabilidades)
5. 11+ singletons sin DI
6. Concurrency issues (PhysicsEngine, SemanticCache)

### Score actual: ~35% para lanzar y cobrar

---

## PLAN DE ACCIÓN (7 pasos, en orden)

### PASO 1: Externalizar anchors a JSON (2-3 hrs)
**Vault source:** ArjanCodes (data-as-code smell), Primeagen (boring code)

Mover `_ANCHORS_*` de selector.py, warmth.py, eip.py, crisis_classifier.py, clinical_detectors.py, safety_detectors.py a archivos JSON en `config/`.

- `config/anchors_selector.json` — anchors de modo (peso, explora, decision)
- `config/anchors_warmth.json` — 7 indices de warmth
- `config/anchors_safety.json` — crisis, psychosis, mania, lethal means, indirect
- `config/anchors_classifier.json` — exemplars por nivel 0-5

Cargar en runtime. Permitir recarga sin deploy. Reduce ~800 LOC de datos inline.

### PASO 2: Analytics mínimo viable (4-6 hrs)
**Vault source:** CRO vault (instrument events before any test), Lean Startup (vanity vs actionable)

iOS: Integrar PostHog (open source, gratis hasta 1M events/mes, no requiere server propio).

Eventos mínimos (20 eventos críticos):
```
# Onboarding
app_opened, consent_accepted, onboarding_completed

# Activación
first_message_sent, first_response_received
returned_day_1, returned_day_3, returned_day_7

# Engagement
message_sent (con session_number, day)
notification_tapped

# Safety
crisis_detected (tier), crisis_resources_shown

# Monetización
paywall_viewed (trigger), purchase_completed, purchase_failed

# Retención
session_duration, streak_count
```

Backend: Agregar `X-Request-ID` header y loggear latency por paso del pipeline.

### PASO 3: Rehabilitar monetización (6-8 hrs)
**Vault source:** Hormozi (círculo virtuoso precio alto), CRO (paywall timing post-valor)

1. Cambiar de packs consumibles a **suscripción** ($9.99/mes, $59.99/año)
2. Restaurar lógica de `hasMessages` con freemium: 3 conversaciones/día gratis, unlimited pagado
3. Usar `product.displayPrice` en vez de precios hardcodeados
4. Paywall timing: mostrar después de primera sesión con valor (primer takeaway o insight)
5. Agregar validación server-side de receipt (Supabase Edge Function o endpoint dedicado)

### PASO 4: Rediseño onboarding (8-12 hrs)
**Vault source:** SPIN (S→P→I→N), Challenger (reframe), StoryBrand (grunt test), Berger (emotion)

Nuevo flow de 3 pantallas:

**Pantalla 1 — Reframe (Challenger)**
"Tu teléfono usa los mismos mecanismos que las máquinas tragamonedas. No es falta de disciplina — es diseño."
+ Dato: screen time estimado del usuario (o promedio: "3.5 hrs/día")

**Pantalla 2 — Need-Payoff (SPIN)**
"¿Qué harías con 2 horas extra cada día?"
(4 opciones tapeables + campo libre)
→ Esto se guarda como su compromiso (Cialdini: Commitment & Consistency)

**Pantalla 3 — Habla (inmediato)**
Chat directo. Sin más pantallas. MARIS abre con accusation audit (Voss):
"Probablemente piensas que es otra app que te va a sermonear. No estoy aquí para eso. Solo cuéntame cómo llegas hoy."

Consent y crisis resources accesibles desde menú, no como barrera pre-onboarding.

### PASO 5: Prompt V6 con técnicas Voss (4-6 hrs)
**Vault source:** Chris Voss vault (9 técnicas)

Reescribir identity.py MARIS_SYSTEM con reglas programáticas:

```
REGLAS DE CONVERSACIÓN:
1. NUNCA preguntar "¿Por qué...?" → siempre "¿Qué hace que...?" o "¿Cómo se siente...?"
2. Antes de sugerir ALGO, etiquetar la emoción: "Suena como que..." / "Parece que..."
3. Cuando el usuario confiesa algo, MIRRORING: repetir las últimas 2-3 palabras clave
4. En primera interacción, ACCUSATION AUDIT: "Sé que otra app prometiendo cosas puede sonar a más de lo mismo..."
5. Buscar "That's right" (conexión) no "You're right" (dismissal)
6. Tono FM DJ: oraciones cortas, sin exclamaciones, sin emojis, cálido pero no efusivo
7. Ratio 70% empatía / 30% nudge en CADA respuesta
8. NUNCA prescribir. Guiar con calibrated questions para que el usuario llegue a su propia conclusión
```

### PASO 6: Health check + plomería backend (4 hrs)
**Vault source:** ByteByteGo (health gating, heartbeat, idempotency), Hussein (PgBouncer), Concurrency (race conditions)

1. `/health` endpoint — Railway no rutea tráfico hasta 200
2. SSE heartbeat cada 15s — previene que carriers maten conexiones
3. Cambiar Supabase a port 6543 (PgBouncer transaction mode)
4. Fijar los 5 thread safety gaps:
   - RateGuard: agregar `threading.Lock`
   - WarmthGuard: agregar lock en `_prev_temperature`
   - search._rate: agregar lock
   - long_term.anchors: agregar lock
   - CrisisState: usar per-user lock via `UserLockManager`
5. `asyncio.gather` para queries paralelas de Supabase en listen()

### PASO 7: Recolección de datos para ML futuro (2 hrs)
**Vault source:** Copilot recommendation, Lean Startup (build-measure-learn)

Agregar tabla en Supabase:
```sql
CREATE TABLE training_data (
    id UUID DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    tier INT,
    friction FLOAT,
    mode TEXT,
    user_action TEXT,  -- 'continued', 'left', 'crisis_tapped'
    clinician_review BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

En respond.py, después de cada respuesta exitosa, insertar row anónima (sin user_id, sin texto completo — solo embedding hash + métricas).

---

## TIMELINE

| Semana | Pasos | Resultado |
|--------|-------|-----------|
| Semana 1 | 1 (anchors) + 2 (analytics) | Código limpio + ojos abiertos |
| Semana 2 | 3 (monetización) + 4 (onboarding) | Se puede cobrar + nueva primera impresión |
| Semana 3 | 5 (prompt V6) + 6 (plomería) | Chat con Voss + backend sólido |
| Semana 4 | 7 (data collection) + TestFlight beta | Datos fluyendo + primeros testers |

**Total: ~35-45 horas de trabajo. 4 semanas a ritmo part-time.**

Después de esto: TestFlight beta → feedback → iterate → lanzar en App Store.

---

## REGLAS PARA EL SIGUIENTE CLAUDE

1. **Un problema a la vez.** No combinar fixes de distintas áreas.
2. **Consultar el vault** antes de tomar decisiones de diseño/arquitectura.
3. **No inventar datos.** Si no estás seguro, pregunta o usa Grep.
4. **Verificar después de implementar.** Syntax check + test real.
5. **No agregar complejidad.** Boring code wins (Primeagen). Si 3 líneas obvias resuelven el problema, no crear una abstracción.
6. **Tag antes de tocar:** `git tag v1.x-pre-[cambio]`
7. **Cold start = 6.5s.** No deployar 6 cambios juntos.
8. **Lenguaje del proyecto:** Hardware/Flow/Fricción. No términos clínicos en strings visibles al usuario.
9. **Chris Voss en el prompt.** Mirroring, labeling, calibrated questions. NUNCA "¿Por qué...?"
10. **MARIS no es terapia.** Es un focus shield. Posicionar como lifestyle upgrade, no salud mental.
