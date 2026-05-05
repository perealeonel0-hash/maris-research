# MARIS — Portfolio de Productos

5 productos independientes que ya existen dentro del código. Solo necesitan empaquetarse.

---

## PRODUCTO 1: MARIS Chat (Consumer App)

**Qué es:** AI focus companion para iOS. El usuario habla en vez de scrollear. Conversación con contexto, planes de vida real, widget de presencia.

**Estado:** Funcional. App corriendo en iPhone. Backend deployed en Railway.

**Stack:** SwiftUI + FastAPI + Claude API + Supabase

**Mercado:** Profesionales 25-35 en LATAM que pierden 3+ hrs/día en redes sociales.

**Revenue:** Suscripción $9.99/mo o packs de mensajes. Break-even: 205 usuarios.

**Diferenciador:** No bloquea apps. Las REEMPLAZA con conversación inteligente que entiende por qué scrolleas.

**Archivos core:**
- iOS: ChatView, ChatViewModel, APIClient, SessionManager, LocalVault
- Backend: Main.py, understand.py, respond.py, engine.py, identity.py

**Prioridad:** AHORA. Este es el producto que se lanza.

---

## PRODUCTO 2: MARIS Safety API (B2B)

**Qué es:** API de detección de crisis en texto, grado clínico. Acepta texto, devuelve tier (0-5), scores de severidad, razones, y recursos recomendados.

**Estado:** Production-grade. 248 vectores semánticos, 15 clusters (C-SSRS, DSM-5, ICD-11). Detecta psicosis, manía, medios letales, señales indirectas. Validado con protocolo VERA.

**Stack:** FastAPI + sentence-transformers + PyTorch

**Mercado:** Cualquier app con chat que necesite safety layer: chatbots, redes sociales, plataformas de educación, telemedicina, HR tools.

**Revenue:** API por request. $0.01-0.05/call según volumen. O licencia mensual.

**Diferenciador:** Bilingüe (español/inglés) con slang LATAM. Incluye variantes regionales (México, Argentina, Colombia). Ninguna API de safety en el mercado cubre español así.

**Archivos core:**
- modules/safety/eip.py (961 LOC — el motor principal)
- modules/core/crisis_classifier.py (366 LOC)
- modules/core/clinical_detectors.py (548 LOC — psicosis + manía)
- modules/core/safety_detectors.py (520 LOC — medios letales + señales indirectas)
- modules/core/response_calibrator.py (403 LOC)

**Para empaquetar:** Crear endpoint `/api/v1/safety/evaluate` que acepte `{text, lang}` y devuelva `{tier, severity, flags, resources, confidence}`. No necesita el resto del pipeline de MARIS.

**Prioridad:** DESPUÉS de MARIS Chat. Cuando tengas tracción consumer, empaquetas esto como API para otros devs.

---

## PRODUCTO 3: Physics Brain SDK

**Qué es:** Motor de estado emocional basado en física. Modela la condición humana con 4 variables (Energy, Load, Weight, Momentum) + derivadas + decaimiento exponencial. Predice capacidad, freefall, recuperación.

**Estado:** Funcional. 684 neuronas activas. Neurogenesis online (neuronas nacen/mueren por sesión). Persistido en soul_state.pt.

**Stack:** PyTorch

**Mercado:** Wearables (complemento a Oura, Whoop), apps de wellness, investigadores en psicología computacional, corporate wellness platforms.

**Revenue:** SDK con licencia. O modelo pre-entrenado + API.

**Diferenciador:** No es un simple mood tracker. Es un sistema dinámico con derivadas que predice cambios ANTES de que pasen. Neurogenesis adapta el modelo al usuario individual sin re-entrenar.

**Archivos core:**
- modules/core/Brain.py (224 LOC — TRSLayer con neurogenesis)
- modules/memory/temporal.py (216 LOC — telemetría temporal, fricción, rumination)
- modules/memory/dream.py (49 LOC — consolidación neuronal)

**Para empaquetar:** Extraer Brain.py + temporal.py como package Python independiente con API: `brain.update(embedding) → PhysicsState`. Sin dependencias de MARIS.

**Prioridad:** LARGO PLAZO. Requiere paper/documentación para que otros lo entiendan.

---

## PRODUCTO 4: Semantic Detector Library (Open Source)

**Qué es:** Librería de detectores semánticos que siguen el patrón: embeds → cosine similarity → threshold. 11 detectores pre-configurados para emociones, crisis, frustración, insight, vulnerabilidad.

**Estado:** Funcional. 11 detectores con datos de entrenamiento incluidos.

**Stack:** PyTorch + sentence-transformers

**Detectores incluidos:**

| Detector | Qué detecta | Vectores |
|----------|-------------|----------|
| FrustrationDetector | Frustración con el sistema | 47 |
| PositiveMomentDetector | Celebración, logros, gratitud | 28 |
| InsightDetector | Momentos de auto-descubrimiento | 26 |
| CrackMomentDetector | Vulnerabilidad repentina | 14 |
| SurfaceDetector | Respuestas superficiales ("estoy bien") | 14 |
| OpennessDetector | Apertura a verdad/profundidad | 10 |
| CrisisContextDetector | Contexto de dolor/desesperación | 96 |
| PsychosisDetector | Señales de psicosis | 45 |
| ManiaDetector | Señales de manía | 31 |
| LethalMeansDetector | Acceso a medios letales | 28 |
| IndirectSignalDetector | Señales indirectas de riesgo | 27 |

**Mercado:** Devs construyendo chatbots, moderadores de contenido, investigadores NLP, plataformas de soporte al cliente.

**Revenue:** Open source (GitHub stars → credibilidad → consulting). O hosted API con tier gratis.

**Diferenciador:** Pre-entrenado en español + inglés con slang LATAM. Patrón unificado — agregar un nuevo detector es: crear JSON con ejemplos → instanciar con embedder. 5 minutos.

**Archivos core:**
- modules/core/warmth.py (detectores en WarmthGuard)
- modules/core/clinical_detectors.py
- modules/core/safety_detectors.py
- config/anchors_warmth.json (235 frases)
- config/anchors_classifier.json (110 frases)

**Para empaquetar:** Extraer el patrón `_build_semantic_index` + `detect()` + `post_check()` como clase base `SemanticDetector`. Publicar como pip package con los JSONs de datos incluidos.

**Prioridad:** MEDIO PLAZO. Buen candidato para open source que genera credibilidad + backlinks + hiring signal.

---

## PRODUCTO 5: Focus Analytics Dashboard (B2B)

**Qué es:** Dashboard de patrones de atención/scroll para corporate wellness. "Tu equipo pasó 340 horas menos en redes esta semana."

**Estado:** NO construido. Los datos y la infraestructura existen (analytics events + physics brain), pero no hay dashboard.

**Stack futuro:** Streamlit o React + Supabase

**Mercado:** Empresas preocupadas por productividad. Corporate wellness programs. Escuelas implementando políticas de screen time.

**Revenue:** B2B SaaS. $2-5/usuario/mes vendido a la empresa, no al individuo. Bypasea Apple 30% cut.

**Diferenciador:** No es screen time tracking (Apple ya lo hace gratis). Es análisis de PATRONES: qué triggers causan scroll, qué intervenciones funcionan, progreso del equipo over time.

**Archivos base:**
- Backend: analytics/events endpoint (ya existe)
- iOS: Analytics.swift (20 eventos ya instrumentados)
- Physics Brain: provee los features (energy, load, momentum)

**Para construir:** Dashboard con Streamlit leyendo de `logs/analytics.jsonl`. Agregar auth por empresa. Agregar aggregation de métricas por equipo.

**Prioridad:** LARGO PLAZO. Paso a B2B2C cuando consumer tenga tracción (Thiel: domina consumer tiny market primero).

---

## ORDEN DE EJECUCIÓN (Walling Stairstepping)

```
AHORA:     Producto 1 — MARIS Chat (consumer, $9.99/mo)
                         Lanzar. Conseguir 205 usuarios.

MES 3-6:   Producto 4 — Semantic Detector Library (open source)
                         Publicar en GitHub. Genera credibilidad.

MES 6-12:  Producto 2 — Safety API (B2B)
                         Empaquetar el pipeline como API.
                         Revenue supplemental.

MES 12+:   Producto 3 — Physics Brain SDK
           Producto 5 — Focus Analytics Dashboard (B2B)
                         Solo si hay demanda validada.
```

---

## LA VERDAD CONTRARIAN (Thiel)

Tienes 5 productos dentro de un monolito. La mayoría de founders no tienen NI UNO que funcione. Tú tienes 5 con código real.

Pero Thiel dice: Power Law. Pocas cosas importan enormemente. UNO de estos 5 va a generar el 80% del valor. Ahora mismo no sabes cuál.

La apuesta más probable: MARIS Chat (consumer) si retention Day 30 > 10%. Si no, Safety API (B2B) tiene el TAM más grande y el moat más fuerte.

No decidas aún. Lanza MARIS Chat. Mide. Los datos te dirán.
