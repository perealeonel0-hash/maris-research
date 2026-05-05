# MARIS — Mapa de Separación de Productos
**Fecha:** 2026-04-11
**Contexto:** Todo se mezcló porque se quería ser universal en un solo flujo. El resultado: un detector clínico serio enterrado dentro de un chat genérico que no sabe si es focus shield, terapeuta, o to-do list.

---

## LA VERDAD

Dentro de este monolito hay **6 productos distintos** que operan con lógicas, usuarios, y modelos de negocio incompatibles. Meterlos en un solo flujo de chat diluye todos.

---

## PRODUCTO 1: Safety Pipeline (el detector clínico)

**Qué es realmente:** Un sistema de detección de crisis en texto, grado casi-clínico. 5 capas independientes que evalúan riesgo desde ángulos distintos.

**Las 5 capas:**
| Capa | Archivo | Qué detecta | Vectores |
|------|---------|-------------|:--------:|
| EIPMonitor | eip.py (961 LOC) | Desesperanza, atrapamiento, agitación, intención. Acumulación entre turnos. | ~96 |
| CrisisClassifier | crisis_classifier.py (372 LOC) | Severidad 0-5 en escala C-SSRS. Lexical + semántico + meta-conversación guard. | ~45 |
| ClinicalDetectors | clinical_detectors.py (548 LOC) | Psicosis (5 clusters: percepción, paranoia, desorganización, grandiosidad, referencia). Manía (4 clusters). | ~76 |
| SafetyDetectors | safety_detectors.py (520 LOC) | Medios letales (6 categorías). Señales indirectas (dolor + pregunta peligrosa). | ~55 |
| ResponseCalibrator | response_calibrator.py (403 LOC) | Post-processing: remueve consejos genéricos, refuerza mirroring, agrega recursos según timing. | N/A |

**Total: ~2,800 LOC dedicadas, 248+ vectores semánticos, calibrado contra C-SSRS/DSM-5/ICD-11.**

**Por qué se pierde:** Está enterrado dentro de `understand.py` como un paso más del pipeline de chat. El usuario nunca sabe que existe. Nadie puede evaluarlo independientemente. No tiene API propia. No tiene métricas propias.

**Lo que debería ser:** Una API standalone: `POST /v1/safety/evaluate` → `{tier, severity, flags, reasons, resources, confidence}`. Deployable sin el chat. Vendible a otras apps. Auditable por profesionales clínicos.

---

## PRODUCTO 2: Physics Brain (el modelo de estado emocional)

**Qué es realmente:** Un sistema dinámico que modela la condición humana con ecuaciones de física — no mood scores, no sliders, no "¿cómo te sientes del 1 al 10?"

**Componentes:**
| Módulo | Qué hace |
|--------|----------|
| TRSLayer (Brain.py) | Red neuronal con neurogenesis. Neuronas nacen y mueren por sesión. Mide fricción como señal de que algo no encaja. |
| Physics state | Energy, capacity, velocity, freefall detection, recovery detection. `H_ef = H_0 · e^(-Fr/H_0)` |
| WarmthGuard | Temperatura emocional, friction_real, encounter_temp, crack moments, gradientes de crisis. Per-user physics. |
| TemporalMonitor | Rumination tracking, session arcs, drift detection. |
| Circadian weighting | Hora del día amplifica/atenúa señales. 3am = factor 0.95. |

**Por qué se pierde:** Todo esto corre en background. El usuario nunca ve su energy, su capacity, su velocity. No hay visualización. Los datos se calculan y se tiran al prompt de Claude como contexto invisible.

**Lo que debería ser:** Una visualización en la app (no números — formas, colores, movimiento). Y/o un SDK vendible a wearables/apps de wellness que quieran modelar estado emocional más allá de "Happy/Sad/Neutral."

---

## PRODUCTO 3: Focus Shield (la app consumer)

**Qué es realmente:** La app iOS que el usuario descarga. Chat + dashboard + widget + planes.

**El problema:** Intenta ser TODO a la vez:
- Alternativa al scroll (focus shield)
- Compañero reflexivo (prótesis)
- Organizador de vida (planes, calendario, brain dump)
- Monitor de bienestar (HealthKit, sleep, HRV)
- Detector de crisis (safety pipeline)

**Lo que debería ser:** UNA cosa. La decisión más importante es: **¿Qué es Boe para el usuario en una oración?**

Opciones reales (incompatibles entre sí):
| Opción | Una oración | Target | Competidor real |
|--------|------------|--------|----------------|
| A. Focus shield | "Abre esto en vez de Instagram" | 25-35 LATAM, +3hrs scroll/día | one sec, Opal, ScreenZen |
| B. Thinking tool | "Tu segundo cerebro que piensa contigo" | Profesionales, creadores | ChatGPT, Notion AI, Pi |
| C. Emotional companion | "Alguien que te conoce y recuerda" | Personas solas, sin red de soporte | Replika, Pi, Character.ai |
| D. Productivity copilot | "Organiza tu día con contexto" | Knowledge workers | Reclaim, Motion, Todoist AI |

**El chat actual intenta ser A+B+C+D simultáneamente.** El prompt V7 es mayormente C (emotional companion con técnicas Voss). El onboarding es D (productivity goals). El positioning es A (focus shield). El backend es C con safety pipeline debajo.

---

## PRODUCTO 4: Semantic Detector Library (open source)

**Qué es:** El patrón reutilizable de los 11 detectores: `embeddings → cosine similarity → threshold → result`.

**El patrón es el mismo en todos:**
```
1. Build index: encode examples → normalize → store
2. Detect: encode input → cosine vs index → max > threshold → detected
3. Post-check: modify LLM response based on detection
```

**Por qué vale la pena separarlo:** Es el moat técnico real. Bilingüe (ES/EN) con slang LATAM. Ninguna librería open source cubre detección emocional/crisis en español así. GitHub stars → credibilidad → contrataciones → consulting.

---

## PRODUCTO 5: Conversation Intelligence (el prompt + pipeline de respuesta)

**Qué es:** El sistema prompt V7 + understand.py + respond.py. Cómo MARIS decide qué decir.

**Lo que lo hace único:**
- Tubería-Piedras-Agua como framework operativo (busca estructura, fricción, y si el valor llega)
- Técnicas Voss programáticas (mirroring, labeling, calibrated questions)
- 6 tonos con instrucciones concretas (crisis, urgent, careful, deep, steady, casual)
- resolve_state como juez que lee TODOS los sensores antes de decidir
- Signal instructions que le dicen a Claude QUÉ HACER, no qué pensar

**Por qué importa separarlo:** Este sistema de "conversation design" podría ser un producto en sí — un framework para hacer que cualquier LLM tenga conversaciones más humanas. Pero hoy está hardcoded en un solo app.

---

## PRODUCTO 6: Analytics/Observability (el sistema de trazabilidad)

**Qué es:** trace.py + analytics events + audit.py + log_crisis_event. El sistema que registra qué pasó y por qué.

**Estado actual:** 20 eventos en iOS, endpoint de ingestion en backend, structured logging con request_id. Básico pero funcional.

**Lo que falta:** Dashboard para ver los datos. Métricas de retención. Funnel de onboarding→activación→retención. Sin esto no se puede medir nada.

---

## EL DIAGRAMA REAL

```
                    ┌─────────────────────────────────────────────┐
                    │              HOY: TODO MEZCLADO              │
                    │                                             │
                    │  iOS App (Boe)                              │
                    │    ├── Chat ←── prompt V7 + Voss            │
                    │    ├── Dashboard (features ocultas)         │
                    │    ├── Widget (estático)                    │
                    │    ├── BrainDump + VoiceTask (redundantes)  │
                    │    └── Plans + Calendar + HealthKit          │
                    │                                             │
                    │  Backend (MARIS)                            │
                    │    ├── understand.py (todo en 1 función)    │
                    │    ├── respond.py                           │
                    │    ├── Safety Pipeline (5 capas, invisible) │
                    │    ├── Physics Brain (invisible)            │
                    │    ├── 11 Semantic Detectors (inline)       │
                    │    └── Analytics (20 eventos, sin dashboard)│
                    └─────────────────────────────────────────────┘

                    ┌─────────────────────────────────────────────┐
                    │            DEBERÍA SER: SEPARADO             │
                    │                                             │
                    │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
                    │  │ Boe App  │  │ Safety   │  │ Physics  │  │
                    │  │ (Focus   │  │ API      │  │ Brain    │  │
                    │  │  Shield) │  │ (B2B)    │  │ SDK      │  │
                    │  │          │  │          │  │          │  │
                    │  │ Chat     │  │ /evaluate│  │ .update()│  │
                    │  │ Widget   │  │ /batch   │  │ .state() │  │
                    │  │ Dashboard│  │ /stream  │  │ .predict│  │
                    │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
                    │       │             │             │         │
                    │       └─────────────┴─────────────┘         │
                    │                     │                       │
                    │  ┌──────────┐  ┌────┴─────┐  ┌──────────┐  │
                    │  │ Detector │  │Conver-   │  │ Analytics│  │
                    │  │ Library  │  │sation    │  │ Dashboard│  │
                    │  │ (OSS)    │  │Intel.    │  │ (B2B)    │  │
                    │  └──────────┘  └──────────┘  └──────────┘  │
                    └─────────────────────────────────────────────┘
```

---

## LA DECISIÓN QUE FALTA

No es técnica. Es de producto. Necesitas responder **UNA** pregunta:

> **¿Qué quieres lanzar primero, y para quién?**

| Si eliges... | Entonces... | Y sacrificas... |
|-------------|------------|----------------|
| **Boe como Focus Shield** | El chat existe para sacar del scroll. Dashboard muestra screen time, streaks, alternativas. Widget es trigger activo. | La profundidad reflexiva. El detector clínico se vuelve safety net invisible, no feature. |
| **Boe como Thinking Tool** | El chat es el producto. Dashboard muestra patterns de pensamiento, insights, historia. | El angle de focus/detox. No compites con Opal sino con Pi/ChatGPT. |
| **Safety API primero** | Empaquetas el pipeline como API. Vendes a otras apps. Boe es demo, no producto. | La app consumer. Pero ganas revenue B2B más predecible. |
| **Open source detectores** | Publicas la librería. Ganas credibilidad. Consulting como revenue. | Revenue directo. Pero construyes marca y comunidad. |

**Lo que NO puedes hacer:** Lanzar una app que es las 4 cosas. Eso es lo que tienes hoy y por eso no funciona.

---

## MI RECOMENDACIÓN

**Lanza Boe como Thinking Tool (opción B).** Razón:

1. El prompt V7 YA es bueno para esto. No necesita rewrite.
2. El physics brain DIFERENCIA de ChatGPT/Pi cuando se hace visible.
3. La safety pipeline funciona como invisible safety net (no feature visible).
4. El mercado de "people who think for a living" paga $9.99/mo sin pestañear.
5. El valor aparece en la PRIMERA conversación (a diferencia de focus shield que toma días).
6. No requiere tracking de screen time (que Apple hace difícil).

**El focus shield angle es más sexy pero más difícil.** Requiere interceptar el scroll habit, lo cual necesita shortcuts/notifications/screen time API que Apple restringe. Y el TTV es días, no minutos.

**Después de tener 200 usuarios pagando en Boe Thinking Tool:**
- Empaqueta Safety API (B2B)
- Open source los detectores
- Agrega focus features como upgrade

---

## SIGUIENTE PASO CONCRETO

Define en 1 oración: **"Boe es _____ para _____ que _____."**

Hasta que esa oración exista, todo el código del mundo no arregla el problema.
