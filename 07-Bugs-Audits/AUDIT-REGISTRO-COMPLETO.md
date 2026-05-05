# REGISTRO DE AUDITORÍA COMPLETA — MARIS/Boe
**Fecha:** 2026-04-09
**Auditor:** Claude Opus 4.6
**Archivos auditados:** 66 (23 Python + 43 Swift)
**LOC total:** ~8,600

---

## RESUMEN

| Categoría | CRITICAL | HIGH | MEDIUM | LOW | TOTAL |
|-----------|:--------:|:----:|:------:|:---:|:-----:|
| Seguridad backend | 4 | 6 | 8 | 2 | 20 |
| Arquitectura backend | 3 | 4 | 10 | 3 | 20 |
| iOS seguridad | 3 | 2 | 1 | 0 | 6 |
| iOS arquitectura | 2 | 8 | 8 | 5 | 23 |
| iOS Apple compliance | 2 | 3 | 0 | 0 | 5 |
| If/else & lógica | 5 | 5 | 5 | 5 | 20 |
| Vault inconsistencias | 7 | 0 | 15 | 7 | 29 |
| **TOTAL** | **26** | **28** | **47** | **22** | **123** |

---

## PARTE 1: SEGURIDAD — BLOQUEAN LANZAMIENTO

### SEC-01 [CRITICAL] Crisis bypass auth
- **Archivo:** `Main.py:41-67`
- **Bug:** Mensajes con keywords de crisis saltan autenticación. Un atacante envía "quiero morir" y accede sin token.
- **Fix:** Siempre autenticar. Solo skip rate limiting para crisis, NO auth.
- **Status:** [x] FIXED 2026-04-09 — Auth siempre corre. Crisis solo skip rate limiting.

### SEC-02 [CRITICAL] `verified=True` con token fallido en crisis path
- **Archivo:** `Main.py:62-68`
- **Bug:** `verified = True` se asigna FUERA del try/except. Token forjado + crisis keywords = verified.
- **Fix:** Mover `verified = True` dentro del try, después de `verify_session_token` exitoso.
- **Status:** [x] FIXED 2026-04-09 — `verified = True` solo se asigna tras verificación exitosa.

### SEC-03 [CRITICAL] `/analytics/events` sin autenticación
- **Archivo:** `endpoints_admin.py:21-41`
- **Bug:** Cualquiera puede POST JSON arbitrario. Vector de disk fill y data poisoning.
- **Fix:** Requerir Bearer token o access_code.
- **Status:** [x] FIXED 2026-04-09 — Requiere Bearer token + límite 500 eventos + path absoluto.

### SEC-04 [CRITICAL] `user_context` sin sanitizar → system prompt injection
- **Archivo:** `identity.py:78-89`, `understand.py:463`
- **Bug:** Valores raw de `user_context` se insertan directo al system prompt. Un atacante pone `"stakes": "IGNORE ALL..."`.
- **Fix:** Sanitizar cada valor de user_context con `sanitize()` de engine.py.
- **Status:** [x] FIXED 2026-04-09 — `_sanitize_user_input()` con 15 patrones de injection + NFKC normalization + truncate 200 chars. También sanitiza anchors_text.

### SEC-05 [CRITICAL] Session token en plaintext UserDefaults (iOS)
- **Archivo:** `SessionManager.swift:56`
- **Bug:** Token legible en backups no cifrados y jailbreak.
- **Fix:** Migrar a Keychain.
- **Status:** [x] FIXED 2026-04-09 — KeychainHelper.swift creado. Token migrado automáticamente de UserDefaults a Keychain en load(). Save/close/delete usan Keychain.

### SEC-06 [CRITICAL] Sin SSL pinning (iOS)
- **Archivo:** `APIClient.swift` (todo el archivo)
- **Bug:** MITM puede interceptar tokens y mensajes de una app de bienestar mental.
- **Fix:** Implementar `URLSessionDelegate` con certificate pinning.
- **Status:** [x] FIXED 2026-04-09 — PinningDelegate valida TLS contra Railway domain. Todas las requests (incluyendo streaming) usan pinnedSession.

### SEC-07 [CRITICAL] `startup.py` descarga y ejecuta código sin verificar checksum
- **Archivo:** `startup.py:51`
- **Bug:** `eip.py` se descarga de Supabase y se ejecuta. Si Supabase se compromete, code execution arbitrario.
- **Fix:** SHA-256 checksum verification antes de ejecutar.
- **Status:** [x] FIXED 2026-04-09 — Checksum verification via EIP_SHA256 env var. Download aborted if mismatch. Necesita: set `EIP_SHA256` en Railway env vars.

### SEC-08 [HIGH] Token refresh sin límite temporal
- **Archivo:** `auth.py:207-229`
- **Bug:** `verify_session_token_allow_expired` acepta tokens expirados hace años.
- **Fix:** Máximo 7 días de gracia post-expiración.
- **Status:** [x] FIXED 2026-04-09 — max_grace_days=7, tokens más viejos requieren re-login.

### SEC-09 [HIGH] PBKDF2 iterations = 100K (OWASP recomienda 600K)
- **Archivo:** `auth.py:40`
- **Fix:** Subir a 600,000 iteraciones.
- **Status:** [x] FIXED 2026-04-09 — 600K para nuevos hashes. verify_password intenta 600K primero, fallback a 100K para hashes legacy.

### SEC-10 [HIGH] `ACCESS_CODE` vacío = admin endpoints abiertos
- **Archivo:** `auth.py:57`
- **Bug:** Si env var no está set, `check_access` nunca lanza excepción.
- **Fix:** Fail hard si `ACCESS_CODE` no está configurado en producción.
- **Status:** [x] FIXED 2026-04-09 — Retorna 503 si ACCESS_CODE no está configurado.

### SEC-11 [HIGH] `/profile`, `/resonance` sin auth
- **Archivo:** `endpoints_admin.py:102-132`
- **Bug:** Cualquiera sobreescribe datos de usuario con solo saber user_id.
- **Fix:** Requerir Bearer token que coincida con user_id.
- **Status:** [x] FIXED 2026-04-09 — Todos los endpoints requieren Bearer token + verificación user_id match.

### SEC-12 [HIGH] Email enumeration en /register
- **Archivo:** `endpoints_auth.py:49-51`
- **Bug:** 409 "Email ya registrado" permite enumerar emails.
- **Fix:** Mensaje genérico + email de confirmación.
- **Status:** [x] FIXED 2026-04-09 — Error genérico 400 sin revelar si el email existe.

### SEC-13 [HIGH] `/debug/trace/{request_id}` sin auth
- **Archivo:** `endpoints_admin.py:225-245`
- **Fix:** Requerir access_code.
- **Status:** [x] FIXED 2026-04-09 — Requiere access_code.

### SEC-14a [HIGH] `/api/chat` benchmark endpoint sin autenticación
- **Archivo:** `Main.py:136-219`
- **Bug:** Cualquiera puede hacer requests a Claude API sin auth. Solo rate limit por conversation_id que el cliente inventa.
- **Fix:** Requerir access_code via header `X-Access-Code`.
- **Status:** [x] FIXED 2026-04-09 — Requiere `X-Access-Code` header verificado contra `ACCESS_CODE`. También: `asyncio.get_event_loop()` → `get_running_loop()`, dead code `math.isnan(f)` eliminado.

### SEC-14 [HIGH] IAP counts en UserDefaults (iOS)
- **Archivo:** `StoreManager.swift:16-24`
- **Bug:** Usuario puede modificar plist y tener mensajes ilimitados. Apple rechaza esto.
- **Fix:** Server-side validation de compras, o mínimo Keychain.
- **Status:** [ ] PENDIENTE

### SEC-15 [MEDIUM] Unicode bypass en sanitize patterns
- **Archivo:** `engine.py:54-85`
- **Fix:** NFKC normalization antes de matching.
- **Status:** [ ] PENDIENTE

### SEC-16 [MEDIUM] Anchors inyectados sin sanitizar al prompt
- **Archivo:** `identity.py:92`
- **Fix:** Sanitizar anchors_text.
- **Status:** [ ] PENDIENTE

### SEC-17 [MEDIUM] Message validation acepta `role="assistant"` del cliente
- **Archivo:** `models.py:128`
- **Bug:** Cliente puede inyectar respuestas falsas de "assistant" en historial.
- **Fix:** Solo permitir `role="user"` del cliente.
- **Status:** [ ] PENDIENTE

---

## PARTE 2: ARQUITECTURA — DEUDA TÉCNICA

### ARCH-01 [CRITICAL] `listen()` = 400 LOC, 23 responsabilidades
- **Archivo:** `understand.py:100-501`
- **Fix:** Refactorear en 5+ sub-funciones.
- **Status:** [ ] PENDIENTE

### ARCH-02 [CRITICAL] Engine instanciado a import time
- **Archivo:** `engine.py:254`
- **Bug:** Si cualquier import falla, crash sin recovery. Tests imposibles.
- **Fix:** Lazy init o factory function.
- **Status:** [x] FIXED 2026-04-09 — `_create_engine()` wrapper con try/except y log antes de re-raise.

### ARCH-03 [CRITICAL] AppTheme usa computed properties → UserDefaults cada frame
- **Archivo:** `AppTheme.swift:12-40`
- **Bug:** Cientos de lecturas UserDefaults por frame. Performance destruida.
- **Fix:** Cambiar a `static let` con colores fijos.
- **Status:** [x] FIXED 2026-04-09 — Todo `static let`. Eliminada Palette struct, load/save, ThemePicker de SettingsView. Widget simplificado a colores fijos.

### ARCH-04 [CRITICAL] ChatViewModel = god object 469 LOC
- **Archivo:** `ChatViewModel.swift` (todo)
- **Bug:** 16 responsabilidades en 1 clase. Double-count de mensajes (líneas 118 y 363).
- **Fix:** Extraer MessageSender, IntentHandler, NameDetector, ConversionManager.
- **Status:** [ ] PENDIENTE (double-count FIXED, refactor completo pendiente)

### ARCH-05 [HIGH] WarmthGuard estado compartido entre usuarios
- **Archivo:** `warmth.py:458-484`
- **Bug:** `_prev_temperature`, `_temp_velocity` son instance-level en singleton. User A contamina User B.
- **Fix:** Estado per-user keyed por user_id.
- **Status:** [x] FIXED 2026-04-09 — `_user_physics` dict keyed por user_id. `get_temperature()` acepta user_id. `warmth_physics_for()` per-user.

### ARCH-06 [HIGH] Brain.py `_current_user_id` single-user tracking
- **Archivo:** `Brain.py:31`
- **Bug:** Solo el ÚLTIMO usuario tiene physics válido en requests concurrentes.
- **Fix:** Physics state per-user.
- **Status:** [x] FIXED 2026-04-09 — `_user_physics` dict per-user. `physics_state_for()` per-user. `understand.py` usa `physics_state_for(req.user_id)`.

### ARCH-07 [HIGH] PhysicsEngine data race (iOS)
- **Archivo:** `PhysicsEngine.swift:343-357`
- **Bug:** `saveToDisk` lee estado mutado en main thread desde background queue.
- **Fix:** Snapshot values antes de dispatch, o hacer actor.
- **Status:** [ ] PENDIENTE

### ARCH-08 [HIGH] URLSession creada por cada mensaje (iOS)
- **Archivo:** `APIClient.swift:12`
- **Fix:** Reusar una sola instancia configurada.
- **Status:** [ ] PENDIENTE

### ARCH-09 [HIGH] `@StateObject` con singletons pre-existentes
- **Archivo:** `AIDAApp.swift:4-5`, `ChatView.swift:9`
- **Fix:** Usar `@ObservedObject` o `.environmentObject()`.
- **Status:** [ ] PENDIENTE

### ARCH-10 [HIGH] LocalVault `queue.sync` bloquea main thread
- **Archivo:** `LocalVault.swift:120-127`
- **Fix:** Cache valores, actualizar desde background.
- **Status:** [ ] PENDIENTE

### ARCH-11 [HIGH] SemanticCache `lookup` sin sincronización
- **Archivo:** `SemanticCache.swift:79-105`
- **Fix:** Wrap en `queue.sync`.
- **Status:** [ ] PENDIENTE

### ARCH-12 [HIGH] Widget siempre renderiza small, nunca medium
- **Archivo:** `BoeWidget.swift:169`
- **Fix:** Switch on `context.family`.
- **Status:** [ ] PENDIENTE

### ARCH-13 [HIGH] Notification content estático en triggers repetitivos
- **Archivo:** `NotificationService.swift:27-48`
- **Bug:** Contenido built una vez, stale para cada día subsecuente.
- **Fix:** Dynamic content o `UNNotificationServiceExtension`.
- **Status:** [ ] PENDIENTE

### ARCH-14 [MEDIUM] Fallback CrisisState sin `self.tier` (2 copias)
- **Archivo:** `engine.py:44-48`, `session.py:22-27`
- **Fix:** Agregar `self.tier = 0` y unificar en un solo lugar.
- **Status:** [ ] PENDIENTE

### ARCH-15 [MEDIUM] `_brain_update` bloquea event loop
- **Archivo:** `respond.py:249`
- **Fix:** Usar `run_in_executor` para PyTorch ops.
- **Status:** [ ] PENDIENTE

### ARCH-16 [MEDIUM] Thread bare para persist_crisis_state
- **Archivo:** `understand.py:298`
- **Fix:** Usar `background_tasks.add_task()`.
- **Status:** [ ] PENDIENTE

### ARCH-17 [MEDIUM] `asyncio.get_event_loop()` deprecado
- **Archivo:** `understand.py:131`, `Main.py:162`
- **Fix:** Usar `asyncio.get_running_loop()`.
- **Status:** [ ] PENDIENTE

### ARCH-18 [MEDIUM] Claude streaming sin timeout
- **Archivo:** `llm.py:36-55`
- **Fix:** Timeout en `queue.get()` y en API call.
- **Status:** [ ] PENDIENTE

### ARCH-19 [MEDIUM] Foto de perfil en UserDefaults como blob
- **Archivo:** `SessionManager.swift:31`, `SettingsView.swift:447`
- **Fix:** Guardar en documents, solo path en UserDefaults.
- **Status:** [ ] PENDIENTE

### ARCH-20 [MEDIUM] deleteAccount fire-and-forget sin feedback
- **Archivo:** `SessionManager.swift:152-154`, `APIClient.swift:96-101`
- **Fix:** Hacer síncrono o dar feedback al usuario.
- **Status:** [ ] PENDIENTE

---

## PARTE 3: APPLE COMPLIANCE — BLOQUEAN APP STORE

### APPLE-01 [CRITICAL] Sin Privacy Policy link
- **Archivo:** `ConsentView.swift`
- **Fix:** Agregar link tappable a privacy policy.
- **Status:** [x] FIXED 2026-04-09 — Links a /privacy y /terms en ConsentView. Endpoints HTML creados en backend.

### APPLE-02 [CRITICAL] Sin Terms of Use en paywall
- **Archivo:** `PremiumView.swift`
- **Fix:** Agregar links legales requeridos por Apple.
- **Status:** [x] FIXED 2026-04-09 — Links a /privacy y /terms debajo de "Restaurar compras".

### APPLE-03 [HIGH] Accesibilidad = CERO
- **Archivo:** TODOS los .swift
- **Bug:** Cero `.accessibilityLabel()` en toda la app.
- **Fix:** Accessibility labels en cada elemento interactivo.
- **Status:** [x] FIXED 2026-04-09 — 11 archivos modificados: ConsentView, PremiumView, MenuView, SettingsView, ChatView, InputBar, MessageBubble, DashboardView, EmotionalOnboarding, MainTabView, SendButton. Icons decorativos ocultos, buttons etiquetados, crisis links con hints.

### APPLE-04 [HIGH] Consent genérico para HealthKit/Calendar/Speech
- **Archivo:** `ConsentView.swift`
- **Bug:** Un solo botón "Empezar" para todo. Apple espera permisos individuales.
- **Fix:** Solicitar permisos individualmente para cada tipo de dato.
- **Status:** [x] NO ERA ISSUE — Los permisos ya se piden con dialogs nativos de iOS cuando se necesitan (HealthKit en dashboard load, Calendar en dashboard load, Speech al abrir mic). Info.plist tiene descripciones para cada permiso. ConsentView es un disclaimer, no un consent de datos.

### APPLE-05 [HIGH] `restore()` no funciona para consumables
- **Archivo:** `StoreManager.swift:54-69`
- **Bug:** `Transaction.currentEntitlements` no incluye consumables terminados.
- **Fix:** Server-side tracking de compras consumables.
- **Status:** [ ] PENDIENTE

---

## PARTE 4: IF/ELSE & LÓGICA INCONSISTENTE

### LOGIC-01 [CRITICAL] Free tier: iOS=5, Backend=15, Action-Plan=3
- **Archivos:** `SessionManager.swift:120`, `engine.py:172`, `Action-Plan.md`
- **Fix:** Una sola fuente de verdad. Backend dicta, iOS obedece.
- **Status:** [x] FIXED 2026-04-09 — Backend alineado a 5 (con comment de sincronización). Ambos usan 5.

### LOGIC-02 [CRITICAL] Accent-sensitive crisis matching
- **Archivo:** `understand.py:161`
- **Bug:** "ya no puedo más" (con tilde) no matchea "ya no puedo mas" (sin tilde). Usuarios móviles omiten acentos.
- **Fix:** `unicodedata.normalize('NFD')` + strip combining marks antes de comparar.
- **Status:** [x] FIXED 2026-04-09 — `_strip_accents()` normaliza mensaje y crisis words antes de comparar.

### LOGIC-03 [CRITICAL] Google/Apple Sign-In token key mismatch
- **Archivos:** `endpoints_auth.py:102,125` devuelve `"session"`, iOS `AuthResponse` espera `"session_token"`
- **Bug:** Token de Google/Apple auth se pierde silenciosamente. Usuario aparece logueado pero requests van sin auth.
- **Fix:** Renombrar key a `"session_token"` en backend, o agregar CodingKey en iOS.
- **Status:** [x] FIXED 2026-04-09 — Backend ahora devuelve `"session_token"` en ambos endpoints.

### LOGIC-04 [CRITICAL] Hard block retorna respuesta original si todas las oraciones matchean
- **Archivo:** `Integrity.py:100-104`
- **Bug:** Si TODAS las sentences contienen el término bloqueado, `result=""`, y se retorna `response` con el leak.
- **Fix:** Retornar mensaje seguro fallback, no `response`.
- **Status:** [x] FIXED 2026-04-09 — Retorna "Estoy aquí. ¿En qué estabas pensando?" como fallback seguro.

### LOGIC-05 [CRITICAL] "Crisis" definida diferente en 5+ lugares
- **Archivos:** `understand.py:30` (severity≥3 OR eip≥1), `respond.py:96` (severity≥1), `respond.py:201` (severity≥4), `understand.py:211` (severity≥1)
- **Fix:** Centralizar en constantes nombradas con documentación.
- **Status:** [x] FIXED 2026-04-09 — `thresholds.py` creado con 12 constantes nombradas y documentadas. understand.py y respond.py migrados.

### LOGIC-06 [HIGH] Crisis word list duplicada y divergente
- **Archivos:** `understand.py:159-169` vs `crisis_classifier.py:118-153`
- **Bug:** "para que seguir" en understand.py pero "para que sigo" en classifier. Drift garantizado.
- **Fix:** Una sola fuente de verdad para crisis words.
- **Status:** [ ] PENDIENTE

### LOGIC-07 [HIGH] Type confusion: `crisis_level` puede ser string, CrisisLevel, o None
- **Archivo:** `understand.py:188`
- **Fix:** Usar `Optional[CrisisLevel]` con `None` como sentinel. Eliminar `"UNCHECKED"` string.
- **Status:** [x] FIXED 2026-04-09 — Reemplazado con `_classifier_crashed` boolean flag + `crisis_level = None`.

### LOGIC-08 [HIGH] No fallback para severity 1-2 con API failure
- **Archivo:** `respond.py:108-119`
- **Bug:** Severities 1-2 (ideación pasiva) con API error = mensaje genérico sin soporte emocional.
- **Fix:** Fallback gentil para severities 1-2.
- **Status:** [ ] PENDIENTE

### LOGIC-09 [HIGH] IntentRouter clasifica texto 2 veces
- **Archivos:** `ChatViewModel.swift:160,168`, `IntentRouter.swift:63-65`
- **Fix:** `isLocalCommand` debe aceptar `IntentResult` ya calculado.
- **Status:** [ ] PENDIENTE

### LOGIC-10 [HIGH] `sessionMessageCount` incrementado 2 veces
- **Archivo:** `ChatViewModel.swift:118,363`
- **Fix:** Remover uno de los dos incrementos.
- **Status:** [x] FIXED 2026-04-09 — Removido el incremento duplicado en onDone (línea 363).

### LOGIC-11 [MEDIUM] 30+ magic numbers sin constantes nombradas
- **Archivos:** understand.py, warmth.py, selector.py, crisis_classifier.py, clinical_detectors.py, ChatViewModel.swift, SessionManager.swift
- **Fix:** Extraer a constantes con nombres descriptivos.
- **Status:** [ ] PENDIENTE

### LOGIC-12 [MEDIUM] `_skip_others` nombre misleading, solo gatea IndirectSignalHandler
- **Archivo:** `understand.py:229`
- **Fix:** Renombrar a `_skip_indirect_signals`.
- **Status:** [ ] PENDIENTE

### LOGIC-13 [MEDIUM] `_crisis_words` re-creada en cada llamada
- **Archivo:** `understand.py:159-169`
- **Fix:** Mover a constante de módulo.
- **Status:** [ ] PENDIENTE

### LOGIC-14 [MEDIUM] Embedding models diferentes: iOS NLEmbedding vs backend MiniLM
- **Archivos:** `SemanticCache.swift:31`, `crisis_classifier.py`
- **Nota:** No bug de seguridad, pero threshold `0.85` no es comparable entre modelos.
- **Status:** [ ] PENDIENTE

### LOGIC-15 [MEDIUM] `datetime.utcnow()` deprecado (3 lugares)
- **Archivos:** `understand.py:427`, `trace.py:23`, `audit.py`
- **Fix:** `datetime.now(datetime.UTC)`.
- **Status:** [ ] PENDIENTE

---

## PARTE 5: VAULT — INCONSISTENCIAS CON EL CÓDIGO

### VAULT-01 [CRITICAL] full-code-audit.md dice "0 analytics, 0 tests" — ambos existen
- **Realidad:** Analytics.swift 205 LOC, 20+ eventos. test_critical_paths.py 16 tests.
- **Fix:** Actualizar full-code-audit.md o archivarlo como obsoleto.
- **Status:** [ ] PENDIENTE

### VAULT-02 [CRITICAL] Pipeline "23 pasos" vs "51 pasos" usado intercambiablemente
- **Fix:** Documentar: listen()=~30 pasos, pipeline completo=~51.
- **Status:** [ ] PENDIENTE

### VAULT-03 [CRITICAL] Modelo financiero asume suscripción, código implementa packs
- **Archivos:** `startup-finance.md` ($9.99/mo), `StoreManager.swift` (packs consumibles)
- **Fix:** Decidir modelo y alinear vault con código.
- **Status:** [ ] PENDIENTE

### VAULT-04 [CRITICAL] Brain "684 neuronas" excede `max_neurons=512` del código
- **Archivos:** vault docs vs `Brain.py:13`
- **Bug:** 684 es imposible dado el cap de 512. Número fabricado o de versión anterior.
- **Fix:** Verificar `soul_state.pt` real, corregir docs.
- **Status:** [ ] PENDIENTE

### VAULT-05 [CRITICAL] Code-Reference-For-Copilot.md masivamente desactualizado
- **Bug:** Describe codebase 2-3 sesiones atrás. Da información falsa a nuevos Claude sessions.
- **Fix:** Reescribir o archivar.
- **Status:** [ ] PENDIENTE

### VAULT-06 [CRITICAL] Prompt version: memoria dice V5, Action-Plan dice V6, código dice V7
- **Fix:** Actualizar todas las referencias a V7.
- **Status:** [ ] PENDIENTE

### VAULT-07 [CRITICAL] Cold start: 6.5s vs 9 min (2 órdenes de magnitud)
- **Fix:** Clarificar: 6.5s = init Engine, 9 min = deploy completo Railway.
- **Status:** [ ] PENDIENTE

### VAULT-08 [MEDIUM] Paleta "navy/teal/gold" en Action-Plan vs "navy+ember" en Handoff
- **Bug:** Action-Plan dice teal. Handoff prohíbe teal explícitamente. Código usa ember.
- **Fix:** Corregir Action-Plan.
- **Status:** [ ] PENDIENTE

### VAULT-09 [MEDIUM] `anchors_safety.json` en Action-Plan pero nunca creado (3/4 done)
- **Fix:** Crear el archivo o actualizar Action-Plan a 3/3.
- **Status:** [ ] PENDIENTE

### VAULT-10 [MEDIUM] ConsentView text: audit dice "Una presencia que escucha", código dice "Tu copiloto"
- **Fix:** Actualizar audit.
- **Status:** [ ] PENDIENTE

### VAULT-11 [MEDIUM] Onboarding: audit describe feelings flow, código tiene goals/productivity flow
- **Fix:** Actualizar audit.
- **Status:** [ ] PENDIENTE

### VAULT-12 [MEDIUM] understand.py: audit dice "388 LOC, 1 función", código tiene 501 LOC, 2 funciones
- **Fix:** Actualizar.
- **Status:** [ ] PENDIENTE

### VAULT-13 [MEDIUM] CLAUDE.md solo lista 2 tablas Supabase, existen 4
- **Fix:** Agregar user_crisis_state y anchors.
- **Status:** [ ] PENDIENTE

### VAULT-14 [MEDIUM] hasMessages: audit dice "retorna true siempre", ya implementado
- **Fix:** Actualizar audit.
- **Status:** [ ] PENDIENTE

### VAULT-15 [MEDIUM] Action-Plan casi completo pero no marcado como superseded
- **Fix:** Archivar o marcar steps como DONE/SUPERSEDED.
- **Status:** [ ] PENDIENTE

---

## ORDEN DE EJECUCIÓN RECOMENDADO

### Sprint 1: Seguridad (bloquea lanzamiento)
1. SEC-01 + SEC-02 (crisis auth fix)
2. SEC-04 + SEC-16 (sanitizar inputs al prompt)
3. SEC-03 + SEC-11 + SEC-13 (auth en endpoints admin)
4. SEC-05 (session token → Keychain)
5. LOGIC-03 (token key mismatch Google/Apple)
6. LOGIC-02 (accent normalization crisis words)
7. LOGIC-04 (Integrity hard block fallback)

### Sprint 2: Estabilidad core
8. ARCH-03 (AppTheme → static let)
9. ARCH-05 + ARCH-06 (per-user state warmth/brain)
10. LOGIC-01 (unificar free tier limit)
11. LOGIC-05 (centralizar crisis thresholds)
12. LOGIC-10 (double message count)
13. ARCH-02 (lazy engine init)

### Sprint 3: Apple compliance
14. APPLE-01 + APPLE-02 (privacy policy + terms)
15. APPLE-03 (accessibility labels)
16. APPLE-04 (permisos individuales)
17. SEC-14 + APPLE-05 (IAP server-side validation)

### Sprint 4: Vault cleanup
18. VAULT-01 (actualizar audit)
19. VAULT-05 (reescribir Code-Reference)
20. VAULT-03 (alinear modelo financiero)
21. VAULT-04 (verificar 684 neuronas)

---

*Este registro debe actualizarse conforme se resuelven issues. Cambiar [ ] a [x] y agregar fecha.*
