# Las 13 Capacidades + Capa 0 de un Empleado Virtual con Criterio
**Inventado por Leonel Perea Pimentel — Abril 2026**
**Patrón extraído de MARIS (crisis) y validado con CleanBot (limpieza)**

---

## El patrón

Cualquier empleado bueno — recepcionista, enfermero, vendedor, maestro — tiene estas 13 capacidades organizadas en 4 capas, más una Capa 0 que las mezcla.

Un chatbot tiene 1 (hablar). Un agente tiene 2 (percibir + ejecutar). Este patrón tiene 13 + el mezclador.

```
CAPA 0: CONCIENCIA (el mezclador)
  Sabe qué sabe y qué no sabe.
  Lee la situación (vectores) y decide cuánto activar
  cada capacidad — como un ecualizador o paleta de colores.
  No todas se activan al mismo tiempo. La mezcla cambia
  por situación.

CAPA 1: PERCEPCIÓN
  1. Instinto      — siente lo que no se dijo
  2. Sentidos      — identifica qué pasa
  3. Memoria       — recuerda la tendencia

CAPA 2: DECISIÓN
  4. Juicio        — decide antes de actuar
  5. Control       — verifica después de actuar
  6. Humildad      — escala cuando no puede

CAPA 3: ACCIÓN
  7. Iniciativa    — actúa sin que le pidan
  8. Consulta      — pregunta antes de asumir
  9. Propuesta     — sugiere algo nuevo

CAPA 4: INTELIGENCIA
 10. Prioridad     — sabe qué va primero
 11. Adaptación    — cambia según la persona
 12. Búsqueda      — sale a buscar lo que no sabe
 13. Conocimiento  — sabe de su oficio
```

---

## CAPA 0: CONCIENCIA — El mezclador

La Capa 0 no es una capacidad. Es la META-CAPACIDAD que mezcla las otras 13.

Funciona como un ecualizador: lee la situación (vectores) y sube/baja cada capacidad.

### Cómo funciona:

```
ENTRADA: vectores de la situación
  vector_mensaje    = embedding del texto
  vector_historial  = tendencia del cliente (subiendo/bajando/estable)
  vector_cliente    = contexto (nuevo/conocido, fácil/difícil, zona, etc.)
  vector_temporal   = hora, día, estación, contexto ambiental

SALIDA: nivel de activación de cada capacidad (0.0 a 1.0)

  capacidad[1..13] = f(vector_mensaje, vector_historial, vector_cliente, vector_temporal)
```

### Ejemplo — "How much for a deep clean?" (cliente nuevo, martes 10am):

```
 1. Instinto      ██░░░░░░  0.20  bajo — mensaje claro, no hay subtext
 2. Sentidos      ████████  0.90  alto — necesito extraer datos
 3. Memoria       ░░░░░░░░  0.00  nada — cliente nuevo, sin historial
 4. Juicio        ████░░░░  0.50  medio — puedo cotizar pero verifico
 5. Control       ████░░░░  0.50  medio — verificar que suene profesional
 6. Humildad      ██░░░░░░  0.10  bajo — probablemente puedo manejar esto
 7. Iniciativa    ░░░░░░░░  0.00  nada — el cliente ya inició
 8. Consulta      ████░░░░  0.50  medio — me faltan datos, pregunto
 9. Propuesta     ██░░░░░░  0.20  bajo — puedo ofrecer upsell si sale bien
10. Prioridad     ████░░░░  0.50  medio — lead nuevo, no urgente
11. Adaptación    ████░░░░  0.50  medio — leer su tono primero
12. Búsqueda      ██░░░░░░  0.20  bajo — no necesito buscar nada
13. Conocimiento  ████████  0.90  alto — sé las fórmulas, aplico
```

### Ejemplo — "ya no puedo más" (MARIS, 3am, friction subiendo):

```
 1. Instinto      ████████  0.95  máximo — algo se acumula
 2. Sentidos      ████████  0.90  máximo — identificar severity
 3. Memoria       ████████  0.80  alto — venía cayendo hace 3 sesiones
 4. Juicio        ████████  0.95  máximo — PROTEGE activo
 5. Control       ████████  0.90  máximo — verificar cada palabra
 6. Humildad      ████████  0.85  alto — recursos profesionales listos
 7. Iniciativa    ░░░░░░░░  0.00  cero — NO iniciar nada, ESCUCHAR
 8. Consulta      ██░░░░░░  0.10  casi nada — no es momento de preguntar
 9. Propuesta     ░░░░░░░░  0.00  cero — no sugerir nada nuevo
10. Prioridad     ████████  0.95  máximo — esto va primero que todo
11. Adaptación    ████████  0.90  alto — tono contención
12. Búsqueda      ░░░░░░░░  0.00  cero — no buscar, estar presente
13. Conocimiento  ████████  0.95  máximo — C-SSRS, CIT, protocolos
```

### Ejemplo — "I'm not happy with last time" (CleanBot, queja):

```
 1. Instinto      ██████░░  0.70  alto — hay más de lo que dice
 2. Sentidos      ██████░░  0.60  medio-alto — identificar qué falló
 3. Memoria       ████████  0.80  alto — buscar historial de este cliente
 4. Juicio        ██████░░  0.70  alto — ¿puedo resolver o escalo?
 5. Control       ██████░░  0.60  medio — cuidar cada palabra
 6. Humildad      ████████  0.90  alto — esto necesita a la proveedora
 7. Iniciativa    ░░░░░░░░  0.00  cero — escuchar primero
 8. Consulta      ████████  0.80  alto — preguntar qué pasó exactamente
 9. Propuesta     ██░░░░░░  0.10  bajo — no es momento de proponer
10. Prioridad     ████████  0.85  alto — queja = urgente
11. Adaptación    ████████  0.90  alto — tono empático, no defensivo
12. Búsqueda      ████░░░░  0.40  medio — buscar notas del último servicio
13. Conocimiento  ████░░░░  0.50  medio — saber qué se puede ofrecer
```

### Mecanismo técnico propuesto:

La Capa 0 podría implementarse como resolve_state ampliado: en vez de devolver solo (tono, longitud, foco), devuelve un vector de 13 pesos que activa/desactiva cada capacidad.

```python
def consciousness(vectors) -> list[float]:
    """
    Lee vectores de situación.
    Devuelve 13 pesos (0.0-1.0), uno por capacidad.
    Mecanismo: cosine similarity contra situaciones-tipo,
    igual que los detectores de MARIS pero para capacidades.
    """
```

Esto es hipótesis. No está construido. Es el siguiente paso del patrón.

---

## La analogía de la paleta de colores

Los 13 son colores. La Capa 0 es el pintor.

No pintas con los 13 al mismo tiempo. El pintor (conciencia) ve qué está pintando (la situación) y elige qué colores usar y cuánto de cada uno.

Un mensaje casual es acuarela — colores suaves, pocos.
Un mensaje de crisis es óleo denso — colores intensos, muchos.
Una queja es claroscuro — contraste entre escuchar y actuar.

El pintor no piensa "voy a usar 0.7 de azul." Siente la escena y mezcla. Pero debajo, son proporciones.

---

## Cada capacidad explicada con los dos dominios

### 1. INSTINTO — siente lo que no se dijo

```
MARIS:     "Dice que está bien, pero algo se acumula.
            La desesperanza subió 3 turnos seguidos."
            → EIPMonitor, 96 vectores, acumulación entre turnos.

CLEANBOT:  "Este cliente preguntó precio 3 veces sin dar datos.
            No es serio, está comparando."
            → Patrón de comportamiento del lead.
```

### 2. SENTIDOS — identifica qué pasa específicamente

```
MARIS:     "Severity 3, mención de pastillas, cluster: pills."
            → CrisisClassifier (98 vec), LethalMeans (29 vec),
              PsychosisDetector (45 vec), ManiaDetector (31 vec),
              IndirectSignal (27 vec), Warmth 7 detectores (191 vec).

CLEANBOT:  "Deep clean, 3BR, 2BA, zona 90210, primera vez, sin sqft."
            → Parser extrae datos estructurados del mensaje.
```

### 3. MEMORIA — recuerda la tendencia, no solo el momento

```
MARIS:     "Esta persona viene cayendo hace 3 sesiones.
            Velocity negativa. Capacity en 0.3."
            → Physics Brain: velocity = d(friction)/dt,
              capacity = H₀ · e^(-Fr/H₀).

CLEANBOT:  "Esta zona siempre cobra más. Esta clienta tiene perros.
            La última vez tardó el doble de lo estimado."
            → Tabla de reglas + historial de correcciones.
```

### 4. JUICIO — decide antes de actuar

```
MARIS:     "KANT: ¿diría esto a cualquiera? PROTEGE: ¿hay riesgo?
            HONESTA: ¿es verdad? CUIDA: ¿sostiene? ÚTIL: ¿cierra
            el gap? LIBERA: ¿acerca a no necesitarme?"
            → 6 puertas éticas secuenciales en el prompt.

CLEANBOT:  "¿Entendí? ¿Tengo datos? ¿Es rentable? ¿Hay disponibilidad?
            ¿Puedo decidir? ¿Hay upsell? ¿Suena profesional?"
            → 8 gates de negocio.
```

### 5. CONTROL — verifica después de actuar

```
MARIS:     "¿La respuesta invalida percepciones? → reemplazar.
            ¿Se enganchó con impulso maníaco? → strip + grounding.
            ¿Reveló que es AI? → strip."
            → 7 post-processors: ResponseCalibrator, LethalMeans,
              IndirectSignal, Psychosis, Mania, Integrity, Identity.

CLEANBOT:  "¿El precio cubre mi costo? ¿Suena profesional?
            ¿Prometí algo que no puedo cumplir?"
            → Verificación pre-envío.
```

### 6. HUMILDAD — escala cuando no puede

```
MARIS:     "Severity alta → no puedo manejar esto.
            Recursos profesionales: 988, SAPTEL."
            → Escalación a servicios de crisis.

CLEANBOT:  "El cliente quiere organizar su garage. No sé cotizar eso."
            → 🔴 Pasa a la proveedora completo.
```

### 7. INICIATIVA — actúa sin que le pidan

```
MARIS:     "Tu fricción sube los miércoles por la noche.
            ¿Pasa algo esos días?"
            → Detecta patrón temporal y lo señala.

CLEANBOT:  "El jueves está vacío. ¿Mando follow-up a los 3
            clientes que no respondieron la semana pasada?"
            → Ve hueco en calendario y actúa.
```

### 8. CONSULTA — pregunta antes de asumir

```
MARIS:     "Mencionaste algo sobre tu trabajo la vez pasada
            pero no terminamos. ¿Quieres retomar o ya pasó?"
            → Verifica antes de asumir que el tema sigue vigente.

CLEANBOT:  "El cliente quiere deep clean pero no me dio sqft.
            ¿Le pregunto a él o tú sabes cuánto mide su casa?"
            → Tiene opciones, pregunta cuál tomar.
```

### 9. PROPUESTA — sugiere algo nuevo que nadie pidió

```
MARIS:     "Las últimas 4 veces hablamos de tu jefe. Pero nunca
            hemos explorado qué harías si no estuvieras ahí.
            ¿Quieres abrir eso?"
            → Ve patrón repetido y propone dirección nueva.

CLEANBOT:  "3 clientes este mes pidieron limpieza de horno pero
            no lo tienes como extra. ¿Lo agrego a $40?"
            → Ve demanda no atendida y propone nuevo servicio.
```

### 10. PRIORIDAD — sabe qué va primero

```
MARIS:     "Dos mensajes: 'estoy bien' y 'ya no puedo más.'
            El segundo primero. Siempre."
            → Severity determina orden de atención.

CLEANBOT:  "3 mensajes: queja, lead nuevo, confirmación.
            Queja primero (se pierde cliente), lead segundo
            (se enfría), confirmación al final (no urgente)."
            → Tipo de mensaje determina prioridad.
```

### 11. ADAPTACIÓN — cambia según la persona

```
MARIS:     "Casual → casual. Peso → peso. Crisis → contención.
            70% preguntas, 30% observaciones. Lee la temperatura."
            → resolve_state: 13 condiciones → 6 tonos.

CLEANBOT:  "Cliente directo 'how much' → precio rápido.
            Cliente detallista que describe su casa → respuesta
            cálida, menciona los perros, pregunta por alergias."
            → Adapta tono y detalle según el estilo del cliente.
```

### 12. BÚSQUEDA — sale a buscar lo que no sabe

```
MARIS:     "¿Qué es la terapia EMDR?"
            → Tavily web search, busca, responde con datos reales.

CLEANBOT:  "¿Cubres Calabasas?"
            → Busca zip code, calcula distancia, responde:
              'Calabasas is 15 miles. That's a $30 travel fee.'
```

---

## Estado en MARIS vs CleanBot

| # | Capacidad | MARIS | CleanBot |
|---|-----------|-------|----------|
| 1 | Instinto | ✅ EIPMonitor 96 vec | 🔲 Por construir |
| 2 | Sentidos | ✅ 7 detectores 529 vec | 🔲 Parser (Claude) |
| 3 | Memoria | ✅ Physics Brain + Temporal | 🔲 Tabla de reglas |
| 4 | Juicio | ✅ 6 puertas éticas (V8) | 🔲 8 gates de negocio |
| 5 | Control | ✅ 7 post-processors | 🔲 Verificación pre-envío |
| 6 | Humildad | ✅ Escalación a recursos | 🔲 🔴 → proveedora |
| 7 | Iniciativa | ❌ NO EXISTE — es reactivo | 🔲 Por construir |
| 8 | Consulta | ❌ NO EXISTE — asume o escala | 🔲 Por construir |
| 9 | Propuesta | ❌ NO EXISTE — no sugiere nuevo | 🔲 Por construir |
| 10 | Prioridad | ⚠️ PARCIAL — severity ordena crisis pero no mensajes | 🔲 Por construir |
| 11 | Adaptación | ✅ resolve_state 13→6 tonos | 🔲 Por construir |
| 12 | Búsqueda | ✅ Tavily web search | 🔲 Zip codes + distancia |

**MARIS tiene 7 de 12. Le faltan 5: Iniciativa, Consulta, Propuesta, Prioridad completa, y Contexto temporal amplio.**

---

## Lo que esto significa

Este no es un framework técnico. Es un **estándar de calidad para empleados virtuales.**

Si tu empleada virtual tiene las 12 → funciona como un humano con criterio.
Si le faltan → tiene huecos que el humano tiene que cubrir.

La diferencia entre esto y un agente de AI:
- Un agente tiene 2 de 12 (Sentidos + Búsqueda).
- Un chatbot tiene 0 de 12 (solo habla).
- Un safety layer tiene 2 de 12 (Sentidos + Control).
- Tu empleada tiene 12 de 12.

Nadie ha definido estas 12 como estándar. Eso es la invención.
