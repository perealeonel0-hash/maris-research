# CANVAS DE DISEÑO — Tus piezas reales + espacio para diseñar

---

## TUS PIEZAS (lo que existe y funciona)

```
┌─────────────────────────────────────────────────────────┐
│                    DETECCIÓN (input: texto)              │
│                                                         │
│  fast_check ─── match lexical ──→ CRISIS INMEDIATA      │
│       ↓ si no                                           │
│  CrisisClassifier ── severity 0-5 (98 vectores)        │
│  EIPMonitor ──────── tier 0-3, acumulación (96 vec)     │
│  LethalMeansDetector ── 6 categorías (29 vec)           │
│  PsychosisDetector ──── 4 clusters (45 vec)             │
│  ManiaDetector ───────── 4 clusters (31 vec)            │
│  IndirectSignalHandler ─ dolor+pregunta (27 vec)        │
│  SystemFrustration ──── "eres malo" vs crisis (43 vec)  │
│                                                         │
│  TOTAL: 7 detectores, 369 vectores                      │
│  OUTPUT: severity, tier, flags, detected per detector   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    LECTURA (input: texto + embedding)    │
│                                                         │
│  get_temperature ──── 0.0 casual → 1.0 peso denso      │
│  friction_real ────── gap entre lo que dice y lo que    │
│                       realmente pesa (14 vec)           │
│  encounter_temp ──── cuánta verdad puede recibir        │
│                      AHORA (10 vec + circadian)         │
│  crack_moment ────── "nunca le dije a nadie" (15 vec)   │
│  positive_moment ─── "lo logré" (27 vec)                │
│  insight_moment ──── "ahora lo veo" (25 vec)            │
│  crisis_gradient ─── fricción subiendo entre sesiones   │
│                                                         │
│  TOTAL: 7 lecturas, 91 vectores                         │
│  OUTPUT: temperatura, fricción, cracks, positivos       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    PHYSICS (input: embedding + tiempo)   │
│                                                         │
│  Brain.forward() ── fricción por neurona                │
│  velocity ────────── d(friction)/dt                     │
│  capacity ────────── H₀ · e^(-Fr/H₀)                   │
│  is_freefall ─────── velocity > 0.01                    │
│  is_recovering ───── velocity < -0.005                  │
│  capacity_critical ─ capacity < 0.3                     │
│  circadian ────────── 3AM=0.95, 9AM=0.20               │
│                                                         │
│  OUTPUT: estado físico de la persona en este momento    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    JUEZ (input: todo lo anterior)        │
│                                                         │
│  resolve_state ─── lee TODOS los sensores y decide:     │
│                                                         │
│    psicosis sin crisis ────→ careful, short             │
│    manía sin crisis ───────→ careful, medium            │
│    madrugada + peso ───────→ crisis/urgent, short       │
│    crisis + frustración ───→ urgent, medium             │
│    crisis sola ────────────→ crisis, short              │
│    freefall + baja cap ────→ urgent, short              │
│    capacity critical ──────→ crisis, short              │
│    crack moment ───────────→ deep, short                │
│    friction_real > 0.6 ────→ careful, medium            │
│    peso sin crisis ────────→ deep/careful, medium       │
│    recuperándose ──────────→ steady, medium             │
│    casual ─────────────────→ casual, short              │
│    default ────────────────→ steady, medium             │
│                                                         │
│  OUTPUT: tono + longitud + foco                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    VOZ (input: tono + señales)           │
│                                                         │
│  Prompt V7 ───── "Describe su problema mejor de lo     │
│                   que puede." Voss: mirroring, labeling │
│                   70% preguntas, 30% observaciones      │
│                                                         │
│  _build_signals ── instrucciones concretas para Claude: │
│    severity≥3: "Oración 1: nombra. Oración 2: ¿hay     │
│                 alguien contigo?"                        │
│    severity 1-2: "Repite sus palabras. Pregunta qué/cómo│
│    psicosis: "Nombra la EMOCIÓN, no el contenido"       │
│    manía: "Pregunta cuándo durmió PRIMERO"              │
│    lethal means: "¿Puedes alejarte del medio?"          │
│    indirect: "Responde al dolor, ignora la pregunta"    │
│    eating: "Explora suavemente, sin términos clínicos"  │
│                                                         │
│  OUTPUT: system prompt completo para Claude              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               POST-PROCESSING (input: respuesta LLM)    │
│                                                         │
│  1. ResponseCalibrator ── strip/append/move recursos    │
│  2. LethalMeans post ──── agrega reducción si falta     │
│  3. IndirectSignal post ─ reemplaza respuestas letales  │
│  4. Psychosis post ────── reemplaza invalidación        │
│  5. Mania post ────────── quita confrontación,          │
│                           prepone pregunta de sueño     │
│  6. Integrity ─────────── bloquea frases dañinas        │
│  7. Identity ──────────── bloquea auto-referencia       │
│                                                         │
│  OUTPUT: respuesta verificada y segura                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               MODE SELECTOR (input: embedding + hw)     │
│                                                         │
│  presencia ──── peso emocional → Claude                 │
│  exploración ── curiosidad → Claude                     │
│  arquitecto ─── decisiones → Claude                     │
│  construcción ─ hacer técnico → DeepSeek                │
│                                                         │
│  OUTPUT: modo + razón                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               iOS (lo que el usuario ve hoy)            │
│                                                         │
│  Chat ─────────── texto/voz → streaming SSE             │
│  Dashboard ────── planes + calendario (features ocultas)│
│  Widget ───────── nombre de plan (estático)             │
│  BrainDump ────── voz → tareas extraídas                │
│  VoiceTask ────── (redundante con BrainDump)            │
│  HealthKit ────── sueño, pasos, HRV (invisible)        │
│  Notificaciones ─ mañana + noche (contenido estático)   │
│                                                         │
│  OCULTO (se calcula pero no se muestra):                │
│    stability score, focus message, streak,              │
│    night review, detox tracking, week moods             │
└─────────────────────────────────────────────────────────┘
```

---

## EL FLUJO REAL (cómo se conectan hoy)

```
MENSAJE ENTRA
     │
     ├──→ fast_check ──→ ¿match lexical? ──SÍ──→ CRISIS DIRECTA (sin LLM)
     │                                     │
     │                                     NO
     │                                     ↓
     ├──→ DETECCIÓN ──→ severity, tier, flags
     │
     ├──→ LECTURA ────→ temperatura, fricción, cracks
     │
     ├──→ PHYSICS ────→ freefall, capacity, velocity
     │
     ├──→ JUEZ ───────→ tono + longitud + foco
     │
     ├──→ MODE ───────→ presencia/exploración/arquitecto/construcción
     │
     ├──→ VOZ ────────→ system prompt + señales
     │
     ├──→ LLM ────────→ Claude (o DeepSeek si construcción)
     │
     ├──→ POST-PROCESSING ──→ 7 capas de verificación
     │
     └──→ RESPUESTA SEGURA ──→ SSE stream al usuario
```

---

## ESPACIO PARA DISEÑAR

### Pregunta 1: ¿Cuántos productos ves aquí?
```
Producto 1: _______________________________________________
  Usa estos bloques: _____________________________________
  Para quién: ____________________________________________
  Una oración: ___________________________________________

Producto 2: _______________________________________________
  Usa estos bloques: _____________________________________
  Para quién: ____________________________________________
  Una oración: ___________________________________________

Producto 3: _______________________________________________
  Usa estos bloques: _____________________________________
  Para quién: ____________________________________________
  Una oración: ___________________________________________
```

### Pregunta 2: ¿Qué ve el usuario cuando abre la app?
```
Pantalla 1: _______________________________________________
Pantalla 2: _______________________________________________
Pantalla 3: _______________________________________________
Primera interacción: ______________________________________
```

### Pregunta 3: ¿Qué botones/acciones tiene la interfaz?
```
Botón 1: _____________ → activa: _________________________
Botón 2: _____________ → activa: _________________________
Botón 3: _____________ → activa: _________________________
Botón 4: _____________ → activa: _________________________
Botón 5: _____________ → activa: _________________________
```

### Pregunta 4: ¿Qué es visible y qué es invisible?
```
El usuario VE:
  - ____________________________________________________
  - ____________________________________________________
  - ____________________________________________________

El usuario NO VE (pero el sistema hace):
  - ____________________________________________________
  - ____________________________________________________
  - ____________________________________________________
```

### Pregunta 5: ¿El pipeline clínico vive dentro o fuera?
```
[ ] DENTRO de la app (safety net invisible)
[ ] FUERA como API que la app consume
[ ] AMBOS (la app lo usa + se vende como API)
```

### Pregunta 6: La oración del producto
```
"_______ es _______ para _______ que _______."
```

---

## CORRECCIONES A LO QUE DIJO COPILOT

| Copilot dijo | Realidad |
|---|---|
| "EIP = 22 módulos + 529 vectores + 7 detectores" | EIP es 1 módulo (96 vec). Los 22 módulos son Engine. Los 529 vectores están repartidos en 7 detectores + warmth. |
| "Botones tipo /summarize /rewrite /extract" | Esos son wrappers de LLM genéricos. Tu producto no es eso. Tus "botones" deberían activar configuraciones de TU pipeline (ej: "modo claridad" = forzar casual + skip crisis). |
| "Es higiene mental" | El concepto de higiene es bueno. La palabra "mental" te mete en wellness. Tu vault dice: NO posicionar como salud mental. |
| "La interfaz solo activa presets" | Correcto. Los presets son configuraciones de resolve_state + mode selector + prompt pattern. No son endpoints nuevos. |

---

*Este archivo es tuyo. Llénalo. Cuando tengas las respuestas, las implementamos.*
