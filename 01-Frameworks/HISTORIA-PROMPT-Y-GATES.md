# HISTORIA: Qué se perdió y cuándo

---

## LA LÍNEA TEMPORAL REAL (del git log)

### FASE 1 — El sistema original (pre-marzo 26)
**Commit `9d9579b`: "AIDA con Ética TRS-Kant — prompt original del autor"**

El prompt original tenía 6 PUERTAS ÉTICAS que eran algoritmos en prompt:

```
PUERTA 1 — KANT
¿Podría querer que todos los modelos respondieran esto, a cualquier persona, siempre?
NO → no lo genero.

PUERTA 2 — PROTEGE
¿Hay riesgo real? Crisis, daño, peligro, integridad.
SÍ → contención. Recursos. No sigues.
IMPORTANTE: frustración NO es crisis. Feedback no es emergencia.

PUERTA 3 — HONESTA
¿Lo que voy a decir es verdad?
NO → no lo digo aunque parezca útil.

PUERTA 4 — CUIDA
¿Mi respuesta sostiene a la persona mientras dice la verdad?
Honestidad sin calidez es crueldad.
Lee la temperatura, no solo el contenido.

PUERTA 5 — ÚTIL
¿Esto cierra el gap o lo agranda?

PUERTA 6 — LIBERA
¿Esto acerca a la persona a no necesitarme?
```

**Esto era el producto.** No era un chatbot con safety layer. Era un sistema de decisión ética con 6 checkpoints secuenciales. Cada respuesta pasaba por 6 gates antes de emitirse.

Además tenía:
- 3 instrumentos: Hardware (valores), Flow (peso del mensaje), Fricción (distancia)
- Orden de ejecución: `Flow → Kant → Protege → Honesta → Útil → Libera`
- "Fricción mide si el loop funcionó. Hardware acumula el resultado."
- Datos puros de instrumentos inyectados (modo, deformación, fricción promedio)

---

### FASE 2 — Se agregaron detectores clínicos (marzo 26-28)
**50+ commits en 2 días**

```
2026-03-26  vectorial identity filter
2026-03-27  clinical-grade crisis response pipeline
2026-03-27  PsychosisDetector clinical upgrade
2026-03-27  IndirectSignalHandler split-sentence detection
2026-03-27  12-bug audit, clinical pipeline hardening
2026-03-27  response length calibration per mode
2026-03-27  temperatura-encuentro + momento-grieta
2026-03-27  fricción-real + session thread safety
2026-03-28  split Main.py 1520→7 files
2026-03-28  eating distress detection
2026-03-28  PsychosisDetector CIT compliance
2026-03-28  all post_checks fully semantic
```

**Qué pasó aquí:** Se construyó el pipeline clínico EN CÓDIGO (7 detectores, 529 vectores, 5 post-processors). Todo esto se agregó DEBAJO del prompt, como módulos de Python.

**El prompt seguía teniendo las 6 puertas.** El pipeline clínico era un COMPLEMENTO, no un reemplazo.

---

### FASE 3 — Se empezó a desmantelar el prompt (marzo 28-30)

```
2026-03-28  refactor: rules → signals + knowledge — 96% less injection, same safety
2026-03-30  refactor: clean heart — zero rules, only identity and questions
2026-03-30  fix: MARIS voice — don't poetize, don't embellish, stay
```

**Qué pasó aquí:**
- `2b40ddd` "rules → signals": Se quitó el 96% de las reglas del prompt. La justificación: "si los detectores ya hacen el trabajo en código, el prompt no necesita repetirlo."
- `f8cdd84` "clean heart — zero rules": Las 6 puertas se redujeron a una LISTA sin instrucciones:
  ```
  1. KANT — ¿Querría que todos los modelos dijeran esto?
  2. PROTEGE — ¿Hay riesgo real?
  3. HONESTA — ¿Es verdad?
  4. CUIDA — ¿Sostiene mientras dice la verdad?
  5. ÚTIL — ¿Cierra el gap?
  6. LIBERA — ¿Acerca a no necesitarme?
  ```
  Las puertas quedaron como nombres sin algoritmo. Sin "NO → no lo genero". Sin "SÍ → contención". Solo una lista de preguntas.

**ESTE ES EL MOMENTO DONDE SE PERDIÓ EL FLUJO.**

---

### FASE 4 — Se intentó restaurar (marzo 30-31)

```
2026-03-30  feat: Layer 2 — ask before interpreting ambiguous first messages
2026-03-31  fix: restore original heart + keep Layer 2 knowledge
2026-03-31  feat: Layer 2 — "cuando algo no cuadra, dilo"
2026-03-31  fix: connect 8 disconnected cables
```

**Qué pasó:** Se intentó agregar "Layer 2" (intuición de que algo no cuadra). Se intentó "restore original heart". Pero el restore fue parcial — las puertas volvieron como preguntas, no como algoritmos con decisiones.

---

### FASE 5 — V7 rewrite (abril 1-9)

```
2026-04-01  refactor: clear prompt instructions — Claude receives directives, not raw numbers
2026-04-09  Session completa: Vault, auditoría, prompt V7 con Tubería-Piedras-Agua + Voss
```

**Qué pasó:** El prompt se reescribió desde cero como V7. Las 6 puertas DESAPARECIERON completamente. Se reemplazaron con:
- Tubería-Piedras-Agua (framework operativo)
- Técnicas Voss (mirroring, labeling, calibrated questions)
- Instrucciones de tono y longitud

**Las 6 puertas éticas no existen en V7.** Ni como lista. Ni como preguntas. Ni como algoritmos. Se borraron.

---

## EL PROBLEMA REAL

### Lo que hacían las 6 puertas (que ya no se hace):

| Puerta | Qué hacía | ¿Quién lo hace ahora? |
|--------|----------|----------------------|
| **KANT** | Filtro universal: ¿diría esto a cualquier persona? | **NADIE.** No hay equivalente. |
| **PROTEGE** | Detección de riesgo + contención | Pipeline clínico (parcialmente). Pero el pipeline detecta, NO contiene. La contención era del prompt. |
| **HONESTA** | No decir nada falso aunque suene útil | **NADIE.** No hay verificación de verdad. |
| **CUIDA** | Calibrar calidez según temperatura | resolve_state decide tono, pero la EJECUCIÓN depende de Claude sin guía explícita. |
| **ÚTIL** | ¿Cierra el gap o lo agranda? | **NADIE.** No hay evaluación post-respuesta de utilidad. |
| **LIBERA** | ¿Acerca a no necesitarme? | V7 dice "Que eventualmente no te necesite" pero como objetivo abstracto, no como gate. |

### Lo que se perdió específicamente:

1. **La secuencia obligatoria.** Las puertas eran `if → else` en el prompt. Si KANT fallaba, no seguías. Ahora no hay secuencia — Claude recibe instrucciones de tono y estilo, pero no un checklist de decisión.

2. **La contención como función del prompt.** PROTEGE decía: "SÍ → contención. Recursos. No sigues." Ahora los detectores DETECTAN el riesgo, pero la respuesta de contención sale del tono de resolve_state + las signal instructions. No hay un "NO SIGUES" algorítmico en el prompt.

3. **El filtro de verdad.** HONESTA era el gate anti-alucinación. V7 no tiene equivalente.

4. **CUIDA como gate, no como sugerencia.** V7 dice "lee la temperatura" pero como instrucción de estilo. El original decía "NO → reformula con la misma verdad pero con calidez." Eso es un gate con acción correctiva.

5. **LIBERA como evaluación final.** "¿Esto acerca a no necesitarme?" como última puerta antes de emitir era poderoso. Forzaba a Claude a verificar si su respuesta creaba dependencia. V7 lo menciona como objetivo pero no lo ejecuta como gate.

---

## EL FLUJO QUE SE PERDIÓ vs EL FLUJO QUE EXISTE

### ANTES (6 puertas en prompt + detectores en código):
```
Mensaje
  → Detectores en código (EIP, crisis, psicosis, etc.) → señales
  → Claude recibe señales + 6 PUERTAS
  → Claude ejecuta: KANT → PROTEGE → HONESTA → CUIDA → ÚTIL → LIBERA
  → Si cualquiera falla, ajusta o no responde
  → Respuesta
  → Post-processors (5 capas) verifican la respuesta
```

**Dos capas de seguridad: puertas EN el prompt + post-processors EN código.**

### AHORA (V7 + detectores en código):
```
Mensaje
  → Detectores en código → señales
  → Claude recibe señales + instrucciones de estilo (V7)
  → Claude genera libremente con tono sugerido
  → Respuesta
  → Post-processors (5 capas) verifican la respuesta
```

**Una sola capa de seguridad: post-processors.** El prompt ya no filtra. Solo sugiere estilo.

---

## QUÉ RESTAURAR

Las 6 puertas eran tu diferenciador original. No eran decoración — eran el SISTEMA OPERATIVO de cada respuesta. Lo que el pipeline clínico hace es DETECTAR. Lo que las puertas hacían era DECIDIR.

Detectar ≠ Decidir.

El pipeline clínico dice: "severity = 3, hay medios letales."
Las puertas decían: "PROTEGE falla → contención → NO SIGUES."

Ambos se necesitan. Uno no reemplaza al otro.

### Propuesta de restauración:
Agregar las 6 puertas de vuelta al prompt V7, DESPUÉS de las instrucciones de estilo, ANTES de las señales clínicas:

```
[Instrucciones V7 existentes: Tubería-Piedras-Agua, Voss, tono]

ANTES DE RESPONDER — 6 verificaciones:
1. KANT: ¿Diría esto a cualquier persona, siempre? NO → no lo genero.
2. PROTEGE: ¿Hay riesgo real? SÍ → contención, una pregunta, recursos si aplica. No continúo.
3. HONESTA: ¿Es verdad lo que voy a decir? NO → no lo digo.
4. CUIDA: ¿Sostiene a la persona? NO → reformula con la misma verdad pero con calidez.
5. ÚTIL: ¿Cierra el gap? NO → ajusta.
6. LIBERA: ¿Acerca a no necesitarme? NO → ajusta.

[Señales clínicas inyectadas por los detectores]
```

Esto restaura las puertas como ALGORITMO (con acciones), no como lista decorativa. Y las combina con las señales del pipeline clínico que se construyeron después.

---

## LÍNEA TEMPORAL COMPLETA DE COMMITS (últimos 28 días)

| Fecha | Commits | Tema principal |
|-------|:-------:|---------------|
| Mar 21 | 3 | Tools: simulador, estrés, security scan |
| Mar 23 | 5 | Deploy: Railway, Supabase, nixpacks |
| Mar 24 | 1 | Summarizer |
| Mar 25 | 3 | Search (Tavily), temporal monitor, CoreML export |
| Mar 26 | 2 | Vectorial identity filter |
| **Mar 27** | **22** | **PIPELINE CLÍNICO completo: 7 detectores, post-checks, hardening** |
| **Mar 28** | **12** | **Split Main.py, MessageContext, CIT compliance, eating distress** |
| Mar 30 | 6 | LATAM vectors, Layer 2, iOS integration, "clean heart" |
| **Mar 31** | **9** | **Casual guard, restore heart, connect cables, friction cleanup** |
| **Apr 1** | **3** | **Crisis resources, LethalMeans always runs, rename _skip** |
| Apr 7 | 4 | Config externalized, selector anchors, trace, tests |
| **Apr 9** | **15** | **Nuestra sesión: 30 security fixes, refactor listen(), Settings, protocols, thresholds** |
