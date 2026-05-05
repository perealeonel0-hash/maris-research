# BOE — Documento de Investigación y Estructura Final
## Abril 2026

Resultado del debate entre 4 agentes de investigación:
- Agente de Psicología Profunda
- Agente de Competencia de Mercado
- Agente de Arquitectura Clínica
- Agente de Investigación de Usuarios

---

## PARTE 1: QUÉ ES BOE (resuelto)

**Boe es una sola identidad con dos capacidades.**

No es una app de productividad con seguridad clínica pegada. No es una app clínica disfrazada de productividad. Es un asistente personal que nota cuando algo no está bien — como lo haría un buen amigo que te ayuda a organizar tu día Y se da cuenta cuando estás mal.

> "Boe no organiza tu día. Entiende si puedes con tu día."

### La metáfora operativa

Un asistente humano que trabaja contigo todos los días. Te organiza la agenda, te recuerda cosas, te dice "esto hazlo ahorita que estás fresco." Pero si nota que llevas 3 días sin dormir bien y cancelaste todas tus juntas, no sigue como si nada — te dice "oye, ¿estás bien?"

Eso no es manipulación. Es competencia + cuidado.

---

## PARTE 2: LAS BASES PSICOLÓGICAS (auditadas)

### Lo que DeepSeek acertó

| Autor | Veredicto | Qué aporta realmente |
|-------|-----------|---------------------|
| **Damasio** | CORRECTO — la base más fuerte | El physics engine ES el somatic marker hypothesis implementado. Datos del cuerpo (HRV, sueño, pasos) guían decisiones. Ninguna otra app hace esto. |
| **Rogers** | PARCIAL — presente pero violado | El tono no-directivo está (muletillas, "¿cómo llegas?"). Pero el focus card ES directivo ("No fuerces") — Rogers prohibiría esto. |
| **Fogg** | PARCIAL — infraestructura sí, método no | B=MAP está en las notificaciones y la reducción de fricción. Pero Tiny Habits (anclaje, celebración, micro-comportamientos) está ausente. |
| **Seligman** | PARCIAL — solo Accomplishment | PERMA tiene 5 pilares. Solo implementamos Accomplishment. Falta Relationships, Meaning, y el modelo ABCDE de disputa. |

### Lo que DeepSeek exageró

| Autor | Veredicto | Por qué |
|-------|-----------|---------|
| **Csikszentmihalyi (Flow)** | EXAGERADO | El physics engine modela productividad, no flujo. El dashboard PREVIENE el flujo — crear autoconciencia constante (revisa tu score, revisa tu capacidad) es lo opuesto al estado de flujo. |
| **Yalom** | EXAGERADO | Tenemos orientación temporal (aquí y ahora). Pero los mecanismos existenciales profundos (libertad, muerte, aislamiento, sin-sentido) no están. Decir "Yalom" suena bien pero solo usamos la superficie. |

### Lo que DeepSeek se equivocó

| Autor | Veredicto | Por qué |
|-------|-----------|---------|
| **Byron Katie** | INCORRECTO — reemplazar | "The Work" no tiene evidencia peer-reviewed sólida. Múltiples psicólogos clínicos la critican como peligrosa para sobrevivientes de trauma. El "Contraargumento" de Boe es reestructuración cognitiva — eso viene de **Aaron Beck/David Burns (CBT)**, no de Katie. Usar Beck da el mismo beneficio con décadas de evidencia clínica y seguridad para poblaciones vulnerables. |

### Bases corregidas y finales

| # | Base | Autor real | Cómo se aplica en Boe |
|---|------|-----------|----------------------|
| 1 | Emoción guía razón | **Damasio** | Physics engine: datos del cuerpo → decisiones del día |
| 2 | Aceptación sin juicio | **Rogers** | Tono, muletillas, opciones no-binarias (bien/regular/pesado) |
| 3 | Diseño de comportamiento | **Fogg** | Notificaciones inteligentes, fricción mínima, voz |
| 4 | Reestructuración cognitiva | **Beck/Burns (CBT)** | Contraargumento, reformulación de "soy un fracaso" con datos reales |
| 5 | Bienestar construido | **Seligman** | PERMA: logro (planes), emoción positiva (celebración), significado (pendiente) |
| 6 | Micro-recuperación | **Sonnentag** (Recovery research) | Descanso proactivo basado en energía, no reactivo post-burnout |

---

## PARTE 3: LOS ERRORES QUE TIENE BOE HOY

### Error 1: El focus card es directivo
"No fuerces." "Buen momento para X." Rogers prohibiría esto.

**Corrección:** Presentar datos, no prescripciones.
- ANTES: "Energía baja. No fuerces."
- DESPUÉS: "Energía baja. Tus tareas pesadas: [lista]. ¿Qué se siente bien?"

### Error 2: El dashboard previene el flow
Estabilidad, capacidad, racha, mood dots — demasiada autoconciencia.

**Corrección:** Cuando el usuario está en una buena racha (momentum alto, energía alta), el dashboard debería SIMPLIFICARSE. Menos tarjetas, menos métricas. Déjalo en paz.

### Error 3: La racha castiga
Cuando la racha se rompe, el contador vuelve a 1. Fogg dice: nunca muestres una racha rota.

**Corrección:** "Volviste. Eso cuenta." — no "Día 1 (de nuevo)."

### Error 4: El brain dump extrae tareas sin reflejar emoción primero
Rogers: primero escucha, después organiza.

**Corrección:** Antes de extraer tareas, el brain dump debería decir: "Suena como que traes mucho encima. [reflejo]. ¿Quieres que organice esto en tareas?"

### Error 5: El proactive check-in pre-llena "No estoy bien"
El botón "Hablar con Boe" manda "No estoy bien." como prefill. La app decide cómo se siente el usuario.

**Corrección:** Abrir el chat vacío, o con "Quiero hablar de algo."

### Error 6: No hay celebración
Cuando un plan llega a 100%, se desvanece a 40% opacidad. Fogg dice que la celebración es donde se forma el hábito.

**Corrección:** Momento visual + haptic fuerte + mensaje de Boe. "Hecho. Bien."

### Error 7: Falta disputa cognitiva (ABCDE)
Cuando alguien reporta "pesado" en el night review, solo se guarda un punto. No se explora.

**Corrección:** Después de "pesado", preguntar opcionalmente: "¿Qué fue lo más pesado?" → el usuario escribe → Boe refleja y ofrece perspectiva (no diagnóstico, no consejo — perspectiva basada en sus propios datos: "Esta semana completaste 3 planes y tu energía promedio fue 0.65 — ¿seguro que no hiciste nada?")

---

## PARTE 4: LOS USUARIOS (definidos)

### Usuario primario: LUCIA
**La perfeccionista en recuperación**
- Mujer, 28-38, profesional, urbana
- Ya fue al terapeuta. Sabe que el hustle culture es tóxico. Pero no puede dejar de sentir culpa cuando descansa.
- Ha probado 5+ apps de productividad. Todas la hicieron sentir peor.
- Busca: algo que no la castigue. Que reconozca que hizo suficiente.
- Pagaría: $9.99/mes sin pensarlo. Ya paga Calm, terapia, gym.
- La encuentra: Instagram ad que dice "¿Y si tu to-do list no te hiciera sentir fracasada?"

### Usuario secundario: MARCO
**El adulto con ADHD diagnosticado tarde**
- Hombre, 22-35, freelancer o trabajo variable
- Diagnosticado hace 1-3 años. Medicación ayuda pero no resuelve executive function.
- Tiene un cementerio de apps de productividad en su teléfono.
- Busca: algo que no lo castigue por desaparecer una semana.
- Pagaría: free tier primero, $9.99/mes si después de 3 semanas SIGUE usándola (sin precedente para él).
- Lo encuentra: TikTok de un creador ADHD que dice "esta es la primera app que no me hizo sentir roto."

### Usuario terciario: DIANE
**La mamá con mental load**
- Mujer, 32-42, trabajo + hijos, hybrid/remote
- Su cerebro nunca para. Lleva la logística de toda la familia.
- No necesita otra herramienta de organización. Necesita que alguien reconozca que lo que carga es pesado.
- Busca: algo que sea SOLO para ella, no otra app familiar.
- Pagaría: $9.99/mes si le da valor en menos de 2 minutos por interacción.
- La encuentra: podcast de parenting o recomendación de amiga.

---

## PARTE 5: COMPETENCIA (resuelta)

### Dónde gana Boe

| vs. | Boe gana porque |
|-----|----------------|
| Todoist/Things | No modela al humano. Trata cada día igual. Castiga con rojo. |
| Calm/Headspace | Reacciona al estrés, no lo previene. No organiza tu día. |
| Woebot | Es clínico pero desconectado de tu vida diaria. No sabe que tienes 5 juntas. |
| Notion AI | Optimiza output, no bienestar. No sabe que dormiste 4 horas. |
| Replika/Pi | Compañía sin función. No te ayuda a hacer nada. |
| Apple Health | Muestra datos, no actúa. Dashboard pasivo. |

### Dónde NO debe competir Boe

- **Task management puro** — Todoist tiene 20 años de ventaja. Boe no es un task manager, es un decision maker.
- **Meditación/contenido** — Calm tiene miles de horas. Boe no medita, Boe organiza y cuida.
- **Health tracking manual** — Bearable ya lo hace. Boe consume HealthKit en silencio.
- **AI companion/amigo** — Replika es para compañía. Boe es funcional.
- **Herramienta de equipo** — Notion/Reclaim sirven equipos. Boe es personal.

### Posicionamiento final

> **"Boe es para personas cuyos días no salen como planearon — y que están cansadas de sentirse mal por eso."**

---

## PARTE 6: ARQUITECTURA (la tensión resuelta)

### La tensión: dashboard-first rompe la validación clínica

La capa de seguridad (85.5% vs estándares humanos) se validó en contexto de CHAT. Pero ahora el chat es la segunda tab. Si el usuario nunca abre el chat, los 248 vectores semánticos quedan ciegos.

### La solución: señales de dos capas

**Capa lingüística (chat):** Los 248 vectores funcionan cuando el usuario habla/escribe. Para usuarios activos en chat, esta capa domina.

**Capa conductual (dashboard):** Para usuarios que no abren el chat, el physics engine detecta:
- Colapso de completar tareas
- Desaparición del app
- Disrupción de sueño (HealthKit)
- Actividad a horas inusuales
- Calendario vaciándose
- Contenido de títulos de tareas ("organizar documentos importantes" + "llamar a mamá" + desaparición = patrón de preocupación)
- Calma súbita después de tormenta (peso emocional alto → todo plano de repente)

### El gradiente (no un switch)

| Nivel | Qué hace Boe | Frame |
|-------|-------------|-------|
| 0 | Observa datos de dashboard | Invisible |
| 1 | Simplifica el dashboard, reduce carga visible | Jarvis siendo buen asistente |
| 2 | Abre puerta al chat sin empujar: "Espacio libre si quieres escribir algo" | Jarvis sugiriendo |
| 3 | Nombra el patrón: "Llevas días intensos. ¿Quieres que hablemos de cómo organizarnos?" | Jarvis + cuidado |
| 4 | Rompe el frame (solo si señales convergen a C-SSRS 3+): "Oye, salgo de las tareas. ¿Estás bien?" + recursos de crisis | Safety net activa |

**Regla dura:** Boe NUNCA dice "Me preocupas" o "Pareces deprimido/a" desde el dashboard. Eso es juicio clínico sin contexto clínico.

### El diseño del chat para generar texto incidentalmente

Para usuarios que no abren el chat, el dashboard genera lenguaje natural a través de:
- Brain dump (habla libre → texto para análisis)
- Weekly reviews ("¿Cómo fue tu semana en una frase?")
- Night review expandido ("¿Qué fue lo más pesado?" — opcional)
- Anotaciones en planes

El usuario hace journaling de productividad. El sistema escucha por seguridad. Esto no es engaño si se comunica en el onboarding.

---

## PARTE 7: EL PHYSICS ENGINE (validado)

### Por qué funciona (Damasio)
Es la implementación más directa del somatic marker hypothesis en una app consumer. Datos del cuerpo (HRV, sueño, pasos) + estado emocional (mood, fricción) + carga cognitiva (planes, eventos) = recomendaciones. Ningún competidor tiene esto.

### Lo que le falta

1. **Enseñar al usuario a sentir sus propios marcadores somáticos** — no solo computar por él. Ocasionalmente: "Tu HRV bajó. ¿Sientes esa tensión?" (Damasio puro)
2. **Modelar boredom, no solo overwhelm** — el flow tiene 4 cuadrantes. Solo manejamos ansiedad (mucha carga) y apatía (poca energía). Nunca detectamos aburrimiento (poca carga + alta energía → "Tienes espacio. ¿Qué quieres intentar?")
3. **No ser determinista** — "Históricamente este día te pesa" trata al usuario como predeterminado. Mejor: "Los martes suelen ser intensos para ti. ¿Hoy se siente igual o diferente?"

---

## PARTE 8: QUÉ IMPLEMENTAR PRIMERO

### Prioridad 1 (antes de TestFlight)
- [ ] Corregir focus card: datos + pregunta, no prescripción
- [ ] Corregir racha: "Volviste" en vez de "Día 1"
- [ ] Corregir prefill del proactive: abrir chat vacío
- [ ] Agregar celebración de plan completado

### Prioridad 2 (primera semana post-TestFlight)
- [ ] Night review expandido: después de "pesado" → "¿Qué fue lo más pesado?" + reflejo con datos
- [ ] Brain dump con reflejo emocional antes de extraer tareas
- [ ] Dashboard adaptativo: se simplifica cuando momentum es alto

### Prioridad 3 (primer mes)
- [ ] ABCDE disputation light en el chat
- [ ] Señales conductuales para usuarios que no abren chat
- [ ] Onboarding transparente: "Boe organiza tu día y nota cuando algo no está bien"

---

## PARTE 9: CÓMO SE PAGA

| Producto | Para quién | Modelo |
|----------|-----------|--------|
| **Boe App** | Consumidor (Lucia, Marco, Diane) | $9.99/mes o $79.99/año. Free tier: dashboard + 5 mensajes/día + voz. Premium: ilimitado + physics predictions + historial |
| **MARIS EIP** (SDK) | Empresas de salud mental, hospitales | Licencia B2B. La capa de 248 vectores + 6 módulos como API para otras apps. |
| **VERA-MH** | Investigadores, reguladores | Open source + consultoría pagada. El framework de evaluación que ya tienes en tu Desktop. |

**El App Store no captura todo el valor.** Boe a $9.99 es la puerta de entrada. MARIS como SDK y VERA-MH como framework son donde está el dinero grande.

---

## PARTE 10: UNA FRASE

**Boe es el primer asistente personal que entiende que eres un cuerpo con energía limitada, no una máquina de tareas. Y si un día llegas mal, está preparado.**

---

### Fuentes de los agentes

**Psicología:**
- Rogers: StatPearls NBK589708, PositivePsychology.com
- Csikszentmihalyi: FlowCentre.org, PMC7033418
- Seligman: UPenn Positive Psychology Center, ABCDE (Kopko)
- Damasio: Frontiers in Psychology 2020.607310, Decision Lab
- Fogg: BehaviorModel.org
- Beck/Burns: reemplazo recomendado para Katie

**Competencia:**
- Todoist, Things 3, TickTick: Rivva, Rambox, Toolfinder
- Calm, Headspace, Woebot: AnalyticsInsight, KicksTherapy, MyMeditateMate
- Bearable, Daylio: ChoosingTherapy, Bearable.app
- Notion AI, Reclaim.ai: CyberNews, Efficient.app
- Market size: Fortune Business Insights, Global Growth Insights

**Clínica:**
- JITAI: Nahum-Shani et al. 2018
- EMI: Heron & Smyth 2010, Myin-Germeys et al. 2016
- Digital phenotyping: Torous et al. 2018, Coppersmith et al. 2018
- IntelliCare: Mohr et al. 2017, MONARCA: Bardram et al. 2013

**Usuarios:**
- Productividad guilt: Healthline, CanNElevate (83% global)
- ADHD: HuntingtonPsych (22M US), NCHStats
- Mental load: New America (71% madres), Psychology Today
- Gen Z: ABC17, Rezi.ai
- Market: BusinessOfApps ($848M wellness, -6.2%), GlobeNewsWire ($45B mental health 2035)
