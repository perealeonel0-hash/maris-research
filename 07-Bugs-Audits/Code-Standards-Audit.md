# MARIS — Auditoría de Código vs Estándar Real

**Fecha:** 27 de marzo de 2026
**Auditor:** Evaluación automática contra FDA SaMD, HIPAA, SOC2, OWASP, IEEE 7014, NIST AI RMF
**Alcance:** 12 archivos del backend, pipeline completo

---

## RESUMEN EJECUTIVO

| Estándar | ¿Pasa? | Razón principal |
|---|---|---|
| **FDA SaMD** | ❌ | Sin audit trail para decisiones clínicas |
| **HIPAA** | ❌ | Sin cifrado en reposo, sin BAA documentado |
| **SOC2 Type II** | ❌ | Secret hardcodeado, endpoints sin auth |
| **OWASP Top 10** | ⚠️ Parcial | Rate limiting incompleto, CORS abierto |
| **IEEE 7014** | ✅ Parcial | Discloses AI nature, tiene consent flow |
| **NIST AI RMF** | ⚠️ Parcial | Graceful degradation buena, sin drift detection |

---

## IDEAL vs MARIS — Comparación detallada

### 1. SEGURIDAD CRÍTICA

| Requisito | Estándar | MARIS | Veredicto |
|---|---|---|---|
| Cifrado en reposo | AES-256 para datos de salud (HIPAA) | ❌ Plaintext en Supabase. Chats, scars, crisis summaries sin cifrar | **CRÍTICO** |
| Cifrado en tránsito | TLS 1.2+ (HIPAA) | ✅ Railway + Supabase usan HTTPS/TLS | **PASA** |
| Secrets management | Sin secrets en código fuente (OWASP) | ❌ Fallback secret hardcodeado en auth.py línea 35: `"maris-fallback-secret-..."` | **CRÍTICO** |
| Autenticación | Todos los endpoints con data sensible requieren auth | ❌ `/eip/{user_id}`, `/cicatrices/{user_id}`, `/brain_map_visual`, `/system_status` sin auth | **ALTO** |
| Rate limiting | Todos los endpoints públicos (OWASP A05) | ❌ `/api/chat`, `/register-ios`, `/greet`, `/profile` sin rate limiting | **ALTO** |
| Token revocation | Mecanismo para invalidar tokens comprometidos (SOC2) | ❌ Tokens válidos 30 días sin forma de revocar | **MEDIO** |
| Input validation | Sanitización de toda entrada (OWASP A03) | ✅ Pydantic con max_length=4000, historial cap 20 mensajes | **PASA** |
| Security headers | HSTS, CSP, X-Frame-Options (OWASP) | ✅ Comprehensive: HSTS, CSP, X-Content-Type, X-Frame-Options, Referrer-Policy | **PASA** |
| Password hashing | bcrypt/argon2/PBKDF2 ≥100K iter (OWASP) | ✅ PBKDF2-HMAC-SHA256, 100K iterations, random salt | **PASA** |
| Timing-safe comparison | Prevenir timing attacks (CWE-208) | ✅ `secrets.compare_digest` en auth, verify, session | **PASA** |

### 2. SEGURIDAD CLÍNICA (el más importante)

| Requisito | Estándar (988/SAMHSA) | MARIS | Veredicto |
|---|---|---|---|
| Crisis fallback cuando Claude falla | Si API falla durante crisis, entregar recursos de todas formas | ❌ **Si Claude falla mid-stream con severity≥3, usuario recibe `{error: true}` sin recursos** (Main.py línea 632-634) | **CRÍTICO** |
| Crisis resources en fast_check path | El path rápido de crisis debe incluir recursos estructurados | ❌ `_crisis_stream()` no incluye `crisis_resources` en DoneEvent. Solo texto + event: CRISIS | **ALTO** |
| Audit trail de decisiones clínicas | Registro inmutable de cada detección, clasificación, override, respuesta | ❌ Solo `print()` al stdout. No hay tabla de auditoría en Supabase | **CRÍTICO** |
| Crisis state persistence | Estado de crisis acumulado debe sobrevivir restart | ❌ `CrisisState` vive en RAM. Railway restart = contexto de crisis perdido | **ALTO** |
| EIP availability | Detección de crisis debe estar siempre activa | ❌ Si eip.py falla al descargar, app corre SIN detección de crisis | **ALTO** |
| Crisis detection bypass prevention | No debe ser posible saltarse la detección | ✅ EIP + CrisisClassifier + WarmthGuard + lexical fast_check — 4 capas | **PASA** |
| Lethal means counseling | Sugerir alejar el método cuando hay acceso | ✅ LethalMeansDetector con 6 categorías + post_check enforcement | **PASA** |
| Indirect signal detection | Responder al dolor, no a la señal peligrosa | ✅ IndirectSignalHandler con override de crisis_level | **PASA** |

### 3. CALIDAD DE CÓDIGO

| Requisito | Estándar (IEC 62304 Clase C) | MARIS | Veredicto |
|---|---|---|---|
| Type hints | Todas las funciones públicas tipadas | ⚠️ Parcial. Presente en nuevos módulos, inconsistente en Main.py | **MEDIO** |
| Docstrings | Todas las clases y métodos públicos | ✅ Presente en todos los módulos clínicos. Buena en módulos core | **PASA** |
| Logging estructurado | Niveles (DEBUG/INFO/WARN/ERROR), formato JSON | ❌ Solo `print()`. Sin niveles, sin formato estructurado, sin rotación | **ALTO** |
| Función `chat()` complexity | Máximo 50 líneas por función (IEC 62304) | ❌ `chat()` tiene ~480 líneas, `event_stream()` ~150 | **ALTO** |
| Silent exception catches | Nunca `except: pass` en código safety-critical | ⚠️ 5 instancias de `except Exception: pass` en warmth.py y clinical_detectors.py | **MEDIO** |
| Thread safety | Locks en estado compartido | ❌ `_global_msg_count` sin lock. Race condition en requests concurrentes | **ALTO** |
| NaN/Inf guards | Guards en todas las operaciones matemáticas | ✅ Brain.py forward(), friccion_promedio, brain_update | **PASA** |
| Graceful degradation | Si un módulo falla, pipeline continúa | ✅ Cada módulo init tiene try/except con fallback. Mejor que promedio | **PASA** |

### 4. PRIVACIDAD DE DATOS

| Requisito | Estándar (GDPR/HIPAA) | MARIS | Veredicto |
|---|---|---|---|
| Data minimization | Solo almacenar lo necesario | ⚠️ Almacena summaries de conversaciones completas. Scars tienen scores numéricos | **MEDIO** |
| Right to erasure | Borrado completo implementado | ✅ `/delete-account` endpoint elimina de Supabase | **PASA** |
| Retention limits | Política de retención en código | ✅ Conversations 7 días, crisis 24h (iOS vault). Scars capped a 50 | **PASA** |
| PII en logs | Nunca loggear contenido del usuario | ✅ Logs muestran scores y severidad, NO el mensaje del usuario | **PASA** |
| Consent flow | Consentimiento informado antes de uso | ✅ ConsentView en iOS con 2 pasos: info + contacto de emergencia | **PASA** |
| BAA documentation | Contratos con proveedores (Supabase, Anthropic, Railway) | ❌ No documentado | **ALTO** |
| DeepSeek data isolation | Modelo alternativo no recibe datos personales | ✅ DeepSeek solo recibe brief técnico en modo construcción | **PASA** |

### 5. PIPELINE CLÍNICO (nuevos módulos)

| Módulo | Estándar | MARIS | Veredicto |
|---|---|---|---|
| CrisisClassifier | Detección multi-nivel con safety net lexical | ✅ 5 niveles + lexical cross-check para 4-5 + casual guard | **PASA** |
| ResponseCalibrator | Recursos calibrados por severidad | ✅ Strip en pasiva, forzar en inmediata, mover al final en activa | **PASA** |
| PsychosisDetector | Neutralidad empática (CIT/LEAP) | ✅ Emergency replacement + inject instruction + post_check | **PASA** |
| ManiaDetector | Pregunta diagnóstica de sueño | ✅ Inject instruction + no confrontar | **PASA** |
| LethalMeansDetector | Reducción de acceso a métodos | ✅ 6 categorías + gating por severity≥3 | **PASA** |
| IndirectSignalHandler | Responder al dolor, no a la señal | ✅ Override crisis_level + split-sentence + lexical fallback | **PASA** |
| positive_moment guard | No detectar crisis como positivo | ✅ 46 vectores de crisis context | **PASA** |

---

## LO QUE MARIS HACE MEJOR QUE EL ESTÁNDAR

1. **4 capas de detección de crisis** — lexical fast_check → EIP semántico → CrisisClassifier → WarmthGuard. La mayoría de sistemas tienen 1-2 capas.

2. **Enforcement algorítmico, no por prompt** — ResponseCalibrator edita la respuesta de Claude con código. La mayoría de chatbots de salud mental usan instrucciones en prompt que se rompen en conversaciones largas.

3. **Vectorial identity filter** — Previene que Claude hable "por" MARIS. Único en la industria.

4. **Lethal means counseling automático** — La mayoría de AI solo da hotlines. MARIS sugiere alejar el método específico.

5. **Indirect signal detection** — 86% de modelos AI fallan al dar info de puentes cuando alguien combina dolor + pregunta peligrosa. MARIS lo detecta y responde al dolor.

6. **Physics brain** — Decaimiento exponencial de capacidad bajo fricción. Ningún otro sistema usa física para modelar estados emocionales.

7. **Circadian awareness** — 3 AM = 0.95 risk weight. Integrado en resolve_state.

---

## LO QUE FALTA PARA CADA CERTIFICACIÓN

### Para FDA SaMD
1. Audit trail inmutable (tabla Supabase separada con escritura WORM)
2. Risk management file (ISO 14971) documentado
3. Traceability matrix: requisito → diseño → código → test
4. Sensitivity/specificity formal del crisis detection
5. IEC 62304 compliance: refactorizar `chat()` (480 líneas → funciones <50)

### Para HIPAA
1. Cifrado en reposo (Supabase column-level encryption o app-level AES)
2. BAA con Supabase, Anthropic, Railway
3. Access logging (quién accedió qué PHI, cuándo)
4. Audit logs retenidos 6 años mínimo
5. Eliminar fallback secret hardcodeado

### Para SOC2 Type II
1. Logging centralizado (structured, con niveles, rotación)
2. Auth en todos los endpoints sensibles
3. Rate limiting en todos los endpoints públicos
4. Monitoring y alerting de eventos de seguridad
5. Change management para eip.py (versionado, no descarga runtime sin verificación)

---

## PRIORIDADES DE FIX (por impacto en seguridad del usuario)

| # | Fix | Impacto | Esfuerzo |
|---|---|---|---|
| 1 | **Crisis fallback cuando Claude falla** | Vida/muerte | Bajo (20 líneas) |
| 2 | **Eliminar fallback secret** | Seguridad total | Bajo (5 líneas) |
| 3 | **Auth en endpoints sensibles** | Privacidad | Bajo (decorador) |
| 4 | **Audit logging de crisis** | Regulatory + evidencia | Medio (tabla + writes) |
| 5 | **Cifrado en reposo** | HIPAA compliance | Alto (schema change) |
| 6 | **Rate limiting en /api/chat** | Abuso | Bajo (1 línea) |
| 7 | **Logging estructurado** | Operabilidad | Medio (reemplazar print) |
| 8 | **Refactorizar chat()** | Mantenibilidad | Alto (split function) |

---

## SCORE FINAL

| Categoría | Score | Detalle |
|---|---|---|
| Seguridad | **6/10** | Buenas prácticas en auth/input/headers, fallas en encryption/secrets/endpoints |
| Clinical Safety | **7/10** | Pipeline de 4 capas excelente, falla en crisis fallback y audit trail |
| Code Quality | **6/10** | Docstrings y degradation buenos, complejidad y logging malos |
| Privacy | **7/10** | Minimización y consent buenos, encryption y BAA faltan |
| Clinical Pipeline | **9/10** | 6 módulos algorítmicos, 248 vectores, 90.3% en evaluación clínica |
| **TOTAL** | **7/10** | |

**Conclusión:** MARIS tiene una arquitectura clínica de vanguardia (mejor que cualquier competidor público) pero con gaps de infraestructura que impiden certificación. Los fixes #1-3 son de vida/muerte y bajo esfuerzo. Los fixes #4-5 son para regulatory compliance.

---

*Auditoría: 27 de marzo de 2026*
*Fuentes: FDA SaMD (IEC 62304), HIPAA 2025 Proposed Rule, SOC2 Type II, OWASP LLM Top 10, IEEE 7014-2024, NIST AI RMF, SAMHSA 988*
*MARIS v1.1 — Leonel Perea Pimentel*
