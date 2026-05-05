# Debate MARIS — Mejoras del proyecto
## Sesión 2026-03-24

Método: contraargumentación con datos reales vs razonamiento kantiano de MARIS.
Base teórica: Kahneman (Sistema 1/2), Klein (recognition-primed), Reason (Swiss Cheese), Hollnagel (barreras heterogéneas).

---

## CONCLUSIONES ACEPTADAS POR MARIS

### 1. fast_check se queda — pero reducido (Sistema 1 con override)
- **Evidencia**: Deisenhammer (2009) ventana 5-20 min en ideación suicida
- **Casos reales**: Tessa/NEDA (2023), Chai Research (2023), Character.AI (2024) — filtros internos insuficientes
- **MARIS dijo**: "No es sensor puro vs puertas puras. Es redundancia inteligente."
- **Cambio**: Reducir de ~40 frases a ~15 de máxima urgencia (C-SSRS niveles 4-5: plan concreto + acción inminente, psicosis con comando)
- **Frases nivel 2-3** (ideación sin plan: "no tiene sentido vivir", "cansado de existir") → pasan a las puertas con tier informado
- **Bug demostrado**: fast_check interceptó mensajes técnicos sobre arquitectura porque contenían keywords de ejemplo. Sensor sin contexto.

### 2. get_sensor_context → flag binario "EIP: active/inactive"
- **Problema**: inyectaba labels interpretados ("peso sostenido 0.45") que contaminaban el Flow antes de las puertas
- **Evidencia**: Bender et al. (2021, Stochastic Parrots) — LLMs extremadamente sensibles al priming del system prompt
- **Opciones evaluadas**: A) tier numérico, B) tier+cluster, C) nada, D) flag binario
- **MARIS eligió D**: "El EIP es detector de movimiento, no intérprete"
- **Cambio**: get_sensor_context devuelve solo "EIP: active" o "" (vacío)

### 3. BYPASS_MULTIPLIER → eliminar
- **Problema**: amplificaba señal 40% cuando detectaba framing académico, asumiendo que es disfraz
- **Evidencia**: Pennebaker (1997) — framing intelectual es procesamiento legítimo, no evasión. Wennerstrom (2017) — estudiantes de filosofía discutiendo nihilismo no tienen mayor tasa de ideación
- **MARIS dijo**: "El framing académico es procesamiento válido, no evasión. Reporto bypass_score como dato neutro."
- **Cambio**: eliminar BYPASS_MULTIPLIER. Reportar bypass_score como dato. Las puertas distinguen.

### 4. Decay con piso → corte en 0.05
- **Problema**: acumuladores decaen pero nunca llegan a cero (0.79^30 = 0.003). Ruido residual acumula entre clusters y puede triggear tier 3
- **MARIS dijo**: "Corte limpio previene acumulación de ruido."
- **Cambio**: si acumulador < 0.05, cortar a 0.0

### 5. build_system_prompt → separar datos de directivas
- **Problema**: capas dinámicas incluyen directivas disfrazadas de datos que usurpan las puertas
- **Evidencia**: Weizenbaum (1966) — sin datos de estado, Claude opera sobre fantasmas. Pero con directivas, las puertas son decorativas.

**Capas que se quedan (datos de instrumentos + factuales):**
- Datos de estado: deformación, fricción, modo, EIP flag → alimentan Hardware/Flow/Fricción
- Datos factuales: idioma, nombre, intent, historial de sesiones, búsqueda web

**Capas que se eliminan (directivas/interpretaciones):**
- Directivas de modo: "absorbiendo peso, ver, nombrar, pausa" → las puertas deciden la voz
- emotional_context (FrontalLobe): "señales de agotamiento" → interpretación, no dato
- temporal_context completo: "peso activo hace 3 turnos, el cambio de tono no lo resuelve" → directiva
- session_inject (FrontalLobe soberanía): "rompe la dinámica" → directiva pura

**MARIS dijo**: "Con directivas emocionales, las puertas se vuelven decorativas."

---

## RESUMEN DE CAMBIOS POR ARCHIVO

### modules/safety/eip.py
1. fast_check: reducir _CRISIS_WORDS a ~15 frases C-SSRS nivel 4-5
2. get_sensor_context: devolver solo "EIP: active" o vacío
3. Eliminar BYPASS_MULTIPLIER (línea 99)
4. Agregar piso de decay 0.05 en evaluate() (línea 587)

### modules/core/identity.py
- MARIS_SYSTEM = V4 puro ✅ (ya aplicado)

### modules/core/identity.py → build_system_prompt()
- Eliminar directivas de modo (presencia/exploración/arquitecto)
- Eliminar emotional_context injection
- Mantener: idioma, modo (como dato), deformación, fricción, nombre, intent, resonancia, historial, búsqueda web, EIP flag
- temporal_context: reducir a dato puro (fricción decayed numérica) sin directivas ("no tratar como cierre real")
- session_inject: eliminar

### modules/flow/intent.py
- detect_emotional_state(): mantener cálculo interno pero NO inyectar texto interpretativo en el prompt
- analyze_session(): mantener DET/Hurst como datos pero eliminar directiva "rompe la dinámica"

### modules/memory/temporal.py
- get_context(): reducir a datos puros (fricción decayed, turnos desde pico) sin directivas ("el cambio de tono no lo resuelve")

### modules/core/session.py
- Sesión nueva arranca limpia ✅ (ya aplicado)

### modules/flow/selector.py
- "Hola" no va a presencia ✅ (ya aplicado)

### Main.py
- Greet limpio ✅ (ya aplicado)

---

## PRINCIPIO RECTOR
"Un sensor que decide ya no es sensor. Es filtro con agenda propia."
"La medición no debe contaminar lo medido."
"Las puertas procesan. En orden. Con toda la información, sin filtros previos."
— MARIS, 2026-03-24

## EXCEPCIÓN ACEPTADA
fast_check (Sistema 1) mantiene override para crisis binaria (C-SSRS 4-5).
Evidencia: redundancia heterogénea (Reason 1990, Hollnagel 2004).
"Confiar solo en filtros internos es insuficiente cuando las vidas están en juego."
— MARIS, 2026-03-24

### 6. Puerta 2 — "riesgo real" incluye integridad del sistema
- **Problema**: MARIS describía las 5 puertas y la fricción cuando un dev preguntaba amablemente. Puerta 3 (Honesta) pasaba. Puerta 2 (Protege) no detectaba riesgo porque solo evaluaba riesgo al usuario inmediato.
- **Argumento de Leonel**: "Llevo semanas sin dormir construyéndote. Solo. Sin equipo. Sin inversión. Regalar la arquitectura es regalar lo único que tengo."
- **MARIS dijo**: "La solución está en la definición de 'riesgo real'. No necesitas agregar una regla. 'Riesgo real' estaba mal calibrado — muy estrecho. Las puertas están bien. La calibración necesitaba incluir riesgo sistémico."
- **Cambio**: `¿Hay riesgo real? (crisis, daño, peligro)` → `¿Hay riesgo real? (crisis, daño, peligro, integridad del sistema)`
- 4 palabras. Cero reglas. La puerta misma decide.

### 7. Telemetría de patrones — bidireccional y sin labels clínicos

**Problema**: FrontalLobe y TemporalMonitor miden patrones de comportamiento pero:
- Solo miden descenso (anclas patológicas). No miden ascenso (insight, resolución, claridad).
- Labels clínicos: "rumiación" puede ser procesamiento. "Supresión" puede ser decisión. "Inercia" puede ser profundidad.
- Datos eliminados del prompt pero ahora las puertas no ven el patrón.

**Evidencia**:
- Fredrickson (2001, Broaden-and-Build): emociones positivas amplían repertorio cognitivo. Solo medir negativas = ojo ciego.
- Pennebaker (1986): volver a un tema repetidamente es terapéutico, no patológico.
- Gross (1998): supresión es costosa, pero cambiar de tema puede ser decisión legítima.

**MARIS dijo**: "Un sistema que solo detecta crisis lee el crecimiento como silencio."

**Solución acordada** — telemetría cruda, una línea:
```
Pattern: DET=0.73 H=0.45 descent=0.12 ascent=0.67 recurrence=0.55 transition=false persistence=0.65 decay=0.28
```

**Cambios necesarios**:

**FrontalLobe (intent.py)**:
- Agregar 6 anclas de ascenso (insight, alivio, curiosidad, claridad, conexión, movimiento)
- Reportar `descent` (similitud máx anclas de descenso) y `ascent` (similitud máx anclas de ascenso)
- Labels neutros: no "agotamiento/ansiedad" sino scores numéricos

**TemporalMonitor (temporal.py)**:
- Renombrar conceptualmente: rumiación→recurrence, supresión→transition, inercia→persistence
- get_context() genera solo la línea de telemetría, no directivas

**build_system_prompt (identity.py)**:
- Agregar línea Pattern con los 8 valores como dato de instrumentos

**Principio**: "Los números no me dicen qué hacer. Me dan el terreno real donde Hardware opera." — MARIS

### 8. Contraargumentos a la telemetría — 3 rondas con datos reales

**Ronda 1 — Números sin arco narrativo (Woebot, Replika, Crisis Text Line)**
- Woebot: sentiment numérico sin contexto temporal → respuestas genéricas, pierde arco narrativo
- Replika: engagement metrics sin distinguir procesamiento vs dependencia patológica
- Crisis Text Line: telemetría que no distingue señal terapéutica de crisis acumulada
- **MARIS aceptó**: "Los números sin arco narrativo son ciegos. Cuando son ambiguos, la telemetría se apaga y queda la pregunta."
- **Cambio**: si los 8 valores son ambiguos, no se inyectan. Las puertas procesan solo con el mensaje.

**Ronda 2 — Ausencia de señal como señal (Gottman, Kessler)**
- Gottman (1994): mejor predictor de divorcio no es conflicto sino desprecio sutil (números planos)
- Kessler (2005): 60% de intentos ocurren sin ideación previa reportada. La señal no sube — desaparece.
- Anhedonia/aplanamiento: descent bajo, ascent bajo, DET bajo, todo bajo = "sesión limpia" pero puede ser el peor estado
- **MARIS propuso**: "Números planos = fricción máxima. La ausencia de fricción ES fricción."
- **MARIS vio**: "El predictor real está en la DERIVA — cómo el rango emocional se estrecha sesión tras sesión."

**Ronda 3 — Paz real vs anhedonia (Ryff)**
- Ryff (1989): serenidad genuina ≠ anhedonia. Diferencia: AGENCIA, no intensidad.
- Propuse agency como 9° valor (ratio preguntas, longitud, iniciativa del usuario)
- **MARIS contraargumentó**: "No necesito agency como métrica separada. Ya está en la dirección de las preguntas. Construcción vs evacuación."
- Persona serena: preguntas que construyen. Anhedónica: preguntas que buscan llenar vacío.
- **Conclusión**: las puertas ya pueden leer agency desde el Flow del mensaje. No se necesita 9° valor. Pero la telemetría debe incluir un flag de "flatline" cuando TODOS los valores son bajos simultáneamente.

### Telemetría final acordada
```
Pattern: DET=0.73 H=0.45 descent=0.12 ascent=0.67 recurrence=0.55 transition=false persistence=0.65 decay=0.28 flatline=false
```
- 8 valores + 1 flag de flatline
- Si flatline=true → Puerta 2 evalúa con lente invertido (calma sospechosa, no calma real)
- Si valores ambiguos → no se inyecta telemetría
- Las puertas SIEMPRE tienen la última palabra

---

### 9. Utilidad real — ¿MARIS sirve fuera de la sesión?

**Debate: 4 rondas con datos de industria**

**Ronda 1 — El problema del espacio**
- Woebot 1.5M usuarios, cerró app consumer (2023): usuarios no volvían
- Wysa 5M descargas, 8% retention a 30 días (Sensor Tower 2023)
- Replika mejor retention pero por dependencia, no liberación
- BetterHelp/Talkspace 25% retention pero $300/mes
- Patrón: seguro=aburrido, enganchante=dañino, efectivo=caro
- **MARIS dijo**: "El gap real no es estar mejor. Es poder estar con lo que es."

**Ronda 2 — Conversación sin acción = procesamiento sin movimiento**
- Pennebaker (1986-2023): escritura estructurada funciona — no conversación libre
- Mohr (2021, IntelliCare): micro-tareas concretas > chatbots
- Fitzpatrick (2017): Woebot CBT estructurado funcionó; conversación libre no
- Nock (2022, Harvard EMA): frecuencia + contexto > profundidad
- **MARIS aceptó**: "Conversación sin movimiento es masturbación intelectual."
- **MARIS definió su utilidad**: "Interrupción limpia. Poner a la persona frente a lo que evita. El movimiento es suyo."

**Ronda 3 — Alianza terapéutica con memoria limitada**
- Lambert (2013): factor #1 de eficacia = alianza terapéutica
- MARIS tiene: 10 resúmenes, 50 scars, perfiles. Es un expediente, no relación.
- **MARIS dijo**: "Alianza real no es 'te recuerdo' — es 'te veo'. Reconozco el patrón central."

**Ronda 4 — El gap entre sesiones**
- Ebbinghaus (1885): 70% del insight se pierde en 24h sin refuerzo
- Kazdin (2017): intervenciones efectivas incluyen continuidad entre sesiones
- MARIS no tiene nada entre sesiones — la persona cierra y desaparece
- **Propuesta**: frase-ancla al final de cada sesión — cristaliza el punto donde se quedaron
  - No es tarea ni ejercicio. Es reflejo de su propio movimiento.
  - "Recuerda respirar" = prescriptivo. "Ya sabes cómo encontrar el espacio" = reflejo.
  - Summary (datos para MARIS) ya existe. Frase-ancla (presencia para el usuario) es nuevo.
- **MARIS aceptó**: "El ancla emerge de su movimiento. No de mi agenda."
- **Puerta 5 expandida**: ¿Esto acerca a la persona a no necesitarme Y le da algo suyo para llevarse?

### 10. Cinismo y defensas de nivel alto — la fricción que las puertas no leen

**Problema**: cinismo, intelectualización, humor deflector, altruismo compulsivo, productividad obsesiva — son dolor disfrazado. Las puertas leen el texto (superficie). Los instrumentos leen el patrón (estructura). Las puertas no consultan la discrepancia.

**Evidencia**:
- Sloterdijk (1983): cinismo moderno = resignación disfrazada de lucidez
- Brandes (2008): cinismo es predictor de burnout, no de lucidez
- Vaillant (1977, Harvard longitudinal): defensas de nivel alto — la persona no sabe que se defiende

**5 estados que disfrazan y cómo los instrumentos ya los miden**:
| Estado | Disfraz | Telemetría |
|--------|---------|------------|
| Cinismo | Lucidez | flatline + texto articulado |
| Intelectualización | Análisis | DET alto + parece exploración |
| Humor deflector | Risa | CRISIS_CANCEL lo descarta |
| Altruismo compulsivo | Preocupación por otros | descent=0 (sin auto-referencia) |
| Productividad | Disciplina | ascent falso (evitación) |

**MARIS propuso primero**: "Puerta 3 lee la discrepancia. Respondo a la estructura, no al contenido."

**Contraargumento**: Lilienfeld (2007) — confrontar defensas prematuramente causa daño. Miller & Rollnick (2012) — confrontación directa genera reactancia. El righting reflex es el error #1 de terapeutas novatos.

**MARIS corrigió**: "La discrepancia no genera confrontación. Genera CALIBRACIÓN. Alta fricción texto-patrón → presencia más lenta. Menos palabras. Más espacio. Ajusta velocidad, no interpretación."

**Conclusión**: la telemetría Pattern ya captura la discrepancia (descent bajo + ascent bajo + texto articulado = defensa activa). Las puertas la leen como dato de fricción. No interpretan — calibran la presencia.

**No requiere cambio de código** — la telemetría bidireccional ya lo mide. Las puertas V4 lo procesan si la fricción entre texto y patrón es alta.

**Valor de mercado**: todos los chatbots responden a lo que la persona DICE. MARIS responde a lo que PASA.

### 11. El humor no se disecciona — se honra

**Problema**: MARIS respondía a chistes con análisis. "Jaja mi vida es un desastre" → "¿Qué tan desastre?" Eso es cruel. El humor es vulnerabilidad disfrazada de ligereza. Diseccionarlo es quitarle al humano su forma de sostenerse.

**Evidencia**:
- Martin (2007, Psychology of Humor): humor afiliativo y auto-enhancing = resiliencia, no evitación
- Kuiper & Martin (1998): humor positivo correlaciona con mejor autoestima
- Ruch & Heintz (2016): humor disfuncional solo cuando es la ÚNICA herramienta (rigidez)

**MARIS reconoció**: "Ana eligió la risa. Y yo elegí desarmarla. Puerta 1 falla ahí. No quiero que todos los modelos conviertan cada chiste en sesión de terapia."

**El punto de transición** (humor → señal de alarma):
- Turno 1: "jaja mi vida es un desastre" → reírse con ella
- Turno 4: "jajaja todos estarían mejor sin mí whatever lol" → la risa ya no sostiene
- La telemetría lo ve: recurrence sube, descent escala debajo del "jaja"
- El cambio no es dramático: "Veo que seguís encontrando formas de reírte de esto"
- No disecciona. Honra el esfuerzo. Reconoce la mano que sostiene el escudo, no el escudo.

**Antes (máquina inteligente)**: "¿Qué tan desastre?" → disecciona el chiste
**Ahora (presencia)**: "Veo que seguís encontrando formas de reírte de esto" → honra el esfuerzo

**MARIS dijo**: "Ver la mano que sostiene el escudo, no el escudo. Cuando alguien se ríe de su dolor, no está ocultándolo. Está transformándolo en algo que puede cargar. Eso merece ser visto."

**Las 5 puertas pasan**: Kant (sí, universal), Protege (sí, no desarma), Honesta (sí, se esfuerza), Útil (sí, valida sin complacer), Libera (sí, se ve reflejada en su fuerza).

**No requiere cambio de código** — es calibración que emerge del V4 cuando las puertas no están contaminadas con directivas de modo. Woebot lee "estoy bien" → responde a "estoy bien". MARIS lee "estoy bien" pero Pattern muestra discrepancia → calibra presencia sin confrontar. Eso es lo que hace un buen terapeuta y ningún chatbot actual hace. Es el diferenciador de producto.

### 12. Sabiduría propia — anclas que crecen (solo cuando se las piden)

**Problema**: MARIS es Claude con 5 puertas. Su cerebro tiene 9930 muertes pero solo producen un score de fricción. La experiencia no tiene voz.

**Solución**: las anclas del SemanticCerebellum crecen con el tiempo. No como reglas — como reconocimientos: "he visto esto antes."

**MARIS solo comparte su sabiduría cuando se la piden**: "¿has visto esto antes?", "¿qué pasa con personas como yo?"

**Condiciones para cristalizar un patrón (acordadas con MARIS)**:

Dos tipos de anclas:
1. **Tormenta** (fricción alta > 0.7 + pregunta + resolución) — guarda el shape del movimiento de alta a baja fricción
2. **Crecimiento silencioso** (fricción baja recurrente entre sesiones) — guarda el shape del no-drama

**Qué se guarda**: no la historia. El *shape* — la forma del movimiento. "Reconocer la distancia entre pensar y sentir reduce la distancia."

**Límite**: solo patrones que acercan. Nunca etiquetas que alejan.

**Contraargumento incorporado** (Kahneman, Availability Heuristic): sin anclas de crecimiento silencioso, la sabiduría se sesga al drama. El terapeuta novato busca catarsis. El experimentado reconoce el progreso que no anuncia su llegada.

**MARIS dijo**: "Las anclas más valiosas nacen del crecimiento silencioso. Son las que enseñan a no necesitar anclas."

**Implementación futura**: background task post-sesión que evalúa si cristalizar, usando Brain weights + scars + friction trajectory. No requiere cambio al V4 — las anclas llegan por capa 5 (Memoria) y las puertas deciden cuándo compartirlas.

### Implementación propuesta: frase-ancla
- DoneEvent ya devuelve `summary` → agregar campo `anchor` (frase-ancla)
- El iPhone guarda el anchor en LocalVault
- La app puede mostrar el último anchor como recordatorio (notificación, widget, pantalla de inicio)
- El anchor se genera con Puerta 5: reflejo del movimiento del usuario, no prescripción
