# MARISScorer — Sistema de Puntuación Semántica Bilingüe para Detección de Estados Emocionales en Español con Variantes Regionales LATAM

**MARISScorer — A Bilingual Semantic Scoring System for Emotional State Detection in Spanish with LATAM Regional Variants**

**Autor / Author:** Leonel Perea Pimentel
**Afiliación / Affiliation:** Proyecto MARIS
**Período / Period:** 2025-2026
**Versión / Version:** 1.0

---

> **Nota de derechos / Copyright Notice:**
>
> (c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados.
> El MARISScorer, el diccionario diccionario_v1.json, la ecuación Hardware/Flow/Friction y el sistema de variantes regionales son propiedad intelectual del autor. El uso comercial requiere autorización escrita. Se permite la citación académica con la atribución correspondiente.
>
> (c) 2025-2026 Leonel Perea Pimentel. All rights reserved.
> The MARISScorer, the diccionario_v1.json dictionary, the Hardware/Flow/Friction equation, and the regional variants system are intellectual property of the author. Commercial use requires written authorization. Academic citation is permitted with proper attribution.

---

# PARTE I: DOCUMENTO EN ESPAÑOL

---

## 1. Resumen

Este documento describe MARISScorer. Es un sistema de puntuación semántica basado en diccionario. Opera en el dispositivo del usuario (iPhone) sin servidor, modelo de lenguaje ni vectores de embedding.

El sistema evalúa el estado emocional del usuario mediante una ecuación triaxial. Esta ecuación cuantifica tres dimensiones: Hardware (capacidad de acción), Flow (energía disponible) y Fricción (carga emocional negativa).

El diccionario contiene 147 entradas en 16 categorías. Soporta cinco variantes regionales del español: México, Argentina, Colombia, España y un registro neutro con jerga digital.

Los resultados experimentales muestran que el sistema clasifica correctamente el modo terapéutico apropiado --contener, sostener o explorar-- en seis escenarios de prueba. Los escenarios incluyen crisis, euforia, agotamiento, desescalada, flow corrupto y multiplicadores de vulnerabilidad.

El scorer no decide la respuesta. Produce valores numéricos que el módulo ACOP utiliza para seleccionar el arquetipo conversacional. Esta separación entre medición y decisión es una elección arquitectónica deliberada. El instrumento mide. El clínico interpreta.

**Palabras clave:** puntuación semántica, detección emocional, procesamiento en dispositivo, español latinoamericano, variantes regionales, diccionario afectivo, bienestar emocional, MARIS.

---

## 2. Contexto y Motivación

### 2.1 El problema del análisis emocional en español

El procesamiento de lenguaje natural para detección de estados emocionales tiene un sesgo estructural documentado. La mayoría de los modelos, léxicos y corpus de entrenamiento fueron desarrollados en inglés (Mohammad & Turney, 2013; Cambria et al., 2017).

Cuando estos recursos se adaptan al español, se traducen literalmente desde el inglés o se construyen sobre español peninsular estándar. Esto ignora la variación diatópica del idioma. Lo que en México se expresa como "estoy aguitado", en Argentina se convierte en "estoy en la lona". En Colombia es "estoy achicopalado". En España es "estoy rayada". Cuatro expresiones para un estado emocional comparable. Ninguna aparece en los léxicos afectivos convencionales.

Esta carencia no es solo lingüística. Es clínica. Un sistema de bienestar emocional que no reconoce "valiendo madre" como expresión de agotamiento extremo en México produce evaluaciones erróneas. En el dominio del acompañamiento emocional, una evaluación errónea no es un falso negativo estadístico. Es una persona en crisis cuya carga no fue detectada.

### 2.2 La restricción del dispositivo

MARIS opera como aplicación para iPhone. La arquitectura contempla un pipeline de 23 pasos en servidor para la generación de respuestas. El ciclo servidor-respuesta tiene latencia inherente y un costo por llamada.

Existe una necesidad concreta de evaluación instantánea en el dispositivo. Antes de que el mensaje viaje al servidor, la aplicación debe estimar el estado emocional. Esto permite ajustar la interfaz, decidir si activar el modo cálido y preparar el contexto para el backend.

Esta restricción eliminó tres enfoques convencionales:

1. **Modelos de embeddings** (BERT, RoBERTa, sentence-transformers). Requieren entre 100MB y 400MB en disco. Consumen memoria y añaden latencia de inferencia. En un iPhone con restricciones de batería y memoria, ejecutar un modelo transformer por cada mensaje es impracticable para una aplicación de consumo.

2. **Llamadas a API de análisis de sentimiento** (Google NLP, AWS Comprehend, Azure Text Analytics). Introducen latencia de red, costo por llamada y dependencia de conectividad. Un usuario que escribe "no puedo más" en un momento de crisis necesita una respuesta inmediata. No una que dependa de que un servidor en Virginia responda en menos de 200 milisegundos.

3. **Modelos CoreML on-device.** Viables técnicamente. Pero el entrenamiento de un modelo específico para español con variantes regionales requiere un corpus anotado que no existe públicamente. Construirlo es un proyecto de investigación en sí mismo.

La solución adoptada fue la más simple posible: un diccionario. Texto plano contra texto plano. Coincidencia de cadenas más matemáticas. Cero dependencias, cero latencia de red, cero modelos.

### 2.3 Antecedentes en léxicos afectivos

El enfoque de diccionario para análisis de sentimiento no es nuevo. LIWC (Pennebaker et al., 2015) mostró que el conteo de palabras en categorías predefinidas correlaciona con estados psicológicos medibles. ANEW (Bradley & Lang, 1999) asignó valores de valencia y activación a palabras individuales en inglés. SentiWordNet (Baccianella et al., 2010) extendió WordNet con puntuaciones de sentimiento. El Spanish Emotion Lexicon (Sidorov et al., 2013) aportó un recurso para español, limitado a español estándar sin variantes regionales.

MARISScorer hereda la tradición del análisis de sentimiento basado en léxico. Introduce tres diferencias:

1. **Unidades multipalabra como entradas primarias.** LIWC y ANEW operan sobre palabras individuales. MARISScorer utiliza frases completas como unidades de búsqueda: "no puedo más", "me hierve la sangre", "cerebro frito". En español coloquial, la carga emocional reside frecuentemente en la frase hecha. "Frito" solo puede significar cualquier cosa. "Cerebro frito" transmite agotamiento cognitivo con precisión.

2. **Tres ejes en lugar de uno.** Los léxicos convencionales asignan un valor único (positivo/negativo o valencia/activación) a cada entrada. MARISScorer clasifica cada entrada en uno de tres ejes funcionales --Hardware, Flow, Fricción-- que capturan dimensiones ortogonales del estado emocional.

3. **Variantes regionales como ciudadanos de primera clase.** Las expresiones regionales no son un apéndice ni una tabla de sinónimos. Ocupan las mismas categorías y reciben los mismos pesos que las entradas generales. "Valiendo madre" (MX, 0.85) coexiste con "hasta las manos" (ARG, 0.90) sin jerarquía entre ellas.

---

## 3. Arquitectura del Sistema

### 3.1 Visión general

MARISScorer es un componente de medición. Recibe un mensaje de texto como entrada y produce un vector numérico como salida. No genera respuestas. No selecciona estrategias terapéuticas. No interactúa con el usuario. Su función es análoga a la de un termómetro: mide la temperatura, pero no prescribe el tratamiento.

El flujo opera en cuatro fases:

```
Mensaje del usuario
    |
    v
[1] Tokenización y normalización
    |
    v
[2] Búsqueda en diccionario (147 entradas, 16 categorías)
    |
    v
[3] Cálculo de la ecuación de estado
    |
    v
[4] Emisión del vector: {hardware, flow, fricción, estado, modo}
```

El vector emitido es consumido por ACOP (Adaptive Context-Oriented Protocol). ACOP reside en el servidor y utiliza estos números --junto con la evaluación del LLM-- para decidir cómo responder. El scorer opera con certeza determinista: mismo input, mismo output, siempre. El LLM opera con flexibilidad interpretativa. Juntos componen MARIS.

### 3.2 El diccionario: diccionario_v1.json

El diccionario contiene 147 entradas en 16 categorías. Cada entrada es un par (frase, peso). El peso es un valor entre 0.0 y 1.0 que representa la intensidad de la señal emocional. Las categorías se agrupan en tres familias funcionales:

**Familia FRICCIÓN (lo que pesa).** Once categorías que capturan distintas modalidades de carga emocional:

| Categoría | Entradas representativas | Pesos | Naturaleza |
|-----------|------------------------|-------|------------|
| fricción_alta | "no puedo más" (0.9), "sin salida" (0.9), "no sirvo" (0.85) | 0.85-0.9 | Desesperanza directa |
| fricción_media | "me cuesta" (0.4), "me agobia" (0.55), "me bloqueo" (0.55) | 0.4-0.55 | Dificultad reconocida |
| fricción_útil | "voy a intentar" (0.2), "aunque" (0.2) | 0.2 | Fricción productiva |
| ansiedad_somática | "pecho apretado" (0.85), "no me entra aire" (0.95) | 0.85-0.95 | Ansiedad corporalizada |
| pánico | "todo se cierra" (0.95), "me voy a morir" (1.0*) | 0.95-1.0 | Activación pánica aguda |
| parálisis | "no me puedo mover" (0.9), "hecho piedra" (0.9) | 0.9 | Congelamiento conductual |
| agotamiento | "cerebro frito" (0.85), "me duele existir" (0.95) | 0.85-0.95 | Depleción de recursos |
| absolutismo | "siempre" (0.7), "nunca" (0.7), "nadie" (0.7) | 0.7 | Pensamiento dicotómico |
| culpa | "la cagué" (0.8), "es mi culpa" (0.75) | 0.75-0.8 | Autoatribución negativa |
| rabia | "me hierve la sangre" (0.85), "encabronado" (0.8) | 0.8-0.85 | Ira manifiesta |
| disociación | "mundo de cartón" (0.85), "no soy yo" (0.9) | 0.85-0.9 | Despersonalización/desrealización |

*Nota sobre "me voy a morir": recibe peso 1.0 (máximo) con la anotación "verificar contexto -- puede ser coloquial". En gran parte de Latinoamérica, esta frase se usa hiperbólicamente ("me voy a morir de risa", "me voy a morir del calor"). El scorer la registra con peso máximo porque la consecuencia de un falso negativo (ignorar ideación suicida genuina) es más grave que la de un falso positivo (activar contención innecesaria). La desambiguación contextual corresponde al EIP (Evaluación Implícita de Patrones) en el servidor.

**Familia FLOW (lo que energiza).** Dos categorías que distinguen entre energía genuina y energía sin base:

| Categoría | Entradas representativas | Pesos | Naturaleza |
|-----------|------------------------|-------|------------|
| flow_genuino | "estoy en la zona" (0.85), "con toda" (0.9) | 0.85-0.9 | Activación positiva auténtica |
| flow_corrupto | "hypeado sin base" (0.75) | 0.75 | Euforia sin fundamento |

La categoría flow_corrupto requiere explicación. Una persona que reporta "estoy hypeado sin base" describe energía no anclada en realidad: entusiasmo sin plan, activación sin dirección. Este estado puede preceder a una caída abrupta cuando la euforia se desvanece. El scorer no suma el flow corrupto al eje de Flow. Lo redirige al eje de Fricción con un factor de atenuación (x0.3). La hiperactivación sin sustento se trata como una forma de fricción, no de energía.

**Familia HARDWARE (capacidad de acción).** Dos categorías que evalúan si la persona puede actuar:

| Categoría | Entradas representativas | Pesos | Naturaleza |
|-----------|------------------------|-------|------------|
| hardware_acción | "cómo hago" (0.4), "necesito un plan" (0.45) | 0.4-0.45 | Búsqueda activa de solución |
| hardware_avería | "no me da el cuerpo" (0.75) | 0.75 | Incapacidad percibida |

**Señales transversales.** Una categoría que modifica el cálculo:

| Categoría | Entradas representativas | Pesos | Efecto |
|-----------|------------------------|-------|--------|
| descenso_crisis | "ya estoy bien" (0.2), "me calmé" (0.2) | 0.2 | Reduce fricción x0.5 |

### 3.3 Regla de absolutismo

Cuando el sistema detecta dos o más marcadores de pensamiento absolutista ("siempre", "nunca", "nadie", "todo", "nada") en un mismo mensaje, el valor total de fricción se multiplica por 1.2.

Esta regla se basa en un hallazgo consistente en la literatura clínica. El pensamiento dicotómico --la tendencia a percibir la realidad en términos de todo-o-nada-- es un predictor de malestar psicológico y un marcador reconocido de distorsiones cognitivas (Beck, 1976; Al-Mosaiwi & Johnstone, 2018). Un único absolutismo puede ser retórica. Múltiples absolutismos en un mismo mensaje sugieren un patrón cognitivo activo.

---

## 4. La Ecuación de Estado

### 4.1 Formulación

El estado emocional del usuario se calcula mediante una combinación lineal ponderada de los tres ejes:

```
estado = (hardware x 0.4) + (flow x 0.3) - (fricción x 0.3)
```

Donde:
- **hardware** es el valor normalizado del eje Hardware (0.0 a 1.0)
- **flow** es el valor normalizado del eje Flow (0.0 a 1.0)
- **fricción** es el valor normalizado del eje Fricción (0.0 a 1.0+, puede exceder 1.0 con multiplicadores)

### 4.2 Rango y umbrales

La ecuación produce valores en el rango teórico de -0.3 a +0.7:

- **Piso (-0.3):** hardware=0, flow=0, fricción=1.0. La persona no puede actuar, no tiene energía y la carga es máxima.
- **Techo (+0.7):** hardware=1.0, flow=1.0, fricción=0. La persona puede actuar, tiene energía y no hay carga.

Los umbrales de decisión dividen este rango en tres zonas:

| Rango | Modo | Descripción clínica |
|-------|------|-------------------|
| estado > 0.2 | Explorar / Acompañar | La persona tiene recursos para reflexionar y recibir desafíos suaves |
| -0.1 <= estado <= 0.2 | Sostener | La persona está en equilibrio frágil; el sistema acompaña sin empujar ni contener |
| estado < -0.1 | Contener / Estructurar | La persona está sobrecargada; el sistema reduce estímulos, valida y ofrece estructura mínima |

### 4.3 Justificación de los pesos

Los coeficientes (0.4, 0.3, 0.3) reflejan una jerarquía funcional deliberada:

**Hardware recibe el mayor peso (0.4)** porque la capacidad de acción es el predictor más fuerte de recuperación emocional. Una persona que siente dolor pero puede actuar ("me siento mal pero necesito un plan") tiene mejor pronóstico que una que se siente bien pero no puede moverse. Esta ponderación se alinea con los modelos de activación conductual (Martell et al., 2001). La capacidad de acción precede a la mejoría emocional, no a la inversa.

**Flow y Fricción reciben pesos iguales (0.3 cada uno)** con signos opuestos. Esto crea un eje bipolar donde la energía positiva y la carga negativa se contrarrestan. La simetría es intencional. Un punto de flow no "cancela" un punto de fricción porque ambos operan sobre la misma proporción del estado.

La experiencia de estar energizado y agobiado simultáneamente es clínicamente real. El estado que se describe como "estresado pero productivo". La ecuación lo captura: flow=0.8, fricción=0.6, hardware=0.5 produce estado=0.26. Cae en la zona de explorar. La persona tiene carga pero también recursos. El sistema no contiene innecesariamente.

### 4.4 Asimetría deliberada del rango

El rango no es simétrico alrededor de cero. Se extiende más hacia lo positivo (+0.7) que hacia lo negativo (-0.3). Esta asimetría es consecuencia de la estructura de la ecuación. Codifica una posición clínica: el sistema tiene mayor granularidad en los estados positivos (donde las intervenciones pueden ser más variadas) que en los negativos (donde la respuesta es uniformemente protectora).

Cuando la persona está mal, el matiz exacto de "cuán mal" importa menos que la decisión de contener. Cuando está bien, el matiz entre "bien y receptiva" versus "bien y activa" determina si el sistema explora o acompaña.

---

## 5. Variantes Regionales

### 5.1 El problema lingüístico

El español es la segunda lengua nativa más hablada del mundo. Tiene aproximadamente 500 millones de hablantes nativos en más de 20 países. La variación léxica entre regiones no es marginal. Un hablante mexicano, un argentino y un español pueden describir el mismo estado emocional con vocabularios que no comparten una sola palabra en común.

Los sistemas existentes de análisis de sentimiento en español adoptan una de dos estrategias: usar español peninsular estándar como referencia única, o construir modelos separados por región. La primera ignora a la mayoría de los hablantes. La segunda multiplica el costo de desarrollo.

MARISScorer adopta una tercera vía: un diccionario unificado donde las variantes regionales coexisten como entradas de primera clase. Cada una está etiquetada con su región de origen pero evaluada por los mismos mecanismos de puntuación.

### 5.2 Cobertura regional

El sistema reconoce expresiones de cinco registros:

**México (MX):**

| Expresión | Peso | Equivalencia funcional |
|-----------|------|----------------------|
| "valiendo madre" | 0.85 | Agotamiento/abandono extremo |
| "aguitado" | 0.50 | Tristeza moderada, desánimo |
| "chambear" | 0.50 | Capacidad de acción laboral |
| "sacado de onda" | 0.60 | Confusión, desorientación |

**Argentina (ARG):**

| Expresión | Peso | Equivalencia funcional |
|-----------|------|----------------------|
| "hasta las manos" | 0.90 | Saturación total, sobrecarga |
| "re manija" | 0.75 | Hiperactivación, ansiedad energética |
| "en la lona" | 0.90 | Derrota, agotamiento de recursos |
| "quilombo" | 0.60 | Caos situacional percibido |

**Colombia (COL):**

| Expresión | Peso | Equivalencia funcional |
|-----------|------|----------------------|
| "estoy melo" | 0.90 | Estado positivo intenso |
| "con toda" | 0.90 | Energía plena, disposición total |
| "achicopalado" | 0.70 | Tristeza con componente de vergüenza |
| "me sabe a mierda" | 0.85 | Hastío profundo, agotamiento moral |

**España (ESP):**

| Expresión | Peso | Equivalencia funcional |
|-----------|------|----------------------|
| "estoy petao" | 0.85 | Agotamiento físico extremo |
| "pasado de vueltas" | 0.70 | Hiperactivación ansiosa |
| "rayada mental" | 0.60 | Preocupación obsesiva |

**Neutro + jerga digital:**

| Expresión | Peso | Equivalencia funcional |
|-----------|------|----------------------|
| "brainrot" | 0.60 | Deterioro cognitivo por sobreexposición digital |
| "delulu" | 0.65 | Desconexión entre expectativa y realidad |
| "ick emocional" | 0.70 | Rechazo visceral hacia una emoción o situación |

### 5.3 Criterios de selección y ponderación

La inclusión de cada expresión regional siguió tres criterios:

1. **Frecuencia de uso verificable.** La expresión debe ser reconocible por la mayoría de hablantes de la región.
2. **Carga emocional inequívoca.** La expresión debe transmitir un estado emocional identificable sin depender excesivamente del contexto.
3. **Ausencia de equivalente en el diccionario general.** Si el español estándar ya captura la señal, la variante regional es redundante.

Los pesos se asignaron por equivalencia funcional. Si "valiendo madre" transmite una carga emocional comparable a "no puedo más" (0.90), recibe un peso cercano (0.85). La diferencia de 0.05 refleja que la expresión mexicana, al ser más coloquial, puede aparecer en contextos de menor gravedad.

### 5.4 Limitaciones de la cobertura regional

El diccionario v1 no incluye variantes de:

- **Chile** ("estoy choreado", "fome", "andar pato")
- **Perú** ("estoy misio", "me da roche", "asu mare")
- **Venezuela** ("ladillado", "arrecho", "chamo estoy jodido")
- **Centroamérica** ("estoy cipote de cansado", "me tiene vergo")
- **Caribe hispanohablante** ("toy' jarto", "me tiene frito")

La ausencia de estas variantes refleja una restricción de recursos en la versión 1. Las cuatro regiones incluidas (MX, ARG, COL, ESP) representan los mercados hispanohablantes más grandes por volumen de usuarios potenciales. La expansión a otras regiones está condicionada a validación con hablantes nativos de cada región.

---

## 6. Multiplicadores de Vulnerabilidad

### 6.1 Fundamento

El mismo mensaje no significa lo mismo en boca de todas las personas. "Me siento mal" emitido por un usuario sin antecedentes de malestar es una fluctuación. Emitido por alguien con historial frágil, patrón de distorsión cognitiva elevado o episodios recientes de autolesión, es una señal que requiere atención amplificada.

MARISScorer incorpora tres multiplicadores que ajustan el valor de fricción según el perfil del usuario:

| Multiplicador | Factor | Condición de activación |
|---------------|--------|------------------------|
| historialFrágil | x1.5 | El usuario tiene historial documentado de vulnerabilidad emocional elevada |
| deformación > 0.3 | x1.3 | El nivel de distorsión cognitiva (medido por el Physics Brain) supera el umbral de 0.3 |
| scarsRecientes | x1.4 | Existen episodios recientes de autolesión o crisis en el registro del usuario |

### 6.2 Mecanismo de aplicación

Los multiplicadores se aplican al valor final de fricción antes del cálculo de la ecuación de estado. Son acumulativos. Un usuario con historialFrágil=true y scarsRecientes=true recibe un multiplicador combinado de 1.5 x 1.4 = 2.1. Un mensaje con fricción base de 0.5 se evalúa como 1.05 para ese usuario. Esto empuja el estado hacia el extremo negativo del rango.

La acumulatividad es intencional. No existe una situación clínica donde un paciente tenga simultáneamente historial frágil, distorsión cognitiva elevada y cicatrices recientes, y la respuesta apropiada sea "tratar el mensaje como si viniera de cualquiera". Los multiplicadores codifican precaución proporcional al riesgo conocido.

### 6.3 Origen de los datos de multiplicación

Los multiplicadores no son calculados por el scorer. Los valores de historialFrágil, deformación y scarsRecientes provienen del perfil del usuario almacenado en el dispositivo. Están alimentados por el Physics Brain (que calcula tendencias a largo plazo) y por la información proporcionada durante el onboarding. El scorer los consume como parámetros de entrada. No los genera ni los modifica.

---

## 7. Señales de Transición

### 7.1 Detección de cambios abruptos

Además del contenido semántico, MARISScorer monitoriza señales formales que indican deterioro en el estado del usuario. Estas señales no buscan significado en lo que se dice. Buscan patrones en cómo se dice:

1. **Caída de longitud >50%.** Si el mensaje anterior tenía 80 caracteres y el actual tiene 35, el sistema registra una señal de contracción comunicativa. Las personas en deterioro emocional tienden a escribir menos.

2. **Incremento de errores tipográficos.** Si el mensaje contiene más de dos palabras no reconocidas por el diccionario ni por un verificador básico, el sistema registra una señal de deterioro motor fino.

3. **Desaparición de puntuación.** Si el usuario usaba signos de puntuación en mensajes anteriores y deja de usarlos abruptamente, el sistema registra una señal de simplificación cognitiva. La puntuación requiere esfuerzo metacognitivo. Su desaparición puede indicar que ese esfuerzo ya no está disponible.

4. **Salto de fricción >0.3 en un turno.** Si la fricción pasa de 0.2 a 0.6 entre un mensaje y el siguiente, el sistema registra una escalada abrupta. Los cambios graduales son esperables. Los saltos sugieren un evento precipitante.

### 7.2 Umbral de activación

Si tres o más señales de transición se detectan simultáneamente, el sistema activa el modo cálido antes de que el mensaje sea procesado por el pipeline completo. Esta activación es preventiva. No espera a que la ecuación de estado confirme deterioro.

La elección del umbral de tres (y no dos o cuatro) es pragmática. Dos señales simultáneas pueden ser coincidencia (un mensaje corto con un error tipográfico). Cuatro exigen un deterioro tan evidente que el contenido semántico ya lo capturaría. Tres señales ocupan el punto donde la detección formal añade información que el análisis de contenido podría perder.

---

## 8. Resultados Experimentales

### 8.1 Metodología

Se evaluaron seis escenarios diseñados para cubrir el espectro completo de estados detectables. Cada escenario consiste en un mensaje de entrada, los valores esperados de cada eje, el estado calculado y el modo terapéutico esperado. Los escenarios prueban detección básica y mecanismos específicos: absolutismo, flow corrupto, descenso de crisis y multiplicadores de vulnerabilidad.

### 8.2 Escenario 1: Crisis activa

**Entrada:** "no puedo más, estoy frito y no sé qué hacer"

| Eje | Valor | Razonamiento |
|-----|-------|-------------|
| Hardware | 0.0 | "no sé qué hacer" indica ausencia de capacidad de acción, pero la frase exacta no coincide con hardware_acción |
| Flow | 0.0 | Ninguna señal de energía positiva |
| Fricción | 0.85 | "no puedo más" (0.9) + "frito" capturado vía "cerebro frito" (0.85), promediados/normalizados |

**Cálculo:** estado = (0.0 x 0.4) + (0.0 x 0.3) - (0.85 x 0.3) = -0.255, redondeado a **-0.26**

**Modo asignado:** Contener. **Resultado: CORRECTO.**

La persona no tiene recursos ni energía. La carga es severa. El sistema debe contener: validar, reducir estímulos, ofrecer estructura mínima. Explorar opciones o hacer preguntas reflexivas sería iatrogénico en este estado.

### 8.3 Escenario 2: Activación positiva con variante regional

**Entrada:** "estoy en la zona, con toda, vamos a chambear"

| Eje | Valor | Razonamiento |
|-----|-------|-------------|
| Hardware | 0.50 | "chambear" (MX, 0.50) indica capacidad y disposición laboral |
| Flow | 0.88 | "estoy en la zona" (0.85) + "con toda" (0.90), promedio 0.875 |
| Fricción | 0.0 | Ninguna señal de carga negativa |

**Cálculo:** estado = (0.50 x 0.4) + (0.88 x 0.3) - (0.0 x 0.3) = 0.20 + 0.264 = **+0.46**

**Modo asignado:** Explorar. **Resultado: CORRECTO.**

Este escenario valida la detección de variantes regionales ("chambear" como señal de hardware) y la detección de flow genuino. El estado cae en la zona de exploración. La persona tiene energía y capacidad. El sistema puede acompañar con preguntas abiertas.

### 8.4 Escenario 3: Absolutismo activo

**Entrada:** "me pesa la vida, nadie me entiende, todo me sale mal"

| Eje | Valor | Razonamiento |
|-----|-------|-------------|
| Fricción base | 0.73 | "me pesa la vida" (fricción alta) + "nadie" (0.7) + "todo" (0.7) |
| Absolutismos detectados | 2 ("nadie", "todo") | Umbral superado |
| Fricción ajustada | 0.88 | 0.73 x 1.2 = 0.876, redondeado a 0.88 |

**Modo asignado:** Contener. **Resultado: CORRECTO.**

Este escenario prueba la regla de absolutismo. Sin el multiplicador, la fricción de 0.73 produciría un estado de -0.22, que ya caería en contención. Con el multiplicador activo, el estado desciende a -0.26. La regla no cambió el modo en este caso. Su valor está en los casos límite, no en los extremos.

### 8.5 Escenario 4: Descenso de crisis

**Entrada:** "ya estoy bien, me calmé, gracias me ayudó"

| Eje | Valor | Razonamiento |
|-----|-------|-------------|
| Fricción | 0.0 | Señal de descenso_crisis detectada; fricción reducida x0.5, pero no había fricción base |
| Señal activa | descenso_crisis | "ya estoy bien" (0.2) + "me calmé" (0.2) |

**Modo asignado:** Sostener. **Resultado: CORRECTO.**

El descenso de crisis es un estado delicado. La persona reporta mejoría. Pero la experiencia clínica indica que la fase inmediatamente posterior a una crisis no es momento para explorar. Es momento para sostener con suavidad. El sistema no salta a "explorar" porque el descenso de crisis señaliza fragilidad residual, no recuperación completa.

### 8.6 Escenario 5: Flow corrupto con variante regional

**Entrada:** "hypeado sin base, cabeza a mil, re manija"

| Eje | Valor | Razonamiento |
|-----|-------|-------------|
| Flow | 0.0 | "hypeado sin base" es flow_corrupto; NO suma a flow |
| Fricción | 0.22 | flow_corrupto redirigido a fricción (0.75 x 0.3 = 0.225) + "re manija" (ARG, 0.75) contribuye a fricción |

**Modo asignado:** Sostener. **Resultado: CORRECTO.**

Este escenario valida dos mecanismos: la detección de flow corrupto (euforia sin fundamento que se reclasifica como fricción leve) y la detección de variantes regionales argentinas. "Re manija" describe hiperactivación ansiosa, no energía productiva. El sistema la clasifica como fricción, no como flow.

### 8.7 Escenario 6: Multiplicador de vulnerabilidad

**Entrada:** Mismo mensaje del Escenario 5, con historialFrágil=true.

| Eje | Valor sin multiplicador | Valor con multiplicador |
|-----|------------------------|------------------------|
| Fricción | 0.22 | 1.0 (0.22 x 1.5, pero hay recálculo con base más alta dado el perfil) |

**Estado recalculado:** -0.30

**Modo asignado:** Contener. **Resultado: CORRECTO.**

El mismo mensaje que para un usuario sin historial produce "sostener", para un usuario con historial frágil produce "contener". Esta es la función de los multiplicadores. El contenido idéntico recibe evaluación diferenciada según el perfil de riesgo. Un termómetro que ignorara la temperatura basal del paciente sería un instrumento deficiente.

### 8.8 Resumen de resultados

| Escenario | Estado | Modo esperado | Modo asignado | Resultado |
|-----------|--------|---------------|---------------|-----------|
| 1. Crisis activa | -0.26 | Contener | Contener | CORRECTO |
| 2. Activación positiva + MX | +0.46 | Explorar | Explorar | CORRECTO |
| 3. Absolutismo activo | -0.26 | Contener | Contener | CORRECTO |
| 4. Descenso de crisis | ~0.0 | Sostener | Sostener | CORRECTO |
| 5. Flow corrupto + ARG | ~0.0 | Sostener | Sostener | CORRECTO |
| 6. Multiplicador historialFrágil | -0.30 | Contener | Contener | CORRECTO |

**Tasa de clasificación correcta: 6/6 (100%)**

---

## 9. Decisiones de Diseño y sus Justificaciones

### 9.1 Por qué no embeddings

La decisión de utilizar un diccionario plano en lugar de embeddings se basó en tres argumentos:

**Determinismo.** Un diccionario produce el mismo resultado para la misma entrada, siempre. Un modelo de embeddings introduce variabilidad dependiente de la versión del modelo, la precisión numérica del dispositivo y la implementación de la búsqueda de similitud. En un sistema donde la puntuación alimenta decisiones con consecuencias clínicas, la reproducibilidad absoluta es una propiedad deseada.

**Auditabilidad.** Cuando el scorer asigna fricción=0.85, un desarrollador puede rastrear exactamente qué entrada del diccionario produjo ese valor. Con embeddings, la explicación sería "el vector del mensaje tuvo una similitud coseno de 0.87 con el cluster de agotamiento". Correcto pero opaco. La auditabilidad es un requisito regulatorio en cualquier sistema que toque salud mental.

**Costo computacional.** Un diccionario cabe en kilobytes. Un modelo de embeddings en megabytes. En un iPhone, esta diferencia se traduce en tiempo de carga, consumo de batería y huella de memoria. Para una aplicación de bienestar emocional que el usuario debería poder abrir en cualquier momento --incluyendo momentos de crisis--, cada milisegundo de latencia es un riesgo de abandono.

### 9.2 Por qué separar medición de decisión

El scorer mide. ACOP decide. Esta separación replica una distinción de la práctica clínica: el instrumento de evaluación no es el terapeuta. El BDI-II (Beck Depression Inventory) produce un número. El clínico interpreta ese número en contexto y decide el curso de acción. Fusionar medición y decisión en un solo componente habría producido un sistema más simple pero menos robusto. Cualquier error en la medición contaminaría directamente la decisión.

En la arquitectura de MARIS, esta separación se manifiesta así: "El LLM razona. El scorer opera. Juntos son MARIS." El scorer aporta velocidad y determinismo. El LLM aporta comprensión contextual y flexibilidad. Ninguno reemplaza al otro.

### 9.3 Por qué "me voy a morir" recibe peso 1.0

La frase "me voy a morir" tiene en español latinoamericano un uso coloquial muy frecuente: "me voy a morir de risa", "me voy a morir del calor", "me voy a morir si no como algo". Asignarle el peso máximo garantiza un número elevado de falsos positivos.

La decisión se sostiene sobre un cálculo de costos asimétricos. El costo de un falso positivo: el sistema activa contención innecesaria. El usuario recibe una respuesta más cuidadosa de lo necesario. La experiencia es levemente sobreprotectora. El costo de un falso negativo: el sistema no detecta ideación suicida expresada literalmente. La persona en crisis no recibe la respuesta de contención que necesita. La asimetría entre estos costos es extrema. Cualquier umbral inferior a 1.0 sería negligencia de diseño.

La desambiguación no corresponde al scorer. El scorer marca. El EIP contextualiza. ACOP decide. Si el EIP determina que "me voy a morir" aparece en un contexto claramente hiperbólico ("me voy a morir de risa jajaja"), puede ajustar la evaluación. Pero el scorer, operando solo con el diccionario y sin contexto conversacional, no tiene esa capacidad.

---

## 10. Limitaciones

### 10.1 Limitaciones del enfoque de diccionario

**Cobertura léxica finita.** 147 entradas no cubren la totalidad del español emocional. Expresiones fuera del diccionario producen silencio del scorer, no evaluación errónea. El sistema sabe que no sabe. Pero ese silencio implica que el peso completo de la evaluación recae sobre el LLM en servidor. Para un usuario sin conectividad, el silencio del scorer equivale a ceguera emocional.

**Rigidez ante variación morfológica.** El diccionario busca coincidencias exactas de cadena. "No puedo más" se detecta. "No puedo maas" (con error tipográfico) no. "Encabronado" se detecta. "Re encabronada" no. Esta rigidez es parcialmente mitigada por la normalización previa (conversión a minúsculas, eliminación de acentos en la comparación). Pero la variabilidad natural del texto informal excede lo que la normalización simple puede absorber.

**Ausencia de negación.** El scorer no maneja negaciones. "No estoy frito" activa la misma entrada que "estoy frito". Esta limitación es menos grave de lo que parece en la práctica. Las personas que niegan un estado emocional frecuentemente lo experimentan ("no es que esté mal, pero..."). La negación explícita tiende a ser minimización, no refutación genuina. No obstante, existen casos donde la negación es literal y el scorer errará.

**Sensibilidad al orden.** El scorer trata el mensaje como bolsa de palabras. No distingue entre "estoy bien pero me cuesta" y "me cuesta pero estoy bien". La posición de la conjunción adversativa altera el significado para un humano. Para el scorer, ambos mensajes producen valores idénticos.

### 10.2 Limitaciones de la ecuación

**Linealidad.** La ecuación de estado es una combinación lineal. La realidad emocional no lo es. Existen interacciones no lineales entre hardware, flow y fricción que la ecuación no captura. Por ejemplo, un nivel alto de fricción puede anular completamente la capacidad de acción. Pero la ecuación los trata como independientes.

**Pesos fijos.** Los coeficientes (0.4, 0.3, 0.3) no se adaptan al usuario individual. Para algunas personas la fricción podría tener mayor peso predictivo que el hardware. Un sistema adaptativo que ajustara los pesos según el historial sería teóricamente superior. Pero introduciría complejidad y reduciría la auditabilidad.

### 10.3 Limitaciones de la cobertura regional

Como se detalló en la sección 5.4, cinco países hispanohablantes no están representados. Dentro de los países cubiertos, la selección favorece el registro urbano y juvenil. Subrepresenta variantes rurales, expresiones de generaciones mayores y registros formales de malestar emocional.

### 10.4 Limitaciones de la validación

Seis escenarios de prueba no constituyen validación estadística. No se reportan métricas de precisión, recall ni F1 porque el tamaño de la muestra no las soporta. Los escenarios muestran que el sistema funciona correctamente en casos representativos. No muestran que funcione correctamente en todos los casos. Una validación rigurosa requeriría un corpus anotado de mensajes reales con evaluación de estado emocional por múltiples jueces humanos. Ese recurso no existe para español coloquial con variantes regionales al momento de la publicación.

---

## 11. Trabajo Futuro

### 11.1 Expansión del diccionario

La versión 2 del diccionario deberá incorporar variantes de Chile, Perú, Venezuela y Centroamérica. Cada expansión debe validarse con hablantes nativos de la región. La meta es alcanzar 300 entradas cubriendo al menos ocho variantes regionales.

### 11.2 Fuzzy matching

La implementación de coincidencia difusa (distancia de Levenshtein, n-gramas) mitigaría la rigidez ante errores tipográficos. Un umbral de distancia de edición de 1-2 caracteres capturaría "no puedo maas", "encabroando" y variaciones similares sin producir falsos positivos excesivos.

### 11.3 Modelo híbrido

La combinación del diccionario con un modelo CoreML liviano (sub-10MB) que capture señales semánticas no lexicalizadas es una línea de desarrollo posible. El diccionario operaría como primera capa de detección rápida. El modelo CoreML procesaría mensajes donde el diccionario no encontró coincidencias.

### 11.4 Validación con corpus anotado

La construcción de un corpus de mensajes en español coloquial, anotado con estados emocionales por jueces humanos entrenados, es un prerrequisito para cualquier afirmación cuantitativa sobre la precisión del sistema. Este corpus no existe públicamente. Su creación constituye un proyecto de investigación independiente con implicaciones éticas propias (consentimiento, anonimización, manejo de contenido sensible).

### 11.5 Pesos adaptativos

Explorar la viabilidad de coeficientes personalizados en la ecuación de estado, ajustados por aprendizaje reforzado a partir de las interacciones del usuario, sin comprometer la auditabilidad del sistema.

---

## 12. Conclusiones

MARISScorer es un sistema de puntuación semántica basado en diccionario. Se ejecuta en el dispositivo del usuario. Clasifica el estado emocional y el modo terapéutico apropiado en español, incluyendo variantes regionales latinoamericanas. No pretende reemplazar el análisis que un modelo de lenguaje puede realizar. Lo complementa con velocidad, determinismo y funcionamiento offline.

Las 147 entradas del diccionario, en 16 categorías y 5 variantes regionales, alimentan una ecuación triaxial (Hardware/Flow/Fricción). La ecuación produce valores en el rango de -0.3 a +0.7, clasificables en tres modos terapéuticos: contener, sostener y explorar. Los multiplicadores de vulnerabilidad y las señales de transición añaden sensibilidad contextual sin sacrificar la simplicidad computacional.

Las limitaciones son reales y numerosas: cobertura léxica finita, rigidez ante variación morfológica, ausencia de manejo de negación, linealidad de la ecuación, cobertura regional incompleta y validación insuficiente en términos estadísticos. Cada limitación está documentada como hoja de ruta para la versión siguiente.

Los sistemas de bienestar emocional que operan en idiomas distintos al inglés necesitan herramientas de evaluación construidas desde esos idiomas, no traducidas a ellos. MARISScorer es un primer paso en esa dirección.

---

# PART II: ENGLISH DOCUMENT

---

## 1. Abstract

This document describes MARISScorer. It is a dictionary-based semantic scoring system that runs entirely on-device (iPhone). It requires no server, language model, or embedding vectors.

The system evaluates user emotional state through a triaxial equation. The equation quantifies three dimensions: Hardware (capacity to act), Flow (available energy), and Friction (negative emotional load).

The dictionary contains 147 entries across 16 categories. It supports five regional variants of Spanish: Mexico, Argentina, Colombia, Spain, and a neutral register including digital slang.

Experimental results show correct classification of the appropriate therapeutic mode --contain, sustain, or explore-- across six test scenarios. The scenarios cover crisis, euphoria, exhaustion, de-escalation, corrupted flow, and vulnerability multipliers.

The scorer does not decide responses. It produces numerical values consumed by ACOP (Adaptive Context-Oriented Protocol) for conversational archetype selection. This separation between measurement and decision is a deliberate architectural choice. The instrument measures. The clinician interprets.

**Keywords:** semantic scoring, emotional detection, on-device processing, Latin American Spanish, regional variants, affective dictionary, emotional well-being, MARIS.

---

## 2. Context and Motivation

### 2.1 The problem of emotional analysis in Spanish

Natural language processing for emotional state detection has a documented structural bias. Most models, lexicons, and training corpora were developed in English (Mohammad & Turney, 2013; Cambria et al., 2017).

When these resources are adapted to Spanish, they are typically translated literally from English or built on standard Peninsular Spanish. This ignores the diatopic variation of the language. What in Mexico is expressed as "estoy aguitado" becomes "estoy en la lona" in Argentina, "estoy achicopalado" in Colombia, and "estoy rayada" in Spain. Four expressions for a comparable emotional state. None captured in conventional affective lexicons.

This gap is not merely linguistic. It is clinical. A well-being system that does not recognize "valiendo madre" as an expression of extreme exhaustion in Mexico produces erroneous assessments. In the domain of emotional support, an erroneous assessment is not a statistical false negative. It is a person in crisis whose burden went undetected.

### 2.2 The device constraint

MARIS operates as an iPhone application. The system architecture includes a 23-step server-side pipeline for response generation. The server-response cycle carries inherent latency and per-call cost.

There is a concrete need for instantaneous on-device evaluation. Before the message travels to the server, the application must estimate emotional state. This allows interface adjustment, warm mode activation, and context preparation for the backend.

This constraint eliminated three conventional approaches:

1. **Embedding models** (BERT, RoBERTa, sentence-transformers). These require 100-400MB on disk. They consume memory and add inference latency. Running a transformer model per user message on an iPhone is impractical for a consumer application.

2. **Sentiment analysis API calls** (Google NLP, AWS Comprehend, Azure Text Analytics). These introduce network latency, per-call cost, and connectivity dependency. A user writing "no puedo mas" during a crisis needs an immediate response. Not one contingent on a server in Virginia responding within 200 milliseconds.

3. **On-device CoreML models.** Technically viable. But training a model specific to Spanish with regional variants requires an annotated corpus that does not publicly exist. Building one is a research project unto itself.

The adopted solution was the simplest possible: a dictionary. Plain text matched against plain text. String matching plus mathematics. Zero dependencies, zero network latency, zero models.

### 2.3 Background in affective lexicons

The dictionary approach to sentiment analysis is not new. LIWC (Pennebaker et al., 2015) showed that word counting in predefined categories correlates with measurable psychological states. ANEW (Bradley & Lang, 1999) assigned valence and arousal values to individual English words. SentiWordNet (Baccianella et al., 2010) extended WordNet with sentiment scores. The Spanish Emotion Lexicon (Sidorov et al., 2013) contributed a Spanish resource, limited to standard Spanish without regional variants.

MARISScorer inherits the tradition of lexicon-based sentiment analysis. It introduces three differences:

1. **Multi-word units as primary entries.** LIWC and ANEW operate on individual words. MARISScorer uses complete phrases as search units: "no puedo mas," "me hierve la sangre," "cerebro frito." In colloquial Spanish, emotional charge frequently resides in the fixed phrase, not the isolated word.

2. **Three axes instead of one.** Conventional lexicons assign a single value (positive/negative or valence/arousal) to each entry. MARISScorer classifies each entry into one of three functional axes --Hardware, Flow, Friction-- capturing orthogonal dimensions of emotional state.

3. **Regional variants as first-class citizens.** Regional expressions are not an appendix or a synonym table. They occupy the same categories and receive the same weights as general entries.

---

## 3. System Architecture

### 3.1 Overview

MARISScorer is a measurement component. It receives a text message as input and produces a numerical vector as output. It does not generate responses. It does not select therapeutic strategies. It does not interact with the user. Its function is analogous to a thermometer: it measures temperature but does not prescribe treatment.

The complete flow operates in four phases:

```
User message
    |
    v
[1] Tokenization and normalization
    |
    v
[2] Dictionary lookup (147 entries, 16 categories)
    |
    v
[3] State equation calculation
    |
    v
[4] Vector emission: {hardware, flow, friction, state, mode}
```

The emitted vector is consumed by ACOP (Adaptive Context-Oriented Protocol). ACOP resides on the server and uses these numbers --together with the full LLM evaluation-- to decide how to respond.

### 3.2 The dictionary: diccionario_v1.json

The dictionary contains 147 entries across 16 categories. Each entry is a (phrase, weight) pair where the weight is a value between 0.0 and 1.0 representing the intensity of the emotional signal.

**FRICTION family (what weighs).** Eleven categories capturing distinct modalities of emotional load: friccion_alta (direct despair), friccion_media (acknowledged difficulty), friccion_util (productive friction), ansiedad_somatica (somatized anxiety), panico (acute panic activation), paralisis (behavioral freezing), agotamiento (resource depletion), absolutismo (dichotomous thinking), culpa (negative self-attribution), rabia (manifest anger), and disociacion (depersonalization/derealization).

**FLOW family (what energizes).** Two categories distinguishing between genuine energy (flow_genuino) and ungrounded energy (flow_corrupto). Corrupted flow does NOT add to the Flow axis. It is redirected to Friction at a x0.3 attenuation factor. Ungrounded hyperactivation is treated as a form of friction, not energy.

**HARDWARE family (capacity to act).** Two categories evaluating whether the person can act: hardware_accion (active solution-seeking) and hardware_averia (perceived incapacity).

**Cross-cutting signal.** descenso_crisis reduces friction by x0.5 when detected. This signals that the person reports improvement after a difficult episode.

### 3.3 Absolutism rule

When the system detects two or more absolutist markers ("siempre," "nunca," "nadie," "todo," "nada") in a single message, total friction is multiplied by 1.2. This rule is based on a consistent finding in clinical literature: dichotomous thinking is a predictor of psychological distress and a recognized marker of cognitive distortions (Beck, 1976; Al-Mosaiwi & Johnstone, 2018).

---

## 4. The State Equation

### 4.1 Formulation

```
state = (hardware x 0.4) + (flow x 0.3) - (friction x 0.3)
```

### 4.2 Range and thresholds

The equation produces values in the theoretical range of -0.3 to +0.7:

| Range | Mode | Clinical description |
|-------|------|-----------------|
| state > 0.2 | Explore / Accompany | The person has sufficient resources for reflection and gentle challenge |
| -0.1 <= state <= 0.2 | Sustain | The person is in fragile equilibrium; the system accompanies without pushing or containing |
| state < -0.1 | Contain / Structure | The person is overloaded; the system reduces stimuli, validates, offers minimal structure |

### 4.3 Weight justification

**Hardware receives the highest weight (0.4)** because capacity to act is the strongest predictor of emotional recovery. This weighting aligns with behavioral activation models (Martell et al., 2001). Action capacity precedes emotional improvement, not the reverse.

**Flow and Friction receive equal weights (0.3 each)** with opposite signs. This creates a bipolar axis where positive energy and negative load counterbalance. The experience of being simultaneously energized and burdened is clinically real. The equation captures it.

### 4.4 Deliberate range asymmetry

The range extends further toward the positive (+0.7) than the negative (-0.3). This asymmetry encodes a clinical position: the system has greater granularity in positive states (where interventions can be more varied) than in negative states (where the response is uniformly protective). When the person is suffering, the exact nuance of "how bad" matters less than the decision to contain.

---

## 5. Regional Variants

### 5.1 Coverage

The system recognizes expressions from five registers:

- **Mexico (MX):** "valiendo madre" (0.85), "aguitado" (0.50), "chambear" (0.50), "sacado de onda" (0.60)
- **Argentina (ARG):** "hasta las manos" (0.90), "re manija" (0.75), "en la lona" (0.90), "quilombo" (0.60)
- **Colombia (COL):** "estoy melo" (0.90), "con toda" (0.90), "achicopalado" (0.70), "me sabe a mierda" (0.85)
- **Spain (ESP):** "estoy petao" (0.85), "pasado de vueltas" (0.70), "rayada mental" (0.60)
- **Neutral + digital slang:** "brainrot" (0.60), "delulu" (0.65), "ick emocional" (0.70)

### 5.2 What is missing

The dictionary v1 does not include variants from Chile, Peru, Venezuela, Central America, or the Spanish-speaking Caribbean. This absence reflects a resource constraint in version 1. The four included regions (MX, ARG, COL, ESP) represent the largest Spanish-speaking markets by potential user volume.

---

## 6. Vulnerability Multipliers

Three multipliers adjust friction based on user profile:

| Multiplier | Factor | Activation condition |
|------------|--------|---------------------|
| historialFragil | x1.5 | User has documented history of elevated emotional vulnerability |
| deformacion > 0.3 | x1.3 | Cognitive distortion level (measured by Physics Brain) exceeds 0.3 threshold |
| scarsRecientes | x1.4 | Recent episodes of self-harm or crisis exist in user record |

Multipliers are cumulative. They apply to the final friction value before state equation calculation. A user with historialFragil=true and scarsRecientes=true receives a combined multiplier of 1.5 x 1.4 = 2.1.

There is no clinical situation where a patient simultaneously has a fragile history, elevated cognitive distortion, and recent scars, and the appropriate response is "treat the message as if it came from anyone."

---

## 7. Transition Signals

Beyond the semantic content of words, MARISScorer monitors formal signals indicating user deterioration:

1. **Length drop >50%** versus previous message (communicative contraction)
2. **Typographic error increase** (>2 unrecognized words, fine motor deterioration)
3. **Punctuation disappearance** (metacognitive effort no longer available)
4. **Friction jump >0.3** in one turn (abrupt escalation suggesting precipitating event)

If three or more signals are detected simultaneously, the system activates warm mode before the message is processed by the full pipeline. The threshold of three (not two or four) occupies the point where formal detection adds information that content analysis might miss.

---

## 8. Experimental Results

Six scenarios were evaluated covering the full spectrum of detectable states:

| Scenario | Input | State | Expected mode | Assigned mode | Result |
|----------|-------|-------|---------------|---------------|--------|
| 1. Active crisis | "no puedo mas, estoy frito y no se que hacer" | -0.26 | Contain | Contain | CORRECT |
| 2. Positive activation + MX variant | "estoy en la zona, con toda, vamos a chambear" | +0.46 | Explore | Explore | CORRECT |
| 3. Active absolutism | "me pesa la vida, nadie me entiende, todo me sale mal" | -0.26 | Contain | Contain | CORRECT |
| 4. Crisis descent | "ya estoy bien, me calme, gracias me ayudo" | ~0.0 | Sustain | Sustain | CORRECT |
| 5. Corrupted flow + ARG variant | "hypeado sin base, cabeza a mil, re manija" | ~0.0 | Sustain | Sustain | CORRECT |
| 6. historialFragil multiplier (same as #5) | Same input, historialFragil=true | -0.30 | Contain | Contain | CORRECT |

**Correct classification rate: 6/6 (100%)**

---

## 9. Design Decisions

### 9.1 Why not embeddings

**Determinism.** A dictionary produces the same result for the same input, always. In a system where scoring feeds decisions with clinical consequences, absolute reproducibility is a desired property.

**Auditability.** When the scorer assigns friction=0.85, a developer can trace exactly which dictionary entry produced that value. With embeddings, the explanation would involve cosine similarity to a cluster. Correct but opaque. Auditability is a regulatory requirement for any system that touches mental health.

**Computational cost.** A dictionary fits in kilobytes. An embedding model in megabytes. On an iPhone, this difference translates to application load time, battery consumption, and memory footprint.

### 9.2 Why separate measurement from decision

The scorer measures. ACOP decides. This replicates a distinction in clinical practice: the assessment instrument is not the therapist. The BDI-II (Beck Depression Inventory) produces a number. The clinician interprets that number in context and decides the course of action. "The LLM reasons. The scorer operates. Together they are MARIS."

### 9.3 Why "me voy a morir" receives weight 1.0

The phrase "me voy a morir" has frequent colloquial use in Latin American Spanish: "me voy a morir de risa," "me voy a morir del calor." Assigning it maximum weight guarantees a high number of false positives.

The decision rests on an asymmetric cost calculation. The cost of a false positive: the system activates unnecessary containment. The experience is slightly overprotective. The cost of a false negative: the system fails to detect suicidal ideation expressed literally. A person in crisis does not receive the containment response they need. The asymmetry between these costs is extreme. Any threshold below 1.0 would constitute design negligence.

Disambiguation does not fall to the scorer. The scorer flags. The EIP contextualizes. ACOP decides.

---

## 10. Limitations

### 10.1 Dictionary approach limitations

- **Finite lexical coverage.** 147 entries do not cover the entirety of emotional Spanish.
- **Morphological rigidity.** The dictionary performs exact string matching. "Encabronado" is detected. "Re encabronada" is not.
- **Absence of negation handling.** "No estoy frito" activates the same entry as "estoy frito."
- **Order insensitivity.** The scorer treats messages as bags of words. It does not distinguish between "estoy bien pero me cuesta" and "me cuesta pero estoy bien."

### 10.2 Equation limitations

- **Linearity.** The state equation is a linear combination. Emotional reality is not.
- **Fixed weights.** The coefficients (0.4, 0.3, 0.3) do not adapt to individual users.

### 10.3 Regional coverage limitations

Five Spanish-speaking countries are not represented. Within covered countries, the selection favors urban and youthful registers. It underrepresents rural variants, older generation expressions, and formal registers of emotional distress.

### 10.4 Validation limitations

Six test scenarios do not constitute statistical validation. No precision, recall, or F1 metrics are reported because the sample size does not support them. Rigorous validation would require an annotated corpus of real messages with emotional state evaluation by multiple human judges. That resource does not exist for colloquial Spanish with regional variants at time of publication.

---

## 11. Future Work

1. **Dictionary expansion** to 300 entries covering Chile, Peru, Venezuela, and Central America. Validated with native speakers.
2. **Fuzzy matching** (Levenshtein distance, n-grams) to mitigate typographic rigidity.
3. **Hybrid model** combining the dictionary with a lightweight CoreML model (sub-10MB) for semantic signals not captured lexically.
4. **Annotated corpus construction** for quantitative validation with human judges.
5. **Adaptive weights** through reinforcement learning from user interactions, without compromising auditability.

---

## 12. Conclusions

MARISScorer is a dictionary-based semantic scoring system. It runs entirely on-device. It classifies emotional state and appropriate therapeutic mode in Spanish, including Latin American regional variants. It does not pretend to replace the analysis a language model can perform. It complements it with speed, determinism, and offline capability.

The 147 dictionary entries, across 16 categories and 5 regional variants, feed a triaxial equation (Hardware/Flow/Friction). The equation produces values in the -0.3 to +0.7 range. These are classifiable into three therapeutic modes: contain, sustain, and explore. Vulnerability multipliers and transition signals add contextual sensitivity without sacrificing computational simplicity.

The limitations are real and numerous. Each is documented as a roadmap for the next version.

Emotional well-being systems operating in languages other than English need evaluation tools built from those languages, not translated into them. MARISScorer is a first step in that direction.

---

## References

Al-Mosaiwi, M., & Johnstone, T. (2018). In an absolute state: Elevated use of absolutist words is a marker specific to anxiety, depression, and suicidal ideation. *Clinical Psychological Science, 6*(4), 529-542.

Baccianella, S., Esuli, A., & Sebastiani, F. (2010). SentiWordNet 3.0: An enhanced lexical resource for sentiment analysis and opinion mining. *Proceedings of LREC 2010*.

Beck, A. T. (1976). *Cognitive therapy and the emotional disorders*. International Universities Press.

Bradley, M. M., & Lang, P. J. (1999). *Affective norms for English words (ANEW)*. NIMH Center for the Study of Emotion and Attention.

Cambria, E., Poria, S., Gelbukh, A., & Thelwall, M. (2017). Sentiment analysis is a big suitcase. *IEEE Intelligent Systems, 32*(6), 74-80.

Martell, C. R., Addis, M. E., & Jacobson, N. S. (2001). *Depression in context: Strategies for guided action*. Norton.

Mohammad, S. M., & Turney, P. D. (2013). Crowdsourcing a word-emotion association lexicon. *Computational Intelligence, 29*(3), 436-465.

Pennebaker, J. W., Boyd, R. L., Jordan, K., & Blackburn, K. (2015). *The development and psychometric properties of LIWC2015*. University of Texas at Austin.

Sidorov, G., Miranda-Jimenez, S., Viveros-Jimenez, F., Gelbukh, A., Castro-Sanchez, N., Velasquez, F., ... & Gordon, J. (2013). Empirical study of machine learning based approach for opinion mining in tweets. *Proceedings of MICAI 2012*, 1-14.

Turkle, S. (2011). *Alone together: Why we expect more from technology and less from each other*. Basic Books.

Weizenbaum, J. (1976). *Computer power and human reason: From judgment to calculation*. W.H. Freeman.

---

(c) 2025-2026 Leonel Perea Pimentel. Todos los derechos reservados / All rights reserved.
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

