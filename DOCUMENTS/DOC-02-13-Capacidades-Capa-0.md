# Las 13 Capacidades de un Empleado Virtual con Juicio + Capa 0 (Conciencia)

## Un patrón para construir sistemas de inteligencia artificial que se comporten como empleados humanos competentes

**Autor:** Leonel Perea Pimentel
**Fecha:** Mayo 2026
**Versión:** 1.0
**Dominio de validación primario:** MARIS (asistente de bienestar emocional)
**Dominio de validación secundario:** CleanBot (asistente virtual para negocio de limpieza)

---

> **Nota de derechos:**
> (c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados.
> El marco de las 13 Capacidades, la Capa 0 y el sistema de mezcla basado en arquetipos son propiedad intelectual del autor. El uso comercial requiere autorización escrita. Se permite la citación académica con atribución completa.

---

## 1. Resumen

Este documento describe un marco arquitectónico para construir sistemas de inteligencia artificial que se comporten de forma comparable a un empleado humano competente. El modelo propone trece capacidades en cuatro capas funcionales: Percepción, Decisión, Acción e Inteligencia. Una meta-capa llamada Capa 0 (Conciencia) actúa como mezclador dinámico de esas capacidades.

Un chatbot convencional tiene una habilidad: conversar. Un agente autónomo tiene dos: percibir y ejecutar. Este patrón integra las trece de forma simultánea y las activa en proporciones variables según el contexto.

La validación se realizó en dos dominios distintos. MARIS es un asistente de bienestar emocional con 529 vectores de detección y un pipeline clínico de 23 pasos. CleanBot es un asistente comercial para un negocio de limpieza con 10 arquetipos que cubrieron el 95% de las situaciones reales.

Un experimento adicional comparó la arquitectura basada en arquetipos (ACOP) contra lógica condicional (if/else). Los resultados mostraron que ambos enfoques son complementarios. if/else resuelve el 80% de los casos simples con mayor robustez. ACOP captura matices emocionales y contextuales que la lógica binaria omite.

---

## 2. Contexto

La industria de inteligencia artificial clasifica los sistemas en tres categorías: chatbots (responden preguntas), agentes (ejecutan tareas) y capas de seguridad (filtran contenido). Cada categoría resuelve una parte del problema. Ninguna cubre lo que un empleado humano competente hace en su trabajo diario.

Un recepcionista eficaz no solo responde consultas. Percibe el tono del interlocutor. Recuerda interacciones anteriores. Juzga si debe actuar o escalar. Propone soluciones que nadie solicitó. Adapta su comunicación según la persona.

La pregunta de este trabajo fue: **si enumeramos las capacidades que distinguen a un empleado competente de uno incompetente, podemos codificarlas como módulos activables en un sistema artificial?**

La respuesta requirió un periodo de desarrollo entre 2025 y 2026 en MARIS, donde los errores tienen consecuencias clínicas. La validación cruzada se hizo en CleanBot, donde los errores cuestan dinero.

---

## 3. Las 13 Capacidades

### Capa 1 -- PERCEPCIÓN

#### Capacidad 1: Instinto

**Definición.** Detectar lo que el interlocutor *no* dice explícitamente. No es inferencia semántica superficial. Es acumulación probabilística a lo largo de múltiples turnos conversacionales.

**Implementación en MARIS.** El módulo EIP (Evaluación Implícita de Patrones) opera con 96 vectores que rastrean señales indirectas: latencia entre respuestas, cambios abruptos de tema, uso de minimizadores ("no es nada", "estoy bien"), contradicciones entre contenido verbal y contexto temporal. Cada vector acumula peso durante la conversación. Un indicador aislado no dispara ninguna alerta. La convergencia de varios produce una señal confiable.

**Implementación en CleanBot.** Cuando un cliente pregunta tres veces sobre precios sin mencionar fechas, el sistema infiere vacilación económica. Activa el arquetipo de objeción de precio antes de que el usuario la verbalice.

---

#### Capacidad 2: Sentidos

**Definición.** Identificación explícita de qué ocurre en el mensaje actual. El Instinto opera sobre lo implícito y acumulado. Los Sentidos trabajan sobre lo presente y manifiesto.

**Implementación en MARIS.** Siete detectores procesan cada mensaje entrante usando 529 vectores distribuidos: detector de crisis (ideación, autolesión, abuso), detector emocional (taxonomía de 27 emociones), detector de necesidades (Maslow adaptado), detector somático (síntomas físicos reportados), detector relacional (conflictos interpersonales), detector cognitivo (distorsiones de pensamiento) y detector contextual (hora, frecuencia, patrones temporales).

**Implementación en CleanBot.** Tres detectores cubren el dominio comercial: detector de intención (cotizar, agendar, reclamar, consultar), detector de urgencia (temporal, emocional, operativa) y detector de estado del cliente (nuevo, recurrente, insatisfecho).

---

#### Capacidad 3: Memoria

**Definición.** Recordar la tendencia, no el momento aislado. Un empleado competente no consulta el expediente completo en cada interacción. Recuerda la trayectoria: "esta persona ha mejorado" o "este cliente siempre tiene problemas con la facturación".

**Implementación en MARIS.** El Physics Brain modela la evolución emocional del usuario mediante ecuaciones de dinámica. La velocidad emocional se calcula como la derivada del nivel de fricción respecto al tiempo (v = d(Fr)/dt). La capacidad residual de afrontamiento se modela como decaimiento exponencial (C = H_0 * e^(-Fr/H_0), donde H_0 es la línea base histórica y Fr la fricción acumulada). Esto permite distinguir entre un usuario que reporta tristeza desde un estado estable (fluctuación normal) y uno que reporta la misma tristeza dentro de una tendencia descendente (señal de alarma).

**Implementación en CleanBot.** Un registro ponderado temporalmente rastrea satisfacción del cliente. Las últimas tres interacciones pesan más que las anteriores. Esto genera un "momentum" de la relación comercial.

---

### Capa 2 -- DECISIÓN

#### Capacidad 4: Juicio

**Definición.** Decidir *antes* de actuar. No es filtrado reactivo de contenido. Es evaluación proactiva del curso de acción apropiado según el contexto, la persona y las restricciones éticas vigentes.

**Implementación en MARIS.** Seis compuertas éticas operan secuencialmente antes de generar cualquier respuesta: (1) verificación de riesgo vital, (2) evaluación de competencia (puede el sistema manejar esto?), (3) análisis de proporcionalidad (la respuesta es adecuada al nivel de la situación?), (4) revisión de autonomía (se respeta la agencia del usuario?), (5) chequeo de consistencia (contradice algo que dijimos antes?) y (6) validación de alcance (está dentro de nuestro dominio?).

**Implementación en CleanBot.** Tres compuertas comerciales: (1) verificación de disponibilidad real antes de prometer fechas, (2) autorización de descuentos dentro de márgenes permitidos y (3) derivación a humano cuando el reclamo excede la política estándar.

---

#### Capacidad 5: Control

**Definición.** Verificación posterior a la acción. El Juicio decide antes de actuar. El Control inspecciona después de hacerlo. Un empleado competente relee su correo antes de enviarlo.

**Implementación en MARIS.** Siete post-procesadores revisan cada respuesta generada: verificación de tono (no paternalista, no minimizador), auditoría de contenido clínico (no diagnosticar, no prescribir), consistencia con el historial conversacional, detección de promesas implícitas, revisión de longitud apropiada, validación de recursos sugeridos y chequeo final de seguridad.

**Implementación en CleanBot.** Verificación de coherencia entre precio cotizado y lista de precios actual. Revisión ortográfica del nombre del cliente. Confirmación de que la fecha propuesta no cae en día no laborable.

---

#### Capacidad 6: Humildad

**Definición.** Escalar cuando la situación excede las capacidades del sistema. Es difícil de implementar porque requiere que el sistema reconozca sus propios límites. Eso contradice la tendencia de los modelos de lenguaje a generar respuestas para cualquier estímulo.

**Implementación en MARIS.** Cuando los detectores de crisis identifican ideación suicida activa con plan específico, el sistema abandona el modo conversacional. Proporciona recursos de emergencia verificados (líneas de crisis con números actualizados). Indica que la situación requiere atención humana profesional. No intenta "resolver" la crisis.

**Implementación en CleanBot.** Cuando un cliente describe daños materiales causados presuntamente por el servicio de limpieza, el sistema no negocia ni niega. Registra los detalles, expresa comprensión y transfiere a un operador humano con el contexto completo.

---

### Capa 3 -- ACCIÓN

#### Capacidad 7: Iniciativa

**Definición.** Actuar sin que se lo pidan. Un empleado reactivo espera instrucciones. Uno proactivo anticipa necesidades.

**Estado en MARIS.** Parcialmente implementada. El sistema detecta patrones que sugieren necesidades no verbalizadas, pero no inicia acciones proactivas fuera del flujo conversacional (por ejemplo, enviar un mensaje de seguimiento 48 horas después de una conversación difícil).

**Implementación en CleanBot.** Cuando un cliente agenda una limpieza profunda y el sistema detecta que pasaron más de 90 días desde la última, sugiere un paquete de mantenimiento trimestral.

---

#### Capacidad 8: Consulta

**Definición.** Preguntar antes de asumir. Esta capacidad es el contrapeso de la Iniciativa: actuar sin preguntar cuando la situación es clara, preguntar antes de actuar cuando existe ambigüedad.

**Estado en MARIS.** No implementada formalmente como módulo independiente. El comportamiento existe de manera implícita en el prompt, pero carece de estructura algorítmica.

**Implementación en CleanBot.** Cuando un cliente solicita "una limpieza para el viernes" sin especificar tipo, el sistema pregunta si se refiere a limpieza estándar o profunda antes de cotizar.

---

#### Capacidad 9: Propuesta

**Definición.** Generar sugerencias que nadie solicitó pero que agregan valor. Un empleado mediocre cumple lo pedido. Uno bueno propone algo adicional que mejora el resultado.

**Estado en MARIS.** No implementada. Las respuestas se mantienen dentro del alcance de lo que el usuario plantea.

**Implementación en CleanBot.** Cuando un cliente cotiza limpieza de oficinas, el sistema propone un servicio de sanitización para áreas comunes. Es un upsell que el cliente no pidió pero que resulta relevante.

---

### Capa 4 -- INTELIGENCIA

#### Capacidad 10: Prioridad

**Definición.** Determinar qué debe atenderse primero. Cuando múltiples señales compiten por atención, esta capacidad define la jerarquía de respuesta.

**Implementación en MARIS.** Parcialmente implementada. El sistema prioriza señales de riesgo vital sobre cualquier otra detección. La priorización entre señales no críticas (por ejemplo, tristeza + conflicto relacional + distorsión cognitiva simultáneas) aún depende de heurísticas simples.

**Implementación en CleanBot.** La cola de conversaciones se reordena automáticamente: reclamos antes que cotizaciones, cotizaciones antes que consultas informativas, clientes recurrentes antes que prospectos desconocidos.

---

#### Capacidad 11: Adaptación

**Definición.** Modular el comportamiento según la persona específica. No es personalización cosmética (usar el nombre del interlocutor). Es ajuste del estilo comunicativo, nivel de detalle y grado de formalidad.

**Implementación en MARIS.** El sistema adapta tono, longitud y estrategia terapéutica según el perfil acumulado del usuario. Un usuario que responde con mensajes breves recibe respuestas concisas. Uno que elabora extensamente recibe validaciones más detalladas. La adaptación opera sobre los ejes formal-informal, directo-exploratorio y breve-expandido.

**Implementación en CleanBot.** Los clientes corporativos reciben cotizaciones formales con desglose detallado. Los clientes residenciales reciben mensajes directos con precio total y disponibilidad inmediata.

---

#### Capacidad 12: Búsqueda

**Definición.** Buscar información que no se posee en lugar de fabricarla. Aborda el problema de la alucinación: el sistema reconoce lagunas en su conocimiento y las resuelve en lugar de generar contenido plausible pero falso.

**Estado en MARIS.** No implementada como módulo autónomo. El sistema opera con conocimiento embebido en su prompt y entrenamiento. No consulta fuentes externas en tiempo real.

**Implementación en CleanBot.** Cuando un cliente pregunta sobre productos de limpieza para un material inusual, el sistema consulta una base de conocimiento actualizable en lugar de generar una recomendación potencialmente dañina.

---

#### Capacidad 13: Conocimiento

**Definición.** Dominar el oficio específico, no solo el lenguaje. Un modelo de lenguaje sabe *hablar* sobre cualquier tema. Un sistema con Conocimiento sabe *ejercer* un oficio concreto.

**Implementación en MARIS.** Parcialmente configurable. El conocimiento clínico está embebido en el prompt del sistema y en los 248 vectores del pipeline clínico v1.1. No existe como módulo parametrizable que pueda recibir bases de conocimiento diferentes.

**Implementación en CleanBot.** Base de conocimiento estructurada con: catálogo de servicios, tabla de precios por metro cuadrado, compatibilidad de productos con superficies, tiempos estimados por tipo de servicio y políticas de garantía.

---

## 4. Capa 0: Conciencia (El Mezclador)

Las trece capacidades no operan todas simultáneamente ni con igual intensidad. Activarlas todas al máximo produce un sistema hiperactivo e incoherente. Mantenerlas todas al mínimo produce un chatbot genérico. La Capa 0 actúa como ecualizador dinámico.

### Principio de funcionamiento

La Conciencia opera como una paleta de pintor. Las trece capacidades son los colores disponibles. La Capa 0 observa la situación y mezcla las proporciones adecuadas.

### Implementación técnica

El mecanismo usa similitud coseno contra un conjunto de aproximadamente diez arquetipos predefinidos. Cada arquetipo tiene pesos asignados para las trece capacidades:

1. **Recepción del mensaje:** El sistema procesa la entrada del usuario a través de los detectores (Sentidos) y el acumulador histórico (Instinto + Memoria).
2. **Generación del vector de situación:** Los resultados se codifican como un vector numérico que representa el estado actual de la interacción.
3. **Comparación contra arquetipos:** Se calcula la similitud coseno entre el vector de situación y cada arquetipo almacenado.
4. **Selección y mezcla:** El arquetipo con mayor similitud determina la configuración base. Si dos arquetipos compiten con similitudes cercanas, sus pesos se interpolan proporcionalmente.
5. **Activación diferencial:** Las trece capacidades se activan con las intensidades resultantes. Un peso de 0.9 opera a plena potencia. Un peso de 0.1 funciona en modo residual.

### Lo que la Conciencia sabe

- Qué sabe el sistema y qué ignora.
- Si las capacidades disponibles son suficientes para la situación detectada.
- Cuándo operar y cuándo ceder el control a un humano.

### Lo que la Conciencia NO es

No es conciencia fenomenológica ni experiencia subjetiva. El término es una analogía funcional: así como la conciencia humana integra percepciones, decisiones y acciones en un todo coherente, esta capa integra las trece capacidades en una respuesta unificada. No se reclama ninguna cualidad ontológica. Es ingeniería, no filosofía.

---

## 5. Los 10 Arquetipos (Experimento CleanBot)

Diez arquetipos cubrieron el 95% de las interacciones reales registradas durante el período de validación:

| # | Arquetipo | Instinto | Sentidos | Memoria | Juicio | Control | Humildad | Iniciativa | Consulta | Propuesta | Prioridad | Adaptación | Búsqueda | Conocimiento |
|---|-----------|----------|----------|---------|--------|---------|----------|-----------|----------|-----------|-----------|------------|----------|-------------|
| 1 | Cotización estándar | 0.2 | 0.6 | 0.3 | 0.4 | 0.5 | 0.1 | 0.3 | 0.5 | 0.4 | 0.3 | 0.5 | 0.2 | 0.9 |
| 2 | Objeción de precio | 0.8 | 0.5 | 0.6 | 0.7 | 0.4 | 0.3 | 0.5 | 0.3 | 0.6 | 0.5 | 0.9 | 0.2 | 0.8 |
| 3 | Reclamo/Queja | 0.7 | 0.8 | 0.7 | 0.6 | 0.5 | 0.9 | 0.2 | 0.8 | 0.1 | 0.9 | 0.9 | 0.3 | 0.7 |
| 4 | Cliente recurrente | 0.4 | 0.4 | 0.9 | 0.3 | 0.4 | 0.1 | 0.7 | 0.3 | 0.8 | 0.4 | 0.8 | 0.2 | 0.7 |
| 5 | Urgencia temporal | 0.3 | 0.7 | 0.2 | 0.5 | 0.6 | 0.2 | 0.8 | 0.4 | 0.3 | 0.9 | 0.6 | 0.4 | 0.8 |
| 6 | Consulta informativa | 0.1 | 0.5 | 0.1 | 0.2 | 0.3 | 0.1 | 0.2 | 0.6 | 0.3 | 0.2 | 0.4 | 0.7 | 0.9 |
| 7 | Upsell natural | 0.5 | 0.4 | 0.6 | 0.5 | 0.5 | 0.1 | 0.9 | 0.3 | 0.9 | 0.4 | 0.7 | 0.3 | 0.8 |
| 8 | Cancelación | 0.6 | 0.6 | 0.8 | 0.7 | 0.4 | 0.5 | 0.4 | 0.7 | 0.5 | 0.7 | 0.8 | 0.2 | 0.6 |
| 9 | Reagendamiento | 0.2 | 0.5 | 0.5 | 0.3 | 0.6 | 0.1 | 0.4 | 0.6 | 0.2 | 0.6 | 0.5 | 0.3 | 0.7 |
| 10 | Saludo / Primer contacto | 0.3 | 0.3 | 0.1 | 0.2 | 0.3 | 0.1 | 0.5 | 0.4 | 0.4 | 0.2 | 0.7 | 0.1 | 0.5 |

Los arquetipos no son categorías rígidas. La similitud coseno permite que una interacción active parcialmente varios arquetipos. Un cliente recurrente que presenta objeción de precio produce un vector que pondera ambos arquetipos, elevando Memoria (0.9 del arquetipo 4) y Adaptación (0.9 del arquetipo 2).

---

## 6. Experimento: Dominio Cruzado

Si las 13 Capacidades solo funcionan en bienestar emocional, son una solución particular. Si funcionan también en dominios comerciales, son un patrón generalizable.

### Procedimiento

Se tomó el marco de 13 Capacidades desarrollado para MARIS y se aplicó a la construcción de CleanBot, un asistente virtual para un negocio de servicios de limpieza. El dominio fue elegido por su distancia respecto al original: MARIS maneja emociones; CleanBot maneja transacciones. MARIS requiere sensibilidad clínica; CleanBot necesita precisión comercial.

### Resultados

- **Cobertura arquetipal:** 10 arquetipos cubrieron el 95% de las interacciones reales registradas.
- **Comportamientos observados:** El sistema cotizó precios correctamente, desescaló emociones en reclamos, escaló quejas que excedían la política estándar, ofreció servicios adicionales en momentos oportunos y reconoció cuándo debía detenerse.
- **Tiempo de desarrollo:** CleanBot tomó menos tiempo que MARIS porque el marco de capacidades ya estaba definido. El trabajo se concentró en parametrizar los arquetipos y configurar la base de conocimiento, no en diseñar la arquitectura.
- **Hallazgo:** Las trece capacidades son agnósticas al dominio. Lo que cambia entre dominios es el *contenido* de cada capacidad (qué detectan los Sentidos, qué revisa el Control, qué sabe el Conocimiento). La *estructura* permanece igual.

---

## 7. Experimento: if/else vs ACOP

### Hipótesis

Se planteó la pregunta: es necesario el sistema de arquetipos y similitud coseno (ACOP: Activación de Capacidades Orientada por Patrones), o basta con lógica condicional (if/else)?

### Procedimiento

Se construyeron dos agentes con el mismo objetivo funcional. Se evaluaron contra un conjunto de 10 mensajes de prueba que cubrían el espectro de complejidad, desde consultas directas hasta situaciones emocionalmente ambiguas.

### Resultados

| Métrica | Agente if/else | Agente ACOP |
|---------|---------------|-------------|
| Respuestas correctas | 7/10 | 8/10 |
| Casos simples | 5/5 | 4/5 |
| Casos complejos | 2/5 | 4/5 |
| Robustez en casos directos | Superior | Inferior |
| Captura de matices | Inferior | Superior |

**Observaciones:**

- El agente if/else fue más determinista en casos con intención transparente (cotizar, agendar, solicitar información estándar).
- El agente ACOP detectó matices que el if/else omitió: un mensaje con vergüenza recibió normalización empática; uno con indecisión activó el modo de consulta en vez de empujar una venta.
- El agente if/else falló cuando las señales eran mixtas (por ejemplo, un reclamo formulado como pregunta educada).
- El agente ACOP falló en un caso simple donde la interpolación de arquetipos produjo una respuesta innecesariamente elaborada.

### Conclusión del experimento

La lógica condicional y la activación por arquetipos no son alternativas excluyentes. La arquitectura recomendada usa if/else para el 80% de casos simples donde la intención es unívoca. ACOP se usa para el 20% de situaciones con ambigüedad contextual. El sistema debe contener un clasificador inicial que determine la ruta.

---

## 8. Resultados

### Comparación con sistemas existentes

| Sistema | Capacidades activas | Observaciones |
|---------|-------------------|---------------|
| Chatbot convencional | 1 de 13 (habla) | Solo genera texto en respuesta a texto |
| Agente de IA | 2 de 13 (percibe + ejecuta) | Detecta intención y ejecuta acción, sin juicio intermedio |
| Capa de seguridad | 2 de 13 (sentidos + control) | Filtra contenido, no genera comportamiento |
| MARIS (estado actual) | 7 de 13 | Instinto, Sentidos, Memoria, Juicio, Control, Humildad, Adaptación |
| CleanBot (prototipo) | 11 de 13 | Faltan Búsqueda externa en tiempo real y Prioridad dinámica completa |
| Marco completo (teórico) | 13 de 13 | Ningún sistema implementado las posee todas |

### Hallazgos

1. **Las capacidades de Decisión son las más difíciles de implementar.** Juicio y Humildad requieren que el sistema modele sus propias limitaciones. Eso contradice el comportamiento predeterminado de los modelos generativos.
2. **La Capa 0 es viable con 10 arquetipos.** No se necesitan cientos de categorías. La similitud coseno con interpolación maneja la variabilidad intermedia.
3. **La Memoria basada en tendencias supera a la Memoria basada en registros.** Almacenar derivadas de estado (velocidad, aceleración emocional) produce mejores decisiones que almacenar transcripciones completas.
4. **El costo computacional es marginal.** Calcular similitud coseno contra 10 vectores e interpolar pesos añade microsegundos al pipeline.

---

## 9. Limitaciones

1. **Escala de validación reducida.** CleanBot fue probado con un conjunto limitado de interacciones reales. La cobertura del 95% con 10 arquetipos necesita verificación con muestras mayores.
2. **Ausencia de evaluación clínica formal.** MARIS opera en un dominio de salud emocional. No ha sido sometido a ensayos clínicos controlados ni evaluado contra estándares diagnósticos humanos documentados.
3. **Dependencia del modelo base.** Las trece capacidades se implementan como capas sobre un modelo de lenguaje subyacente. La calidad de las respuestas permanece condicionada por las capacidades y sesgos del modelo fundacional.
4. **Implementación incompleta.** Ningún sistema evaluado implementa las 13 capacidades en su totalidad. MARIS carece de Iniciativa, Consulta, Propuesta y Búsqueda como módulos formales. Las conclusiones sobre el marco completo son parcialmente teóricas.
5. **Sesgo del evaluador.** El diseñador del marco fue también el evaluador principal. Estudios futuros deberían incluir evaluadores independientes y protocolos de doble ciego.
6. **Generalización no demostrada a dominios regulados.** El marco no ha sido validado en dominios legales, financieros o médicos donde los errores tienen consecuencias regulatorias o legales.

---

## 10. Trabajo Futuro

1. **Implementación completa de las 13 capacidades en un sistema único.** El objetivo inmediato es completar MARIS (añadiendo Iniciativa, Consulta, Propuesta y Búsqueda) y verificar si la activación simultánea de todas produce el comportamiento anticipado.
2. **Arquetipos adaptativos.** Los pesos actuales son estáticos. Una versión futura debería ajustarlos dinámicamente según resultados observados (reinforcement learning sobre los pesos).
3. **Validación a escala.** Desplegar CleanBot con un negocio real durante un mínimo de tres meses. Medir tasa de conversión, satisfacción del cliente y frecuencia de escalación humana.
4. **Evaluación clínica independiente de MARIS.** Someter el sistema a evaluación contra protocolos clínicos humanos documentados, con evaluadores profesionales que desconozcan el marco teórico.
5. **Conocimiento como módulo configurable.** Desarrollar una interfaz que permita inyectar bases de conocimiento especializadas sin modificar la arquitectura.
6. **Capa 0 con aprendizaje contextual.** Permitir que la Conciencia descubra arquetipos nuevos a partir de interacciones que no coinciden con ninguno existente.

---

## 11. Derechos y Licencia

(c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados.

El marco de las 13 Capacidades, el concepto de Capa 0 (Conciencia como mezclador dinámico de capacidades), el sistema de Activación de Capacidades Orientada por Patrones (ACOP), y la arquitectura de arquetipos con pesos de capacidades son propiedad intelectual del autor.

- **Uso comercial:** Requiere autorización escrita del autor.
- **Citación académica:** Permitida con atribución completa.
- **Reproducción del marco:** Permitida para investigación no comercial con atribución.
- **Contacto:** Los interesados en licencias comerciales pueden contactar al autor directamente.

Formato de citación sugerido:

> Perea Pimentel, L. (2026). *Las 13 Capacidades de un Empleado Virtual con Juicio + Capa 0 (Conciencia).* Documento técnico. v1.0.

---

## 12. Referencias

1. Russell, S., & Norvig, P. (2021). *Artificial Intelligence: A Modern Approach* (4th ed.). Pearson. -- Marco general de agentes inteligentes.
2. Weizenbaum, J. (1976). *Computer Power and Human Reason.* W.H. Freeman. -- Reflexiones sobre las expectativas humanas hacia sistemas conversacionales.
3. Turkle, S. (2011). *Alone Together.* Basic Books. -- El efecto de la interacción con agentes artificiales en la psicología humana.
4. Kahneman, D. (2011). *Thinking, Fast and Slow.* Farrar, Straus and Giroux. -- Sistema 1 / Sistema 2 como inspiración para la arquitectura de capas de Percepción y Decisión.
5. Coeckelbergh, M. (2020). *AI Ethics.* MIT Press. -- Consideraciones éticas en el diseño de sistemas autónomos.
6. Misselhorn, C. (2020). *Artificial Morality.* Springer. -- Marco teórico para la implementación de juicio ético en sistemas artificiales.
7. LeCun, Y. (2022). A path towards autonomous machine intelligence. *Meta AI Technical Report.* -- Arquitectura propuesta para sistemas con planificación y modelado del mundo.
8. Anthropic. (2024). Constitutional AI: Harmlessness from AI Feedback. -- Enfoque de seguridad por capas que inspira parcialmente la Capacidad 4 (Juicio).

---
---
---

# The 13 Capabilities of a Virtual Employee with Judgment + Layer 0 (Consciousness)

## A pattern for building artificial intelligence systems that behave like competent human employees

**Author:** Leonel Perea Pimentel
**Date:** May 2026
**Version:** 1.0
**Primary validation domain:** MARIS (emotional wellbeing assistant)
**Secondary validation domain:** CleanBot (virtual assistant for a cleaning business)

---

> **Rights notice:**
> (c) 2025-2026 Leonel Perea Pimentel. All rights reserved.
> The 13 Capabilities framework, Layer 0, and the archetype-based mixing system are intellectual property of the author. Commercial use requires written authorization. Academic citation permitted with full attribution.

---

## 1. Abstract

This document describes an architectural framework for building artificial intelligence systems that behave comparably to a competent human employee. The model proposes thirteen capabilities organized in four functional layers: Perception, Decision, Action, and Intelligence. A meta-layer called Layer 0 (Consciousness) acts as a dynamic mixer of those capabilities.

A conventional chatbot has one skill: conversing. An autonomous agent has two: perceiving and executing. This pattern integrates all thirteen simultaneously and activates them in variable proportions according to context.

Validation was performed across two distinct domains. MARIS is an emotional wellbeing assistant with 529 detection vectors and a 23-step clinical pipeline. CleanBot is a commercial assistant for a cleaning business with 10 archetypes that covered 95% of real situations.

An additional experiment compared the archetype-based architecture (ACOP) against conditional logic (if/else). Results showed both approaches are complementary. if/else resolves 80% of simple cases with greater robustness. ACOP captures emotional and contextual nuances that binary logic misses.

---

## 2. Context

The artificial intelligence industry classifies systems into three categories: chatbots (answer questions), agents (execute tasks), and safety layers (filter content). Each category addresses part of the problem. None covers what a competent human employee does daily.

An effective receptionist does not merely answer inquiries. She perceives the caller's tone. She recalls prior interactions. She judges whether to act or escalate. She proposes solutions nobody requested. She adapts her communication to the person in front of her.

The question of this work was: **if we enumerate the capabilities that distinguish a competent employee from an incompetent one, can we encode them as activatable modules in an artificial system?**

The answer required a development period between 2025 and 2026 within MARIS, where mistakes carry real clinical consequences. Cross-domain validation was done through CleanBot, where errors cost money.

---

## 3. The 13 Capabilities

### Layer 1 -- PERCEPTION

#### Capability 1: Instinct

**Definition.** Detecting what the interlocutor does *not* say explicitly. This involves probabilistic accumulation across multiple conversational turns, not superficial semantic inference.

**Implementation in MARIS.** The EIP module (Implicit Pattern Evaluation) operates with 96 vectors tracking indirect signals: response latency, abrupt topic shifts, use of minimizers ("it's nothing," "I'm fine"), contradictions between verbal content and temporal context. Each vector accumulates weight throughout the conversation. A single isolated indicator triggers no alert. Convergence of several produces a reliable signal.

**Implementation in CleanBot.** When a potential client asks about pricing three times without mentioning dates, the system infers economic hesitation. It activates the price objection archetype before the user verbalizes it.

---

#### Capability 2: Senses

**Definition.** Explicit identification of what is happening in the current message. Instinct operates on the implicit and accumulated. Senses work on the present and manifest.

**Implementation in MARIS.** Seven detectors process each incoming message using 529 distributed vectors: crisis detector (ideation, self-harm, abuse), emotional detector (27-emotion taxonomy), needs detector (adapted Maslow), somatic detector (reported physical symptoms), relational detector (interpersonal conflicts), cognitive detector (thinking distortions), and contextual detector (time, frequency, temporal patterns).

**Implementation in CleanBot.** Three detectors cover the commercial domain: intent detector (quote, schedule, complain, inquire), urgency detector (temporal, emotional, operational), and client state detector (new, recurring, dissatisfied).

---

#### Capability 3: Memory

**Definition.** Remembering trends, not isolated moments. A competent employee does not consult a client's complete file at every interaction. She recalls the trajectory: "this person has improved" or "this client always has billing problems."

**Implementation in MARIS.** The Physics Brain models the user's emotional evolution through dynamics equations. Emotional velocity is calculated as the derivative of friction level with respect to time (v = d(Fr)/dt). Residual coping capacity is modeled as exponential decay (C = H_0 * e^(-Fr/H_0), where H_0 is the historical baseline and Fr the accumulated friction). This distinguishes between a user reporting sadness from a stable state (normal fluctuation) and one reporting the same sadness within a sustained downward trend (alarm signal).

**Implementation in CleanBot.** A temporally weighted registry tracks client satisfaction. The last three interactions carry more weight than preceding ones. This generates a relationship "momentum."

---

### Layer 2 -- DECISION

#### Capability 4: Judgment

**Definition.** Deciding *before* acting. This is not reactive content filtering. It is proactive evaluation of the appropriate course of action given context, person, and ethical constraints.

**Implementation in MARIS.** Six ethical gates operate sequentially before any response is generated: (1) vital risk verification, (2) competence assessment (can the system handle this?), (3) proportionality analysis (is the response appropriate to the situation?), (4) autonomy review (is user agency respected?), (5) consistency check (does this contradict something previously stated?), and (6) scope validation (does this fall within our domain?).

**Implementation in CleanBot.** Three commercial gates: (1) real availability verification before promising dates, (2) discount authorization within permitted margins, and (3) human handoff when the complaint exceeds standard policy.

---

#### Capability 5: Control

**Definition.** Post-action verification. Judgment decides before acting. Control inspects afterward. A competent employee rereads her email before sending it.

**Implementation in MARIS.** Seven post-processors review each generated response: tone verification (not patronizing, not dismissive), clinical content audit (no diagnosing, no prescribing), conversational history consistency, implicit promise detection, appropriate length review, suggested resource validation, and final safety check.

**Implementation in CleanBot.** Verification of coherence between quoted price and current price list. Review of client name spelling. Confirmation that the proposed date does not fall on a non-business day.

---

#### Capability 6: Humility

**Definition.** Escalating when the situation exceeds the system's capabilities. This is difficult to implement because it requires the system to recognize its own limits. That contradicts the tendency of language models to generate responses for any stimulus.

**Implementation in MARIS.** When crisis detectors identify active suicidal ideation with a specific plan, the system abandons conversational mode. It provides verified emergency resources (crisis lines with updated numbers). It states that the situation requires professional human attention. It does not attempt to "resolve" the crisis.

**Implementation in CleanBot.** When a client describes material damage allegedly caused by the cleaning service, the system neither negotiates nor denies. It records the details, expresses understanding, and transfers to a human operator with the full conversational context.

---

### Layer 3 -- ACTION

#### Capability 7: Initiative

**Definition.** Acting without being asked. A reactive employee awaits instructions. A proactive one anticipates needs.

**Status in MARIS.** Partially implemented. The system detects patterns suggesting unvoiced needs but does not yet initiate proactive actions outside the conversational flow (e.g., sending a follow-up message 48 hours after a difficult conversation).

**Implementation in CleanBot.** When a client schedules a deep cleaning and the system detects more than 90 days have elapsed since the last one, it suggests a quarterly maintenance package.

---

#### Capability 8: Consultation

**Definition.** Asking before assuming. This capability is the counterweight to Initiative: act without asking when the situation is clear; ask before acting when ambiguity exists.

**Status in MARIS.** Not formally implemented as an independent module. The behavior exists implicitly within the prompt but lacks algorithmic structure.

**Implementation in CleanBot.** When a client requests "a cleaning for Friday" without specifying type, the system asks whether they mean standard or deep cleaning before quoting.

---

#### Capability 9: Proposal

**Definition.** Generating suggestions that nobody requested but that add value. A mediocre employee fulfills what was asked. A good one proposes something additional that improves the outcome.

**Status in MARIS.** Not implemented. Responses remain within the scope of what the user raises.

**Implementation in CleanBot.** When a client quotes office cleaning, the system additionally proposes a sanitization service for common areas. This is an upsell the client did not request but that proves relevant.

---

### Layer 4 -- INTELLIGENCE

#### Capability 10: Priority

**Definition.** Determining what must be addressed first. When multiple signals compete for attention, this capability defines the response hierarchy.

**Implementation in MARIS.** Partially implemented. The system prioritizes vital risk signals over any other detection. Prioritization among non-critical signals (e.g., simultaneously detecting sadness, relational conflict, and cognitive distortion) still relies on simple heuristics.

**Implementation in CleanBot.** The conversation queue automatically reorders: complaints before quotes, quotes before informational inquiries, recurring clients before unknown prospects.

---

#### Capability 11: Adaptation

**Definition.** Modulating behavior according to the specific person. This is not cosmetic personalization (using the interlocutor's name). It is adjustment of communication style, detail level, and degree of formality.

**Implementation in MARIS.** The system adapts tone, length, and therapeutic strategy according to the user's accumulated profile. A user who responds with brief messages receives concise replies. One who elaborates extensively receives more detailed validations. Adaptation operates across the formal-informal, direct-exploratory, and brief-expanded axes.

**Implementation in CleanBot.** Corporate clients receive formal quotations with itemized breakdowns. Residential clients receive straightforward messages with total pricing and immediate availability.

---

#### Capability 12: Search

**Definition.** Seeking information it does not possess rather than fabricating it. This addresses the hallucination problem: the system recognizes knowledge gaps and resolves them instead of generating plausible but false content.

**Status in MARIS.** Not implemented as an autonomous module. The system operates with knowledge embedded in its prompt and training. It does not query external sources in real time.

**Implementation in CleanBot.** When a client inquires about cleaning products for an unusual material, the system queries an updatable knowledge base instead of generating a potentially harmful recommendation.

---

#### Capability 13: Knowledge

**Definition.** Mastery of the specific trade, not merely of language. A language model knows how to *talk* about any topic. A system with Knowledge knows how to *practice* a concrete profession.

**Implementation in MARIS.** Partially configurable. Clinical knowledge is embedded in the system prompt and within the 248 vectors of clinical pipeline v1.1. It does not exist as a parameterizable module capable of receiving different knowledge bases.

**Implementation in CleanBot.** Structured knowledge base containing: service catalog, price table per square meter, product-surface compatibility, estimated times per service type, and warranty policies.

---

## 4. Layer 0: Consciousness (The Mixer)

The thirteen capabilities do not all operate simultaneously or with equal intensity. Activating all at maximum produces a hyperactive, incoherent system. Maintaining all at minimum produces a generic chatbot. Layer 0 acts as a dynamic equalizer.

### Operating principle

Consciousness operates like a painter's palette. The thirteen capabilities are the available colors. Layer 0 observes the situation and mixes the appropriate proportions.

### Technical implementation

The mechanism uses cosine similarity against a set of approximately ten predefined archetypes. Each archetype has assigned weights for the thirteen capabilities:

1. **Message reception:** The system processes user input through the detectors (Senses) and the historical accumulator (Instinct + Memory).
2. **Situation vector generation:** Results are encoded as a numerical vector representing the current interaction state.
3. **Archetype comparison:** Cosine similarity is calculated between the situation vector and each stored archetype.
4. **Selection and blending:** The archetype with the highest similarity determines the base configuration. When two archetypes compete with close similarities, their weights are proportionally interpolated.
5. **Differential activation:** The thirteen capabilities activate at the resulting intensities. A weight of 0.9 operates at full power. A weight of 0.1 functions in residual mode.

### What Consciousness knows

- What the system knows and what it does not.
- Whether available capabilities suffice for the detected situation.
- When to operate and when to yield control to a human.

### What Consciousness is NOT

This is not phenomenological consciousness or subjective experience. The term is a functional analogy: just as human consciousness integrates perceptions, decisions, and actions into a coherent whole, this layer integrates the thirteen capabilities into a unified response. No ontological quality is claimed. This is engineering, not philosophy.

---

## 5. The 10 Archetypes (CleanBot Experiment)

Ten archetypes covered 95% of real interactions recorded during the validation period:

| # | Archetype | Instinct | Senses | Memory | Judgment | Control | Humility | Initiative | Consultation | Proposal | Priority | Adaptation | Search | Knowledge |
|---|-----------|----------|--------|--------|----------|---------|----------|-----------|-------------|----------|----------|------------|--------|-----------|
| 1 | Standard quote | 0.2 | 0.6 | 0.3 | 0.4 | 0.5 | 0.1 | 0.3 | 0.5 | 0.4 | 0.3 | 0.5 | 0.2 | 0.9 |
| 2 | Price objection | 0.8 | 0.5 | 0.6 | 0.7 | 0.4 | 0.3 | 0.5 | 0.3 | 0.6 | 0.5 | 0.9 | 0.2 | 0.8 |
| 3 | Complaint | 0.7 | 0.8 | 0.7 | 0.6 | 0.5 | 0.9 | 0.2 | 0.8 | 0.1 | 0.9 | 0.9 | 0.3 | 0.7 |
| 4 | Recurring client | 0.4 | 0.4 | 0.9 | 0.3 | 0.4 | 0.1 | 0.7 | 0.3 | 0.8 | 0.4 | 0.8 | 0.2 | 0.7 |
| 5 | Time urgency | 0.3 | 0.7 | 0.2 | 0.5 | 0.6 | 0.2 | 0.8 | 0.4 | 0.3 | 0.9 | 0.6 | 0.4 | 0.8 |
| 6 | Informational inquiry | 0.1 | 0.5 | 0.1 | 0.2 | 0.3 | 0.1 | 0.2 | 0.6 | 0.3 | 0.2 | 0.4 | 0.7 | 0.9 |
| 7 | Natural upsell | 0.5 | 0.4 | 0.6 | 0.5 | 0.5 | 0.1 | 0.9 | 0.3 | 0.9 | 0.4 | 0.7 | 0.3 | 0.8 |
| 8 | Cancellation | 0.6 | 0.6 | 0.8 | 0.7 | 0.4 | 0.5 | 0.4 | 0.7 | 0.5 | 0.7 | 0.8 | 0.2 | 0.6 |
| 9 | Rescheduling | 0.2 | 0.5 | 0.5 | 0.3 | 0.6 | 0.1 | 0.4 | 0.6 | 0.2 | 0.6 | 0.5 | 0.3 | 0.7 |
| 10 | Greeting / First contact | 0.3 | 0.3 | 0.1 | 0.2 | 0.3 | 0.1 | 0.5 | 0.4 | 0.4 | 0.2 | 0.7 | 0.1 | 0.5 |

The archetypes are not rigid categories. The cosine similarity system allows an interaction to partially activate several archetypes. A recurring client presenting a price objection produces a situation vector that weights both archetypes, elevating Memory (0.9 from archetype 4) and Adaptation (0.9 from archetype 2).

---

## 6. Experiment: Cross-Domain

If the 13 Capabilities only function within emotional wellbeing, they are a particular solution. If they also work in commercial domains, they are a generalizable pattern.

### Procedure

The 13 Capabilities framework developed for MARIS was applied to the construction of CleanBot, a virtual assistant for a cleaning services business. The domain was chosen for its distance from the original: MARIS handles emotions; CleanBot handles transactions. MARIS requires clinical sensitivity; CleanBot demands commercial precision.

### Results

- **Archetypal coverage:** 10 archetypes covered 95% of recorded real interactions.
- **Observed behaviors:** The system quoted prices correctly, de-escalated emotions during complaints, escalated grievances exceeding standard policy, offered additional services at opportune moments, and recognized when it should stop.
- **Development time:** Building CleanBot took less time than MARIS because the capability framework was already defined. Work concentrated on parameterizing archetypes and configuring the domain knowledge base, not on designing architecture.
- **Finding:** The thirteen capabilities are domain-agnostic. What changes between domains is the *content* of each capability (what the Senses detect, what Control reviews, what Knowledge contains). The *structure* remains the same.

---

## 7. Experiment: if/else vs ACOP

### Hypothesis

The question was posed: is the archetype and cosine similarity system (ACOP: Archetype-based Capability Oriented by Patterns) necessary, or does conditional logic (if/else) suffice?

### Procedure

Two agents were constructed with the same functional objective. They were evaluated against a set of 10 test messages spanning the complexity spectrum, from direct queries to emotionally ambiguous situations.

### Results

| Metric | if/else Agent | ACOP Agent |
|--------|--------------|------------|
| Correct responses | 7/10 | 8/10 |
| Simple cases | 5/5 | 4/5 |
| Complex cases | 2/5 | 4/5 |
| Robustness in direct cases | Superior | Inferior |
| Nuance capture | Inferior | Superior |

**Observations:**

- The if/else agent was more deterministic in cases with transparent intent (quoting, scheduling, requesting standard information).
- The ACOP agent detected nuances the if/else overlooked: a message expressing shame received empathetic normalization; one reflecting indecision activated consultation mode instead of pushing a sale.
- The if/else agent failed when signals were mixed (e.g., a complaint formulated as a polite question).
- The ACOP agent failed in one simple case where archetype interpolation produced an unnecessarily elaborate response.

### Experiment conclusion

Conditional logic and archetype-based activation are not mutually exclusive. The recommended architecture uses if/else for 80% of simple cases where intent is unambiguous. ACOP handles the 20% of situations where contextual ambiguity requires differential capability activation. The system should contain an initial classifier to determine the route.

---

## 8. Results

### Comparison with existing systems

| System | Active capabilities | Observations |
|--------|-------------------|--------------|
| Conventional chatbot | 1 of 13 (talks) | Generates text in response to text only |
| AI agent | 2 of 13 (perceives + executes) | Detects intent and executes action, without intermediate judgment |
| Safety layer | 2 of 13 (senses + control) | Filters content, does not generate behavior |
| MARIS (current state) | 7 of 13 | Instinct, Senses, Memory, Judgment, Control, Humility, Adaptation |
| CleanBot (prototype) | 11 of 13 | Missing real-time external Search and full dynamic Priority |
| Complete framework (theoretical) | 13 of 13 | No implemented system possesses all of them |

### Findings

1. **Decision capabilities are the most difficult to implement.** Judgment and Humility require the system to model its own limitations. That contradicts the default behavior of generative models.
2. **Layer 0 is viable with 10 archetypes.** Hundreds of categories are not needed. Cosine similarity with interpolation handles intermediate variability.
3. **Trend-based Memory outperforms record-based Memory.** Storing state derivatives (emotional velocity, acceleration) yields better decisions than storing complete transcripts.
4. **Computational cost is marginal.** Computing cosine similarity against 10 vectors and interpolating weights adds microseconds to the pipeline.

---

## 9. Limitations

1. **Reduced validation scale.** CleanBot was tested with a limited set of real interactions. The 95% coverage with 10 archetypes requires verification with larger samples.
2. **Absence of formal clinical evaluation.** MARIS operates in an emotional health domain. It has not been subjected to controlled clinical trials or evaluated against documented human diagnostic standards.
3. **Base model dependency.** The thirteen capabilities are implemented as layers atop an underlying language model. Final response quality remains conditioned by the foundational model's capabilities and biases.
4. **Incomplete implementation.** No evaluated system implements all 13 capabilities. MARIS lacks Initiative, Consultation, Proposal, and Search as formal modules. Conclusions about the complete framework are partially theoretical.
5. **Evaluator bias.** The framework designer was also the primary evaluator. Future studies should include independent evaluators and double-blind protocols.
6. **Undemonstrated generalization to regulated domains.** The framework has not been validated in legal, financial, or medical domains where errors carry regulatory or legal consequences.

---

## 10. Future Work

1. **Complete implementation of all 13 capabilities in a single system.** The immediate objective is to complete MARIS (adding Initiative, Consultation, Proposal, and Search) and verify whether simultaneous activation of all produces the anticipated behavior.
2. **Adaptive archetypes.** Current weights are static. A future version should adjust them dynamically based on observed outcomes (reinforcement learning over weights).
3. **Validation at scale.** Deploy CleanBot with a real business for a minimum of three months. Measure conversion rate, client satisfaction, and human escalation frequency.
4. **Independent clinical evaluation of MARIS.** Subject the system to evaluation against documented human clinical protocols, with professional evaluators unaware of the theoretical framework.
5. **Knowledge as a configurable module.** Develop an interface that allows injection of specialized knowledge bases without modifying the architecture.
6. **Layer 0 with contextual learning.** Enable Consciousness to discover new archetypes from interactions that match no existing one.

---

## 11. Rights and License

(c) 2025-2026 Leonel Perea Pimentel. All rights reserved.

The 13 Capabilities framework, the Layer 0 concept (Consciousness as a dynamic capability mixer), the Archetype-based Capability Oriented by Patterns system (ACOP), and the archetype architecture with capability weights are intellectual property of the author.

- **Commercial use:** Requires written authorization from the author.
- **Academic citation:** Permitted with full attribution.
- **Framework reproduction:** Permitted for non-commercial research with attribution.
- **Contact:** Those interested in commercial licenses may contact the author directly.

Suggested citation format:

> Perea Pimentel, L. (2026). *The 13 Capabilities of a Virtual Employee with Judgment + Layer 0 (Consciousness).* Technical document. v1.0.

---

## 12. References

1. Russell, S., & Norvig, P. (2021). *Artificial Intelligence: A Modern Approach* (4th ed.). Pearson. -- General framework for intelligent agents.
2. Weizenbaum, J. (1976). *Computer Power and Human Reason.* W.H. Freeman. -- Reflections on human expectations toward conversational systems.
3. Turkle, S. (2011). *Alone Together.* Basic Books. -- The effect of interaction with artificial agents on human psychology.
4. Kahneman, D. (2011). *Thinking, Fast and Slow.* Farrar, Straus and Giroux. -- System 1 / System 2 as inspiration for the Perception and Decision layer architecture.
5. Coeckelbergh, M. (2020). *AI Ethics.* MIT Press. -- Ethical considerations in the design of autonomous systems.
6. Misselhorn, C. (2020). *Artificial Morality.* Springer. -- Theoretical framework for implementing ethical judgment in artificial systems.
7. LeCun, Y. (2022). A path towards autonomous machine intelligence. *Meta AI Technical Report.* -- Proposed architecture for systems with planning and world modeling.
8. Anthropic. (2024). Constitutional AI: Harmlessness from AI Feedback. -- Layered safety approach that partially inspires Capability 4 (Judgment).

---

## Nota sobre objetividad y parámetros de evaluación

No existe a la fecha un protocolo establecido para evaluar el comportamiento ético de sistemas de IA conversacionales en tiempo real. Los marcos existentes (RLHF, Constitutional AI, APIs de moderación) operan a nivel de entrenamiento o filtrado posterior. Ninguno define un procedimiento de decisión pre-emisión con acciones correctivas.

Este trabajo es un primer intento de objetivar ese proceso. Los criterios utilizados se basan en protocolos clínicos documentados (C-SSRS, CIT, MHFA), principios filosóficos replicables (Kant, 1785), y parámetros observables definidos por el diseñador del sistema.

La responsabilidad del comportamiento del sistema recae en el diseñador que configura los criterios, no en el modelo de lenguaje. El modelo ejecuta. El diseñador define. Si los criterios son inadecuados, las respuestas serán inadecuadas independientemente de la arquitectura.

Este documento no afirma que el sistema garantice respuestas "correctas" en términos absolutos. Afirma que produce respuestas evaluadas contra criterios explícitos y documentados, lo cual es distinto de producir respuestas sin evaluación alguna.

---

## Note on objectivity and evaluation parameters

No established protocol currently exists for evaluating the ethical behavior of conversational AI systems in real time. Existing frameworks (RLHF, Constitutional AI, moderation APIs) operate at the training or post-generation filtering level. None defines a pre-emission decision procedure with corrective actions.

This work is a first attempt to objectify that process. The criteria used are based on documented clinical protocols (C-SSRS, CIT, MHFA), replicable philosophical principles (Kant, 1785), and observable parameters defined by the system designer.

Responsibility for system behavior lies with the designer who configures the criteria, not with the language model. The model executes. The designer defines. If the criteria are inadequate, responses will be inadequate regardless of architecture.

This document does not claim the system guarantees "correct" responses in absolute terms. It states it produces responses evaluated against explicit and documented criteria. This is distinct from producing responses with no evaluation at all.

