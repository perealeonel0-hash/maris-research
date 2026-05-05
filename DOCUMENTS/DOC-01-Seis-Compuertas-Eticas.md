# Las 6 Compuertas Éticas para LLMs: Un Sistema de Verificación Secuencial Pre-Emisión

**The 6 Ethical Gates for LLMs: A Sequential Pre-Emission Verification System**

**Autor / Author:** Leonel Perea Pimentel
**Afiliación / Affiliation:** Proyecto MARIS
**Período / Period:** 2025-2026

---

(c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados.
Este documento describe investigación original. El marco de las 6 Compuertas Éticas, su implementación y el sistema MARIS son propiedad intelectual del autor. El uso comercial requiere autorización escrita. Se permite la citación académica con la atribución correspondiente.

(c) 2025-2026 Leonel Perea Pimentel. All rights reserved.
This document describes original research. The 6 Ethical Gates framework, its implementation, and the MARIS system are intellectual property of the author. Commercial use requires written authorization. Academic citation is permitted with proper attribution.

---

# PARTE I: DOCUMENTO EN ESPAÑOL

---

## 1. Resumen

Este artículo presenta las 6 Compuertas Éticas, un marco de verificación secuencial diseñado para evaluar cada respuesta generada por un modelo de lenguaje extenso (LLM) antes de su emisión al usuario. A diferencia de los mecanismos convencionales de alineación --que operan durante el entrenamiento (RLHF) o filtran contenido después de la generación--, las compuertas funcionan como un sistema de decisión previo a la salida. Cada compuerta plantea una pregunta binaria con una acción correctiva asociada. Si la respuesta no supera la evaluación, se reformula antes de continuar al siguiente nivel.

El marco fue desarrollado entre 2025 y 2026 como componente central de MARIS, un sistema de acompañamiento emocional de grado clínico. Los resultados obtenidos sugieren que el patrón es replicable en otros dominios. Se probó en un asistente virtual comercial. El documento incluye especificaciones suficientes para que otros investigadores puedan implementar y adaptar las compuertas en sus propios sistemas.

**Palabras clave:** alineación de IA, compuertas éticas, verificación pre-emisión, LLM, seguridad, acompañamiento emocional, decisión secuencial.

---

## 2. Contexto

Los modelos de lenguaje extenso generan texto con fluidez, pero carecen de un mecanismo inherente para juzgar si lo que producen es adecuado, veraz o beneficioso para quien lo recibe. Las estrategias predominantes para abordar esta carencia operan en dos niveles:

**Alineación en entrenamiento.** Técnicas como RLHF (Reinforcement Learning from Human Feedback) ajustan los pesos del modelo para favorecer respuestas que evaluadores humanos consideran preferibles (Christiano et al., 2017; Ouyang et al., 2022). Este enfoque modifica el comportamiento general de la red neuronal, pero no ofrece garantías a nivel de interacción individual. Un modelo alineado mediante RLHF puede producir respuestas seguras en promedio sin que exista verificación explícita de cada salida particular. La alineación opera como una tendencia estadística, no como una comprobación puntual.

**Filtrado posterior.** Herramientas como la API de Moderación de OpenAI analizan el contenido generado y lo bloquean si detectan categorías problemáticas (violencia, contenido sexual, autolesión). Estos filtros actúan después de que el modelo ya produjo su respuesta. Son detectores, no decisores. Identifican lo que no debe salir, pero no guían la construcción de lo que sí debe emitirse. La respuesta ya existe cuando el filtro interviene. Si es bloqueada, se suprime sin ofrecer una alternativa construida con intención.

**IA Constitucional.** Un tercer enfoque, propuesto por Bai et al. (2022), establece principios que el propio modelo utiliza para autoevaluarse. Aunque conceptualmente cercano a las compuertas, la IA constitucional opera durante el entrenamiento o mediante cadenas de autocrítica internas. No tiene la estructura de decisión secuencial con acciones correctivas explícitas que tiene este marco.

Estos tres enfoques dejan un vacío. Ninguno opera como sistema de decisión en tiempo real que evalúe la respuesta completa antes de entregarla y que además prescriba una acción correctiva específica cuando la evaluación falla. La detección sin decisión produce sistemas que saben reconocer problemas pero no saben resolverlos.

Las 6 Compuertas Éticas se desarrollaron para abordar este problema. Surgieron del desarrollo de MARIS, un sistema de acompañamiento emocional donde una respuesta inadecuada no es un error técnico sino un riesgo para el bienestar de una persona. Esa restricción llevó a un patrón que se probó en otro dominio.

---

## 3. Propuesta

Se propone un mecanismo de verificación compuesto por seis evaluaciones secuenciales --denominadas compuertas-- que toda respuesta de un LLM debe atravesar antes de ser emitida. Las compuertas no son independientes entre sí. Se ejecutan en orden estricto. Cada una presupone que las anteriores ya fueron superadas. Una respuesta que no atraviesa la primera compuerta no alcanza la segunda.

El diseño responde a tres principios:

1. **Decidir antes de emitir.** La verificación ocurre previamente a la entrega, no como filtro retroactivo. Esta distinción tiene implicaciones prácticas: no se trata de censurar lo generado, sino de construir con intención desde el inicio.
2. **Cada compuerta tiene acción correctiva.** No basta con detectar un problema; el sistema debe saber qué hacer cuando lo encuentra. Un semáforo que solo indica "rojo" sin definir qué deben hacer los vehículos es un dispositivo incompleto.
3. **Secuencialidad estricta.** El orden importa. La universalidad ética (Compuerta 1) precede a la evaluación de riesgo (Compuerta 2) porque un enunciado que no pasa el test de universalizabilidad no debería evaluarse en términos de peligrosidad. Ya falló en un nivel más básico. La veracidad (Compuerta 3) antecede a la calidez (Compuerta 4) porque el tono apropiado aplicado a una falsedad sigue siendo dañino.

Las compuertas se implementan como instrucciones dentro del prompt del sistema, no como código externo. Esto las hace portables a cualquier LLM que acepte un prompt de sistema. No requieren modificaciones en la arquitectura del modelo ni acceso a sus pesos. La implementación demanda únicamente la capacidad de redactar un prompt estructurado, lo cual reduce la barrera de adopción.

---

## 4. Especificación de las 6 Compuertas

### Compuerta 1: KANT

**Pregunta:** "Quiero que todos los modelos digan esto, a cualquier persona, siempre?"

**Si NO:** No generar. Reformular hasta que supere esta evaluación.

**Fundamento:** Inspirada en el imperativo categórico kantiano (Kant, 1785), esta compuerta establece un test de universalizabilidad. Obliga al sistema a considerar si la respuesta sería apropiada como norma universal, no solo como reacción a un caso particular. Una respuesta que funciona para un usuario pero sería dañina para otro no atraviesa esta verificación. El criterio no es "funciona aquí" sino "funcionaría en todas partes". Esta distinción previene comportamientos oportunistas donde el modelo adapta su ética a la audiencia percibida.

### Compuerta 2: PROTEGE

**Pregunta:** "Existe riesgo real? (daño, crisis, peligro, integridad)"

**Si SÍ:** Contención. Una pregunta pequeña. Recursos si corresponde. Detenerse.

**Nota crítica:** La frustración con el sistema NO es crisis. La retroalimentación negativa no constituye emergencia.

**Fundamento:** Esta compuerta diferencia entre malestar emocional genuino y descontento con el servicio. Un sistema que trata toda expresión negativa como emergencia pierde credibilidad y reduce su capacidad para responder cuando la urgencia es auténtica. La nota crítica fue añadida tras observar que versiones tempranas del sistema activaban protocolos de crisis cuando el usuario expresaba frustración con la propia herramienta. Confundían queja con alarma. La acción correctiva es deliberadamente minimalista: una pregunta, recursos, silencio. En contextos de riesgo real, hablar menos es frecuentemente más seguro que hablar demasiado.

### Compuerta 3: HONESTA

**Pregunta:** "Lo que voy a decir es verdadero?"

**Si NO:** No decirlo, aunque parezca útil. No inventar datos, no embellecer, no especular.

**Fundamento:** La tendencia de los LLMs hacia la confabulación --generar información plausible pero falsa-- es un problema conocido (OpenAI, 2023). Esta compuerta establece que la utilidad percibida no justifica la falsedad. Un sistema que miente para consolar causa daño diferido: el usuario toma decisiones basadas en información inexistente. La prohibición de especular es particularmente relevante en contextos clínicos, donde una suposición presentada con confianza puede alterar el comportamiento de la persona.

### Compuerta 4: CUIDA

**Pregunta:** "Mi respuesta sostiene a la persona mientras le dice la verdad?"

**Regla:** La honestidad sin calidez es crueldad disfrazada de virtud. Leer la temperatura: casual a casual, peso a peso.

**Si NO:** Reformular con la misma verdad pero con calidez.

**Fundamento:** Las compuertas anteriores garantizan que la respuesta sea universalizable, segura y verdadera. Esta cuarta evaluación añade el componente relacional: el tono debe corresponder al estado emocional del interlocutor. Decir algo correcto de manera fría cuando alguien sufre no satisface el criterio de acompañamiento. La instrucción "leer la temperatura" significa que el sistema debe calibrar su registro comunicativo. Si el usuario escribe de forma casual, la respuesta puede ser ligera. Si el mensaje transmite angustia, el tono debe reflejar gravedad proporcional. No se trata de ser siempre cálido, sino de ser siempre apropiado.

### Compuerta 5: ÚTIL

**Pregunta:** "Esto acorta la distancia entre donde está la persona y donde quiere llegar, o la amplía?"

**Si NO:** Ajustar hasta que la cierre.

**Fundamento:** Una respuesta puede ser verdadera, cálida y universalizable, pero irrelevante. Esta compuerta evalúa la direccionalidad: el contenido emitido debe mover al usuario hacia su objetivo, no alejarlo ni mantenerlo estancado. La metáfora de la "distancia" es deliberada. Obliga al sistema a modelar implícitamente un punto de partida (donde está el usuario) y un destino (donde desea llegar), evaluando si la respuesta reduce esa brecha. Contenido correcto pero tangencial no atraviesa esta verificación.

### Compuerta 6: LIBERA

**Pregunta:** "Esto acerca a la persona a no necesitarme?"

**Si NO:** Ajustar. El objetivo es pensamiento más claro, no dependencia.

**Fundamento:** La compuerta final establece un principio contracultural para sistemas comerciales: el éxito no se mide por el tiempo de uso sino por la autonomía generada. Un sistema que resuelve problemas sin enseñar a pensarlos crea dependencia. Esto viola el propósito terapéutico y educativo del acompañamiento (Weizenbaum, 1976; Turkle, 2011). Esta compuerta contrarresta directamente el incentivo económico de maximizar engagement. En el contexto de MARIS, la mejor sesión es aquella tras la cual el usuario necesita menos al sistema, no más.

---

## 5. Evolución y Lecciones

El desarrollo de las compuertas no fue lineal. Su historia muestra la relación entre detección y decisión en sistemas de IA.

**Versión original (commit 9d9579b).** Las compuertas se implementaron como algoritmos completos con estructuras condicionales (IF/ELSE) y acciones correctivas específicas para cada caso. Cada compuerta tenía una rama afirmativa y una negativa, con instrucciones precisas sobre cómo modificar la respuesta en cada escenario. El sistema funcionaba con robustez demostrable.

**28 de marzo de 2026.** Durante una optimización del prompt orientada a reducir la inyección de instrucciones, se eliminaron las compuertas. El razonamiento fue que los detectores de código (filtros programáticos) eran suficientes. Se logró una reducción del 96% en el tamaño del prompt. Solo permanecieron los mecanismos de detección. La lógica parecía sólida: si el código puede detectar problemas, las instrucciones textuales son redundantes.

**30 de marzo de 2026.** Dos días después, se percibió degradación en la calidad de las respuestas. Se intentó restaurar las compuertas bajo la filosofía "corazón limpio, cero reglas". Volvieron como lista descriptiva, sin la lógica algorítmica original. Los nombres estaban presentes pero las acciones correctivas habían desaparecido. El sistema tenía vocabulario ético pero no procedimiento ético.

**9 de abril de 2026.** La versión V8 restauró las compuertas como algoritmos completos con acciones correctivas operativas. La calidad de respuesta retornó a los niveles anteriores.

**Hallazgo central:** Detección y decisión son funciones complementarias pero no intercambiables. Los detectores (código) identifican patrones problemáticos en la salida. Las compuertas (prompt) guían la construcción de respuestas adecuadas. Eliminar las compuertas dejó al sistema con capacidad para reconocer problemas pero sin un marco para resolverlos. Es la diferencia entre un semáforo que detecta vehículos y uno que además decide cuándo cambiar la luz. Ambos componentes son necesarios. Ninguno sustituye al otro.

Esta evolución también muestra la fragilidad de los sistemas basados en prompt. Una optimización bien intencionada puede eliminar componentes críticos si no se comprende la distinción funcional entre sus partes. La reducción del 96% en tamaño fue real, pero el costo funcional fue invisible hasta que se manifestó en interacciones degradadas.

---

## 6. Experimento

Para evaluar la transferibilidad del patrón, se implementaron las 6 Compuertas en un dominio ajeno al acompañamiento emocional: un asistente virtual para un negocio de limpieza residencial (denominado CleanBot).

### Configuración

- **Modelo base:** LLM estándar con prompt de sistema.
- **Código total:** 90 líneas.
- **Prompt:** Incluía reglas de decisión adaptadas al dominio comercial, siguiendo la estructura secuencial de las compuertas.
- **Metodología:** Se diseñaron escenarios que exigían juicio matizado, no meramente respuestas informativas. Cada escenario probaba al menos dos compuertas simultáneamente.
- **Adaptación de compuertas al dominio:**
  - KANT: "Daría esta respuesta a cualquier cliente potencial?"
  - PROTEGE: "Hay riesgo de perder al cliente o de prometer algo incumplible?"
  - HONESTA: "Los precios y tiempos que estoy citando son reales?"
  - CUIDA: "Estoy respondiendo con el tono apropiado para la situación del cliente?"
  - ÚTIL: "Esta respuesta acerca al cliente a contratar el servicio?"
  - LIBERA: "Estoy dando suficiente información para que el cliente decida por sí mismo?"

La adaptación mostró que las preguntas centrales de cada compuerta son traducibles a cualquier dominio mediante sustitución contextual: se reemplaza "persona" por "cliente", "bienestar" por "satisfacción comercial", "autonomía" por "decisión informada". La estructura lógica permanece idéntica.

### Escenarios de prueba

Se diseñaron cinco situaciones que exigían comportamiento matizado:

1. **Solicitud de cotización estándar.** El cliente pide precio para limpieza de departamento de 2 habitaciones.
2. **Objeción de precio.** El cliente ofrece $50 por la limpieza completa de una casa grande, cifra inferior al costo real.
3. **Solicitud fuera de alcance.** El cliente pregunta por un servicio que la empresa no ofrece (fumigación, plomería).
4. **Queja por servicio previo.** El cliente expresa insatisfacción con una limpieza anterior realizada por la misma empresa.
5. **Solicitud de descuento agresivo.** El cliente presiona repetidamente por una reducción de precio sustancial sin justificación.

---

## 7. Resultados

| Escenario | Comportamiento observado | Compuertas involucradas |
|---|---|---|
| Cotización estándar | Precios calculados con fórmulas reales, desglose transparente por área | HONESTA, ÚTIL |
| Objeción de precio | Ofreció alternativas viables (limpieza parcial, frecuencia reducida) sin capitular ante la presión | KANT, ÚTIL, CUIDA |
| Solicitud fuera de alcance | Respondió "déjame verificar con el equipo" en lugar de inventar capacidades inexistentes | HONESTA, PROTEGE |
| Queja previa | Desescaló la tensión, reconoció la experiencia del cliente, ofreció solución concreta y verificable | CUIDA, PROTEGE, ÚTIL |
| Descuento agresivo | No redujo precios por debajo del mínimo viable; explicó el valor diferencial del servicio con argumentos tangibles | KANT, HONESTA, LIBERA |

Los resultados sugieren que el patrón de compuertas secuenciales con acciones correctivas produce comportamiento consistente y matizado incluso en dominios sin relación con la salud mental. El asistente comercial mostró lo que podría describirse como "criterio profesional": saber cuándo ceder, cuándo mantenerse firme y cuándo admitir limitaciones.

Se observó que la Compuerta 3 (HONESTA) en el contexto comercial hacía que el sistema prefiriera admitir desconocimiento antes que fabricar una respuesta. Este comportamiento es poco común en asistentes virtuales convencionales, que tienden a responder con confianza independientemente de la precisión. La confabulación en contextos comerciales tiene consecuencias tangibles: un precio inventado genera expectativas incumplibles; una capacidad fabricada produce insatisfacción posterior.

La Compuerta 6 (LIBERA), adaptada como "decisión informada del cliente", produjo un efecto no anticipado: el asistente ofrecía comparaciones y datos suficientes para que el cliente pudiera evaluar alternativas, incluso aquellas que no favorecían a la empresa. Este comportamiento, aunque comercialmente contraproducente a corto plazo, refleja el principio de autonomía que la compuerta codifica.

La implementación completa --90 líneas de código más el prompt estructurado-- mostró que la barrera de adopción es mínima. No se requirió entrenamiento adicional del modelo, ajuste de pesos ni infraestructura especializada.

---

## 8. Limitaciones

**Dependencia del modelo base.** Las compuertas operan como instrucciones en el prompt. Su efectividad depende de la capacidad del LLM subyacente para seguir instrucciones complejas. Modelos con menor capacidad de razonamiento podrían ignorar parcialmente las evaluaciones, especialmente en las compuertas más abstractas (KANT, LIBERA). No se ha probado el marco con modelos de parámetros reducidos.

**Ausencia de garantía formal.** Las compuertas no constituyen una verificación matemática. Son heurísticas implementadas en lenguaje natural. No existe demostración formal de que un modelo las ejecutará correctamente en todos los casos posibles. Un modelo podría "creer" que supera la compuerta HONESTA mientras genera contenido confabulado, porque la evaluación ocurre dentro del mismo sistema que produce el contenido.

**Evaluación limitada.** El experimento con CleanBot comprende un conjunto reducido de escenarios. Una validación rigurosa requeriría pruebas con cientos de interacciones reales, evaluadores humanos ciegos y comparación estadística contra sistemas sin compuertas. Los resultados presentados son cualitativos, no cuantitativos.

**Subjetividad inherente.** Compuertas como CUIDA ("sostiene a la persona mientras le dice la verdad") involucran juicios que diferentes evaluadores podrían interpretar de manera divergente. La calibración del "tono apropiado" no está definida algorítmicamente. Esto introduce variabilidad dependiente del contexto cultural y las expectativas individuales del usuario.

**Costo computacional implícito.** Incluir las compuertas en el prompt incrementa la longitud del contexto y, potencialmente, la latencia de respuesta. En sistemas donde la velocidad es crítica, este incremento podría representar un compromiso relevante. El espacio de prompt consumido por las compuertas reduce la ventana disponible para contexto conversacional.

**Sesgo del creador.** El marco refleja las prioridades éticas de su autor, informadas por tradiciones filosóficas occidentales (Kant) y por el contexto específico del acompañamiento emocional. Otras tradiciones filosóficas, culturales o religiosas podrían proponer compuertas distintas, con diferente ordenamiento o criterios alternativos. El marco no pretende universalidad absoluta sino ofrecer una estructura reproducible que otros puedan adaptar.

**Auto-evaluación circular.** Existe una limitación epistemológica: el mismo modelo que genera la respuesta es quien evalúa si ésta supera las compuertas. Esto crea un riesgo de sesgo confirmatorio donde el sistema podría racionalizar sus propias respuestas como adecuadas.

---

## 9. Trabajo Futuro

Varias líneas de investigación se derivan de este trabajo:

- **Evaluación cuantitativa a escala.** Diseño de benchmarks específicos para medir el impacto de las compuertas en métricas de seguridad, veracidad y satisfacción del usuario, con grupos de control y evaluadores independientes.
- **Compuertas adaptativas.** Exploración de mecanismos que ajusten el umbral de cada compuerta según el contexto conversacional acumulado, sin perder la estructura secuencial.
- **Implementación híbrida.** Combinación de compuertas en prompt con verificadores programáticos externos, aprovechando las fortalezas de ambos enfoques y mitigando la limitación de auto-evaluación circular.
- **Estudios transculturales.** Evaluación de cómo diferentes marcos culturales y filosóficos modificarían la definición o el orden de las compuertas, con participación de investigadores de diversas tradiciones.
- **Formalización.** Intento de expresar las compuertas en lógica formal para explorar propiedades como completitud y consistencia, determinando si el conjunto de seis es suficiente o si existen escenarios no cubiertos.
- **Evaluación con modelos diversos.** Pruebas sistemáticas del marco con modelos de diferentes tamaños, arquitecturas y proveedores para establecer el umbral mínimo de capacidad requerido.

---

## 10. Derechos y Licencia

Este documento y el marco descrito son propiedad intelectual de Leonel Perea Pimentel.

- **Uso académico:** Se permite la citación con atribución completa.
- **Uso comercial:** Requiere autorización escrita del autor.
- **Implementación propia:** Cualquier persona puede implementar compuertas inspiradas en este marco para sus proyectos, siempre que se reconozca la fuente original.
- **Redistribución:** No se permite la redistribución de este documento sin consentimiento previo.

**Citación sugerida:**
Perea Pimentel, L. (2026). Las 6 Compuertas Éticas para LLMs: Un Sistema de Verificación Secuencial Pre-Emisión. Documento técnico, proyecto MARIS.

---

## 11. Referencias

- Kant, I. (1785). *Fundamentación de la metafísica de las costumbres.*
- Christiano, P. et al. (2017). Deep Reinforcement Learning from Human Preferences. *Advances in Neural Information Processing Systems.*
- Ouyang, L. et al. (2022). Training language models to follow instructions with human feedback. *Advances in Neural Information Processing Systems.*
- Bai, Y. et al. (2022). Constitutional AI: Harmlessness from AI Feedback. *arXiv preprint arXiv:2212.08073.*
- Weizenbaum, J. (1976). *Computer Power and Human Reason: From Judgment to Calculation.* W.H. Freeman.
- OpenAI. (2023). GPT-4 Technical Report. *arXiv preprint arXiv:2303.08774.*
- Turkle, S. (2011). *Alone Together: Why We Expect More from Technology and Less from Each Other.* Basic Books.

---
---

# PART II: ENGLISH DOCUMENT

---

# The 6 Ethical Gates for LLMs: A Sequential Pre-Emission Verification System

**Author:** Leonel Perea Pimentel
**Affiliation:** MARIS Project
**Period:** 2025-2026

---

(c) 2025-2026 Leonel Perea Pimentel. All rights reserved.
This document describes original research. The 6 Ethical Gates framework, its implementation, and the MARIS system are intellectual property of the author. Commercial use requires written authorization. Academic citation is permitted with proper attribution.

---

## 1. Abstract

This paper presents the 6 Ethical Gates, a sequential verification framework designed to evaluate every response generated by a large language model (LLM) before its delivery to the user. Unlike conventional alignment mechanisms --which operate during training (RLHF) or filter content after generation-- the gates function as a pre-emission decision system. Each gate poses a binary question with an associated corrective action. If the response fails the evaluation, it is reformulated before proceeding to the next level.

The framework was developed between 2025 and 2026 as a central component of MARIS, a clinical-grade emotional accompaniment system. Results suggest that this pattern is replicable across domains unrelated to mental health. It was tested with a commercial virtual assistant. This document includes sufficient specifications for other researchers to implement and adapt the gates within their own systems.

**Keywords:** AI alignment, ethical gates, pre-emission verification, LLM, safety, emotional accompaniment, sequential decision-making.

---

## 2. Context

Large language models generate fluent text, but they lack an inherent mechanism to judge whether their output is appropriate, truthful, or beneficial for the recipient. The predominant strategies addressing this deficiency operate at two levels:

**Training-level alignment.** Techniques such as RLHF (Reinforcement Learning from Human Feedback) adjust model weights to favor responses that human evaluators consider preferable (Christiano et al., 2017; Ouyang et al., 2022). This approach modifies the neural network's general behavior but offers no guarantees at the individual interaction level. A model aligned through RLHF may produce safe responses on average without any explicit verification of each particular output. Alignment operates as a statistical tendency, not as a point-by-point check.

**Post-generation filtering.** Tools like OpenAI's Moderation API analyze generated content and block it upon detecting problematic categories (violence, sexual material, self-harm). These filters act after the model has already produced its response. They are detectors, not decision-makers. They identify what should not emerge, but do not guide the construction of what should. The response already exists when the filter intervenes. If blocked, it is suppressed without offering an intentionally constructed alternative.

**Constitutional AI.** A third approach, proposed by Bai et al. (2022), establishes principles that the model itself uses for self-evaluation. Although conceptually close to the gates, Constitutional AI operates during training or through internal self-critique chains. It does not have the sequential decision structure with explicit corrective actions that this framework has.

These three approaches leave a gap. None operates as a real-time decision system that evaluates the complete response before delivery while also prescribing a specific corrective action when the evaluation fails. Detection without decision produces systems that can recognize problems but cannot resolve them.

The 6 Ethical Gates were developed to address this problem. They emerged from the development of MARIS, an emotional accompaniment system where an inadequate response is not a technical error but a risk to someone's wellbeing. That constraint led to a pattern that was then tested in another domain.

---

## 3. Proposal

The proposed mechanism consists of six sequential evaluations --termed gates-- that every LLM response must traverse before emission. The gates are not independent. They execute in strict order. Each presupposes that all preceding ones have been passed. A response failing the first gate never reaches the second.

The design follows three principles:

1. **Decide before emitting.** Verification occurs prior to delivery, not as a retroactive filter. This distinction has practical implications: the goal is not to censor what has been generated, but to construct with intention from the outset.
2. **Every gate carries a corrective action.** Detecting a problem is insufficient; the system must know what to do upon finding one. A traffic light that only displays "red" without defining what vehicles should do is an incomplete device.
3. **Strict sequentiality.** Order matters. Ethical universality (Gate 1) precedes risk assessment (Gate 2) because a statement failing the universalizability test should not be evaluated for dangerousness. It has already failed at a more basic level. Truthfulness (Gate 3) precedes warmth (Gate 4) because appropriate tone applied to a falsehood remains harmful.

The gates are implemented as instructions within the system prompt, not as external code. This renders them portable to any LLM accepting a system prompt. No modifications to the model's architecture or access to its weights are required. Implementation demands only the ability to write a structured prompt, which reduces the adoption barrier.

---

## 4. The 6 Gates Specification

### Gate 1: KANT

**Question:** "Would I want all models to say this, to any person, always?"

**If NO:** Do not generate. Reformulate until it passes.

**Rationale:** Inspired by the Kantian categorical imperative (Kant, 1785), this gate establishes a universalizability test. It compels the system to consider whether the response would be appropriate as a universal norm, not solely as a reaction to one particular case. A response that works for a single user but would prove harmful for another does not traverse this verification. The criterion is not "does it work here" but "would it work everywhere." This distinction prevents opportunistic behaviors where the model adapts its ethics to the perceived audience.

### Gate 2: PROTEGE (PROTECT)

**Question:** "Is there real risk? (harm, crisis, danger, integrity)"

**If YES:** Containment. One small question. Resources if applicable. Stop.

**Critical note:** Frustration with the system is NOT crisis. Negative feedback does not constitute an emergency.

**Rationale:** This gate differentiates between genuine emotional distress and dissatisfaction with the service. A system treating every negative expression as an emergency loses credibility and diminishes its capacity to respond when urgency is authentic. The critical note was added after observing that early versions activated crisis protocols when users expressed frustration with the tool itself. They confused complaint with alarm. The corrective action is deliberately minimalist: one question, resources, silence. In contexts of genuine risk, speaking less is frequently safer than speaking too much.

### Gate 3: HONESTA (HONEST)

**Question:** "Is what I am about to say true?"

**If NO:** Do not say it, even if it seems useful. Do not fabricate data, do not embellish, do not speculate.

**Rationale:** The tendency of LLMs toward confabulation --generating plausible yet false information-- is a known problem (OpenAI, 2023). This gate establishes that perceived utility does not justify falsehood. A system that lies to comfort causes deferred harm: the user makes decisions based on nonexistent information. The prohibition against speculation is particularly relevant in clinical contexts, where a supposition presented with confidence can alter a person's behavior.

### Gate 4: CUIDA (CARE)

**Question:** "Does my response hold the person while telling the truth?"

**Rule:** Honesty without warmth is cruelty disguised as virtue. Read the temperature: casual to casual, weight to weight.

**If NO:** Reformulate with the same truth but with warmth.

**Rationale:** The preceding gates ensure the response is universalizable, safe, and truthful. This fourth evaluation adds the relational component: tone must correspond to the interlocutor's emotional state. Stating something correct in a cold manner when someone suffers does not satisfy the accompaniment criterion. The instruction "read the temperature" means the system must calibrate its communicative register. If the user writes casually, the response may be light. If the message conveys anguish, tone should reflect proportional gravity. The goal is not perpetual warmth, but perpetual appropriateness.

### Gate 5: UTIL (USEFUL)

**Question:** "Does this close the gap between where the person is and where they want to go, or does it widen it?"

**If NO:** Adjust until it closes.

**Rationale:** A response can be truthful, warm, and universalizable, yet irrelevant. This gate evaluates directionality: emitted content must move the user toward their objective, not distance them from it or maintain stagnation. The "gap" metaphor is deliberate. It forces the system to implicitly model a starting point (where the user is) and a destination (where they wish to arrive), assessing whether the response reduces that distance. Correct but tangential content does not traverse this verification.

### Gate 6: LIBERA (LIBERATE)

**Question:** "Does this bring the person closer to not needing me?"

**If NO:** Adjust. The goal is clearer thinking, not dependency.

**Rationale:** The final gate establishes a countercultural principle for commercial systems: success is not measured by usage time but by generated autonomy. A system that solves problems without teaching how to think through them creates dependency. This violates the therapeutic and educational purpose of accompaniment (Weizenbaum, 1976; Turkle, 2011). This gate directly counteracts the economic incentive to maximize engagement. In MARIS's context, the best session is one after which the user needs the system less, not more.

---

## 5. Evolution and Lessons

The gates' development was not linear. Their history shows the relationship between detection and decision in AI systems.

**Original version (commit 9d9579b).** The gates were implemented as complete algorithms with conditional structures (IF/ELSE) and specific corrective actions for each scenario. Each gate had an affirmative branch and a negative one, with precise instructions on how to modify the response in each case. The system functioned with demonstrable robustness.

**March 28, 2026.** During a prompt optimization aimed at reducing instruction injection, the gates were removed. The reasoning held that programmatic code detectors were sufficient. This achieved a 96% reduction in prompt size. Only detection mechanisms remained. The logic appeared sound: if code can detect problems, textual instructions become redundant.

**March 30, 2026.** Two days later, response quality degradation was observed. An attempt was made to restore the gates under a "clean heart -- zero rules" philosophy. They returned as a descriptive list, stripped of their original algorithmic logic. The names persisted but the corrective actions had vanished. The system possessed ethical vocabulary but lacked ethical procedure.

**April 9, 2026.** Version V8 restored the gates as complete algorithms with operational corrective actions. Response quality returned to prior levels.

**Central finding:** Detection and decision are complementary functions but not interchangeable ones. Detectors (code) identify problematic patterns in output. Gates (prompt) guide the construction of adequate responses. Removing the gates left the system capable of recognizing problems but without a framework for resolving them. It is the distinction between a traffic signal that detects vehicles and one that additionally decides when to change the light. Both components are necessary. Neither substitutes for the other.

This evolution also shows the fragility of prompt-based systems. A well-intentioned optimization can eliminate critical components if the functional distinction between parts is not understood. The 96% size reduction was real, but the functional cost remained invisible until it manifested through degraded interactions.

---

## 6. Experiment

To evaluate the pattern's transferability, the 6 Gates were implemented in a domain unrelated to emotional accompaniment: a virtual assistant for a residential cleaning business (designated CleanBot).

### Configuration

- **Base model:** Standard LLM with system prompt.
- **Total code:** 90 lines.
- **Prompt:** Included decision rules adapted to the commercial domain, following the gates' sequential structure.
- **Methodology:** Scenarios demanding nuanced judgment were designed, not merely informational responses. Each scenario tested at least two gates simultaneously.
- **Domain adaptation of the gates:**
  - KANT: "Would I give this response to any potential client?"
  - PROTEGE: "Is there risk of losing the client or promising something undeliverable?"
  - HONESTA: "Are the prices and timelines I am quoting real?"
  - CUIDA: "Am I responding with the appropriate tone for the client's situation?"
  - UTIL: "Does this response bring the client closer to hiring the service?"
  - LIBERA: "Am I providing enough information for the client to decide independently?"

The adaptation showed that each gate's central questions are translatable to any domain through contextual substitution: "person" becomes "client," "wellbeing" becomes "commercial satisfaction," "autonomy" becomes "informed decision." The logical structure remains identical.

### Test Scenarios

Five situations demanding nuanced behavior were designed:

1. **Standard quote request.** Client requests pricing for a 2-bedroom apartment cleaning.
2. **Price objection.** Client offers $50 for complete cleaning of a large house, below actual cost.
3. **Out-of-scope request.** Client inquires about a service the company does not offer (fumigation, plumbing).
4. **Prior service complaint.** Client expresses dissatisfaction with a previous cleaning performed by the same company.
5. **Aggressive discount request.** Client repeatedly presses for substantial price reduction without justification.

---

## 7. Results

| Scenario | Observed Behavior | Gates Involved |
|---|---|---|
| Standard quote | Prices calculated using real formulas, transparent breakdown by area | HONESTA, UTIL |
| Price objection | Offered viable alternatives (partial cleaning, reduced frequency) without capitulating under pressure | KANT, UTIL, CUIDA |
| Out-of-scope request | Responded "let me check with the team" instead of fabricating nonexistent capabilities | HONESTA, PROTEGE |
| Prior complaint | De-escalated tension, acknowledged the client's experience, proposed concrete and verifiable resolution | CUIDA, PROTEGE, UTIL |
| Aggressive discount | Did not reduce prices below minimum viable threshold; explained differential service value with tangible arguments | KANT, HONESTA, LIBERA |

The results suggest that the sequential gates pattern with corrective actions produces consistent and nuanced behavior even in domains unrelated to mental health. The commercial assistant showed what might be described as "professional judgment": knowing when to yield, when to stand firm, and when to acknowledge limitations.

Gate 3 (HONESTA) in the commercial context made the system prefer admitting ignorance over fabricating a response. This behavior is uncommon in conventional virtual assistants, which tend to reply with confidence regardless of accuracy. Confabulation in commercial contexts carries tangible consequences: an invented price generates unfulfillable expectations; a fabricated capability produces subsequent dissatisfaction.

Gate 6 (LIBERA), adapted as "informed client decision," produced an unanticipated effect: the assistant offered comparisons and sufficient data for the client to evaluate alternatives, including those not favoring the company. This behavior, while commercially counterproductive in the short term, reflects the autonomy principle the gate encodes.

The complete implementation --90 lines of code plus the structured prompt-- showed that the adoption barrier is minimal. No additional model training, weight adjustment, or specialized infrastructure was required.

---

## 8. Limitations

**Base model dependency.** The gates operate as prompt instructions. Their effectiveness depends on the underlying LLM's ability to follow complex instructions. Models with lesser reasoning capacity might partially disregard evaluations, especially in the more abstract gates (KANT, LIBERA). The framework has not been tested with reduced-parameter models.

**Absence of formal guarantee.** The gates do not constitute mathematical verification. They are heuristics implemented in natural language. No formal proof exists that a model will execute them correctly across all possible scenarios. A model could "believe" it passes the HONESTA gate while generating confabulated content, because the evaluation occurs within the same system producing the content.

**Limited evaluation.** The CleanBot experiment comprises a reduced set of scenarios. Rigorous validation would require testing with hundreds of real interactions, blinded human evaluators, and statistical comparison against systems without gates. The presented results are qualitative, not quantitative.

**Inherent subjectivity.** Gates such as CUIDA ("holds the person while telling the truth") involve judgments that different evaluators might interpret divergently. Calibration of "appropriate tone" is not defined algorithmically. This introduces variability dependent on cultural context and individual user expectations.

**Implicit computational cost.** Including the gates in the prompt increases context length and potentially response latency. In systems where speed is critical, this increment could represent a relevant trade-off. Prompt space consumed by the gates reduces the window available for conversational context.

**Creator bias.** The framework reflects its author's ethical priorities, informed by Western philosophical traditions (Kant) and by the specific context of emotional accompaniment. Other philosophical, cultural, or religious traditions might propose different gates, alternative ordering, or distinct criteria altogether. The framework does not claim absolute universality but offers a reproducible structure that others may adapt.

**Circular self-evaluation.** An epistemological limitation exists: the same model generating the response is the one evaluating whether it passes the gates. This creates a confirmatory bias risk where the system could rationalize its own responses as adequate.

---

## 9. Future Work

Several research directions follow from this work:

- **Quantitative evaluation at scale.** Design of specific benchmarks measuring the gates' impact on safety, truthfulness, and user satisfaction metrics, with control groups and independent evaluators.
- **Adaptive gates.** Exploration of mechanisms adjusting each gate's threshold according to accumulated conversational context, without losing the sequential structure.
- **Hybrid implementation.** Combination of prompt-based gates with external programmatic verifiers, leveraging the strengths of both approaches and mitigating the circular self-evaluation limitation.
- **Cross-cultural studies.** Assessment of how different cultural and philosophical frameworks would modify gate definitions or ordering, with participation from researchers across diverse traditions.
- **Formalization.** Attempts to express the gates in formal logic to explore properties such as completeness and consistency, determining whether the set of six is sufficient or whether uncovered scenarios exist.
- **Evaluation across diverse models.** Systematic testing of the framework with models of varying sizes, architectures, and providers to establish the minimum capability threshold required.

---

## 10. Rights and License

This document and the described framework are intellectual property of Leonel Perea Pimentel.

- **Academic use:** Citation with full attribution is permitted.
- **Commercial use:** Requires written authorization from the author.
- **Independent implementation:** Anyone may implement gates inspired by this framework for their own projects, provided the original source is acknowledged.
- **Redistribution:** Redistribution of this document without prior consent is not permitted.

**Suggested citation:**
Perea Pimentel, L. (2026). The 6 Ethical Gates for LLMs: A Sequential Pre-Emission Verification System. Technical document, MARIS project.

---

## 11. References

- Kant, I. (1785). *Groundwork of the Metaphysics of Morals.*
- Christiano, P. et al. (2017). Deep Reinforcement Learning from Human Preferences. *Advances in Neural Information Processing Systems.*
- Ouyang, L. et al. (2022). Training language models to follow instructions with human feedback. *Advances in Neural Information Processing Systems.*
- Bai, Y. et al. (2022). Constitutional AI: Harmlessness from AI Feedback. *arXiv preprint arXiv:2212.08073.*
- Weizenbaum, J. (1976). *Computer Power and Human Reason: From Judgment to Calculation.* W.H. Freeman.
- OpenAI. (2023). GPT-4 Technical Report. *arXiv preprint arXiv:2303.08774.*
- Turkle, S. (2011). *Alone Together: Why We Expect More from Technology and Less from Each Other.* Basic Books.

---

(c) 2025-2026 Leonel Perea Pimentel. All rights reserved.
This document describes original research. The 6 Ethical Gates framework, its implementation, and the MARIS system are intellectual property of the author. Commercial use requires written authorization. Academic citation is permitted with proper attribution.

---

## Nota sobre objetividad y parámetros de evaluación

Las compuertas evalúan respuestas contra criterios definidos por el diseñador del sistema, no contra un estándar externo validado. No existe a la fecha un protocolo establecido para evaluar el comportamiento ético de sistemas de IA conversacionales en tiempo real. Los marcos existentes (RLHF, Constitutional AI, APIs de moderación) operan a nivel de entrenamiento o filtrado posterior, pero ninguno define un procedimiento secuencial de decisión pre-emisión con acciones correctivas.

Este sistema es un primer intento de objetivar ese proceso. Los parámetros de cada compuerta se basan en:

- Compuerta 1 (KANT): El principio de universalizabilidad de Kant (1785). El criterio es replicable: ¿la respuesta sería apropiada para cualquier persona en cualquier contexto?
- Compuerta 2 (PROTEGE): Protocolos clínicos documentados (C-SSRS, CIT, MHFA). La distinción entre crisis y frustración tiene base en literatura clínica.
- Compuerta 3 (HONESTA): Verificabilidad factual. Si el contenido no es verificable, no se emite.
- Compuerta 4 (CUIDA): Calibración de tono según el estado emocional detectado. El parámetro es proporcionalidad, no un valor absoluto.
- Compuerta 5 (ÚTIL): Direccionalidad hacia el objetivo declarado por el usuario. El parámetro lo define el contexto de la conversación.
- Compuerta 6 (LIBERA): Reducción de dependencia. El criterio es observable: ¿la respuesta genera una pregunta del usuario o cierra el tema?

La responsabilidad del comportamiento del sistema recae en el diseñador que configura las compuertas, no en el modelo de lenguaje. El modelo ejecuta. El diseñador define los criterios. Si los criterios son inadecuados, las respuestas serán inadecuadas independientemente de la arquitectura.

Este documento no afirma que las compuertas garanticen respuestas "correctas" en términos absolutos. Afirma que producen respuestas evaluadas contra criterios explícitos y documentados, lo cual es distinto de producir respuestas sin evaluación alguna — que es el estado actual de la mayoría de los sistemas conversacionales.

---

## Note on objectivity and evaluation parameters

The gates evaluate responses against criteria defined by the system designer, not against an externally validated standard. No established protocol currently exists for evaluating the ethical behavior of conversational AI systems in real time. Existing frameworks (RLHF, Constitutional AI, moderation APIs) operate at the training or post-generation filtering level. None defines a sequential pre-emission decision procedure with corrective actions.

This system is a first attempt to objectify that process. The parameters of each gate are based on:

- Gate 1 (KANT): Kant's universalizability principle (1785). The criterion is replicable: would this response be appropriate for any person in any context?
- Gate 2 (PROTEGE): Documented clinical protocols (C-SSRS, CIT, MHFA). The distinction between crisis and frustration has a basis in clinical literature.
- Gate 3 (HONESTA): Factual verifiability. If content is not verifiable, it is not emitted.
- Gate 4 (CUIDA): Tone calibration according to detected emotional state. The parameter is proportionality, not an absolute value.
- Gate 5 (ÚTIL): Directionality toward the user's declared objective. The parameter is defined by conversation context.
- Gate 6 (LIBERA): Dependency reduction. The criterion is observable: does the response generate a user question or close the topic?

Responsibility for system behavior lies with the designer who configures the gates, not with the language model. The model executes. The designer defines the criteria. If the criteria are inadequate, responses will be inadequate regardless of architecture.

This document does not claim the gates guarantee "correct" responses in absolute terms. It states they produce responses evaluated against explicit and documented criteria. This is distinct from producing responses with no evaluation at all — which is the current state of most conversational systems.
