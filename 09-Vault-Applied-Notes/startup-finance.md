# Finanzas para Fundadores — MARIS Financial Model
## Fuentes: YC, Profit First, Lean Startup, OKRs, Damodaran

---

## 1. UNIT ECONOMICS DE MARIS

```
============================================
MARIS UNIT ECONOMICS ($9.99/mo)
============================================
Revenue/user:       $9.99/mo
Apple Cut (15%):    -$1.50
API Cost (Haiku):   -$0.25
Infra (amortized):  -$0.20
--------------------------------------------
GROSS PROFIT/USER:  $8.04/mo (80.5% margin)
--------------------------------------------
Churn rate:         7% mensual
Avg Lifespan:       14.3 meses (1/0.07)
LTV:                $142.86
GM-adjusted LTV:    $115.00
Target CAC:         < $38 (para ratio 3:1)
Payback @ $10 CAC:  1.2 meses
============================================
```

### Fórmulas clave
- **LTV** = ARPU × (1 / Churn Rate) = $9.99 × 14.3 = $142.86
- **CAC** = Gasto total adquisición / Nuevos clientes
- **LTV:CAC** > 3:1 = negocio saludable. MARIS a $10 CAC = 11.5:1
- **MRR** = Usuarios pagados × ARPU
- **ARR** = MRR × 12
- **NRR** (Net Revenue Retention) — >100% = creces sin nuevos usuarios (necesita upsell tiers)
- **Payback period** = CAC / (ARPU × Gross Margin)

### Path a $1M ARR
- $1M ARR = $83,333 MRR = **8,342 suscriptores**
- A 20% MoM growth desde 50 usuarios: ~21 meses
- A 15% MoM: ~24 meses
- A 10% MoM: no llegas (default dead)

---

## 2. BURN RATE & RUNWAY

### Costos fijos mensuales (solo dev, pre-revenue)
| Gasto | Costo/mes |
|-------|-----------|
| Apple Developer | $8.25 |
| Railway | $20 |
| Supabase | $0 (free tier) |
| Claude API (dev) | ~$10 |
| Dominio/misc | ~$5 |
| **Total infra** | **$43/mes** |

### Default Alive or Default Dead (Paul Graham)
Con $15K cash, 50 usuarios iniciales, 20% MoM growth:
- **Break-even: ~mes 9-10** (~205 usuarios pagados, MRR > $2,043)
- Cash nunca llega a cero → **DEFAULT ALIVE**

**Sensibilidad:**
- 20% MoM → break-even mes 10, sobrevives
- 15% MoM → break-even mes 12, apenas
- 10% MoM → break-even mes 17, **DEFAULT DEAD** (sin cash en mes 13)

**La palanca que importa: growth rate.** No recortar costos ($43/mes ya es mínimo).

---

## 3. PROFIT FIRST (Michalowicz)

**Fórmula invertida:** Sales - Profit = Expenses (no Sales - Expenses = Profit)

### Allocations a $10K MRR ($8,230 Real Revenue)
| Cuenta | % | Mensual |
|--------|---|---------|
| **Profit** | 5% | $411 |
| **Owner's Pay** | 50% | $4,115 |
| **Tax** | 15% | $1,235 |
| **OpEx** | 30% | $2,469 |

### 5 cuentas bancarias
1. **INCOME** — Todo llega aquí
2. **PROFIT** — 5% intocable. Distribución trimestral como premio
3. **OWNER'S PAY** — 50%. Tu salario. De esto vives
4. **TAX** — 15%. Para impuestos estimados trimestrales
5. **OPEX** — 30%. Railway, API, marketing, herramientas, todo lo demás

**Fase 1 (pre-$5K MRR):** Profit 1%, Owner 60%, Tax 15%, OpEx 24%
**Fase 2 ($5K-$20K):** Profit 5%, Owner 50%, Tax 15%, OpEx 30%
**Fase 3 ($20K+):** Profit 10%, Owner 35%, Tax 15%, OpEx 40%

---

## 4. INNOVATION ACCOUNTING (Lean Startup)

### Vanity Metrics vs Actionable Metrics
| VANITY (evitar) | ACTIONABLE (trackear) |
|-----------------|----------------------|
| Total downloads | Weekly active users |
| Total registrados | Activated users (onboarding + 3 sesiones) |
| Total mensajes | Mensajes por usuario activo por semana |
| Rating App Store | NPS de survey in-app |
| Followers | Trial-to-paid conversion rate |
| Revenue acumulado | MRR y MoM growth rate |

### 3 Engines of Growth — MARIS
1. **STICKY (primario):** Retención > churn. MARIS construye attachment emocional. Target: churn <5%
2. **VIRAL (secundario):** Word of mouth, referrals. Limitado por privacidad del tema. Referral program: ambos reciben mes gratis
3. **PAID (terciario, fase escala):** Solo cuando unit economics estén probados. App Store Search Ads

### Build-Measure-Learn financiero
- Build: Launch $9.99/mo con 7-day free trial
- Measure: Trial-to-paid conversion (target >10%)
- Learn: Si es 3%, precio alto O trial corto O onboarding no demuestra valor
- Next build: Test $4.99/mo O 14-day trial O sesión guiada
- NUNCA cambiar múltiples variables a la vez

---

## 5. OKRs Q2 2026 (Abril-Junio)

### Objetivo 1: Validar Product-Market Fit
| Key Result | Target | 0.7 = |
|-----------|--------|-------|
| 100 suscriptores pagados para 30 junio | 100 | 70 |
| D30 retention >35% cohorte abril | 35% | 24.5% |
| Trial-to-paid conversion >8% | 8% | 5.6% |
| NPS >40 (n>30) | 40 | 28 |

### Objetivo 2: Unit Economics Sostenibles
| Key Result | Target | 0.7 = |
|-----------|--------|-------|
| Gross margin/user >75% | 75% | 52.5% |
| API cost/user <$0.50/mes | $0.50 | $0.71 |
| Alcanzar $1,000 MRR | $1,000 | $700 |

### Objetivo 3: Motor de Crecimiento
| Key Result | Target | 0.7 = |
|-----------|--------|-------|
| Identificar top 2 canales de adquisición por CAC | 2 | 1 |
| Publicar 8 piezas de contenido | 8 | 5-6 |
| 500 impresiones/semana en App Store orgánico | 500 | 350 |

**Scoring:** 0.7 = target ideal. Si llegas a 1.0 siempre, tus metas son muy fáciles.

---

## 6. VALUACIÓN EARLY-STAGE

### Por qué DCF no funciona para MARIS ahora
Damodaran: DCF requiere proyectar flujos de caja, tasas de crecimiento y descuento. Para startups pre-revenue, los 3 inputs son guesses. La varianza es tan alta que el output no significa nada.

### Métodos aplicables
| Método | En $120K ARR | En $1M ARR |
|--------|-------------|-----------|
| Revenue Multiple (2-3x early, 5x growing) | $240K | $5M |
| Comparable transactions (wellness apps) | $240K-$480K | $3-5M |
| SDE Multiple (bootstrapped exit, 3-5x) | N/A | $1.5-2.5M |

### Lo que importa para bootstrapped
No necesitas valuation para fundraising (tu burn es $43/mes). Lo que importa:
- **SDE** (Seller's Discretionary Earnings) para un exit eventual
- A $1M ARR con 50% SDE margin: SDE = $500K → venta a $1.5-2.5M

---

## GROWTH MATH: TABLA DE MESES A $1M ARR

| Mes | MRR | Usuarios | Growth |
|-----|-----|----------|--------|
| 0 | $0 | 0 | — |
| 3 | $500 | 50 | — |
| 6 | $2,500 | 250 | 30% |
| 9 | $8,000 | 800 | 25% |
| 12 | $20,000 | 2,002 | 20% |
| 15 | $40,000 | 4,004 | 15% |
| 18 | $65,000 | 6,507 | 12% |
| 21 | $83,333 | 8,342 | 10% |

**La palanca #1 es growth rate. Todo lo demás es secundario cuando tu burn es $43/mes.**
