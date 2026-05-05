# ByteByteGo (Alex Xu) — System Design para MARIS
## Decisiones arquitectónicas concretas

---

## 1. SSE STREAMING
- SSE para streaming AI (server→client). HTTP POST para enviar mensajes. NO WebSocket.
- Heartbeat `:keepalive\n\n` cada 15s (carriers móviles matan conexiones idle a 30-60s)
- `Last-Event-ID` para reconnection — numerar eventos, buffer últimos N en Redis 5min TTL
- Backpressure: `asyncio.Queue(maxsize=100)` por conexión
- Multi-instancia futuro: Redis Pub/Sub para fan-out

## 2. CACHING
| Pattern | Uso en MARIS |
|---------|-------------|
| Cache-Aside | User profiles, anchors, crisis state lookups |
| Write-Through | Crisis state updates (cache + DB atómico) |
| Write-Behind | Analytics, session logs, message history |

**Claude API:** Semantic cache con key = `intent + entities + user_state`. Redis 1hr TTL. Hit rate esperado 15-25%.
**Embeddings:** Cache vector por input `sha256(text)`. Redis 24hr TTL.
**Crisis:** NUNCA cachear — siempre computar fresh.
**Invalidation:** TTL como safety net, invalidación explícita como mecanismo primario.

## 3. RATE LIMITING
- **Token Bucket** per-user: Free 10 msg/hr, Paid 60 msg/hr. Permite bursts (usuario en distress).
- **Sliding Window** global: Max 100 Claude API calls/min. Si excede → queue, no reject.

## 4. API PATTERNS
- Versioning URL: `/api/v1/chat`
- Response envelope: `{"status": "ok", "data": {...}, "meta": {"request_id": "xxx"}}`
- **Idempotency keys:** ULID-based. Redis 5min TTL. Previene mensajes duplicados por retry de iOS.
- Timeout cascade: iOS 30s → Gateway 25s → Claude 20s. Inner siempre < outer.

## 5. DATABASE (Supabase/Postgres)
- **Usar port 6543** (PgBouncer transaction mode), NO 5432 (directo)
- Pool max 15-20 conexiones para Railway
- Indexes necesarios:
  ```sql
  CREATE INDEX idx_messages_user_created ON messages(user_id, created_at DESC);
  CREATE INDEX idx_crisis_state_user ON crisis_state(user_id) WHERE active = true;
  ```
- **asyncio.gather** para queries paralelas (1 round trip vs 5)
- Nunca `SELECT *` — especificar columnas
- Cursor pagination (`WHERE id > last_id`), no OFFSET

## 6. COLD START (el problema de 6 segundos)
- Health check gating: `/health` retorna 503 hasta que modelo esté listo. Railway no rutea tráfico hasta 200.
- Warm model con dummy inference en startup
- Ping cada 5min para evitar sleep (cron desde Supabase Edge Functions)
- Lazy loading para modelos no-críticos

## 7. ASYNC PROCESSING
Pipeline split:
```
Steps 1-8 (síncronos): Intent → Safety → State → Mode
Steps 9-15 (parallelizable): Anchors ∥ History ∥ Health data
Steps 16-20 (secuenciales): Prompt → Claude → Stream
Steps 21-23 (fire-and-forget queue): Save DB → Update state → Analytics
```
Steps 21-23 al queue = response más rápido al usuario.

## 8. PRIORIDAD DE IMPLEMENTACIÓN
1. Health check gating (30min)
2. Redis cache user data (2hrs)
3. asyncio.gather queries paralelas (1hr)
4. Fire-and-forget queue steps 21-23 (1hr)
5. Token bucket rate limiting (2hrs)
6. SSE heartbeat + Last-Event-ID (2hrs)
7. Semantic cache Claude responses (4hrs)
8. Idempotency keys (1hr)
Total: ~14 horas para ir de "funciona" a "production-grade"
