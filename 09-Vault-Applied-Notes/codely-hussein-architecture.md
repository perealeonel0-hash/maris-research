# Codely (DDD/Hexagonal) + Hussein Nasser (Backend Engineering)
## Decisiones arquitectónicas para MARIS

---

## CODELY: ARQUITECTURA

### Hexagonal para MARIS: Parcial, no completa
Crear ports SOLO donde hay un segundo adapter realista:
- **SÍ port:** `LLMProvider` (Claude hoy, Gemini mañana), `EmbeddingProvider` (sentence-transformers hoy, OpenAI mañana)
- **NO port:** Supabase auth (no va a cambiar), NotificationService (solo APNs)

### 3 Bounded Contexts naturales de MARIS
| Contexto | Responsabilidad | Entidades clave |
|----------|----------------|-----------------|
| **Conversation** | Chat flow, intent routing, response gen | Message, Session, Intent, Response |
| **Clinical** | Safety, crisis detection, mood tracking | CrisisState, MoodVector, RiskLevel |
| **Memory** | Anchors, user history, semantic search | Anchor, UserProfile, EmbeddingVector |

"User" significa algo diferente en cada contexto = bounded contexts separados.
**Mantenerlos como módulos en un monolito.** Bounded context = frontera lógica, NO de deployment.

### Value Objects vs Entities
```python
# Value Object: inmutable, comparado por valor, sin identidad
@dataclass(frozen=True)
class MoodScore:
    value: float
    def __post_init__(self):
        if not -1.0 <= self.value <= 1.0:
            raise ValueError(f"MoodScore debe estar entre -1 y 1")

# Entity: tiene identidad, mutable
@dataclass
class UserSession:
    id: str  # UUID = identidad
    user_id: str
    mood_score: MoodScore
    crisis_state: CrisisState
```

Value Objects MARIS: MoodScore, RiskLevel, EmbeddingVector, TokenCount
Entities MARIS: UserSession, Anchor, ConversationThread, CrisisEvaluation

### Testing Hexagonal
- Unit test: Application layer con ports mockeados
- Integration test: adapters contra servicios reales
- NO testear domain logic a través del API

---

## HUSSEIN NASSER: BACKEND

### SSE vs WebSocket vs Long Polling
**Decisión: SSE.** Chat de MARIS es asimétrico. User manda mensaje corto (POST). AI streama respuesta larga (SSE). No necesitas bidireccional.
- SSE auto-reconnecta (WebSocket no)
- SSE funciona por todos los proxies sin config
- FastAPI tiene soporte nativo via StreamingResponse

### Connection Pooling Supabase
- Cada conexión Postgres = fork de proceso OS (~10MB RAM)
- **Usar port 6543** (PgBouncer transaction mode)
- Pool max 15-20 para Railway
- Transaction mode, no session mode (endpoints son short-lived)

### Postgres Optimization
1. Nunca `SELECT *`
2. Nunca `OFFSET` para paginación — cursor-based con `WHERE id > last_id`
3. Composite indexes para queries frecuentes
4. `EXPLAIN ANALYZE` en cada query que corre >1 vez por request
5. Evitar `SELECT COUNT(*)` — full table scan en Postgres

### Idempotency
ULIDs como idempotency keys (ordenados + index-friendly). Redis 5min TTL.
Crítico porque: Claude API cuesta dinero (duplicados = tokens desperdiciados), network retries en iOS, double-tap de usuarios, Railway puede reiniciar containers mid-request.

### Diagnóstico de Performance (framework)
1. Communication: ¿bottleneck en protocolo?
2. Execution: ¿bottleneck en tu código?
3. Proxying: ¿bottleneck en intermediarios?
4. Caching: ¿re-computando cosas cacheables?
5. Database: ¿queries lentos?

**Jerarquía de bottleneck en MARIS:**
1. Claude API latency (~2-5s) — no puedes hacer nada excepto streamear
2. Embedding computation (~200ms) — cachear agresivamente
3. Supabase queries (~50-100ms) — indexar, connection pooling
4. FastAPI overhead (~5ms) — negligible
