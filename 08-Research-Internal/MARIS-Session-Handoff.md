# MARIS/Boe — Handoff para siguiente sesión

---

## QUÉ ES ESTO

Boe es una app iOS de AI que ayuda a la gente a pensar más claro. No es terapia. No es wellness. Es una prótesis reflexiva — extiende la capacidad de pensar, no la reemplaza. El backend corre en Railway (FastAPI + Python), usa Claude API, y tiene un pipeline de 23 pasos con detección de crisis, physics brain, y 248 vectores semánticos.

## ESTADO ACTUAL: HAY UN BUG VISUAL QUE ARREGLAR PRIMERO

La sesión anterior intentó implementar un sistema de temas dinámicos (4 paletas seleccionables por el usuario). **Se hizo mal.** El resultado:

- `Theme` usa `static var` (computed properties) que leen de UserDefaults cada vez → SwiftUI no re-renderiza cuando cambia
- Algunos botones/views no pasan por Theme → colores inconsistentes
- Se agregó complejidad innecesaria (Palette struct, App Group sync, WidgetCenter reload) cuando lo que se necesita es UNA paleta fija que funcione

### LO QUE HAY QUE HACER PRIMERO (antes de cualquier otra cosa):

1. **Revertir `AppTheme.swift` a valores fijos** — quitar Palette struct, quitar computed properties, quitar load()/save(). Solo `static let` con UN set de colores:
   - Background: navy `#0C1520`
   - Cards: `#151E2B`
   - Accent: burnt ember `#E8643A` (esto lo diferencia de Copilot que usa teal)
   - Text: warm off-white `#E8E6E2`
   - User bubble: `#1A2535`

2. **Auditar CADA archivo .swift** — grep por `Color(hex:` y verificar que NO quede ninguno. Todo debe ser `Theme.algo`.

3. **Eliminar ThemePicker** — la selección de temas se puede implementar después cuando la base funcione. Ahora es complejidad prematura.

4. **Verificar que el widget use los mismos colores** hardcoded (el widget es target separado, necesita su propia copia de los hex values, eso es correcto).

---

## VAULT DE CONOCIMIENTO

Existe una carpeta `research/vault/` con **18+ archivos** de frameworks verificados. Cada decisión de diseño, código, o negocio debe consultarse contra estos archivos. NO son opiniones — son frameworks extraídos de libros reales, investigación publicada, y datos de apps exitosas.

### Cómo usar el vault:
1. Lee `research/vault/INDEX.md` para ver qué hay
2. Antes de tomar una decisión de arquitectura → lee `arjancodes-python-patterns.md` y `primeagen-code-aesthetics.md`
3. Antes de tocar UI/UX → lee `tone-conversion-data.md` y `branding-naming-visual-design.md`
4. Antes de tocar el prompt → lee `tuberia-piedras-agua-philosophy.md` y `chris-voss-negotiation.md`
5. Antes de cualquier decisión de negocio → lee `saas-solofounder-product.md` y `startup-finance.md`

### Los archivos más importantes:

**Filosofía del producto (escrito por el fundador — es la fuente de verdad):**
- `tuberia-piedras-agua-philosophy.md` — Todo sistema tiene Tubería (arquitectura), Piedras (fricción), Agua (valor). MARIS detecta estructura, fricción, y si el valor llega. El usuario nunca ve estos términos. Solo siente que MARIS ve lo que otros no ven.

**Reglas técnicas:**
- `arjancodes-python-patterns.md` — DI con Protocols, Strategy pattern, SOLID. UNA fuente de verdad para todo.
- `primeagen-code-aesthetics.md` — Never nesting, boring code wins, max 25 líneas por función, no abstraer hasta tener 3 casos.
- `bytebytego-system-design.md` — SSE, caching, cold start, async queue.
- `full-code-audit.md` — Auditoría completa de los 50 archivos. God objects identificados. Scores por archivo.

**Reglas de diseño:**
- `tone-conversion-data.md` — Coach+Companion tone. Gain-framed. Solution-focused. Identity-reinforcing. NO fear, NO shame, NO clinical.
- `berger-contagious.md` — NUNCA posicionar como salud mental. Lifestyle upgrade. Triggers 100x/día (widget).

**Negocio:**
- `hormozi-100m-offers.md` — Ecuación de valor. Grand Slam offer.
- `startup-finance.md` — Unit economics: $0.0015/msg prompt cost. Break-even 205 usuarios. $9.99/mo target.

---

## ARQUITECTURA ACTUAL

### Backend (Desktop/MiProyecto/)
- `Main.py` — FastAPI entry, /chat route
- `engine.py` — God object con 22 módulos (del audit: score 1/5 en testability)
- `understand.py` — listen() 388 LOC, 1 función (del audit: score 1/5 en simplicity)
- `respond.py` — 5 post-processors + VETO gate
- `modules/core/identity.py` — **PROMPT V7** con filosofía Tubería-Piedras-Agua + técnicas Voss. 567 tokens.
- `config/` — Anchors externalizados a JSON (3 archivos). Loader genérico.
- `modules/core/trace.py` — log_step() structured logging
- `tests/test_critical_paths.py` — 16 tests, todos pasando

### iOS (Documents/AIDA-iOS/AIDA/)
- `Core/AppTheme.swift` — **ROTO** — tiene Palette dinámico que no funciona bien. REVERTIR a static let.
- `Core/Analytics.swift` — 20 eventos tipados, batch queue, funciona
- `Core/ChatViewModel.swift` — God object 459 LOC, 16 responsabilidades (del audit)
- `Core/SessionManager.swift` — Monetización: 5 msgs/día free, hasMessages funciona
- `Views/Chat/ChatView.swift` — Migrado a Theme.*, dark mode, serif AI text
- `Views/Chat/MessageBubble.swift` — Migrado a Theme.*, teal user bubble (cambiar a Theme.userBubble)
- `Views/Dashboard/DashboardView.swift` — Simplificado: saludo + planes + calendario + acciones. 240 LOC (antes 578)
- `Views/Components/ConsentView.swift` — "Tu copiloto para pensar con claridad"
- `Views/Components/EmotionalOnboarding.swift` — "¿En qué quieres avanzar?" + goals productivos
- `Views/Components/MenuView.swift` — Dark, crisis al final, sin hearts
- `Views/Components/SettingsView.swift` — 471 LOC, necesita rediseño (tiene Theme picker que debe removerse por ahora)
- `BoeWidget/BoeWidget.swift` — Reescrito: plan activo, no mood words. Tiene WidgetPalette que debe simplificarse a colores fijos.

### Supabase
- Tables: users, memory_vault, user_crisis_state, anchors
- RLS policies activas
- URL: https://pgcircqhctfgxnddwcgg.supabase.co

### Railway
- Producción: https://web-production-7c97d.up.railway.app
- Deploy: `railway up` desde Desktop/MiProyecto/
- Cold start: ~9 min (sentence-transformers + todos los indices)
- Prompt V7 deployed y activo

---

## LO QUE YA SE HIZO EN ESTA SESIÓN

| Logro | Status |
|-------|--------|
| Vault de conocimiento (18 archivos) | DONE |
| Auditoría completa backend + iOS | DONE |
| Anchors externalizados a JSON (3/3 módulos) | DONE |
| Analytics (20 eventos + endpoint backend) | DONE |
| Monetización rehabilitada (5/día free) | DONE |
| Onboarding rediseñado (productivity, no therapy) | DONE |
| Prompt V7 (Tubería-Piedras-Agua + Voss) | DONE, deployed |
| Prompt injections hardened (anti-extraction + 15 patterns nuevos) | DONE |
| RateGuard thread safety fix | DONE |
| Dark mode | DONE |
| Dashboard simplificado (240 LOC vs 578) | DONE |
| Widget reescrito (plan activo, no mood) | DONE |
| 16 tests pasando | DONE |
| Product Portfolio (5 productos separados) | DONE, documented |

## LO QUE FALTA

| Prioridad | Tarea |
|-----------|-------|
| **P0** | Fix AppTheme — revertir a static let, auditar que todo use Theme.*, eliminar ThemePicker |
| **P1** | Rediseño SettingsView — deprioritizar features clínicas, reframe a herramienta |
| **P1** | Identidad visual propia — paleta navy + ember accent está definida, falta mascota Boe |
| **P2** | Health check endpoint en backend |
| **P2** | Haiku routing para mensajes casuales (ahorro 50% API cost) |
| **P3** | Apple Developer Program ($99) + TestFlight |
| **P3** | Privacy policy page |
| **P3** | App Store screenshots + icon |

---

## REGLAS PARA EL SIGUIENTE CLAUDE

1. **Un problema a la vez.** No combines fixes de distintas áreas.
2. **Consultar el vault** antes de tomar decisiones. Está en `research/vault/INDEX.md`.
3. **No inventar datos.** Si no estás seguro, pregunta o usa Grep.
4. **Verificar después de implementar.** Build + test.
5. **No agregar complejidad.** Boring code wins (Primeagen). Static let > computed properties. Una fuente de verdad.
6. **Tag antes de tocar:** `git tag v1.x-pre-[cambio]`
7. **Cold start = 9 min.** No deployar 6 cambios juntos.
8. **Lenguaje del proyecto:** Hardware/Flow/Fricción internamente. El usuario nunca ve estos términos.
9. **El prompt V7 usa Tubería-Piedras-Agua como sistema operativo interno.** NUNCA revelar estos términos al usuario. Claude busca estructura, fricción, y si el valor llega.
10. **Boe no es terapia.** Es una prótesis reflexiva. Posicionar como herramienta de pensamiento, no salud mental.
11. **El nombre de usuario de la app es "Boe".** MARIS es el nombre del proyecto/sistema.
12. **Navy con ember accent** es la paleta elegida. No Copilot (teal), no Calm (blue), no Headspace (orange).
