# CRO & A/B Testing — Frameworks Aplicados a MARIS
## Fuentes: CXL, WiderFunnel (LIFT), Hotjar, Product-Led Growth

---

## 1. LIFT MODEL (WiderFunnel — Chris Goward)

6 factores de conversión. 1 vehículo + 2 drivers + 2 inhibidores:

**VEHÍCULO:**
- **Value Proposition** — "¿Por qué elegir esto sobre alternativas, incluyendo no hacer nada?"

**DRIVERS (aumentan conversión):**
- **Relevance** — ¿La página coincide con lo que el usuario esperaba? Mismatch = bounce
- **Clarity** — ¿Entiende la oferta y la acción en 5 segundos? (diseño + copy)
- **Urgency** — ¿Razón para actuar AHORA? Interna (necesidad propia) o externa (escasez, deadline)

**INHIBIDORES (disminuyen conversión):**
- **Anxiety** — Miedos: privacidad, "¿es legítimo?", "¿funcionará?"
- **Distraction** — Elementos que compiten por atención y alejan del CTA

### LIFT aplicado a cada pantalla de MARIS:

| Pantalla | Anxiety principal | Distraction principal |
|----------|------------------|-----------------------|
| App Store | Privacidad con AI, reviews bajas | "You might also like" de la tienda |
| Onboarding | "¿Esto realmente funciona?" | Demasiados permisos, onboarding largo |
| Primer mensaje | "¿El AI es bueno?" — primera impresión | UI cluttered, no claro qué puede hacer |
| Paywall | "¿Puedo cancelar?" | Demasiadas opciones de plan |

---

## 2. ResearchXL (CXL — Peep Laja)

**Nunca testear ideas random. Investigar primero.**

6 pilares en orden:
1. **Technical Analysis** — Crash logs, API latency, onboarding completion por device/iOS version
2. **Digital Analytics** — Funnel de onboarding por cohort, retention curves, feature usage
3. **Heuristic Analysis** — Walkthrough con LIFT, 3-5 evaluadores independientes
4. **Mouse/Interaction Tracking** — Session recordings (UXCam/Smartlook para iOS)
5. **Qualitative Surveys** — "¿Qué casi te detuvo?" "¿Qué falta?" "¿Qué te trajo aquí?"
6. **User Testing** — 5 usuarios task-based. Graba pantalla + audio. 5 usuarios capturan 85% de problemas.

Output: Findings → Hypotheses → Prioritize (PIE/ICE) → A/B Test

---

## 3. PRIORIZACIÓN: PIE vs ICE

**PIE (para elegir QUÉ PÁGINA optimizar):**
- Potential + Importance + Ease / 3

**ICE (para elegir QUÉ IDEA testear):**
- Impact × Confidence × Ease (multiplicativo)

### PIE para MARIS:
| Stage | P | I | E | PIE |
|-------|---|---|---|-----|
| App Store→Download | 7 | 8 | 6 | 7.0 |
| **Download→First Message** | **9** | **9** | **7** | **8.3** |
| First Message→Day 3 | 8 | 8 | 5 | 7.0 |
| Day 3→Day 30 | 6 | 7 | 4 | 5.7 |
| **Free→Paid** | **8** | **10** | **7** | **8.3** |

**Prioridad: Onboarding y Paywall empatados. Empezar con onboarding porque es upstream.**

---

## 4. A/B TESTING ESTADÍSTICAS

### Bayesian vs Frequentist
- **Frequentist:** Calcular sample size ANTES, correr hasta completar, NUNCA peek midway. Mejor para alto tráfico.
- **Bayesian:** Outputs probabilidad ("94% chance B es mejor"). Más práctico para bajo tráfico. Puede checar en cualquier momento (pero más data = más preciso).

**Para MARIS early stage: Bayesian es más práctico.**

### Reglas de sample size:
- Mínimo ~1,000 conversiones totales entre todas las variantes
- Nunca correr test <7 días aunque tengas el sample size
- Mínimo 2 ciclos de negocio completos (2 semanas)
- Para suscripción: medir downstream (Day 30 retention) = tests de 30+ días

### Errores comunes:
1. **Peeking** — Checar diario y parar cuando p < 0.05. Infla false positives de 5% a 30%+
2. **Parar temprano** — Esperar sample size Y duración mínima
3. **Muchas variantes** — Empezar con A/B (2), no A/B/C/D
4. **Testear cosas tiny** — Color de botón cuando tu value prop no es clara
5. **Sin hipótesis** — Ideas random sin research = waste de tráfico
6. **Segment mining post-hoc** — "No ganó overall pero ganó para iOS 17 los martes" = p-hacking

---

## 5. PROCESO CUALITATIVO HOTJAR

### Heatmaps — qué buscar:
- **Rage clicks** — Tapping repetido en elementos no-interactivos
- **Dead zones** — Áreas con cero interacción donde hay CTAs
- **Scroll drop-off** — ¿Qué % llega debajo del fold? Info crítica debe estar arriba

### Session recordings — señales de fricción:
- **U-turns** — Va a pantalla, regresa inmediatamente
- **Scrolling excesivo** — Busca algo que no encuentra
- **Pausas largas** — 10+ segundos sin interacción = confusión
- **Error states** — ¿Se recuperan o abandonan?

### Surveys clave:
1. Al llegar: "¿Qué te trajo a MARIS hoy?"
2. En fricción: "¿Algo no funciona como esperabas?"
3. Post-primera interacción: "¿Qué casi te detuvo de probar MARIS?"
4. Al salir: "¿Qué te haría volver?"

### Pipeline: Observe → Ask → Hypothesize → Prioritize (ICE) → Test

---

## 6. PRODUCT-LED ONBOARDING

### Time-to-Value (TTV)
Tiempo desde signup hasta el primer "aha moment."
**Para MARIS: Valor en el PRIMER MENSAJE. No después de 3 días. No después de 5 pantallas de onboarding.**

Si el onboarding tarda 5 pantallas antes de que el usuario pueda escribir, TTV es demasiado largo. Considerar: dejar que escriban inmediato y recoger data contextualmente.

### Activation Metric
La acción que más correlaciona con retención a Day 30.

Candidatos MARIS:
- ¿Mandó primer mensaje? (muy básico)
- ¿Completó sesión de 15+ min de enfoque?
- ¿Regresó Day 2?
- ¿Usó MARIS 3 veces en primeros 7 días?
- ¿Activó notificaciones?

**Necesitas datos para encontrar TU "magic number."**
(Facebook: 7 amigos en 10 días. Slack: 2,000 mensajes. MARIS: ?)

### BJ Fogg: Behavior = Motivation × Ability × Trigger
Si usuarios no convierten en un paso: motivación baja, es muy difícil, o falta el trigger.

---

## ROADMAP DE TESTS — PRIORIZADO POR ICE

| # | Test | ICE | Stage |
|---|------|-----|-------|
| 1 | Reducir onboarding a 2 pantallas + primer mensaje inmediato | 504 | Onboarding |
| 2 | Reescribir primera respuesta de AI para valor instantáneo | 504 | Activación |
| 3 | Notificación Day 1 personalizada vs genérica | 448 | Activación |
| 4 | Timing del paywall: post-momento-de-valor vs time-based | 392 | Monetización |
| 5 | Screenshots App Store: outcome vs feature | 384 | ASO |
| 6 | Diferir permisos hasta después de entregar valor | 336 | Onboarding |
| 7 | Price point: $4.99 vs $9.99 vs packs | 280 | Monetización |
| 8 | Reporte semanal de progreso | 210 | Retención |
| 9 | Optimización horario check-in mañanero | 240 | Retención |
| 10 | Streak/gamification vs sin gamification | 120 | Retención |

---

## ANALYTICS MÍNIMO VIABLE

Eventos a instrumentar antes de cualquier test:

```
# Onboarding
app_opened (first_time: bool)
onboarding_screen_viewed (screen_number: int)
onboarding_completed
permission_granted/denied (type)

# Activación
first_message_sent
first_response_received
session_completed (duration: seconds)
returned_day_N (N: 1,2,3,7,14,30)

# Engagement
message_sent (session_number, day)
notification_tapped/dismissed

# Monetización
paywall_viewed (trigger: string)
purchase_completed (product_id, price)
trial_started/converted/expired
subscription_cancelled
```

---

## PRINCIPIO UNIFICADOR
**Acortar time-to-value.** Que el usuario llegue a su primera interacción significativa con el AI lo más rápido posible. Esto afecta cada métrica downstream.
