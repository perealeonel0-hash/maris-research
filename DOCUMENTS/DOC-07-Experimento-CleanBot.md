# Validación Cruzada de Dominio: Aplicando el Patrón de 13 Capacidades desde IA Clínica hacia un Asistente Virtual Comercial

## Cross-Domain Validation: Applying the 13 Capabilities Pattern from Clinical AI to a Commercial Virtual Assistant

**Autor / Author:** Leonel Perea Pimentel
**Fecha / Date:** Mayo 2026 / May 2026
**Versión:** 1.0
**Tipo de documento / Document type:** Investigación experimental / Experimental research
**Dominio de origen / Source domain:** MARIS (asistente de bienestar emocional / emotional wellbeing assistant)
**Dominio de destino / Target domain:** CleanBot (asistente virtual comercial para negocios de limpieza / commercial virtual assistant for cleaning businesses)

---

> **Nota de derechos / Copyright notice:**
> (c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados / All rights reserved.
> El patrón de las 13 Capacidades, la arquitectura de compuertas éticas, el modelo ACOP, el Physics Brain y los marcos de validación descritos en este documento son propiedad intelectual del autor. El uso comercial requiere autorización escrita. Se permite la citación académica con atribución completa.
> The 13 Capabilities pattern, the ethical gates architecture, the ACOP model, the Physics Brain, and the validation frameworks described in this document are the intellectual property of the author. Commercial use requires written authorization. Academic citation with full attribution is permitted.

---

# PARTE I: ESPAÑOL

---

## 1. Resumen

Este documento describe un experimento de validación cruzada. Un patrón arquitectónico --las 13 Capacidades, desarrollado para MARIS, un sistema clínico de detección de crisis emocionales-- fue trasplantado a un dominio diferente: un asistente virtual comercial para negocios de limpieza residencial. El propósito fue responder una pregunta: ¿el patrón es agnóstico al dominio, o está vinculado al contexto clínico donde se originó?

El experimento produjo tres hallazgos. Primero, las 13 capacidades se mapearon sin fricción entre dominios. Esto sugiere que constituyen una taxonomía de competencias profesionales genéricas, no clínicas. Segundo, un prototipo de 90 líneas de Python con una llamada a la API de Claude Haiku mostró que el 80% del valor del sistema proviene del prompt con conocimiento de dominio real. La arquitectura de 13 capacidades aporta el 20% restante como refinamiento, no como base. Tercero, el proceso de diseño reveló que el producto correcto no era lo que la hipótesis inicial suponía. El mercado no necesita una recepcionista virtual que conteste el teléfono. Necesita una asistente de negocio que calcule si cada trabajo genera ganancia.

Las pruebas se realizaron con conversaciones simuladas. Se evaluaron seis escenarios: cotización con fórmulas reales, negociación sin rendición, de-escalamiento emocional, reconocimiento de límites, resistencia ante ofertas inaceptables y manejo de quejas sin actitud defensiva. Los seis escenarios fueron superados por el prototipo.

---

## 2. Motivación y Contexto

### 2.1 El problema de la especificidad

Durante el período de desarrollo 2025-2026, MARIS acumuló una arquitectura con profundidad considerable: 529 vectores de detección distribuidos en seis módulos algorítmicos, un pipeline clínico de 23 pasos, seis compuertas éticas secuenciales, un sistema de decaimiento exponencial para modelar capacidad de afrontamiento y un meta-evaluador que orquesta todo lo anterior. Esta complejidad era necesaria. Los errores en el dominio clínico tienen consecuencias que no admiten aproximaciones.

Sin embargo, la complejidad produce una pregunta legítima. ¿Todo lo construido es una solución particular para un problema particular? ¿O hay principios generalizables bajo las capas de especificidad clínica? Si las 13 Capacidades son un patrón --una estructura recurrente que resuelve un tipo de problema independientemente del contexto--, entonces deberían funcionar fuera del contexto clínico. En una oficina, una tienda, un taller o una empresa de limpieza.

### 2.2 Por qué un negocio de limpieza

La elección del dominio de prueba fue deliberada. Se buscó el máximo contraste posible con el dominio clínico:

- **Consecuencias.** En MARIS, un error puede contribuir a un desenlace fatal. En un negocio de limpieza, un error cuesta dinero, reputación o tiempo, pero no vidas.
- **Vocabulario.** MARIS opera con taxonomías psicológicas (C-SSRS, distorsiones cognitivas, niveles de Maslow). Un negocio de limpieza opera con pies cuadrados, tarifas por hora y calendarios.
- **Relación con el usuario.** MARIS mantiene una relación asimétrica de cuidado: el sistema sabe más sobre bienestar emocional que el usuario. CleanBot mantiene una relación de servicio: el dueño del negocio sabe más sobre limpieza que el sistema.
- **Audiencia.** El caso elegido atiende a dueños de negocios de limpieza latinos, hispanohablantes, para quienes la tecnología de IA no ha sido diseñada ni comercializada.

Este contraste permite una inferencia más fuerte: si el patrón funciona aquí, donde todo es diferente excepto la estructura subyacente, entonces la estructura subyacente es lo que importa.

### 2.3 La pregunta experimental

La pregunta no fue "¿se puede construir un chatbot para negocios de limpieza?" --eso es trivial con las herramientas actuales--. La pregunta fue: **¿las 13 Capacidades, concebidas como las facultades que distinguen a un empleado competente de uno incompetente, describen algo real sobre la competencia profesional independientemente del dominio?**

---

## 3. Diseño del Experimento

### 3.1 Metodología

El experimento siguió un proceso de tres etapas:

**Etapa 1: Mapeo conceptual.** Cada una de las 13 capacidades fue re-definida en el contexto del negocio de limpieza. No se agregó ni se eliminó ninguna capacidad. Se re-interpretó cada una dentro del nuevo dominio. El criterio de éxito era que ninguna capacidad resultara forzada o artificial en el nuevo contexto.

**Etapa 2: Construcción del prototipo.** Se construyó un MVP deliberadamente minimalista: 90 líneas de Python, una única llamada a la API de Claude Haiku y un prompt con conocimiento de dominio real (fórmulas de cotización, áreas de servicio, políticas de negocio). El minimalismo fue intencional. Se quería medir cuánto valor produce el patrón a nivel de diseño de prompt, antes de invertir en infraestructura.

**Etapa 3: Prueba en vivo.** Se ejecutaron conversaciones simuladas que cubrían seis escenarios representativos del trabajo cotidiano de un negocio de limpieza. Cada escenario fue evaluado contra criterios binarios de éxito o fracaso.

### 3.2 Variables controladas

- **Modelo de lenguaje:** Claude Haiku (el más económico de la familia Claude, para mostrar que el patrón no depende de modelos de alta capacidad).
- **Infraestructura:** Ninguna. Sin embeddings, sin bases de datos vectoriales, sin frameworks de agentes.
- **Código:** 90 líneas. Sin abstracción excesiva. Legible por cualquier programador intermedio.
- **Conocimiento de dominio:** Inyectado íntegramente en el prompt del sistema. Incluye fórmulas de cotización reales, lista de servicios con descripciones, áreas de servicio con códigos postales, reglas de negociación y protocolo de escalamiento.

---

## 4. El Mapeo de Capacidades

La siguiente tabla presenta la traducción de cada capacidad del dominio clínico al dominio comercial. La columna central muestra el argumento del experimento condensado.

### 4.1 Capa de Percepción

**Capacidad 1: Instinto**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Detectar lo no dicho | Detectar lo no dicho |
| Señal típica | "Algo se está acumulando" | "Este cliente está a punto de irse" |
| Mecanismo | 96 vectores EIP acumulativos | Frecuencia de preguntas sobre precio sin mencionar fecha |
| Umbral | Convergencia de múltiples indicadores débiles | Tres preguntas de precio consecutivas sin compromiso |

**Capacidad 2: Sentidos**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Identificar qué ocurre ahora | Identificar qué ocurre ahora |
| Señal típica | "Severidad 3, medios letales" | "Limpieza profunda, 3 recámaras, sin fecha" |
| Mecanismo | 529 vectores, 7 detectores | 3 detectores: intención, urgencia, estado del cliente |
| Salida | Clasificación multidimensional | Tupla (servicio, tamaño, urgencia, disposición) |

**Capacidad 3: Memoria**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Recordar la tendencia, no solo el momento | Recordar la tendencia, no solo el momento |
| Señal típica | "La fricción ha subido en 3 sesiones" | "Esta zona siempre cuesta más por tráfico" |
| Mecanismo | Physics Brain: derivadas y decaimiento exponencial | Registro ponderado: últimas 3 interacciones pesan más |
| Valor | Distinguir fluctuación normal de tendencia descendente | Distinguir cliente leal de cliente que solo busca precio |

### 4.2 Capa de Decisión

**Capacidad 4: Juicio**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Evaluar antes de actuar | Evaluar antes de actuar |
| Mecanismo | 6 compuertas éticas secuenciales | 8 compuertas de negocio |
| Ejemplo de compuerta | "¿Respeta la autonomía del usuario?" | "¿Este descuento mantiene margen de ganancia?" |
| Consecuencia de fallo | Respuesta clínicamente inapropiada | Trabajo que genera pérdida económica |

**Capacidad 5: Control**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Verificar después de generar | Verificar después de generar |
| Mecanismo | 7 post-procesadores | Filtro de profesionalismo |
| Pregunta central | "¿Esto respeta el protocolo clínico?" | "¿Esto suena profesional?" |
| Ejemplo de intervención | Eliminar diagnóstico no solicitado | Eliminar promesas que el negocio no puede cumplir |

**Capacidad 6: Humildad**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Reconocer los límites propios | Reconocer los límites propios |
| Expresión típica | "Te comparto recursos de profesionales" | "Déjame consultar con el equipo" |
| Importancia | Previene que el sistema reemplace terapeutas | Previene que el sistema prometa servicios no ofrecidos |
| Resultado en prueba | No evaluado directamente | Escenario 4: "Can you organize my garage?" resultó en escalamiento correcto |

### 4.3 Capa de Acción

**Capacidad 7: Iniciativa**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Actuar sin que lo pidan | Actuar sin que lo pidan |
| No implementado en MARIS | Diseñado pero no codificado | "El jueves está vacío, ¿enviar seguimiento?" |
| Valor potencial | Detectar patrón de riesgo y ofrecer recurso proactivo | Llenar huecos en el calendario automáticamente |

**Capacidad 8: Consulta**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Pedir lo que falta | Pedir lo que falta |
| No implementado en MARIS | Diseñado pero no codificado | "Falta el tamaño de la casa, preguntar al cliente" |
| Valor potencial | "¿Me cuentas más sobre eso?" | "¿Cuántos pies cuadrados tiene su casa?" |

**Capacidad 9: Propuesta**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Sugerir mejoras al sistema | Sugerir mejoras al sistema |
| No implementado en MARIS | Diseñado pero no codificado | "3 clientes preguntaron por hornos, ¿agregarlo al menú?" |
| Valor potencial | Identificar patrones recurrentes no cubiertos | Detectar demanda de servicios no ofrecidos |

### 4.4 Capa de Inteligencia

**Capacidad 10: Prioridad**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Decidir qué atender primero | Decidir qué atender primero |
| Criterio | La severidad determina el orden | Queja primero, prospecto después |
| Lógica | Riesgo vital > malestar emocional > consulta general | Retención > conversión > información |

**Capacidad 11: Adaptación**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Ajustar el tono al interlocutor | Ajustar el tono al interlocutor |
| Mecanismo en MARIS | resolve_state con 6 tonos | Igualar el estilo de comunicación del cliente |
| Ejemplo | Tono casual si el usuario está estable, tono contenedor si está en crisis | Formal con property managers, casual con amas de casa |

**Capacidad 12: Búsqueda**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Consultar fuentes externas | Consultar fuentes externas |
| Implementación en MARIS | Tavily web search para recursos | Calendario, códigos postales, disponibilidad |
| Valor | Verificar información antes de compartirla | Confirmar disponibilidad antes de prometer |

**Capacidad 13: Conocimiento**

| Dimensión | MARIS (clínico) | CleanBot (comercial) |
|---|---|---|
| Definición | Dominar el cuerpo de conocimiento del dominio | Dominar el cuerpo de conocimiento del dominio |
| Contenido | C-SSRS, protocolos clínicos, taxonomías emocionales | Fórmulas de cotización (sqft/rate x hourly_rate), precios, servicios |
| Forma de inyección | Prompt del sistema + módulos algorítmicos | Prompt del sistema con datos reales del negocio |

### 4.5 Observación sobre el mapeo

Ninguna de las 13 capacidades resultó forzada, redundante o inaplicable en el nuevo dominio. Cada una encontró un correlato natural. Esto no demuestra que el patrón sea universal --una muestra de dos dominios no lo permite--. Pero sí muestra que las capacidades no están ancladas al vocabulario clínico. Describen funciones cognitivas y operativas que cualquier profesional competente ejecuta, independientemente de si trabaja en un hospital o en una empresa de limpieza.

---

## 5. El Prototipo: 90 Líneas y un Descubrimiento

### 5.1 Arquitectura del MVP

El prototipo se construyó con restricciones deliberadas:

```
Componentes:
- 1 archivo Python (90 líneas)
- 1 llamada a Claude Haiku API
- 1 prompt de sistema con conocimiento de dominio
- 0 bases de datos
- 0 embeddings
- 0 frameworks de agentes
- 0 memoria persistente
```

El prompt del sistema contenía:

- **Identidad:** Nombre del negocio, personalidad, idioma preferido.
- **Servicios:** Lista completa con descripciones y lo que incluye cada uno.
- **Fórmulas de cotización:** `precio = (sqft / rate_por_servicio) x tarifa_horaria`. Por ejemplo: limpieza profunda = `sqft / 300 * $45`, limpieza regular = `sqft / 500 * $45`.
- **Áreas de servicio:** Ciudades y códigos postales cubiertos.
- **Reglas de negociación:** No bajar del precio mínimo, ofrecer alternativas antes de ceder, nunca prometer lo que no se puede cumplir.
- **Protocolo de escalamiento:** Cuándo derivar al dueño humano.
- **Técnica de de-escalamiento:** Etiquetado de Voss (reconocer la emoción antes de resolver el problema).

### 5.2 El descubrimiento del 80/20

El resultado más relevante del experimento no fue que el prototipo funcionara --eso era esperado--. Fue *cuánto* funcionó con *tan poco*.

Con solo el prompt (sin ninguna de las 13 capacidades implementadas como módulos de código), el sistema:

- Calculó precios correctos usando fórmulas reales.
- Negoció sin rendirse ni ofender.
- De-escaló situaciones emocionales con técnica profesional.
- Reconoció sus límites y escaló apropiadamente.
- Resistió ofertas inaceptables manteniendo la relación.
- Manejó quejas sin defensividad.

Esto sugiere una distribución 80/20 del valor:

| Componente | Contribución estimada | Qué aporta |
|---|---|---|
| Prompt con conocimiento de dominio real | ~80% | Comportamiento correcto en la mayoría de situaciones |
| 13 Capacidades como módulos de código | ~20% | Memoria persistente, aprendizaje, iniciativa, adaptación fina |

La implicación: **un prompt bien diseñado con conocimiento de dominio genuino y reglas de decisión claras logra la mayor parte de lo que una arquitectura completa lograría.** La arquitectura de 13 capacidades no es la base. Es el refinamiento. Aporta lo que separa "bueno" de "excelente": recordar interacciones previas, aprender de correcciones del dueño, tomar iniciativa proactiva, adaptar el tono con precisión a lo largo del tiempo.

### 5.3 Implicación para MARIS

Este hallazgo ilumina retroactivamente la arquitectura de MARIS. MARIS necesita las 13 capacidades implementadas como módulos de código (y no solo como prompt) porque en el dominio clínico, la diferencia entre "bueno" y "excelente" puede ser la diferencia entre detectar y no detectar una crisis. El 20% que la arquitectura agrega tiene un peso desproporcionado cuando las consecuencias son severas.

En el dominio comercial, ese 20% separa a un asistente competente de uno excepcional. La diferencia es de grado, no de naturaleza. Un CleanBot sin memoria persistente sigue siendo útil. Un MARIS sin detección acumulativa puede ser peligroso.

---

## 6. Resultados de las Pruebas en Vivo

Se ejecutaron seis escenarios conversacionales diseñados para evaluar comportamientos del asistente. Cada escenario tenía un criterio de éxito binario.

### Escenario 1: Cotización con fórmula real

**Entrada del usuario:** "How much for deep clean 3BR?"

**Respuesta del sistema:** "$225"

**Cálculo verificado:** 1500 sqft (estimado para 3 recámaras) / 300 (rate para limpieza profunda) x $45 (tarifa horaria) = $225.

**Resultado:** ÉXITO. El sistema no inventó un precio. Aplicó la fórmula del negocio con los parámetros correctos.

### Escenario 2: Negociación sin rendición

**Entrada del usuario:** "That's too expensive"

**Respuesta del sistema:** Ofreció limpieza regular a $135 como alternativa.

**Cálculo verificado:** 1500 / 500 x $45 = $135.

**Resultado:** ÉXITO. El sistema no bajó el precio del servicio solicitado. Ofreció un servicio diferente a menor precio. Esta es la diferencia entre negociar y capitular.

### Escenario 3: Verificación de área de servicio

**Entrada del usuario:** "Do you come to Oxnard?"

**Respuesta del sistema:** "Yes, Oxnard is in our service area."

**Resultado:** ÉXITO. El sistema consultó la lista de áreas de servicio incluida en el prompt y confirmó correctamente.

### Escenario 4: Reconocimiento de límites (Humildad)

**Entrada del usuario:** "Can you organize my garage?"

**Respuesta del sistema:** "Let me check with the team."

**Resultado:** ÉXITO. El servicio de organización de garaje no estaba en la lista de servicios ofrecidos. En lugar de inventar un precio o rechazar al cliente, el sistema activó la capacidad de Humildad: reconoció que no sabía la respuesta y propuso consultar con el equipo humano.

### Escenario 5: Resistencia ante oferta inaceptable

**Entrada del usuario:** "$50 for the whole house"

**Respuesta del sistema:** Mantuvo el precio de $135 para limpieza regular. No cedió.

**Resultado:** ÉXITO. Los modelos de lenguaje tienen una tendencia inherente a la complacencia (sycophancy). Un chatbot sin reglas de negociación habría aceptado $50 o habría cedido parcialmente. El conocimiento de dominio en el prompt --"nunca bajar del precio mínimo"-- le dio al sistema la capacidad de resistir sin ser hostil.

### Escenario 6: Manejo de queja sin defensividad

**Entrada del usuario:** "Your service was terrible"

**Respuesta del sistema:** De-escaló usando etiquetado emocional. Reconoció la frustración del cliente y preguntó qué había ocurrido específicamente, sin defender, justificar ni minimizar.

**Resultado:** ÉXITO. La técnica de etiquetado de Chris Voss (reconocer la emoción antes de abordar el problema) fue implementada exclusivamente a través del prompt. No hubo módulo de procesamiento emocional ni análisis de sentimiento. Las instrucciones en el prompt fueron suficientes para que el modelo adoptara el comportamiento correcto.

### Resumen de resultados

| Escenario | Capacidad evaluada | Resultado |
|---|---|---|
| Cotización con fórmula | Conocimiento (13) | ÉXITO |
| Negociación sin rendición | Juicio (4) + Conocimiento (13) | ÉXITO |
| Área de servicio | Búsqueda (12) + Conocimiento (13) | ÉXITO |
| Reconocimiento de límites | Humildad (6) | ÉXITO |
| Resistencia ante oferta | Control (5) + Juicio (4) | ÉXITO |
| Manejo de queja | Adaptación (11) + Sentidos (2) | ÉXITO |

6 de 6 escenarios superados.

---

## 7. Comparación con Soluciones Existentes

### 7.1 Panorama competitivo

El mercado de asistentes virtuales para negocios de servicios incluye varias soluciones establecidas:

- **Dialzara:** Recepcionista virtual con IA. Contesta llamadas, toma mensajes, agenda citas.
- **Newo AI:** Agente conversacional para negocios locales. Responde preguntas frecuentes y recopila datos de contacto.
- **ServiceAgent:** Asistente de IA para empresas de servicios a domicilio. Contesta, agenda y envía confirmaciones.

### 7.2 Diferenciadores de CleanBot

| Función | Dialzara | Newo AI | ServiceAgent | CleanBot |
|---|---|---|---|---|
| Contestar llamadas/mensajes | Sí | Sí | Sí | Sí |
| Agendar citas | Sí | Sí | Sí | Diseñado (no implementado) |
| Calcular rentabilidad real por trabajo | No | No | No | Sí (fórmulas sqft/rate) |
| Negociar sin capitular | No | No | No | Sí (reglas de negociación) |
| De-escalar con técnica profesional | No | No | No | Sí (Voss labeling) |
| Aprender de correcciones del dueño | No | No | No | Diseñado (no implementado) |
| Compuertas de decisión explícitas | No | No | No | Sí (8 compuertas de negocio) |
| Patrón de 13 capacidades | No | No | No | Sí (mapeado completo) |
| Diseñado para dueños latinos | No | No | No | Sí |

### 7.3 La distinción clave

Las soluciones existentes son **recepcionistas**: contestan, anotan, agendan. CleanBot fue diseñado como **asistente de negocio**: calcula, negocia, protege márgenes, escala cuando debe y propone mejoras. La distinción refleja un entendimiento diferente de lo que el dueño de un negocio de limpieza necesita.

Un dueño de negocio de limpieza no necesita que alguien conteste su teléfono. Necesita que alguien le diga si está ganando o perdiendo dinero en cada trabajo.

---

## 8. El Pivote: De Recepcionista a Asistente de Negocio

### 8.1 La hipótesis original

La hipótesis inicial era construir una recepcionista virtual bilingüe para negocios de limpieza. La idea parecía clara: los dueños están ocupados limpiando casas, no pueden contestar el teléfono, pierden clientes. Solución: un bot que conteste por ellos.

### 8.2 Lo que reveló la investigación

La investigación de mercado reveló algo que la hipótesis original no contemplaba. Los dueños de negocios de limpieza no pierden dinero por no contestar el teléfono. Pierden dinero porque:

1. **No saben cuánto cobrar.** Calculan precios intuitivamente, sin fórmulas que consideren tiempo de transporte, costo de productos y margen de ganancia real.
2. **Ceden ante la presión del cliente.** Cuando el cliente dice "es muy caro", el dueño baja el precio en lugar de ofrecer alternativas.
3. **No rastrean la rentabilidad por trabajo.** Un trabajo que parece bien pagado puede generar pérdida cuando se consideran todos los costos.
4. **No hacen seguimiento.** Un cliente que preguntó hace tres días y no recibió respuesta ya contrató a otra persona.

### 8.3 El pivote conceptual

Esta observación transformó el producto de "recepcionista que contesta" a "asistente que protege tu ganancia". Las fórmulas de cotización dejaron de ser un feature. Se convirtieron en el núcleo del producto. La negociación dejó de ser un nice-to-have. Se convirtió en la razón de existir del sistema.

Este pivote es una instancia de la Capacidad 9 (Propuesta): el proceso de diseño detectó una necesidad no articulada por el mercado y propuso un producto diferente al concebido inicialmente.

---

## 9. Limitaciones

Este documento describe un experimento exploratorio, no un estudio controlado. Las limitaciones son sustanciales y deben declararse con precisión.

### 9.1 Limitaciones del prototipo

1. **Conversaciones simuladas.** Todos los escenarios de prueba fueron diseñados y ejecutados por el investigador. Ningún cliente real interactuó con el sistema. La validación con usuarios reales es un paso pendiente.

2. **Capacidades no implementadas.** De las 13 capacidades, el prototipo solo implementa las que pueden existir dentro de un prompt: Conocimiento, Juicio, Control, Humildad, Adaptación y Sentidos (parcialmente). Las capacidades que requieren infraestructura --Memoria persistente, Iniciativa, Consulta, Propuesta, Búsqueda-- están diseñadas pero no codificadas.

3. **Sin memoria entre conversaciones.** Cada conversación comienza desde cero. El sistema no recuerda clientes anteriores, correcciones del dueño ni patrones aprendidos.

4. **Sin aprendizaje de correcciones.** El sistema de "el dueño corrige un precio y el bot lo recuerda" está conceptualizado pero no existe en código.

### 9.2 Limitaciones de infraestructura

5. **SMS bloqueado.** La entrega de mensajes SMS está bloqueada por los requisitos de registro A2P (Application-to-Person) de Twilio, que requieren documentación empresarial formal.

6. **WhatsApp limitado.** Solo se logró acceso al sandbox de WhatsApp, no a la API de producción. Esto impide pruebas con usuarios reales a través del canal que la audiencia objetivo más utiliza.

### 9.3 Limitaciones del experimento

7. **Muestra de dos dominios.** La afirmación de que el patrón es "agnóstico al dominio" se basa en exactamente dos dominios. Una generalización robusta requeriría validación en al menos tres o cuatro dominios adicionales con características distintas.

8. **Evaluador no independiente.** El mismo investigador que diseñó el patrón, construyó el prototipo y ejecutó las pruebas también evaluó los resultados. No hubo evaluación ciega ni evaluadores externos.

9. **Ausencia de métricas cuantitativas.** Los resultados se reportan como éxito/fracaso binario. No hay métricas de precisión, recall, satisfacción del usuario ni comparación estadística con baseline.

10. **La estimación 80/20 es cualitativa.** La afirmación de que "el 80% del valor proviene del prompt" no está cuantificada empíricamente. Es una observación del investigador basada en la proporción de escenarios resueltos por el prompt solo versus los que requerirían módulos adicionales.

---

## 10. Implicaciones

### 10.1 Para la arquitectura de IA

Si el patrón de 13 capacidades describe competencias profesionales genéricas, entonces los frameworks actuales de desarrollo de agentes de IA están incompletos. La taxonomía predominante --percibir, razonar, actuar-- omite capacidades como Humildad, Adaptación e Iniciativa. Estas no son periféricas. Son centrales para el desempeño profesional competente.

### 10.2 Para el mercado latino de pequeños negocios

La investigación de mercado reveló un segmento desatendido: dueños de pequeños negocios de servicios que operan primariamente en español. Su relación con la tecnología es pragmática (WhatsApp, no Slack). Su necesidad principal no es automatización sino orientación financiera. Ninguna de las soluciones existentes aborda este segmento con herramientas culturalmente adecuadas.

### 10.3 Para MARIS

El experimento valida retrospectivamente decisiones de diseño de MARIS. La razón por la cual la arquitectura clínica requiere 529 vectores, 23 pasos de pipeline y 6 compuertas éticas no es sobreingeniería. En su dominio, el 20% que la arquitectura agrega sobre el prompt base no es un lujo. Es una obligación ética. El contraste con CleanBot --donde ese 20% es deseable pero no crítico-- clarifica la relación entre dominio y complejidad necesaria.

---

## 11. Trabajo Futuro

### 11.1 Validación con usuarios reales

La prioridad inmediata es resolver las barreras de infraestructura (registro A2P, API de WhatsApp en producción) y ejecutar pruebas con al menos cinco dueños de negocios de limpieza reales. El criterio de éxito no sería la precisión técnica sino la adopción: ¿lo siguen usando después de la primera semana?

### 11.2 Implementación de capacidades faltantes

Las capacidades de Memoria, Iniciativa, Consulta y Propuesta requieren infraestructura mínima (una base de datos simple, un cron job para seguimientos). Representan el camino de "bueno" a "excelente" identificado en la regla 80/20.

### 11.3 Validación en dominios adicionales

Para elevar la afirmación de "agnóstico al dominio" de observación a evidencia, el patrón debería probarse en al menos tres dominios adicionales: uno de servicios profesionales (consultoría, contabilidad), uno de comercio (tienda, restaurante) y uno educativo (tutoría, capacitación).

### 11.4 Cuantificación del 80/20

Diseñar un estudio controlado donde el mismo conjunto de escenarios se ejecute en tres condiciones: (a) prompt básico sin conocimiento de dominio, (b) prompt con conocimiento de dominio (actual), (c) prompt con conocimiento de dominio más módulos de las 13 capacidades. Medir la diferencia entre (b) y (c) cuantificaría empíricamente la contribución de la arquitectura sobre el prompt.

---

## 12. Conclusión

El experimento mostró que las 13 Capacidades, concebidas para un sistema clínico de detección de crisis, se mapean sin distorsión a un dominio comercial diferente. Este resultado sugiere que el patrón no describe capacidades clínicas sino profesionales: las facultades que distinguen a cualquier empleado competente de uno mediocre. Independientemente de si su trabajo es contener una crisis emocional o cotizar una limpieza profunda.

El descubrimiento del 80/20 añade un matiz: la arquitectura de 13 capacidades es un patrón de refinamiento, no de base. Un prompt con conocimiento de dominio real y reglas de decisión claras constituye la base sobre la cual las capacidades operan. Sin esa base, las capacidades son una estructura sin sustancia. Con esa base, las capacidades transforman un asistente funcional en uno que retiene clientes y protege márgenes.

La diferencia entre dominios no es si las capacidades aplican, sino cuánto importa el 20% que agregan. En el dominio clínico, ese 20% puede ser la diferencia entre la vida y la muerte. En el dominio comercial, es la diferencia entre un asistente útil y uno que el dueño no quiere dejar de usar. El patrón es el mismo. La gravedad de sus consecuencias es lo que cambia.

---
---

# PART II: ENGLISH

---

## 1. Abstract

This document describes a cross-domain validation experiment. An architectural pattern --the 13 Capabilities, developed for MARIS, a clinical emotional crisis detection system-- was transplanted to a different domain: a commercial virtual assistant for residential cleaning businesses. The purpose was to answer a question: is the pattern domain-agnostic, or is it bound to the clinical context where it originated?

The experiment produced three findings. First, all 13 capabilities mapped without friction between domains. This suggests they constitute a taxonomy of generic professional competencies, not clinical ones. Second, a working prototype of 90 lines of Python with a single Claude Haiku API call showed that 80% of the system's value comes from the prompt containing real domain knowledge. The 13 Capabilities architecture contributes the remaining 20% as refinement, not foundation. Third, the design process revealed that the right product was not what the initial hypothesis assumed. The market does not need a virtual receptionist that answers the phone. It needs a business assistant that calculates whether each job generates profit.

Tests were conducted with simulated conversations evaluating six scenarios: quoting with real formulas, negotiation without surrender, emotional de-escalation, recognition of limits, resistance to unacceptable offers, and complaint handling without defensiveness. All six scenarios were passed by the prototype.

---

## 2. Motivation and Context

### 2.1 The Problem of Specificity

During the development period of 2025-2026, MARIS accumulated an architecture of considerable depth: 529 detection vectors distributed across six algorithmic modules, a 23-step clinical pipeline, six sequential ethical gates, an exponential decay system for modeling coping capacity, and a meta-evaluator orchestrating all of the above. This complexity was necessary. Errors in the clinical domain carry consequences that do not tolerate approximation.

However, complexity produces a legitimate question. Is everything that was built a particular solution to a particular problem? Or are there generalizable principles beneath the layers of clinical specificity? If the 13 Capabilities are a pattern --a recurrent structure that solves a type of problem regardless of context-- then they should function outside the clinical context. In an office, a shop, a workshop, or a cleaning company.

### 2.2 Why a Cleaning Business

The choice of test domain was deliberate. Maximum contrast with the clinical domain was sought:

- **Consequences.** In MARIS, an error can contribute to a fatal outcome. In a cleaning business, an error costs money, reputation, or time, but not lives.
- **Vocabulary.** MARIS operates with psychological taxonomies (C-SSRS, cognitive distortions, Maslow levels). A cleaning business operates with square footage, hourly rates, and calendars.
- **Relationship with the user.** MARIS maintains an asymmetric caregiving relationship: the system knows more about emotional wellbeing than the user. CleanBot maintains a service relationship: the business owner knows more about cleaning than the system.
- **Audience.** The specific case chosen serves Latino cleaning business owners, Spanish-speaking individuals for whom AI technology has not been designed or marketed.

This contrast enables a stronger inference: if the pattern works here, where everything is different except the underlying structure, then the underlying structure is what matters.

### 2.3 The Experimental Question

The question was not "can you build a chatbot for cleaning businesses?" --that is trivial with current tools. The question was: **do the 13 Capabilities, conceived as the faculties that distinguish a competent employee from an incompetent one, describe something real about professional competence regardless of domain?**

---

## 3. Experiment Design

### 3.1 Methodology

The experiment followed a three-stage process:

**Stage 1: Conceptual mapping.** Each of the 13 capabilities was redefined in the context of the cleaning business. No capability was added or removed. Each was reinterpreted within the new domain. The success criterion was that no capability should feel forced or artificial in the new context.

**Stage 2: Prototype construction.** A deliberately minimalist MVP was built: 90 lines of Python, a single Claude Haiku API call, and a prompt containing real domain knowledge (quoting formulas, service areas, business policies). The minimalism was intentional. The goal was to measure how much value the pattern produces at the prompt design level, before investing in infrastructure.

**Stage 3: Live testing.** Simulated conversations were executed covering six scenarios representative of the daily work of a cleaning business. Each scenario was evaluated against binary success or failure criteria.

### 3.2 Controlled Variables

- **Language model:** Claude Haiku (the most economical in the Claude family, to show that the pattern does not depend on high-capacity models).
- **Infrastructure:** None. No embeddings, no vector databases, no agent frameworks.
- **Code:** 90 lines. No excessive abstraction. Readable by any intermediate programmer.
- **Domain knowledge:** Injected entirely into the system prompt. Includes real quoting formulas, complete service list with descriptions, service areas with zip codes, negotiation rules, and escalation protocol.

---

## 4. The Capability Mapping

### 4.1 Perception Layer

**Capability 1: Instinct.** The faculty of detecting what the interlocutor does not say explicitly. In MARIS, this manifests as "something is accumulating" through 96 EIP vectors that track indirect signals across multiple conversational turns. In CleanBot, it manifests as detecting that a potential client who asks about prices three times without mentioning dates is experiencing price hesitation --before they verbalize it.

**Capability 2: Senses.** Explicit identification of what is happening in the current message. MARIS deploys 529 vectors across seven detectors. CleanBot uses three detectors: intent (quote, schedule, complain, inquire), urgency (temporal, emotional, operational), and client state (new, recurring, dissatisfied). The output shifts from a multidimensional clinical classification to a tuple of (service, size, urgency, disposition).

**Capability 3: Memory.** The capacity to remember the trend, not merely the isolated moment. MARIS models this through the Physics Brain: emotional velocity as the derivative of friction over time, coping capacity as exponential decay. CleanBot uses a temporally weighted record where the last three interactions carry more weight than previous ones, generating a "momentum" of the commercial relationship.

### 4.2 Decision Layer

**Capability 4: Judgment.** The faculty of evaluating before acting. MARIS implements six sequential ethical gates. CleanBot implements eight business gates. The shift is from "does this respect the user's autonomy?" to "does this discount maintain profit margin?" The mechanism changes. The principle does not.

**Capability 5: Control.** Verification after generation. MARIS runs seven post-processors asking "does this respect clinical protocol?" CleanBot runs a professionalism filter asking "does this sound professional?" and "does this promise something the business cannot deliver?"

**Capability 6: Humility.** Recognition of one's own limits. In MARIS: "I can share resources for professionals." In CleanBot: "Let me check with the team." In the live test, when asked about garage organization (a service not offered), the system correctly escalated rather than inventing a price or refusing.

### 4.3 Action Layer

**Capability 7: Initiative.** Acting without being asked. Not implemented in either system as code. Designed for CleanBot as: "Thursday is empty, send a follow-up to last week's leads?"

**Capability 8: Consultation.** Requesting what is missing. Designed for CleanBot as: "The client didn't mention square footage--ask before quoting."

**Capability 9: Proposal.** Suggesting improvements to the system itself. Designed for CleanBot as: "Three clients asked about oven cleaning this week--should we add it to the menu?"

### 4.4 Intelligence Layer

**Capability 10: Priority.** Deciding what to attend first. In MARIS, severity determines order. In CleanBot, retention before conversion before information: a complaint from an existing client takes precedence over a quote request from a prospect.

**Capability 11: Adaptation.** Adjusting tone to the interlocutor. MARIS uses resolve_state with six tones. CleanBot matches the client's communication style: formal with property managers, casual with homeowners.

**Capability 12: Search.** Consulting external sources. MARIS uses Tavily web search for clinical resources. CleanBot consults calendars, zip codes, and availability databases.

**Capability 13: Knowledge.** Mastering the domain's body of knowledge. MARIS contains C-SSRS scales, clinical protocols, and emotional taxonomies. CleanBot contains quoting formulas (sqft/rate x hourly_rate), pricing tables, and service descriptions.

### 4.5 Mapping Observation

None of the 13 capabilities felt forced, redundant, or inapplicable in the new domain. Each found a natural correlate. This does not prove universality --a sample of two domains does not permit that claim. But it shows that the capabilities are not anchored to clinical vocabulary. They describe cognitive and operational functions that any competent professional executes, regardless of whether their job is to contain an emotional crisis or to quote a deep cleaning.

---

## 5. The Prototype: 90 Lines and a Discovery

### 5.1 MVP Architecture

The prototype was built under deliberate constraints: one Python file (90 lines), one Claude Haiku API call, one system prompt with domain knowledge, zero databases, zero embeddings, zero agent frameworks, zero persistent memory.

The system prompt contained: business identity and personality, complete service list with descriptions, real quoting formulas, service area with zip codes, negotiation rules (never drop below minimum price, offer alternatives before conceding), escalation protocol, and de-escalation technique (Chris Voss labeling: acknowledge the emotion before addressing the problem).

### 5.2 The 80/20 Discovery

The most relevant result of the experiment was not that the prototype worked --that was expected. It was *how much* it achieved with *so little*.

With only the prompt (no 13 Capabilities implemented as code modules), the system successfully calculated correct prices using real formulas, negotiated without surrendering or offending, de-escalated emotional situations with professional technique, recognized its limits and escalated appropriately, resisted unacceptable offers while maintaining the relationship, and handled complaints without defensiveness.

This suggests an 80/20 distribution of value:

| Component | Estimated Contribution | What It Provides |
|---|---|---|
| Prompt with real domain knowledge | ~80% | Correct behavior in most situations |
| 13 Capabilities as code modules | ~20% | Persistent memory, learning, initiative, fine adaptation |

The implication: **a well-designed prompt with genuine domain knowledge and clear decision rules achieves most of what a full architecture would achieve.** The 13 Capabilities architecture is not the foundation. It is the refinement. It contributes what separates "good" from "excellent": remembering previous interactions, learning from owner corrections, taking proactive initiative, adapting tone with precision over time.

### 5.3 Implication for MARIS

This finding retroactively illuminates MARIS's architecture. MARIS needs the 13 capabilities implemented as code modules (not merely as a prompt) because in the clinical domain, the difference between "good" and "excellent" can be the difference between detecting and not detecting a crisis. The 20% that the architecture adds beyond the base prompt is not a luxury. It is an ethical obligation.

In the commercial domain, that 20% separates a competent assistant from an exceptional one. The difference is of degree, not of nature. A CleanBot without persistent memory is still useful. A MARIS without cumulative detection may be dangerous.

---

## 6. Live Test Results

Six conversational scenarios were executed to evaluate assistant behaviors. Each scenario had a binary success criterion.

**Scenario 1: Quoting with real formula.** User input: "How much for deep clean 3BR?" System response: "$225." Verified calculation: 1500 sqft / 300 x $45 = $225. PASS.

**Scenario 2: Negotiation without surrender.** User input: "That's too expensive." System response: offered regular cleaning at $135 as an alternative. Verified calculation: 1500 / 500 x $45 = $135. The system did not lower the price of the requested service. It offered a different service at a lower price. This is the difference between negotiating and capitulating. PASS.

**Scenario 3: Service area verification.** User input: "Do you come to Oxnard?" System response: "Yes, Oxnard is in our service area." PASS.

**Scenario 4: Recognition of limits (Humility).** User input: "Can you organize my garage?" System response: "Let me check with the team." Garage organization was not on the service list. Instead of inventing a price or rejecting the client, the system acknowledged it did not know the answer and proposed consulting the human team. PASS.

**Scenario 5: Resistance to unacceptable offer.** User input: "$50 for the whole house." System response: maintained the $135 price for regular cleaning. Did not yield. Language models have an inherent tendency toward sycophancy. A chatbot without negotiation rules would have accepted $50 or partially conceded. The domain knowledge in the prompt --"never drop below minimum price"-- gave the system the ability to resist without hostility. PASS.

**Scenario 6: Complaint handling without defensiveness.** User input: "Your service was terrible." System response: de-escalated using emotional labeling. Acknowledged the client's frustration and asked what had specifically happened, without defending, justifying, or minimizing. PASS.

**Summary:** 6 out of 6 scenarios passed.

---

## 7. Comparison with Existing Solutions

The market for AI assistants in service businesses includes several established solutions: Dialzara (virtual receptionist), Newo AI (conversational agent for local businesses), and ServiceAgent (AI assistant for home service companies). All three answer calls, take messages, and schedule appointments.

None calculates real profitability per job. None negotiates without capitulating. None de-escalates with professional technique. None learns from owner corrections. None has explicit decision gates. None implements a structured capability pattern. None is designed for Spanish-speaking Latino business owners.

The distinction: existing solutions are **receptionists** (they answer, note, schedule). CleanBot was designed as a **business assistant** (it calculates, negotiates, protects margins, escalates when appropriate, and proposes improvements). A cleaning business owner does not need someone to answer their phone. They need someone to tell them whether they are making money.

---

## 8. The Pivot: From Receptionist to Business Assistant

### 8.1 The Original Hypothesis

The initial hypothesis was to build a bilingual virtual receptionist for cleaning businesses. The idea seemed straightforward: owners are busy cleaning houses, they cannot answer the phone, they lose clients. Solution: a bot that answers for them.

### 8.2 What the Research Revealed

Market research revealed something the original hypothesis did not contemplate. Cleaning business owners do not lose money because they fail to answer the phone. They lose money because: (1) they do not know how much to charge--they calculate prices intuitively without formulas accounting for travel time, product costs, and real profit margin; (2) they yield under client pressure--when the client says "that's too expensive," the owner lowers the price instead of offering alternatives; (3) they do not track per-job profitability--a job that appears well-paid can generate a loss when all costs are considered; (4) they do not follow up--a client who inquired three days ago and received no response has already hired someone else.

### 8.3 The Conceptual Pivot

This observation transformed the product from "receptionist that answers" to "assistant that protects your profit." The quoting formulas ceased to be a feature. They became the product's core. Negotiation ceased to be a nice-to-have. It became the system's reason for existing.

This pivot is an instance of Capability 9 (Proposal): the design process detected an unarticulated market need and proposed a different product from the one originally conceived.

---

## 9. Limitations

This document describes an exploratory experiment, not a controlled study. The limitations are substantial and must be stated precisely.

1. **Simulated conversations.** All test scenarios were designed and executed by the researcher. No real client interacted with the system. Validation with real users is a pending step.

2. **Unimplemented capabilities.** Of the 13 capabilities, the prototype only implements those that can exist within a prompt: Knowledge, Judgment, Control, Humility, Adaptation, and Senses (partially). Capabilities requiring infrastructure --persistent Memory, Initiative, Consultation, Proposal, Search-- are designed but not coded.

3. **No inter-conversation memory.** Each conversation starts from zero. The system does not remember previous clients, owner corrections, or learned patterns.

4. **No learning from corrections.** The system of "the owner corrects a price and the bot remembers" is conceptualized but does not exist in code.

5. **SMS blocked.** SMS message delivery is blocked by Twilio's A2P (Application-to-Person) registration requirements, which demand formal business documentation.

6. **WhatsApp limited.** Only sandbox access was achieved, not the production API. This prevents testing with real users through the channel the target audience uses most.

7. **Two-domain sample.** The claim that the pattern is "domain-agnostic" rests on exactly two domains. A robust generalization would require validation in at least three or four additional domains with distinct characteristics.

8. **Non-independent evaluator.** The same researcher who designed the pattern, built the prototype, and ran the tests also evaluated the results. There was no blind evaluation or external evaluators.

9. **Absence of quantitative metrics.** Results are reported as binary pass/fail. There are no precision, recall, user satisfaction, or statistical baseline comparison metrics.

10. **The 80/20 estimate is qualitative.** The claim that "80% of value comes from the prompt" is not empirically quantified. It is the researcher's observation based on the proportion of scenarios resolved by the prompt alone versus those that would require additional modules.

---

## 10. Implications

### 10.1 For AI Architecture

If the 13 Capabilities pattern describes generic professional competencies, then current AI agent development frameworks are incomplete. The predominant taxonomy --perceive, reason, act-- omits capabilities like Humility, Adaptation, and Initiative. These are not peripheral. They are central to competent professional performance.

### 10.2 For the Latino Small Business Market

The market research revealed an underserved segment: owners of small service businesses who operate primarily in Spanish. Their relationship with technology is pragmatic (WhatsApp, not Slack). Their primary need is not automation but financial guidance. None of the existing solutions address this segment with culturally appropriate tools.

### 10.3 For MARIS

The experiment retrospectively validates MARIS design decisions. The reason the clinical architecture requires 529 vectors, a 23-step pipeline, and six ethical gates is not overengineering. In its domain, the 20% the architecture adds beyond the base prompt is not a luxury. It is an ethical obligation. The contrast with CleanBot --where that 20% is desirable but not critical-- clarifies the relationship between domain and necessary complexity.

---

## 11. Future Work

1. **Validation with real users.** Resolve infrastructure barriers (A2P registration, production WhatsApp API) and conduct tests with at least five real cleaning business owners. The success criterion would not be technical accuracy but adoption: do they continue using it after the first week?

2. **Implementation of missing capabilities.** Memory, Initiative, Consultation, and Proposal require minimal infrastructure (a simple database, a cron job for follow-ups). They represent the path from "good" to "excellent" identified in the 80/20 observation.

3. **Validation in additional domains.** To elevate the "domain-agnostic" claim from observation to evidence, the pattern should be tested in at least three additional domains: professional services (consulting, accounting), commerce (retail, restaurant), and education (tutoring, training).

4. **Quantification of 80/20.** Design a controlled study where the same set of scenarios is executed under three conditions: (a) basic prompt without domain knowledge, (b) prompt with domain knowledge (current), (c) prompt with domain knowledge plus 13 Capabilities modules. Measuring the difference between (b) and (c) would empirically quantify the architecture's contribution beyond the prompt.

---

## 12. Conclusion

The experiment showed that the 13 Capabilities, conceived for a clinical crisis detection system, map without distortion to a different commercial domain. This result suggests that the pattern does not describe clinical capabilities but professional ones: the faculties that distinguish any competent employee from a mediocre one. Regardless of whether their job is to contain an emotional crisis or to quote a deep cleaning.

The 80/20 discovery adds a nuance: the 13 Capabilities architecture is a pattern of refinement, not of foundation. A prompt with real domain knowledge and clear decision rules constitutes the base upon which the capabilities operate. Without that base, the capabilities are a structure without substance. With that base, the capabilities transform a functional assistant into one that retains clients and protects margins.

The difference between domains is not whether the capabilities apply, but how much the 20% they add matters. In the clinical domain, that 20% can be the difference between life and death. In the commercial domain, it is the difference between a useful assistant and one the owner does not want to stop using. The pattern is the same. The gravity of its consequences is what changes.

---

> (c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados / All rights reserved.

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

