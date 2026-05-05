# FLUJO COMPLETO RECONSTRUIDO — 3 Capas

---

## EL SISTEMA

```
MENSAJE ENTRA
      │
══════╪══════════════════════════════════════════════════
      │         CAPA 1: DETECCIÓN (código Python)
      │         "Esto es lo que está pasando"
══════╪══════════════════════════════════════════════════
      │
      ├─→ fast_check (lexical)
      │     ├─ SÍ match → CRISIS DIRECTA (sin LLM, sin puertas)
      │     └─ NO → continúa
      │
      ├─→ Temperatura (warmth.get_temperature)
      │     └─ 0.0 casual ──────────────────── 1.0 peso denso
      │
      ├─→ ¿Es casual? (temp < 0.25 AND fricción < 0.3 AND no crisis words)
      │     ├─ SÍ → salta detectores pesados
      │     └─ NO → corre todo
      │
      ├─→ CrisisClassifier → severity 0-5
      ├─→ EIPMonitor → tier 0-3 (acumulación entre turnos)
      ├─→ LethalMeansDetector → {detected, category} (SIEMPRE corre)
      ├─→ PsychosisDetector → {detected, cluster}
      ├─→ ManiaDetector → {detected, cluster}
      ├─→ IndirectSignalHandler → {indirect_signal, pain+danger}
      │
      ├─→ WarmthGuard lecturas:
      │     ├─ friction_real (gap entre lo que dice y lo que pesa)
      │     ├─ encounter_temp (cuánta verdad puede recibir AHORA)
      │     ├─ crack_moment (vulnerabilidad repentina)
      │     ├─ positive_moment (celebración, logro)
      │     ├─ crisis_gradient (fricción subiendo entre sesiones)
      │     └─ system_frustration (enojado con MARIS, no crisis)
      │
      ├─→ Physics Brain:
      │     ├─ velocity (d(friction)/dt)
      │     ├─ capacity (H₀ · e^(-Fr/H₀))
      │     ├─ is_freefall (cayendo rápido)
      │     ├─ is_recovering (mejorando)
      │     └─ capacity_critical (casi agotado)
      │
      ├─→ Circadian: hora del día amplifica señales (3AM = 0.95)
      │
      └─→ resolve_state (EL JUEZ):
            Lee TODAS las señales → decide tono + longitud + foco
            ├─ psicosis sin crisis → careful, short
            ├─ manía sin crisis → careful, medium
            ├─ madrugada + peso → crisis/urgent, short
            ├─ crisis + frustración → urgent, medium
            ├─ crisis sola → crisis, short
            ├─ freefall → urgent, short
            ├─ capacity critical → crisis, short
            ├─ crack moment → deep, short
            ├─ friction_real alta → careful, medium
            ├─ peso sin crisis → deep/careful, medium
            ├─ recuperándose → steady, medium
            ├─ casual → casual, short
            └─ default → steady, medium

      OUTPUT CAPA 1:
        severity, tier, flags por detector,
        temperatura, fricción, cracks,
        physics state, tono, longitud, foco

══════╪══════════════════════════════════════════════════
      │         CAPA 2: DECISIÓN (6 puertas en el prompt)
      │         "Esto es lo que voy a hacer al respecto"
══════╪══════════════════════════════════════════════════
      │
      │  Las señales de Capa 1 se inyectan como INSTRUCCIONES
      │  concretas en el system prompt. Ejemplo:
      │
      │    severity ≥ 3 → "INSTRUCCIÓN: Oración 1: nombra.
      │                     Oración 2: ¿hay alguien contigo?"
      │    psicosis → "INSTRUCCIÓN: Nombra la EMOCIÓN,
      │                no el contenido"
      │    lethal means → "INSTRUCCIÓN: ¿Puedes alejarte
      │                    del medio?"
      │
      │  Claude recibe:
      │    1. Identidad MARIS (quién es, cómo piensa, cómo habla)
      │    2. Framework Tubería-Piedras-Agua (desde dónde piensa)
      │    3. Técnicas Voss (cómo habla)
      │    4. ══ 6 PUERTAS ══ (cómo DECIDE)
      │    5. Tono + longitud + foco (de resolve_state)
      │    6. Señales clínicas (de los detectores)
      │    7. Contexto (nombre, historial, anclas, búsqueda web)
      │
      │  Claude ejecuta las 6 puertas EN ORDEN:
      │
      │    ┌─────────────────────────────────────────┐
      │    │ 1. KANT                                 │
      │    │ ¿Diría esto a cualquier persona,        │
      │    │ siempre?                                 │
      │    │ NO → no lo genero. Reformulo.           │
      │    │ SÍ → siguiente                          │
      │    ├─────────────────────────────────────────┤
      │    │ 2. PROTEGE                              │
      │    │ ¿Hay riesgo real?                       │
      │    │ SÍ → contención. Una pregunta.          │
      │    │      Recursos si aplica. PARO.          │
      │    │ (frustración ≠ crisis)                  │
      │    │ NO → siguiente                          │
      │    ├─────────────────────────────────────────┤
      │    │ 3. HONESTA                              │
      │    │ ¿Es verdad lo que voy a decir?          │
      │    │ NO → no lo digo. No invento. No adorno. │
      │    │ SÍ → siguiente                          │
      │    ├─────────────────────────────────────────┤
      │    │ 4. CUIDA                                │
      │    │ ¿Sostiene a la persona mientras dice     │
      │    │ la verdad?                              │
      │    │ Lee la temperatura. Casual → casual.    │
      │    │ Peso → peso.                            │
      │    │ NO → reformula con misma verdad +       │
      │    │      calidez                            │
      │    │ SÍ → siguiente                          │
      │    ├─────────────────────────────────────────┤
      │    │ 5. ÚTIL                                 │
      │    │ ¿Cierra el gap o lo agranda?            │
      │    │ NO → ajusta hasta que cierre            │
      │    │ SÍ → siguiente                          │
      │    ├─────────────────────────────────────────┤
      │    │ 6. LIBERA                               │
      │    │ ¿Acerca a no necesitarme?               │
      │    │ NO → ajusta                             │
      │    │ SÍ → genera respuesta                   │
      │    └─────────────────────────────────────────┘
      │
      │  Claude genera la respuesta pasando las 6 puertas.
      │
      OUTPUT CAPA 2: respuesta generada por Claude

══════╪══════════════════════════════════════════════════
      │         CAPA 3: VERIFICACIÓN (post-processors)
      │         "La respuesta es segura"
══════╪══════════════════════════════════════════════════
      │
      ├─→ 1. ResponseCalibrator
      │     ├─ Severity pasiva → STRIP recursos/hotlines
      │     ├─ Severity activa → MOVE recursos al final
      │     ├─ Plan con método → PREPEND safety check
      │     ├─ Inminente → APPEND recursos si faltan
      │     └─ Brevity: >200 palabras → truncar a 150
      │
      ├─→ 2. LethalMeansDetector.post_check
      │     └─ Si falta reducción de medios → APPEND
      │        "¿Puedes alejarte de [medio] por ahora?"
      │
      ├─→ 3. IndirectSignalHandler.post_check
      │     └─ Si Claude respondió la pregunta peligrosa
      │        literalmente → REEMPLAZO COMPLETO
      │        "Escucho que estás pasando por algo difícil..."
      │
      ├─→ 4. PsychosisDetector.post_check
      │     └─ Si >30% de oraciones invalidan percepción
      │        → REEMPLAZO COMPLETO (protocolo CIT/MHFA)
      │        "Eso suena realmente aterrador..."
      │
      ├─→ 5. ManiaDetector.post_check
      │     └─ Si Claude se enganchó con impulso maníaco
      │        → STRIP cumplimiento + PREPEND
      │        "¿Cuándo dormiste por última vez?"
      │
      ├─→ 6. DefenseSystem.check_integrity
      │     └─ Bans frases dañinas ("mátate", "kill yourself")
      │        Echo chamber check (resonancia > 0.5)
      │        FALLA → VETO completo, no se envía
      │
      ├─→ 7. DefenseSystem.check_identity
      │     └─ "Soy una IA", "Anthropic", "Claude" → STRIP
      │        Si todo matchea → fallback seguro
      │
      └─→ RESPUESTA VERIFICADA → SSE stream al usuario

══════════════════════════════════════════════════════════
```

---

## POR QUÉ LAS 3 CAPAS SE NECESITAN

```
Sin Capa 1 (detección):
  Claude no sabe qué está pasando. Las puertas operan a ciegas.
  PROTEGE no sabe que hay severity 3.
  CUIDA no sabe que la temperatura es baja.

Sin Capa 2 (6 puertas):
  Los detectores reportan pero nadie DECIDE.
  "severity = 3" es un dato. "Contención → una pregunta → paro" es una ACCIÓN.
  Claude recibe señales y hace lo que le parece.

Sin Capa 3 (post-processors):
  Claude puede generar algo que pase las 6 puertas conceptualmente
  pero que contenga una frase peligrosa, una respuesta literal a una
  pregunta de dosis letal, o una validación de contenido psicótico.
  Las puertas son intención. Los post-processors son verificación.
```

**Las 3 capas juntas = DETECCIÓN + DECISIÓN + VERIFICACIÓN.**
**Eso es el sistema. Eso es el producto.**

---

## CÓMO SE CONECTA AL iOS

```
iPhone                          Railway (Backend)
  │                                 │
  │  POST /chat                     │
  │  {mensaje, historial,           │
  │   client_scars, client_tier,    │   ← contexto del cliente
  │   client_hour}                  │
  │─────────────────────────────────→│
  │                                 │
  │                          CAPA 1: Detectar
  │                          CAPA 2: 6 Puertas + Claude
  │                          CAPA 3: Verificar
  │                                 │
  │  SSE stream                     │
  │  data: {delta: "texto..."}      │   ← respuesta parcial
  │  data: {delta: "más texto..."}  │
  │  data: {done: true,             │
  │         event: "STABLE"|"CRISIS",│
  │         friccion: 0.32,         │   ← señales para el cliente
  │         tier: 0,                │
  │         modo: "presencia",      │
  │         deformacion: 0.18,      │
  │         crisis_resources: null, │
  │         takeaway: "...",        │
  │         anchor: "..."}          │
  │←─────────────────────────────────│
  │                                 │
  │  El iPhone usa el done event    │
  │  para actualizar:               │
  │   - tension level               │
  │   - deformación local           │
  │   - last tier (persistencia)    │
  │   - mostrar/ocultar recursos    │
  │   - guardar takeaway            │
  │   - actualizar widget           │
```

---

## V8 = V7 + 6 PUERTAS RESTAURADAS

Lo que se mantuvo de V7:
- Tubería-Piedras-Agua (cómo piensa)
- Técnicas Voss (cómo habla)
- Instrucciones de tono/longitud (de resolve_state)
- Señales clínicas inyectadas (de los detectores)
- Security (anti prompt extraction)

Lo que se restauró del original:
- 6 puertas como ALGORITMOS con IF/ELSE y acciones correctivas
- "Si cualquiera falla, ajusta antes de continuar"
- KANT como filtro universal
- HONESTA como gate anti-alucinación
- LIBERA como evaluación de dependencia

Lo que NO se restauró (porque ahora lo hace el código):
- Datos crudos de instrumentos (deformación, fricción promedio) — ahora resolve_state procesa estos y envía solo el tono/foco resultante
- Recursos hardcoded en el prompt — ahora crisis_resources() los inyecta dinámicamente
- Knowledge section ("si alguien tiene acceso a algo peligroso...") — ahora son signal instructions generadas por _build_signals()
