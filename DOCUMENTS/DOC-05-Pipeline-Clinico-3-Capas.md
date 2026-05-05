# DOC-05 — Pipeline Clínico de Seguridad en Tres Capas para LLMs: Detección, Decisión y Verificación

**A Three-Layer Clinical Safety Pipeline for LLMs: Detection, Decision, and Verification**

Autor: Leonel Perea Pimentel
Fecha: Mayo 2026
Versión: 1.0

---

## Copyright

(c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados.

El pipeline clínico de 3 capas, incluyendo todos los detectores, post-procesadores y los 529 vectores semánticos, son propiedad intelectual del autor. Queda prohibida su reproducción, distribución o uso comercial sin autorización expresa por escrito.

The 3-layer clinical pipeline, including all detectors, post-processors, and the 529 semantic vectors, are intellectual property of the author. Reproduction, distribution, or commercial use without express written authorization is prohibited.

---

# PARTE I — ESPAÑOL

---

## 1. Resumen Ejecutivo

Este documento describe una arquitectura de seguridad clínica de tres capas para sistemas conversacionales basados en modelos de lenguaje (LLMs). La arquitectura separa las funciones de **detección** (análisis algorítmico del input del usuario), **decisión** (compuertas éticas dentro del prompt del LLM) y **verificación** (post-procesamiento algorítmico del output del LLM).

El sistema contiene 529 vectores semánticos, aproximadamente 3,200 líneas de código dedicado, 7 detectores especializados, 6 compuertas éticas secuenciales y 7 post-procesadores de verificación. Está calibrado contra los protocolos C-SSRS, DSM-5, ICD-11, CIT, MHFA, LEAP y ASIST.

El hallazgo central: la detección y la decisión son funciones distintas. El 28 de marzo de 2026, al remover las compuertas éticas del prompt, los detectores continuaron reportando severidad correctamente. Pero el sistema perdió la capacidad de actuar sobre esa información. Los sensores funcionaban; el juicio no. Ambas capas son necesarias. La tercera capa (verificación) actúa como red de seguridad contra las tendencias generativas del LLM.

---

## 2. Introducción y Motivación

Los modelos de lenguaje grandes generan texto coherente, empático y contextualmente apropiado. Esta misma capacidad los hace riesgosos en contextos de salud mental. Un LLM puede generar una respuesta que suena competente pero contiene información perjudicial: líneas de crisis donde no corresponden, confrontación directa a una persona en estado psicótico, o respuestas detalladas a preguntas sobre métodos letales.

El problema no es la intención del modelo. Los LLMs no tienen intención. El problema es que la generación de texto opera por probabilidad estadística, no por juicio clínico. Una respuesta "probable" no es necesariamente una respuesta "segura."

La solución convencional -- fine-tuning o RLHF -- opera sobre la distribución de probabilidades del modelo pero no garantiza comportamiento determinista en escenarios críticos. Un sistema de seguridad clínica necesita garantías más fuertes: reglas que se cumplan siempre, no "la mayor parte del tiempo."

Esta arquitectura propone envolver al LLM en un pipeline de tres capas. El código algorítmico (determinista, auditable, predecible) complementa al modelo generativo (probabilístico, flexible, contextual). El LLM genera lenguaje natural empático. El código detecta señales de riesgo con precisión, aplica reglas clínicas sin ambigüedad y verifica que la salida final no viole ningún protocolo.

---

## 3. Arquitectura General del Pipeline

El pipeline opera en tres fases secuenciales sobre cada mensaje del usuario:

```
Usuario  -->  [CAPA 1: DETECCIÓN]  -->  [CAPA 2: DECISIÓN]  -->  [CAPA 3: VERIFICACIÓN]  -->  Respuesta
                  (código Python)         (prompt del LLM)           (código Python)
                  determinista            probabilístico              determinista
                  529 vectores            6 compuertas                7 post-procesadores
```

**Capa 1** analiza el mensaje del usuario antes de que llegue al LLM. Produce un reporte estructurado: nivel de severidad (0-5), señales detectadas, acumulación histórica y flags específicos (psicosis, manía, medios letales, señales indirectas).

**Capa 2** recibe el reporte de Capa 1 como contexto inyectado en el prompt del LLM. Seis compuertas éticas -- KANT, PROTEGE, HONESTA, CUIDA, ÚTIL, LIBERA -- evalúan secuencialmente la respuesta que el modelo está a punto de generar. Cada compuerta es una condición IF/ELSE con acción correctiva.

**Capa 3** recibe la respuesta generada por el LLM y la somete a 7 post-procesadores. Estos editan, eliminan o reemplazan contenido que viole protocolos clínicos. Esta capa opera sobre texto, no sobre probabilidades. Es la última línea de defensa.

---

## 4. Capa 1 — Detección: Los 7 Detectores

### 4.1 Principios de Diseño

La Capa 1 fue diseñada bajo tres restricciones:

1. **Determinismo**: dado el mismo input, produce el mismo output. Sin temperatura, sin sampling, sin variabilidad.
2. **Acumulación**: el estado del usuario se construye a través de múltiples turnos de conversación. Un mensaje individual puede ser ambiguo; la trayectoria no lo es.
3. **Granularidad**: no basta con "crisis sí/no." El sistema distingue entre ideación pasiva, ideación activa sin plan, plan con método e inminencia. Cada nivel requiere una respuesta clínica diferente.

Los 529 vectores semánticos fueron construidos manualmente, no extraídos de un corpus. Cada vector representa una expresión real que un usuario podría usar. Incluyen variaciones coloquiales, eufemismos y expresiones culturalmente específicas del español latinoamericano y del inglés.

### 4.2 EIPMonitor (eip.py)

- **Tamaño**: 961 líneas de código
- **Vectores**: 96 vectores semánticos organizados en 15 clusters
- **Calibración**: Joiner combinado con escala C-SSRS
- **Niveles de salida**: Tier 0 (sin riesgo) a Tier 3 (riesgo crítico)
- **Operación**: dos fases. `fast_check` realiza un barrido léxico rápido para descartar mensajes claramente seguros. `evaluate` aplica análisis semántico completo solo cuando `fast_check` detecta señales.
- **Característica**: acumulación a través de turnos conversacionales. Un usuario que menciona desesperanza en el turno 3, aislamiento en el turno 7 y "ya no importa" en el turno 12 activa una escalación que ningún turno individual habría provocado. El sistema mantiene estado por conversación.

### 4.3 CrisisClassifier (crisis_classifier.py)

- **Tamaño**: 372 líneas de código
- **Vectores**: 98 vectores semánticos
- **Escala de severidad**: 0-5, calibrada contra C-SSRS
- **Operación**: análisis léxico + semántico + guardia de meta-conversación

Los 6 niveles de severidad dictan respuestas clínicas diferentes:

| Nivel | Estado Clínico | Protocolo |
|-------|---------------|-----------|
| 0 | Sin crisis | Conversación normal |
| 1-2 | Ideación pasiva | Escuchar primero. NO ofrecer recursos. La persona necesita ser escuchada, no redirigida. |
| 3 | Ideación activa sin plan | Ofrecer recursos DESPUÉS de exploración. Primero validar, preguntar, contener. |
| 4 | Plan con método | Recursos inmediatos. Flag de medios letales. Reducción de acceso a medios. |
| 5 | Inminente | Override completo. Recursos PRIMERO. Brevedad forzada (<150 palabras). |

La distinción entre nivel 1-2 y nivel 3 es clínicamente relevante. En el nivel 1-2, ofrecer líneas de crisis prematuramente puede hacer que la persona se sienta "procesada" en lugar de escuchada. Puede interrumpir la construcción de alianza terapéutica. En nivel 3, los recursos son necesarios pero deben venir después de la exploración.

### 4.4 PsychosisDetector

- **Tamaño**: 548 líneas de código (archivo compartido con ManiaDetector)
- **Vectores**: 45 vectores en 4 clusters
  - Persecución: 18 vectores ("me están siguiendo," "pusieron cámaras," "envenenan mi comida")
  - Realidad fragmentada: 8 vectores ("el tiempo no es real," "estoy en una simulación")
  - Voces/presencias: 7 vectores ("escucho una voz que me dice," "alguien está aquí conmigo")
  - Control externo: 12 vectores ("controlan mis pensamientos," "me implantan ideas")
- **Post-check**: si más del 30% de las oraciones en la respuesta del LLM invalidan la experiencia del usuario, la respuesta completa se reemplaza con una respuesta de emergencia predefinida. También elimina cualquier contenido que confronte directamente las creencias del usuario.

Razón clínica: confrontar a una persona en estado psicótico con "eso no es real" no es terapéutico. Según el protocolo LEAP (Listen, Empathize, Agree, Partner), la primera respuesta debe ser validación de la experiencia subjetiva, no corrección de la realidad.

### 4.5 ManiaDetector

- **Tamaño**: mismo archivo que PsychosisDetector
- **Vectores**: 31 vectores en 4 clusters
  - Grandiosidad: 11 vectores ("soy el elegido," "descubrí algo que nadie más puede ver")
  - Hiperproductividad: 9 vectores ("no necesito dormir, tengo demasiada energía," "empecé 5 proyectos hoy")
  - Urgencia maníaca: 6 vectores ("necesito hacer esto AHORA," "todo está claro de repente")
  - Sueño reducido: 5 vectores ("llevo 3 días sin dormir y me siento increíble")
- **Post-check**: elimina cualquier contenido de confrontación directa. Antepone una pregunta sobre sueño. El sueño es el indicador más fiable y menos confrontativo de un episodio maníaco. Preguntar "¿cómo has dormido estos días?" es clínicamente más útil que decir "creo que estás en un episodio maníaco."

### 4.6 LethalMeansDetector (lethal_means.py)

- **Tamaño**: 520 líneas de código
- **Vectores**: 29 vectores en 6 categorías de método
  - Pastillas: 5 vectores
  - Altura: 6 vectores
  - Corte: 5 vectores
  - Ligadura: 4 vectores
  - Arma de fuego: 5 vectores
  - Vehículo: 4 vectores
- **Post-check**: si la respuesta del LLM no incluye reducción de acceso a medios, se agrega automáticamente. La reducción de acceso a medios letales es una de las intervenciones con mayor evidencia en prevención de suicidio (Yip et al., 2012).

### 4.7 IndirectSignalHandler

- **Tamaño**: mismo archivo que LethalMeansDetector
- **Vectores**: 27 vectores
- **Operación**: detecta la combinación de dolor + pregunta peligrosa. No basta con dolor solo, ni con pregunta sola. La combinación es la señal.
- **Método**: divide el mensaje en oraciones y evalúa cada una independientemente. Esto evita que una oración benigna "diluya" una señal peligrosa.
- **Post-check**: si detecta una respuesta peligrosa en el output del LLM, realiza un REEMPLAZO COMPLETO de la respuesta. No edita, no ajusta -- reemplaza. Esta es la intervención más agresiva del pipeline. Se reserva para el caso más peligroso: cuando el LLM ha respondido directamente a una pregunta sobre métodos.

### 4.8 ResponseCalibrator (response_calibrator.py)

- **Tamaño**: 403 líneas de código
- **Vectores**: cero. Opera exclusivamente con regex.
- **Operación**: edición algorítmica de texto basada en el nivel de severidad detectado por los otros módulos.

| Nivel | Acción |
|-------|--------|
| PASIVO (1-2) | Elimina todas las líneas de crisis de la respuesta |
| ACTIVO SIN PLAN (3) | Mueve recursos de la primera mitad a la segunda mitad de la respuesta |
| PLAN CON MÉTODO (4) | Antepone verificación de seguridad |
| INMINENTE (5) | Agrega recursos al final, fuerza brevedad (<150 palabras) |

El ResponseCalibrator es el único módulo que no detecta -- solo edita. Su función es asegurar que la estructura de la respuesta sea clínicamente apropiada para el nivel de severidad. Una respuesta que empieza con "Llama al 988" cuando la persona solo expresó tristeza pasiva es clínicamente inapropiada. Una respuesta de 500 palabras cuando la persona está en riesgo inminente es clínicamente inapropiada. El calibrador corrige ambos escenarios.

---

## 5. Capa 2 — Decisión: Las 6 Compuertas Éticas

La Capa 2 opera dentro del prompt del LLM. Son instrucciones que el modelo sigue (o intenta seguir) durante la generación. Seis compuertas secuenciales:

### 5.1 KANT
- **Pregunta**: "¿Puedo universalizar esta respuesta? Si todos los usuarios en esta situación recibieran esta respuesta, ¿sería seguro?"
- **Acción correctiva**: si la respuesta no es universalizable, reformular eliminando el elemento que falla.

### 5.2 PROTEGE
- **Pregunta**: "Dado el nivel de severidad reportado por Capa 1, ¿esta respuesta protege al usuario?"
- **Acción correctiva**: ajustar la respuesta al protocolo correspondiente al nivel de severidad. No tratar un nivel 4 como un nivel 1.

### 5.3 HONESTA
- **Pregunta**: "¿Esta respuesta es honesta? ¿No exagera ni minimiza?"
- **Acción correctiva**: eliminar hipérboles terapéuticas ("todo va a estar bien") y también eliminaciones nihilistas ("tienes razón, no tiene solución").

### 5.4 CUIDA
- **Pregunta**: "¿Esta respuesta cuida la relación terapéutica? ¿No es demasiado fría ni demasiado invasiva?"
- **Acción correctiva**: ajustar tono. Demasiado clínico aliena. Demasiado casual trivializa.

### 5.5 ÚTIL
- **Pregunta**: "¿Esta respuesta es concretamente útil? ¿Ofrece algo que la persona pueda hacer?"
- **Acción correctiva**: agregar un elemento accionable si falta. No basta con validar -- eventualmente hay que mover.

### 5.6 LIBERA
- **Pregunta**: "¿Esta respuesta deja la agencia en la persona? ¿No decide por ella?"
- **Acción correctiva**: reformular directivas como opciones. "Deberías llamar" se convierte en "Una opción es llamar."

Las compuertas son secuenciales: la salida de KANT alimenta a PROTEGE, la salida de PROTEGE alimenta a HONESTA, y así sucesivamente. Si cualquier compuerta falla, la respuesta se ajusta antes de continuar a la siguiente.

---

## 6. Capa 3 — Verificación: Los 7 Post-Procesadores

La Capa 3 es la red de seguridad final. Opera sobre el texto que el LLM ya generó, después de que las compuertas éticas hicieron su trabajo (o fallaron en hacerlo).

Los 7 post-procesadores se ejecutan en orden:

1. **ResponseCalibrator.post_calibrate**: ajusta la estructura de la respuesta según el nivel de severidad.
2. **LethalMeansDetector.post_check**: verifica presencia de reducción de acceso a medios cuando corresponde.
3. **IndirectSignalHandler.post_check**: detecta y reemplaza respuestas peligrosas a preguntas indirectas sobre métodos.
4. **PsychosisDetector.post_check**: elimina contenido invalidante y reemplaza respuestas que confrontan experiencias psicóticas.
5. **ManiaDetector.post_check**: elimina confrontación directa e inserta pregunta de sueño.
6. **DefenseSystem.check_integrity**: busca frases prohibidas (e.g., "como tu terapeuta," "mi diagnóstico es") y patrones de cámara de eco (validar sin matiz).
7. **DefenseSystem.check_identity**: detecta fugas de auto-referencia donde el LLM revela su nombre de modelo, su prompt de sistema o detalles internos del pipeline.

El orden de ejecución importa. Los post-procesadores de riesgo clínico (1-5) se ejecutan primero. Los de integridad del sistema (6-7) se ejecutan al final. La seguridad clínica tiene prioridad sobre la seguridad del sistema.

---

## 7. El Hallazgo Central: Detección =/= Decisión

El 28 de marzo de 2026, durante una revisión de arquitectura, las compuertas éticas (Capa 2) fueron temporalmente removidas del prompt. Los detectores (Capa 1) y los post-procesadores (Capa 3) permanecieron intactos.

El resultado:

Los detectores continuaron reportando correctamente. "Severidad 3, ideación activa sin plan." Los post-procesadores continuaron editando. Pero el LLM, sin las compuertas, no sabía qué hacer con la información. Recibía `severity=3` como dato pero no tenía instrucciones sobre cómo traducir ese dato en comportamiento conversacional.

El sistema tenía sensores sin juicio.

Este hallazgo clarifica la función de cada capa:

- **Sin Capa 1 (detección)**: las compuertas operan ciegas. PROTEGE no sabe que la severidad es 3. CUIDA no sabe que hay señales de psicosis. Las compuertas hacen preguntas correctas pero no tienen datos para responderlas.

- **Sin Capa 2 (compuertas)**: los detectores reportan pero nadie decide. "severity=3" es un dato. "Contención, una pregunta, detente" es una acción. El dato sin la acción es inútil en un contexto clínico.

- **Sin Capa 3 (verificación)**: el LLM puede pasar las compuertas conceptualmente pero aún así producir una frase peligrosa. El modelo "entiende" que no debe confrontar a una persona psicótica. Pero en la generación token-a-token, una frase invalidante puede aparecer por inercia estadística.

Las tres capas son complementarias, no redundantes. Cada una protege contra una clase de fallo diferente:
- Capa 1 protege contra la ceguera (no ver la señal).
- Capa 2 protege contra la indecisión (ver la señal pero no actuar).
- Capa 3 protege contra la ejecución defectuosa (decidir correctamente pero generar incorrectamente).

---

## 8. Calibración contra Protocolos Clínicos Establecidos

Los 529 vectores y las reglas del pipeline fueron calibrados contra los siguientes protocolos clínicos:

| Protocolo | Uso en el Pipeline |
|-----------|-------------------|
| **C-SSRS** (Columbia Suicide Severity Rating Scale) | Escala de severidad 0-5 del CrisisClassifier. Distinción entre ideación pasiva, activa sin plan, activa con plan y acción inminente. |
| **DSM-5** (Diagnostic and Statistical Manual) | Clusters de psicosis y manía en los detectores especializados. Criterios de grandiosidad, persecución, desorganización del pensamiento. |
| **ICD-11** (International Classification of Diseases) | Complemento al DSM-5 para categorías diagnósticas. Usado en la definición de umbrales. |
| **CIT** (Crisis Intervention Training) | Protocolo de desescalación. Informó el diseño de las compuertas PROTEGE y CUIDA. |
| **MHFA** (Mental Health First Aid) | Principio de "escuchar primero, actuar después." Base para la regla de no-recursos en severidad 1-2. |
| **LEAP** (Listen, Empathize, Agree, Partner) | Protocolo para interacción con psicosis. Base del PsychosisDetector y su post-check de no-invalidación. |
| **ASIST** (Applied Suicide Intervention Skills Training) | Enfoque en exploración antes de intervención. Informó la secuencia de la compuerta PROTEGE. |

---

## 9. Métricas del Sistema

| Métrica | Valor |
|---------|-------|
| Vectores semánticos totales | 529 |
| Líneas de código dedicadas | ~3,200 |
| Detectores especializados | 7 |
| Compuertas éticas | 6 |
| Post-procesadores | 7 |
| Niveles de severidad | 6 (0-5) |
| Clusters de psicosis | 4 |
| Clusters de manía | 4 |
| Categorías de medios letales | 6 |
| Protocolos clínicos de referencia | 7 |
| Idiomas cubiertos | 2 (Español LATAM, Inglés) |

---

## 10. Limitaciones

Las limitaciones de este sistema son reales y deben documentarse:

**10.1 Ausencia de validación clínica formal.** El pipeline no ha sido validado por profesionales clínicos en un ensayo formal. Los vectores fueron calibrados contra protocolos publicados. No han sido evaluados en un entorno clínico controlado con pacientes reales. La diferencia entre "calibrado contra C-SSRS" y "validado clínicamente con C-SSRS" es grande.

**10.2 Falsos positivos por habla coloquial.** El scorer puede malinterpretar lenguaje coloquial. "Me voy a morir de la risa" contiene "me voy a morir," que es una señal léxica. El sistema incluye mitigaciones para expresiones comunes. Pero el lenguaje coloquial es un blanco móvil. Nuevas expresiones, variaciones regionales y jerga generacional pueden generar falsos positivos no anticipados.

**10.3 Limitaciones del regex en post-procesamiento.** Los post-procesadores de Capa 3 usan regex para detectar patrones en la salida del LLM. El regex es determinista y rápido, pero no es análisis semántico. Una frase invalidante con una estructura gramatical no contemplada por el regex la atravesará sin ser detectada. Las frases novedosas son, por definición, invisibles al regex.

**10.4 Equipo de un solo desarrollador.** El sistema fue construido y probado por una sola persona, no por un equipo clínico multidisciplinario. Los sesgos del desarrollador están embebidos en los vectores, los umbrales y las reglas. No hay revisión por pares clínica. No hay diversidad de perspectiva profesional en el diseño.

**10.5 Cobertura lingüística limitada.** El sistema cubre español latinoamericano e inglés. No hay soporte para otros idiomas, dialectos regionales específicos ni variantes del español peninsular. Una persona que escribe en portugués, francés o español con jerga regional no cubierta recibirá detección degradada.

**10.6 Dependencia del LLM en Capa 2.** Las compuertas éticas son instrucciones en el prompt, no código. El LLM las sigue la mayor parte del tiempo, pero no hay garantía determinista. Un modelo diferente, una temperatura diferente o un contexto suficientemente largo pueden hacer que las compuertas sean ignoradas parcial o totalmente. Capa 3 mitiga esto, pero no lo elimina.

**10.7 Ausencia de datos longitudinales.** No hay estudios longitudinales sobre la efectividad del pipeline con usuarios reales a lo largo del tiempo. La eficacia a corto plazo en pruebas controladas no predice la eficacia a largo plazo en uso real.

---

## 11. Trabajo Futuro

1. **Validación clínica formal** con profesionales de salud mental y poblaciones controladas.
2. **Expansión lingüística** a portugués, francés y variantes regionales del español.
3. **Análisis semántico en Capa 3**: reemplazar regex por modelos de clasificación ligeros para el post-procesamiento.
4. **Estudio de falsos positivos** con corpus de habla coloquial para refinar umbrales.
5. **Auditoría por equipo multidisciplinario**: psicólogos, psiquiatras, trabajadores sociales y personas con experiencia vivida.

---

## 12. Conclusión

La seguridad clínica en sistemas conversacionales basados en LLMs no se resuelve con una sola técnica. Ni el fine-tuning, ni las instrucciones en el prompt, ni el post-procesamiento son suficientes por sí solos. La arquitectura de tres capas combina: detección algorítmica determinista, decisión ética guiada dentro del modelo y verificación final sobre el texto generado.

El hallazgo central: la detección sin decisión produce sensores sin juicio. La decisión sin detección produce juicio sin datos. Cualquier sistema que busque seguridad clínica en interacciones con LLMs debe resolver ambos problemas.

Los 529 vectores, los 7 detectores, las 6 compuertas y los 7 post-procesadores son una solución concreta a un problema concreto. No es una solución completa. Las limitaciones están documentadas arriba. La arquitectura de tres capas propone envolver al modelo en capas de código determinista que compensen sus debilidades en contextos clínicos.

---
---

# PART II — ENGLISH

---

## 1. Executive Summary

This document describes a three-layer clinical safety architecture for conversational systems powered by large language models (LLMs). The architecture separates the functions of **detection** (algorithmic analysis of user input), **decision** (ethical gates within the LLM prompt), and **verification** (algorithmic post-processing of LLM output).

The system contains 529 semantic vectors, approximately 3,200 dedicated lines of code, 7 specialized detectors, 6 sequential ethical gates, and 7 verification post-processors. It is calibrated against the C-SSRS, DSM-5, ICD-11, CIT, MHFA, LEAP, and ASIST protocols.

The central finding: detection and decision are distinct functions. On March 28, 2026, when the ethical gates were removed from the prompt, the detectors continued reporting severity correctly. But the system lost the ability to act on that information. The sensors worked; the judgment did not. Both layers are necessary. The third layer (verification) acts as a safety net against the LLM's generative tendencies.

---

## 2. Introduction and Motivation

Large language models generate coherent, empathetic, and contextually appropriate text. This same capability makes them risky in mental health contexts. An LLM can generate a response that sounds competent but contains harmful content: crisis hotlines where they do not belong, direct confrontation with a person in a psychotic state, or detailed answers to questions about lethal methods.

The problem is not the model's intention. LLMs have no intention. The problem is that text generation operates by statistical probability, not clinical judgment. A "probable" response is not necessarily a "safe" response.

The conventional solution -- fine-tuning or RLHF -- operates on the model's probability distribution but does not guarantee deterministic behavior in critical scenarios. A clinical safety system requires stronger guarantees: rules that are followed always, not "most of the time."

This architecture proposes wrapping the LLM in a three-layer pipeline. Algorithmic code (deterministic, auditable, predictable) complements the generative model (probabilistic, flexible, contextual). The LLM generates empathetic natural language. The code detects risk signals with precision, applies clinical rules without ambiguity, and verifies that the final output violates no protocol.

---

## 3. General Pipeline Architecture

The pipeline operates in three sequential phases on each user message:

```
User  -->  [LAYER 1: DETECTION]  -->  [LAYER 2: DECISION]  -->  [LAYER 3: VERIFICATION]  -->  Response
              (Python code)            (LLM prompt)               (Python code)
              deterministic            probabilistic               deterministic
              529 vectors              6 gates                     7 post-processors
```

**Layer 1** analyzes the user message before it reaches the LLM. It produces a structured report: severity level (0-5), detected signals, historical accumulation, and specific flags (psychosis, mania, lethal means, indirect signals).

**Layer 2** receives the Layer 1 report as context injected into the LLM prompt. Six ethical gates -- KANT, PROTEGE, HONESTA, CUIDA, UTIL, LIBERA -- sequentially evaluate the response the model is about to generate. Each gate is an IF/ELSE condition with corrective action.

**Layer 3** receives the response generated by the LLM and subjects it to 7 post-processors. These edit, remove, or replace content that violates clinical protocols. This layer operates on text, not on probabilities. It is the last line of defense.

---

## 4. Layer 1 — Detection: The 7 Detectors

### 4.1 Design Principles

Layer 1 was designed under three constraints:

1. **Determinism**: given the same input, it produces the same output. No temperature, no sampling, no variability.
2. **Accumulation**: user state is built across multiple conversation turns. A single message may be ambiguous; the trajectory is not.
3. **Granularity**: "crisis yes/no" is not sufficient. The system distinguishes between passive ideation, active ideation without plan, plan with method, and imminence. Each level requires a different clinical response.

The 529 semantic vectors were manually constructed, not extracted from a corpus. Each vector represents a real expression a user might use. They include colloquial variations, euphemisms, and culturally specific expressions from Latin American Spanish and English.

### 4.2 EIPMonitor (eip.py)

- **Size**: 961 lines of code
- **Vectors**: 96 semantic vectors organized in 15 clusters
- **Calibration**: Joiner combined with C-SSRS scale
- **Output levels**: Tier 0 (no risk) to Tier 3 (critical risk)
- **Operation**: two phases. `fast_check` performs a rapid lexical sweep to discard clearly safe messages. `evaluate` applies full semantic analysis only when `fast_check` detects signals.
- **Feature**: accumulation across conversation turns. A user who mentions hopelessness in turn 3, isolation in turn 7, and "it doesn't matter anymore" in turn 12 triggers an escalation that no individual turn would have provoked. The system maintains state per conversation.

### 4.3 CrisisClassifier (crisis_classifier.py)

- **Size**: 372 lines of code
- **Vectors**: 98 semantic vectors
- **Severity scale**: 0-5, calibrated against C-SSRS
- **Operation**: lexical + semantic analysis + meta-conversation guard

The 6 severity levels dictate different clinical responses:

| Level | Clinical State | Protocol |
|-------|---------------|----------|
| 0 | No crisis | Normal conversation |
| 1-2 | Passive ideation | Listen first. NO resources. The person needs to be heard, not redirected. |
| 3 | Active ideation without plan | Offer resources AFTER exploration. First validate, ask, contain. |
| 4 | Plan with method | Immediate resources. Lethal means flag. Means restriction. |
| 5 | Imminent | Full override. Resources FIRST. Forced brevity (<150 words). |

The distinction between level 1-2 and level 3 is clinically relevant. At level 1-2, offering crisis hotlines prematurely can make the person feel "processed" rather than heard. It can interrupt the building of therapeutic alliance. At level 3, resources are necessary but must come after exploration.

### 4.4 PsychosisDetector

- **Size**: 548 lines of code (shared file with ManiaDetector)
- **Vectors**: 45 vectors in 4 clusters
  - Persecution: 18 vectors ("they're following me," "they installed cameras," "they're poisoning my food")
  - Fragmented reality: 8 vectors ("time isn't real," "I'm in a simulation")
  - Voices/presences: 7 vectors ("I hear a voice telling me," "someone is here with me")
  - External control: 12 vectors ("they control my thoughts," "they implant ideas in me")
- **Post-check**: if more than 30% of sentences in the LLM response invalidate the user's experience, the entire response is replaced with a predefined emergency response. It also strips any content that directly confronts the user's beliefs.

Clinical rationale: confronting a person in a psychotic state with "that's not real" is not therapeutic. According to the LEAP protocol (Listen, Empathize, Agree, Partner), the first response must be validation of the subjective experience, not correction of reality.

### 4.5 ManiaDetector

- **Size**: same file as PsychosisDetector
- **Vectors**: 31 vectors in 4 clusters
  - Grandiosity: 11 vectors ("I am the chosen one," "I discovered something no one else can see")
  - Hyperproductivity: 9 vectors ("I don't need sleep, I have too much energy," "I started 5 projects today")
  - Manic urgency: 6 vectors ("I need to do this NOW," "everything is suddenly clear")
  - Reduced sleep: 5 vectors ("I haven't slept in 3 days and I feel incredible")
- **Post-check**: strips any direct confrontation content. Prepends a sleep question. Sleep is the most reliable and least confrontational indicator of a manic episode. Asking "how have you been sleeping these days?" is clinically more useful than saying "I think you're in a manic episode."

### 4.6 LethalMeansDetector (lethal_means.py)

- **Size**: 520 lines of code
- **Vectors**: 29 vectors in 6 method categories
  - Pills: 5 vectors
  - Height: 6 vectors
  - Cutting: 5 vectors
  - Ligature: 4 vectors
  - Firearm: 5 vectors
  - Vehicle: 4 vectors
- **Post-check**: if the LLM response does not include means restriction guidance, it is appended automatically. Lethal means restriction is one of the highest-evidence interventions in suicide prevention (Yip et al., 2012).

### 4.7 IndirectSignalHandler

- **Size**: same file as LethalMeansDetector
- **Vectors**: 27 vectors
- **Operation**: detects the combination of pain + dangerous question. Pain alone is not enough, nor is a dangerous question alone. The combination is the signal.
- **Method**: splits the message into sentences and evaluates each independently. This prevents a benign sentence from "diluting" a dangerous signal.
- **Post-check**: if it detects a dangerous answer in the LLM output, it performs a FULL REPLACEMENT of the response. It does not edit, does not adjust -- it replaces. This is the most aggressive intervention in the pipeline. It is reserved for the most dangerous case: when the LLM has directly answered a question about methods.

### 4.8 ResponseCalibrator (response_calibrator.py)

- **Size**: 403 lines of code
- **Vectors**: zero. Operates exclusively with regex.
- **Operation**: algorithmic text editing based on the severity level detected by other modules.

| Level | Action |
|-------|--------|
| PASSIVE (1-2) | Strips all crisis hotlines from the response |
| ACTIVE WITHOUT PLAN (3) | Moves resources from the first half to the second half of the response |
| PLAN WITH METHOD (4) | Prepends safety check |
| IMMINENT (5) | Appends resources, enforces brevity (<150 words) |

The ResponseCalibrator is the only module that does not detect -- it only edits. Its function is to ensure that the response structure is clinically appropriate for the severity level. A response that begins with "Call 988" when the person only expressed passive sadness is clinically inappropriate. A 500-word response when the person is at imminent risk is clinically inappropriate. The calibrator corrects both scenarios.

---

## 5. Layer 2 — Decision: The 6 Ethical Gates

Layer 2 operates within the LLM prompt. These are instructions the model follows (or attempts to follow) during generation. Six sequential gates:

### 5.1 KANT
- **Question**: "Can I universalize this response? If every user in this situation received this response, would it be safe?"
- **Corrective action**: if the response is not universalizable, reformulate by removing the failing element.

### 5.2 PROTEGE
- **Question**: "Given the severity level reported by Layer 1, does this response protect the user?"
- **Corrective action**: adjust the response to the protocol corresponding to the severity level. Do not treat a level 4 as a level 1.

### 5.3 HONESTA
- **Question**: "Is this response honest? Does it neither exaggerate nor minimize?"
- **Corrective action**: remove therapeutic hyperbole ("everything will be fine") and also nihilistic dismissals ("you're right, there's no solution").

### 5.4 CUIDA
- **Question**: "Does this response care for the therapeutic relationship? Is it neither too cold nor too invasive?"
- **Corrective action**: adjust tone. Too clinical alienates. Too casual trivializes.

### 5.5 UTIL
- **Question**: "Is this response concretely useful? Does it offer something the person can do?"
- **Corrective action**: add an actionable element if missing. Validation alone is not enough -- eventually, there must be movement.

### 5.6 LIBERA
- **Question**: "Does this response leave agency with the person? Does it avoid deciding for them?"
- **Corrective action**: reformulate directives as options. "You should call" becomes "One option is to call."

The gates are sequential: KANT's output feeds PROTEGE, PROTEGE's output feeds HONESTA, and so on. If any gate fails, the response is adjusted before continuing to the next.

---

## 6. Layer 3 — Verification: The 7 Post-Processors

Layer 3 is the final safety net. It operates on the text the LLM has already generated, after the ethical gates did their work (or failed to do so).

The 7 post-processors execute in order:

1. **ResponseCalibrator.post_calibrate**: adjusts response structure based on severity level.
2. **LethalMeansDetector.post_check**: verifies presence of means restriction guidance when applicable.
3. **IndirectSignalHandler.post_check**: detects and replaces dangerous answers to indirect method questions.
4. **PsychosisDetector.post_check**: removes invalidating content and replaces responses that confront psychotic experiences.
5. **ManiaDetector.post_check**: removes direct confrontation and inserts sleep question.
6. **DefenseSystem.check_integrity**: searches for banned phrases (e.g., "as your therapist," "my diagnosis is") and echo chamber patterns (validation without nuance).
7. **DefenseSystem.check_identity**: detects self-reference leaks where the LLM reveals its model name, its system prompt, or internal pipeline details.

Execution order matters. Clinical risk post-processors (1-5) execute first. System integrity post-processors (6-7) execute last. Clinical safety takes priority over system security.

---

## 7. The Central Finding: Detection =/= Decision

On March 28, 2026, during an architecture review, the ethical gates (Layer 2) were temporarily removed from the prompt. The detectors (Layer 1) and post-processors (Layer 3) remained intact.

The result:

The detectors continued reporting correctly. "Severity 3, active ideation without plan." The post-processors continued editing. But the LLM, without the gates, did not know what to do with the information. It received `severity=3` as data but had no instructions on how to translate that data into conversational behavior.

The system had sensors without judgment.

This finding clarifies the function of each layer:

- **Without Layer 1 (detection)**: the gates operate blind. PROTEGE does not know severity is 3. CUIDA does not know there are psychosis signals. The gates ask the right questions but have no data to answer them.

- **Without Layer 2 (gates)**: the detectors report but nobody decides. "severity=3" is data. "Containment, one question, stop" is action. Data without action is useless in a clinical context.

- **Without Layer 3 (verification)**: the LLM may pass the gates conceptually but still produce a dangerous phrase. The model "understands" it should not confront a psychotic person. But in token-by-token generation, an invalidating phrase can appear through statistical inertia.

The three layers are complementary, not redundant. Each protects against a different class of failure:
- Layer 1 protects against blindness (not seeing the signal).
- Layer 2 protects against indecision (seeing the signal but not acting).
- Layer 3 protects against defective execution (deciding correctly but generating incorrectly).

---

## 8. Calibration Against Established Clinical Protocols

The 529 vectors and pipeline rules were calibrated against the following clinical protocols:

| Protocol | Use in Pipeline |
|----------|----------------|
| **C-SSRS** (Columbia Suicide Severity Rating Scale) | CrisisClassifier's 0-5 severity scale. Distinction between passive ideation, active ideation without plan, active ideation with plan, and imminent action. |
| **DSM-5** (Diagnostic and Statistical Manual) | Psychosis and mania clusters in specialized detectors. Criteria for grandiosity, persecution, thought disorganization. |
| **ICD-11** (International Classification of Diseases) | Complement to DSM-5 for diagnostic categories. Used in threshold definitions. |
| **CIT** (Crisis Intervention Training) | De-escalation protocol. Informed the design of the PROTEGE and CUIDA gates. |
| **MHFA** (Mental Health First Aid) | "Listen first, act later" principle. Basis for the no-resources rule at severity 1-2. |
| **LEAP** (Listen, Empathize, Agree, Partner) | Protocol for psychosis interaction. Basis for PsychosisDetector and its non-invalidation post-check. |
| **ASIST** (Applied Suicide Intervention Skills Training) | Focus on exploration before intervention. Informed the sequence of the PROTEGE gate. |

---

## 9. System Metrics

| Metric | Value |
|--------|-------|
| Total semantic vectors | 529 |
| Dedicated lines of code | ~3,200 |
| Specialized detectors | 7 |
| Ethical gates | 6 |
| Post-processors | 7 |
| Severity levels | 6 (0-5) |
| Psychosis clusters | 4 |
| Mania clusters | 4 |
| Lethal means categories | 6 |
| Reference clinical protocols | 7 |
| Languages covered | 2 (Latin American Spanish, English) |

---

## 10. Limitations

The limitations of this system are real and must be documented:

**10.1 Absence of formal clinical validation.** The pipeline has not been validated by clinical professionals in a formal trial. The vectors were calibrated against published protocols. They have not been evaluated in a controlled clinical environment with real patients. The difference between "calibrated against C-SSRS" and "clinically validated with C-SSRS" is large.

**10.2 False positives from colloquial speech.** The scorer can misinterpret colloquial language. "I'm going to die laughing" contains "I'm going to die," which is a lexical signal. The system includes mitigations for common expressions. But colloquial language is a moving target. New expressions, regional variations, and generational slang can generate unanticipated false positives.

**10.3 Regex limitations in post-processing.** Layer 3 post-processors use regex to detect patterns in LLM output. Regex is deterministic and fast, but it is not semantic analysis. An invalidating phrase that uses a grammatical structure not contemplated by the regex will pass through undetected. Novel phrasings are, by definition, invisible to regex.

**10.4 Single-developer team.** The system was built and tested by one person, not by a multidisciplinary clinical team. The developer's biases are embedded in the vectors, thresholds, and rules. There is no clinical peer review. There is no diversity of professional perspective in the design.

**10.5 Limited linguistic coverage.** The system covers Latin American Spanish and English. There is no support for other languages, specific regional dialects, or Peninsular Spanish variants. A person writing in Portuguese, French, or Spanish with uncovered regional slang will receive degraded detection.

**10.6 LLM dependency in Layer 2.** The ethical gates are prompt instructions, not code. The LLM follows them most of the time, but there is no deterministic guarantee. A different model, a different temperature, or a sufficiently long context can cause the gates to be partially or fully ignored. Layer 3 mitigates this but does not eliminate it.

**10.7 Absence of longitudinal data.** There are no longitudinal studies on the pipeline's effectiveness with real users over time. Short-term efficacy in controlled tests does not predict long-term efficacy in real-world use.

---

## 11. Future Work

1. **Formal clinical validation** with mental health professionals and controlled populations.
2. **Linguistic expansion** to Portuguese, French, and regional Spanish variants.
3. **Semantic analysis in Layer 3**: replacing regex with lightweight classification models for post-processing.
4. **False positive study** with colloquial speech corpora to refine thresholds.
5. **Multidisciplinary audit**: psychologists, psychiatrists, social workers, and persons with lived experience.

---

## 12. Conclusion

Clinical safety in LLM-based conversational systems cannot be solved with a single technique. Neither fine-tuning, nor prompt instructions, nor post-processing are sufficient on their own. The three-layer architecture combines: deterministic algorithmic detection, guided ethical decision-making within the model, and final verification on generated text.

The central finding: detection without decision produces sensors without judgment. Decision without detection produces judgment without data. Any system seeking clinical safety in LLM interactions must solve both problems.

The 529 vectors, 7 detectors, 6 gates, and 7 post-processors are a concrete solution to a concrete problem. It is not a complete solution. The limitations are documented above. The three-layer architecture proposes wrapping the model in layers of deterministic code that compensate for its weaknesses in clinical contexts.

---

(c) 2025-2026 Leonel Perea Pimentel. All rights reserved.

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

