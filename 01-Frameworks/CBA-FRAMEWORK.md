# CBA — Cognitive Behavior Architecture
**Framework target para MARIS**
**Fecha:** 2026-04-13

---

## Definición

CBA es un marco de ingeniería que organiza percepción, regulación, memoria, intención y post-procesamiento para producir comportamiento coherente y controlado sobre un LLM.

El LLM genera lenguaje. CBA genera comportamiento.

---

## Los 10 módulos y su estado real

| # | Módulo CBA | Qué hace | Estado | Código real |
|---|---|---|---|---|
| 1 | **InternalClassifier** | Detecta lo que el usuario NO dice: emociones, intención, fricción, señales implícitas | **COMPLETO** | crisis_classifier.py (372 LOC, 98 vec), clinical_detectors.py (548 LOC, 76 vec), safety_detectors.py (520 LOC, 55 vec), warmth.py 7 detectores (191 vec). Total: 529 vectores. |
| 2 | **CoherenceValidator** | Compara lo que el usuario dice vs la meta activa. Si no coincide → ajusta | **NO EXISTE** | Necesita: vector de meta declarada (del onboarding/resonance), comparar contra vector de acción real (últimas 3 sesiones), disparar excepción de coherencia si cos(θ) < umbral |
| 3 | **CognitiveControl** | El lóbulo prefrontal: decide tono, presión, confrontación, estilo | **PARCIAL** | 6 puertas en prompt V8 (KANT→PROTEGE→HONESTA→CUIDA→ÚTIL→LIBERA) + resolve_state() 13 condiciones → 6 tonos. Funciona pero no es una clase, es prompt + función separada. |
| 4 | **Physics Brain** | Regulación dinámica: cómo se mueve el sistema según fricción y contexto | **COMPLETO** | Brain.py (225 LOC). velocity = d(friction)/dt, capacity = H₀·e^(-Fr/H₀), neurogenesis online, max 512 neuronas. Per-user state. |
| 5 | **RelevanceDecay** | Reloj biológico: qué se olvida rápido, qué persiste | **NO EXISTE** | La ecuación existe en Brain.py (e^(-Fr/H₀)) pero NO se aplica a memoria. Necesita: W_memoria = W_base · e^(-Δt/τ) aplicado al peso de recuperación en Storage.py/long_term.py. τ diferente por tipo: humor (τ=2hrs), conflicto (τ=24hrs), meta de vida (τ=∞). |
| 6 | **Memory System** | 3 capas: semántica, episódica, grafo cognitivo | **PARCIAL** | Semántica: long_term.py (anchors). Episódica: Storage.py (chats, scars). Grafo cognitivo: NO EXISTE (patrones universales tipo "cuando X sube, Y baja"). |
| 7 | **Identity Engine** | Define la "mente" activa: vendedor, mentor, tutor, etc. | **PARCIAL** | identity.py tiene UNA identidad fija (MARIS V8). Para múltiples cerebros necesita: DI para swappear gates + vectores + post-processors por perfil de config. |
| 8 | **LLMClient** | Motor de lenguaje encapsulado | **COMPLETO** | llm.py: claude_sse_stream(), deepseek_sse_stream(), deepseek_chat_stream(). 25s timeout. LLM-agnostic. |
| 9 | **PostProcessor** | El freno: recorta, regula, inhibe, ajusta | **COMPLETO** | 7 capas: ResponseCalibrator, LethalMeans post, IndirectSignal post, Psychosis post, Mania post, Integrity check, Identity check. Protocolos CIT/MHFA/LEAP/ASIST. |
| 10 | **Orchestrator** | Integra todo en un ciclo cognitivo | **COMPLETO** | understand.py listen() coordina 5 pasos. respond.py genera + verifica. Main.py fast path para crisis léxica. |

**Score: 6/10 completos, 2/10 parciales, 2/10 no existen.**

---

## El ciclo cognitivo (cómo corren los 10 módulos)

```
1. PERCEPCIÓN     → InternalClassifier analiza texto + embedding
2. COHERENCIA     → CoherenceValidator compara input vs meta [NO EXISTE]
3. REGULACIÓN     → CognitiveControl (resolve_state + 6 puertas) decide tono
4. MEMORIA        → Recupera contexto semántico + episódico
5. DECAIMIENTO    → RelevanceDecay pesa los recuerdos por tiempo [NO EXISTE]
6. GENERACIÓN     → LLMClient produce borrador (Claude/DeepSeek)
7. INHIBICIÓN     → PostProcessor corrige, recorta, regula (7 capas)
8. ACCIÓN         → Orchestrator ejecuta respuesta final via SSE
```

---

## Los 3 huecos reales

### Hueco 1: CoherenceValidator
**Qué hace:** Si el usuario declaró "quiero terminar mi proyecto" pero lleva 3 sesiones filosofando, el sistema debe señalarlo.

**Implementación propuesta:**
```
vec_G = embedding de meta declarada (del onboarding/resonance)
vec_A = embedding promedio de últimas 3 sesiones
coherence = cosine_similarity(vec_G, vec_A)
if coherence < 0.3:
    → forzar modo "confrontación suave"
    → signal: "Llevas 3 sesiones sin tocar [meta]. ¿Cambió algo?"
```

**Dificultad:** Baja. Los embeddings y cosine ya existen en Processor.py.
**Tiempo estimado:** 1 día.

### Hueco 2: RelevanceDecay para memoria
**Qué hace:** Los recuerdos pierden peso con el tiempo. Un mal humor de ayer no debería afectar hoy.

**Implementación propuesta:**
```
W = W_base · e^(-Δt/τ)

τ por tipo de recuerdo:
  humor/estado temporal  → τ = 2 horas
  conflicto/frustración  → τ = 24 horas
  insight/claridad       → τ = 7 días
  meta de vida           → τ = ∞ (no decae)
  crisis                 → τ = 30 días (no olvidar rápido)
```

**Dificultad:** Media. Requiere modificar cómo Storage.py/long_term.py recuperan y pesan recuerdos.
**Tiempo estimado:** Medio día.

### Hueco 3: Identity Engine configurable
**Qué hace:** Permite crear múltiples "cerebros" con la misma arquitectura pero diferentes personalidades.

**Implementación propuesta:**
```
config/brains/clinical.json:
{
  "name": "MARIS Clinical",
  "gates": ["kant", "protege", "honesta", "cuida", "util", "libera"],
  "vectors": "config/vectors_clinical/",
  "post_processors": ["calibrator", "lethal_means", "indirect", "psychosis", "mania"],
  "prompt_template": "identity_clinical.py",
  "resolve_rules": "resolve_clinical.py"
}

config/brains/sales.json:
{
  "name": "AIDA Sales",
  "gates": ["etico", "autorizado", "verificable", "apropiado", "cierra", "protege_cliente"],
  "vectors": "config/vectors_sales/",
  "post_processors": ["strip_false_promises", "verify_pricing", "enforce_terms"],
  "prompt_template": "identity_sales.py",
  "resolve_rules": "resolve_sales.py"
}
```

**Dificultad:** Alta. Requiere refactorear Engine para aceptar config en vez de hardcodear módulos.
**Tiempo estimado:** 2-3 días.

---

## CBA como producto

| Formato | Qué incluye | Para quién |
|---|---|---|
| **CBA Clinical** (ya existe) | 529 vectores, 6 puertas éticas, 5 post-processors clínicos | Apps de salud, telemedicina, crisis lines |
| **CBA Sales** (por construir) | Vectores de objeciones, puertas de persuasión ética, post-processors de compliance | Chatbots de ventas, e-commerce |
| **CBA Compliance** (por construir) | Vectores de claims regulatorios, puertas legales, post-processors de disclaimer | Bancos, aseguradoras, fintech |
| **CBA Support** (por construir) | Vectores de frustración/escalation, puertas de resolución, post-processors técnicos | Soporte al cliente, SaaS |
| **CBA Framework** (open source parcial) | El patrón base: detector + gates + post-processor. Sin vectores específicos. | Developers que quieren construir sus propios cerebros |

---

## Origen del nombre

- **Copilot** propuso el framework de 10 módulos y el nombre CBA
- **Gemini** propuso RelevanceDecay con exponential decay, CoherenceValidator con vectores de meta, e Identity Engine con DI por perfiles
- **Leonel** diseñó y construyó el sistema original: 6 puertas éticas (concepto propio), pipeline de 3 capas, 529 vectores curados manualmente, physics brain con neurogenesis

CBA no es un campo nuevo de ingeniería (cognitive architectures existen desde los 60s: ACT-R, SOAR, CLARION). Lo que es nuevo es la implementación específica: gates éticos algorítmicos + detección clínica semántica + physics brain + post-processing sobre LLMs. Esa combinación no existía.
