# Python Concurrency, Asyncio & Async Architecture Patterns
## Aplicado al backend de MARIS (FastAPI en Railway, SSE streaming, 5 background tasks, PyTorch)

**Fuentes:** ArjanCodes, Hussein Nasser, Cosmic Python (Percival & Gregory), Real Python, SuperFastPython, FastAPI docs, Python 3.11+ docs

---

## 1. CUÁNDO USAR QUÉ: THREADING vs MULTIPROCESSING vs ASYNCIO

| Tipo de trabajo | Herramienta | Por qué | Ejemplo MARIS |
|----------------|-------------|---------|---------------|
| **I/O-bound, muchas conexiones** | `asyncio` | Un solo thread, sin overhead de context switch, escala a miles | Supabase queries, Claude API calls, SSE streaming |
| **I/O-bound, librería sync** | `run_in_executor` con ThreadPool | No bloquea el event loop, GIL se libera durante I/O | Anthropic sync SDK (claude_sse_stream) |
| **CPU-bound, GIL se libera** | `threading` / `run_in_executor` | PyTorch/NumPy liberan el GIL durante operaciones de tensor | sentence-transformers embedding |
| **CPU-bound puro Python** | `multiprocessing` | Único way de usar múltiples cores en Python | NO aplica a MARIS (no tenemos CPU-bound puro) |

### Regla de oro:
```
¿Espera I/O?           → asyncio (async/await)
¿Librería sync que espera I/O?  → run_in_executor(ThreadPool)
¿CPU en C extensions (PyTorch)?  → run_in_executor(ThreadPool) — GIL released
¿CPU puro Python (loops)?       → ProcessPoolExecutor
```

### Por qué PyTorch funciona con threading:
PyTorch libera el GIL durante operaciones de tensor (matmul, embeddings, forward pass). Esto significa que `sentence-transformers` embedding NO bloquea otros threads mientras computa. Un ThreadPoolExecutor es suficiente — NO necesitas multiprocessing.

---

## 2. ASYNCIO PATTERNS PARA FASTAPI

### 2.1 async/await basics — qué bloquea y qué no

```python
# CORRECTO — no bloquea el event loop
async def get_user_data(user_id: str):
    # httpx es async-native, cada await cede control al event loop
    async with httpx.AsyncClient() as client:
        response = await client.get(f"/users/{user_id}")
    return response.json()

# INCORRECTO — bloquea TODO el event loop
async def get_user_data_bad(user_id: str):
    # requests es sync, bloquea el thread del event loop
    response = requests.get(f"/users/{user_id}")  # MUERTE
    return response.json()

# CORRECTO — sync code via executor
async def get_user_data_sync_lib(user_id: str):
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(
        None,  # usa default ThreadPoolExecutor
        lambda: requests.get(f"/users/{user_id}").json()
    )
    return result
```

**Regla:** Cada vez que llamas algo sin `await` dentro de una función `async`, estás bloqueando el event loop. Todas las demás requests se congelan.

### 2.2 asyncio.gather() — I/O paralelo

Ejecuta múltiples coroutines concurrentemente. Ideal cuando necesitas N resultados antes de continuar.

```python
# MARIS: cargar datos del usuario en paralelo al inicio del pipeline
async def load_user_context(user_id: str) -> PipelineContext:
    # Estas 4 queries corren AL MISMO TIEMPO
    profile, anchors, history, crisis = await asyncio.gather(
        supabase.get_profile(user_id),
        supabase.get_anchors(user_id),
        supabase.get_recent_messages(user_id, limit=10),
        supabase.get_crisis_state(user_id),
    )
    return PipelineContext(
        profile=profile,
        anchors=anchors,
        history=history,
        crisis_state=crisis,
    )
```

**Problema de gather:** Si una task falla, las demás siguen corriendo en background (zombies).

```python
# gather con return_exceptions=True — no cancela las demás
results = await asyncio.gather(
    risky_call_1(),
    risky_call_2(),
    return_exceptions=True  # errores se devuelven como valores, no se lanzan
)
for r in results:
    if isinstance(r, Exception):
        logger.error(f"Task failed: {r}")
```

### 2.3 TaskGroup (Python 3.11+) — structured concurrency

**Reemplaza gather.** Si una task falla, CANCELA todas las demás. No hay zombies.

```python
# MARIS: cargar contexto con cancelación automática
async def load_user_context_safe(user_id: str) -> PipelineContext:
    async with asyncio.TaskGroup() as tg:
        t_profile = tg.create_task(supabase.get_profile(user_id))
        t_anchors = tg.create_task(supabase.get_anchors(user_id))
        t_history = tg.create_task(supabase.get_recent_messages(user_id, limit=10))
        t_crisis  = tg.create_task(supabase.get_crisis_state(user_id))

    # Si cualquiera falla, TODAS se cancelan y se lanza ExceptionGroup
    return PipelineContext(
        profile=t_profile.result(),
        anchors=t_anchors.result(),
        history=t_history.result(),
        crisis_state=t_crisis.result(),
    )
```

**Diferencias clave:**

| | `gather()` | `TaskGroup` |
|---|---|---|
| Error handling | Una falla no cancela las demás | Una falla cancela TODAS |
| Tasks dinámicas | No (lista fija) | Sí (create_task en el contexto) |
| Excepciones | Primera excepción o return_exceptions | ExceptionGroup (todas juntas) |
| Python version | 3.4+ | 3.11+ |
| **Usar en MARIS** | Para cosas que pueden fallar independientemente | Para cosas que NECESITAN todas para continuar |

### 2.4 asyncio.create_task() — fire-and-forget

```python
# MARIS: disparar background work después de enviar respuesta
async def handle_message(user_id: str, message: str):
    # Procesar y responder primero
    response = await generate_response(user_id, message)

    # Disparar tasks en background — NO esperamos resultado
    asyncio.create_task(brain_update(user_id, message, response))
    asyncio.create_task(increment_msg_count(user_id))
    asyncio.create_task(save_mode(user_id))

    return response
```

**PELIGRO:** Si no guardas referencia al task, el garbage collector puede matarlo:
```python
# INCORRECTO — task puede ser garbage collected
asyncio.create_task(brain_update(user_id, message, response))

# CORRECTO — mantener referencia
background_tasks = set()

task = asyncio.create_task(brain_update(user_id, message, response))
background_tasks.add(task)
task.add_done_callback(background_tasks.discard)  # limpia cuando termina
```

### 2.5 BackgroundTasks (FastAPI) vs asyncio.create_task

```python
from fastapi import BackgroundTasks

# Opción A: FastAPI BackgroundTasks
# Corre DESPUÉS de enviar la response. Secuencial por defecto.
@app.post("/chat")
async def chat(msg: ChatRequest, background_tasks: BackgroundTasks):
    response = await generate_response(msg)
    background_tasks.add_task(brain_update, msg.user_id, msg.text)
    background_tasks.add_task(save_mode, msg.user_id)
    return response

# Opción B: asyncio.create_task
# Corre INMEDIATAMENTE en paralelo. Más control.
@app.post("/chat")
async def chat(msg: ChatRequest):
    response = await generate_response(msg)
    asyncio.create_task(brain_update(msg.user_id, msg.text))
    asyncio.create_task(save_mode(msg.user_id))
    return response
```

| | `BackgroundTasks` | `asyncio.create_task` |
|---|---|---|
| Cuándo corre | Después de enviar response | Inmediatamente |
| Orden | Secuencial (uno tras otro) | Paralelo |
| Error handling | Si falla, log y continúa | Si falla y no capturaste, exception lost |
| Lifecycle | Ligado al request | Vive en el event loop |
| **MARIS:** | Para tasks simples (msg_count) | Para tasks que deben correr en paralelo (brain_update + crystallize) |

### 2.6 run_in_executor — sync code sin bloquear

```python
from concurrent.futures import ThreadPoolExecutor
import asyncio

# Pool dedicado para PyTorch — limita concurrencia a 2 threads
EMBEDDING_POOL = ThreadPoolExecutor(max_workers=2, thread_name_prefix="embedding")

# MARIS: sentence-transformers embedding sin bloquear el event loop
async def compute_embedding(text: str) -> list[float]:
    loop = asyncio.get_running_loop()
    # model.encode() es sync y CPU-bound, pero PyTorch libera el GIL
    embedding = await loop.run_in_executor(
        EMBEDDING_POOL,
        lambda: model.encode(text, normalize_embeddings=True).tolist()
    )
    return embedding

# Alternativa FastAPI-native (más simple):
from starlette.concurrency import run_in_threadpool

async def compute_embedding_simple(text: str) -> list[float]:
    return await run_in_threadpool(
        lambda: model.encode(text, normalize_embeddings=True).tolist()
    )
```

**Para MARIS específicamente:**
- `run_in_executor(EMBEDDING_POOL)` para `sentence-transformers` — max 2 workers porque cada embedding usa ~500MB RAM
- `run_in_threadpool` para Anthropic sync SDK si no puedes migrar a async
- NUNCA `run_in_executor` para Supabase queries — usa supabase-py async client directamente

---

## 3. SSE STREAMING + BACKGROUND WORK SIMULTÁNEO

### Patrón actual de MARIS (threading.Thread + asyncio.Queue):
El bridge sync-to-async con threading.Thread funciona pero es frágil. Patrón mejorado:

```python
from sse_starlette.sse import EventSourceResponse
import asyncio

async def stream_chat(user_id: str, message: str):
    queue: asyncio.Queue[str | None] = asyncio.Queue()

    async def producer():
        """Genera tokens y los pone en la queue."""
        try:
            # Si Claude SDK es sync, correr en executor
            loop = asyncio.get_running_loop()

            def sync_stream():
                """Corre en thread separado, pone tokens en queue thread-safe."""
                for token in claude_client.stream(message):
                    # asyncio.Queue NO es thread-safe — usar call_soon_threadsafe
                    loop.call_soon_threadsafe(queue.put_nowait, token)
                loop.call_soon_threadsafe(queue.put_nowait, None)  # señal de fin

            await loop.run_in_executor(None, sync_stream)
        except Exception as e:
            loop.call_soon_threadsafe(queue.put_nowait, None)
            logger.error(f"Stream error: {e}")

    async def event_generator():
        """Lee de la queue y yield SSE events."""
        # Disparar producer en background
        producer_task = asyncio.create_task(producer())

        full_response = []
        while True:
            token = await asyncio.wait_for(queue.get(), timeout=30.0)
            if token is None:
                break
            full_response.append(token)
            yield {"event": "token", "data": token}

        # Stream terminó — disparar background tasks
        response_text = "".join(full_response)
        asyncio.create_task(post_stream_tasks(user_id, message, response_text))
        yield {"event": "done", "data": ""}

    return EventSourceResponse(event_generator())

async def post_stream_tasks(user_id: str, message: str, response: str):
    """5 background tasks en paralelo después del stream."""
    async with asyncio.TaskGroup() as tg:
        tg.create_task(brain_update(user_id, message, response))
        tg.create_task(increment_msg_count(user_id))
        tg.create_task(save_mode(user_id))
        tg.create_task(crystallize_if_needed(user_id))
        tg.create_task(auto_sleep_check(user_id))
```

**Punto clave:** `asyncio.Queue` NO es thread-safe. Cuando produces desde un thread (sync SDK) y consumes desde async, debes usar `loop.call_soon_threadsafe(queue.put_nowait, item)`.

---

## 4. CONNECTION POOLING (Hussein Nasser)

### Principio: Crear conexiones es CARO. Reutilízalas.

```python
import httpx

# INCORRECTO — nueva conexión TCP + TLS handshake por cada request
async def call_claude_bad(prompt: str):
    async with httpx.AsyncClient() as client:  # nueva conexión cada vez
        return await client.post("https://api.anthropic.com/v1/messages", ...)

# CORRECTO — pool de conexiones reutilizable
class ClaudeClient:
    def __init__(self):
        self._client = httpx.AsyncClient(
            base_url="https://api.anthropic.com",
            limits=httpx.Limits(
                max_connections=20,       # max conexiones totales
                max_keepalive_connections=10,  # mantener vivas
                keepalive_expiry=30,      # segundos antes de cerrar idle
            ),
            timeout=httpx.Timeout(
                connect=5.0,    # timeout de conexión
                read=30.0,      # timeout de lectura (Claude puede tardar)
                write=5.0,
                pool=10.0,      # timeout esperando conexión del pool
            ),
            headers={"Authorization": f"Bearer {API_KEY}"},
        )

    async def generate(self, prompt: str) -> str:
        response = await self._client.post("/v1/messages", json={...})
        return response.json()

    async def close(self):
        await self._client.aclose()

# Lifecycle en FastAPI
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.claude = ClaudeClient()
    app.state.supabase = AsyncSupabaseClient()
    yield
    await app.state.claude.close()
    await app.state.supabase.close()

app = FastAPI(lifespan=lifespan)
```

**Para Supabase:** Mismo patrón. Un AsyncClient global con connection pooling, NO crear cliente por request.

---

## 5. RACE CONDITIONS Y SEGURIDAD

### 5.1 Por qué MARIS tiene race conditions

Los bugs del audit: `RateGuard`, `WarmthGuard`, `search._rate`, `long_term.anchors`, `CrisisState` — todos comparten estado mutable entre requests concurrentes sin protección.

```python
# PELIGROSO — código actual tipo
class RateGuard:
    def __init__(self):
        self.counts = defaultdict(int)  # compartido entre TODAS las requests

    def check(self, user_id: str) -> bool:
        self.counts[user_id] += 1  # race condition entre requests concurrentes
        return self.counts[user_id] < 10
```

### 5.2 asyncio.Lock vs threading.Lock

```python
# asyncio.Lock — para código async (coroutines)
# NUNCA bloquea el event loop, cede control mientras espera
lock = asyncio.Lock()

async def safe_increment(user_id: str):
    async with lock:  # solo una coroutine a la vez
        count = await get_count(user_id)
        await set_count(user_id, count + 1)

# threading.Lock — para código con threads reales
# BLOQUEA el thread, no usar en async context
import threading
thread_lock = threading.Lock()

def sync_safe_increment(user_id: str):
    with thread_lock:
        count = get_count_sync(user_id)
        set_count_sync(user_id, count + 1)
```

**REGLA ABSOLUTA:** Nunca uses `threading.Lock` en código async. Bloquea el event loop entero. Nunca uses `asyncio.Lock` en código threaded. No funciona (no hay event loop en el thread).

### 5.3 Patrón per-user lock (para MARIS)

```python
class UserLockManager:
    """Un lock por usuario. Requests del mismo usuario se serializan.
    Requests de usuarios diferentes corren en paralelo."""

    def __init__(self):
        self._locks: dict[str, asyncio.Lock] = {}
        self._meta_lock = asyncio.Lock()  # protege el dict de locks

    async def acquire(self, user_id: str) -> asyncio.Lock:
        async with self._meta_lock:
            if user_id not in self._locks:
                self._locks[user_id] = asyncio.Lock()
            return self._locks[user_id]

# Uso en MARIS
user_locks = UserLockManager()

async def handle_message(user_id: str, message: str):
    lock = await user_locks.acquire(user_id)
    async with lock:
        # Todo el pipeline de este usuario es serial
        # Pero otros usuarios corren en paralelo
        context = await load_user_context(user_id)
        response = await generate_response(context, message)
        await save_state(user_id, context)
        return response
```

### 5.4 Shared Nothing — la mejor solución

```python
# EN VEZ DE estado compartido en memoria:
class RateGuard:
    counts = defaultdict(int)  # PELIGRO: compartido, mutable, sin lock

# USAR Supabase/Redis como source of truth:
class RateGuard:
    def __init__(self, supabase: AsyncSupabaseClient):
        self.db = supabase

    async def check(self, user_id: str) -> bool:
        # Supabase maneja la concurrencia — cada query es atómica
        result = await self.db.rpc("increment_and_check_rate", {
            "p_user_id": user_id,
            "p_max_rate": 10,
            "p_window_seconds": 60,
        }).execute()
        return result.data["allowed"]
```

**Principio (Hussein Nasser):** "Si tienes estado compartido, tienes bugs. La pregunta es cuándo los vas a encontrar." Mover estado a la base de datos (Supabase) o a Redis. El proceso de FastAPI queda stateless.

### 5.5 Fixes específicos para los bugs del audit

```python
# FIX 1: RateGuard — mover a Supabase
# Crear tabla: rate_limits (user_id, count, window_start)
# Usar RPC con operación atómica

# FIX 2: WarmthGuard — mismo patrón
# El warmth score per-user va en la sesión de Supabase, no en memoria

# FIX 3: search._rate — rate limiting en Redis o Supabase
# NUNCA defaultdict en un singleton FastAPI

# FIX 4: long_term.anchors — cargar per-request, no cachear en memoria
async def get_anchors(user_id: str) -> list[Anchor]:
    # Cada request carga fresh de Supabase
    result = await supabase.table("anchors").select("*").eq("user_id", user_id).execute()
    return [Anchor(**row) for row in result.data]

# FIX 5: CrisisState — ya está en Supabase (resuelto en audit)
# Pero asegurar que SIEMPRE se lee de DB, nunca de variable en memoria
```

---

## 6. MESSAGE BUS / EVENT-DRIVEN (Cosmic Python)

### 6.1 El problema en MARIS

El pipeline actual tiene side effects mezclados con lógica principal:
- `brain_update` se llama directamente después de generar respuesta
- `crystallize` se llama inline
- Si uno falla, afecta al flujo principal

### 6.2 Domain Events + Message Bus

```python
from dataclasses import dataclass, field
from typing import Callable, Type

# --- Events (hechos que ocurrieron) ---
@dataclass(frozen=True)
class MessageProcessed:
    user_id: str
    message: str
    response: str
    session_id: str

@dataclass(frozen=True)
class MoodChanged:
    user_id: str
    old_mood: float
    new_mood: float

@dataclass(frozen=True)
class CrisisDetected:
    user_id: str
    level: str
    message: str

# --- Commands (intenciones de hacer algo) ---
@dataclass(frozen=True)
class UpdateBrain:
    user_id: str
    message: str
    response: str

@dataclass(frozen=True)
class CheckCrystallization:
    user_id: str

# --- Message Bus ---
class MessageBus:
    def __init__(self):
        self._handlers: dict[Type, list[Callable]] = {}

    def register(self, event_type: Type, handler: Callable):
        self._handlers.setdefault(event_type, []).append(handler)

    async def handle(self, event):
        handlers = self._handlers.get(type(event), [])
        for handler in handlers:
            try:
                await handler(event)
            except Exception as e:
                logger.error(f"Handler {handler.__name__} failed for {type(event).__name__}: {e}")
                # Events: log and continue (otros handlers deben correr)
                # Commands: re-raise (el caller necesita saber)

# --- Wiring (composition root) ---
bus = MessageBus()
bus.register(MessageProcessed, handle_brain_update)
bus.register(MessageProcessed, handle_msg_count)
bus.register(MessageProcessed, handle_save_mode)
bus.register(MessageProcessed, handle_crystallize)
bus.register(MessageProcessed, handle_auto_sleep)
bus.register(CrisisDetected, handle_crisis_escalation)
bus.register(MoodChanged, handle_mood_notification)

# --- En el pipeline ---
async def process_message(user_id: str, message: str) -> str:
    response = await generate_response(user_id, message)

    # Emitir evento — el bus se encarga de los side effects
    await bus.handle(MessageProcessed(
        user_id=user_id,
        message=message,
        response=response,
        session_id=current_session_id,
    ))

    return response
```

**Ventaja:** El pipeline principal NO sabe qué side effects existen. Agregar uno nuevo = registrar un handler. Eliminar uno = quitar el registro. Testing = bus con 0 handlers.

### 6.3 Command vs Event

| | **Command** | **Event** |
|---|---|---|
| Nombre | Imperativo: `UpdateBrain` | Pasado: `MessageProcessed` |
| Handlers | Exactamente 1 | 0 o más |
| Si falla | Re-raise, el caller decide | Log and continue |
| Ejemplo MARIS | `SendCrisisAlert` | `CrisisDetected` |

### 6.4 Unit of Work (Cosmic Python)

```python
from contextlib import asynccontextmanager

class AsyncUnitOfWork:
    """Transacción atómica: todo se guarda o nada."""

    def __init__(self, supabase: AsyncSupabaseClient):
        self._supabase = supabase
        self._events: list = []  # eventos pendientes

    @asynccontextmanager
    async def __call__(self):
        try:
            yield self
            # Commit: guardar todo
            await self._supabase.rpc("commit_transaction").execute()
            # Solo emitir eventos si el commit fue exitoso
            for event in self._events:
                await bus.handle(event)
        except Exception:
            await self._supabase.rpc("rollback_transaction").execute()
            raise
        finally:
            self._events.clear()

    def add_event(self, event):
        self._events.append(event)

# Uso
async def process_and_save(user_id: str, message: str):
    uow = AsyncUnitOfWork(supabase)
    async with uow():
        response = await generate_response(user_id, message)
        await uow.save_message(user_id, message, "user")
        await uow.save_message(user_id, response, "assistant")
        uow.add_event(MessageProcessed(user_id=user_id, message=message, response=response))
        # Si save_message falla, se hace rollback Y no se emiten eventos
```

---

## 7. TASK QUEUE: CUÁNDO GRADUAR

### Escalera de complejidad:

```
Nivel 1: BackgroundTasks (FastAPI built-in)
    ✓ Simple, in-process
    ✗ Se pierde si el proceso muere
    ✗ No retry, no monitoring
    → MARIS HOY: suficiente para brain_update, msg_count

Nivel 2: asyncio.create_task + TaskGroup
    ✓ Paralelo, structured cancellation
    ✗ Se pierde si el proceso muere
    → MARIS PRONTO: para paralelizar 5 background tasks

Nivel 3: asyncio.Queue (producer-consumer)
    ✓ Backpressure, desacopla producción de consumo
    ✗ In-process, se pierde al morir
    → MARIS: para SSE streaming (ya lo usas)

Nivel 4: ARQ (Async Redis Queue)
    ✓ Persiste en Redis, retry automático, async-native
    ✓ Ligero, diseñado para FastAPI
    ✗ Necesita Redis
    → MARIS FUTURO: cuando tengas >100 users concurrentes

Nivel 5: Celery + Redis/RabbitMQ
    ✓ Battle-tested, monitoring (Flower), scheduling
    ✗ Pesado, no async-native, overhead de setup
    → MARIS: NO necesario. ARQ es mejor para tu caso.
```

### ARQ ejemplo (para cuando MARIS lo necesite):

```python
# worker.py
from arq import create_pool
from arq.connections import RedisSettings

async def brain_update(ctx, user_id: str, message: str, response: str):
    """Corre en worker separado, persiste en Redis."""
    await update_brain_vectors(user_id, message, response)

class WorkerSettings:
    functions = [brain_update]
    redis_settings = RedisSettings(host="redis-host")

# api.py — enqueue desde FastAPI
redis = await create_pool(RedisSettings(host="redis-host"))
await redis.enqueue_job("brain_update", user_id, message, response)
```

---

## 8. CIRCUIT BREAKER PARA APIs EXTERNAS

### Para Claude API (2-5s response time, puede fallar):

```python
import asyncio
from enum import StrEnum
from time import monotonic

class CircuitState(StrEnum):
    CLOSED = "closed"        # funcionando normal
    OPEN = "open"            # rechazando requests
    HALF_OPEN = "half_open"  # probando con 1 request

class AsyncCircuitBreaker:
    def __init__(
        self,
        name: str,
        fail_threshold: int = 5,
        reset_timeout: float = 60.0,
        half_open_max: int = 1,
    ):
        self.name = name
        self.fail_threshold = fail_threshold
        self.reset_timeout = reset_timeout
        self.half_open_max = half_open_max

        self._state = CircuitState.CLOSED
        self._fail_count = 0
        self._last_failure_time = 0.0
        self._half_open_count = 0
        self._lock = asyncio.Lock()

    async def call(self, func, *args, **kwargs):
        async with self._lock:
            if self._state == CircuitState.OPEN:
                if monotonic() - self._last_failure_time > self.reset_timeout:
                    self._state = CircuitState.HALF_OPEN
                    self._half_open_count = 0
                else:
                    raise CircuitBreakerOpen(f"{self.name} circuit is OPEN")

            if self._state == CircuitState.HALF_OPEN:
                if self._half_open_count >= self.half_open_max:
                    raise CircuitBreakerOpen(f"{self.name} circuit is HALF_OPEN, max trials reached")
                self._half_open_count += 1

        try:
            result = await func(*args, **kwargs)
            async with self._lock:
                self._fail_count = 0
                self._state = CircuitState.CLOSED
            return result
        except Exception as e:
            async with self._lock:
                self._fail_count += 1
                self._last_failure_time = monotonic()
                if self._fail_count >= self.fail_threshold:
                    self._state = CircuitState.OPEN
                    logger.warning(f"Circuit {self.name} OPENED after {self._fail_count} failures")
            raise

class CircuitBreakerOpen(Exception):
    pass

# Uso en MARIS
claude_breaker = AsyncCircuitBreaker("claude_api", fail_threshold=3, reset_timeout=30.0)

async def generate_response_safe(user_id: str, message: str) -> str:
    try:
        return await claude_breaker.call(call_claude_api, user_id, message)
    except CircuitBreakerOpen:
        # Fallback: respuesta genérica o cached
        return "Estoy teniendo problemas técnicos. ¿Podemos intentar de nuevo en un momento?"
```

---

## 9. TIMEOUT PATTERNS

```python
# Timeout para Claude API (puede colgar)
async def call_claude_with_timeout(prompt: str, timeout: float = 15.0) -> str:
    try:
        return await asyncio.wait_for(
            call_claude_api(prompt),
            timeout=timeout,
        )
    except asyncio.TimeoutError:
        logger.warning(f"Claude API timeout after {timeout}s")
        raise

# Timeout con fallback
async def generate_response(user_id: str, message: str) -> str:
    try:
        return await asyncio.wait_for(call_claude_api(message), timeout=15.0)
    except (asyncio.TimeoutError, CircuitBreakerOpen):
        # Fallback 1: retry con prompt más corto
        try:
            short_prompt = truncate_context(message)
            return await asyncio.wait_for(call_claude_api(short_prompt), timeout=10.0)
        except (asyncio.TimeoutError, CircuitBreakerOpen):
            # Fallback 2: respuesta empática genérica
            return get_fallback_response(user_id)
```

---

## 10. PATRÓN COMPLETO PARA MARIS

### Arquitectura target: pipeline async con background tasks

```python
# main.py — composition root
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: inicializar recursos compartidos
    app.state.claude = ClaudeClient()           # connection pool
    app.state.supabase = AsyncSupabaseClient()  # connection pool
    app.state.embedding_pool = ThreadPoolExecutor(max_workers=2)
    app.state.bus = create_message_bus()         # wired handlers
    app.state.claude_breaker = AsyncCircuitBreaker("claude", fail_threshold=3)
    app.state.user_locks = UserLockManager()

    yield

    # Shutdown: limpiar
    await app.state.claude.close()
    await app.state.supabase.close()
    app.state.embedding_pool.shutdown(wait=True)

app = FastAPI(lifespan=lifespan)

# --- Endpoint SSE ---
@app.post("/v1/chat/stream")
async def chat_stream(request: ChatRequest):
    user_id = request.user_id
    message = request.message

    # Per-user lock: serializar mensajes del mismo usuario
    lock = await app.state.user_locks.acquire(user_id)

    async def event_generator():
        async with lock:
            # 1. Cargar contexto (paralelo)
            context = await load_user_context(user_id, app.state.supabase)

            # 2. Safety check (sync PyTorch via executor)
            loop = asyncio.get_running_loop()
            embedding = await loop.run_in_executor(
                app.state.embedding_pool,
                lambda: model.encode(message).tolist()
            )

            # 3. Stream response (Claude con circuit breaker)
            queue: asyncio.Queue = asyncio.Queue()
            full_response = []

            async def produce():
                try:
                    async for token in await app.state.claude_breaker.call(
                        stream_claude, context, message
                    ):
                        await queue.put(token)
                        full_response.append(token)
                except Exception as e:
                    logger.error(f"Stream error: {e}")
                finally:
                    await queue.put(None)

            producer = asyncio.create_task(produce())

            while True:
                token = await asyncio.wait_for(queue.get(), timeout=30.0)
                if token is None:
                    break
                yield {"event": "token", "data": token}

            yield {"event": "done", "data": ""}

        # 4. Background tasks (FUERA del lock — otros mensajes pueden entrar)
        response_text = "".join(full_response)
        asyncio.create_task(
            fire_post_message_events(app.state.bus, user_id, message, response_text)
        )

    return EventSourceResponse(event_generator())

async def fire_post_message_events(bus: MessageBus, user_id: str, message: str, response: str):
    """Emitir evento — el bus dispara los 5 handlers en paralelo."""
    await bus.handle(MessageProcessed(
        user_id=user_id,
        message=message,
        response=response,
        session_id="current",
    ))
```

---

## RESUMEN: DECISIONES PARA MARIS

| Problema actual | Solución | Prioridad |
|----------------|----------|-----------|
| Claude sync SDK bloquea event loop | `run_in_executor` + `asyncio.Queue` bridge | ALTA |
| 5 background tasks secuenciales | `asyncio.TaskGroup` en paralelo | ALTA |
| Race conditions (RateGuard, etc.) | Mover estado a Supabase, `asyncio.Lock` per-user | ALTA |
| Sin connection pooling | `httpx.AsyncClient` global con limits | MEDIA |
| Sin timeout en Claude API | `asyncio.wait_for` + circuit breaker | MEDIA |
| Side effects acoplados al pipeline | Message Bus + Domain Events | MEDIA |
| No retry en background tasks | ARQ (cuando >100 users) | BAJA |
| Sin transacciones atómicas | Unit of Work con Supabase | BAJA |

---

Sources:
- [Real Python: Speed Up Your Python Program With Concurrency](https://realpython.com/python-concurrency/)
- [Real Python: Asyncio Hands-On Walkthrough](https://realpython.com/async-io-python/)
- [Cosmic Python: Unit of Work Pattern](https://www.cosmicpython.com/book/chapter_06_uow.html)
- [Cosmic Python: Events and the Message Bus](https://www.cosmicpython.com/book/chapter_08_events_and_message_bus.html)
- [Cosmic Python: Going to Town on the Message Bus](https://www.cosmicpython.com/book/chapter_09_all_messagebus.html)
- [FastAPI: Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/)
- [FastAPI: Concurrency and async/await](https://fastapi.tiangolo.com/async/)
- [BackgroundTasks vs Threads vs Async (Medium)](https://hussainwali.medium.com/fastapi-backgroundtasks-vs-threads-vs-async-f0020540bb87)
- [Better Stack: Background Tasks in FastAPI](https://betterstack.com/community/guides/scaling-python/background-tasks-in-fastapi/)
- [Why TaskGroup and Timeout Are Crucial in Python 3.11 Asyncio](https://www.dataleadsfuture.com/why-taskgroup-and-timeout-are-so-crucial-in-python-3-11-asyncio/)
- [Sentry: run_in_executor vs run_in_threadpool](https://sentry.io/answers/fastapi-difference-between-run-in-executor-and-run-in-threadpool/)
- [Maximizing PyTorch Throughput with FastAPI](https://jonathanc.net/blog/maximizing_pytorch_throughput)
- [FastAPI Race Conditions (DataSci Ocean)](https://datasciocean.com/en/other/fastapi-race-condition/)
- [SuperFastPython: Asyncio Race Conditions](https://superfastpython.com/asyncio-race-conditions/)
- [Python Dictionary Async Safety (Medium)](https://medium.com/@goldengrisha/is-pythons-dictionary-async-safe-why-you-can-still-get-race-conditions-in-async-code-c786412af567)
- [Hussein Nasser: Threads and Connections in Backend Applications](https://medium.com/@hnasr/threads-and-connections-in-backend-applications-a225eed3eddb)
- [Python Asyncio Sync Primitives (docs)](https://docs.python.org/3/library/asyncio-sync.html)
- [Python Coroutines and Tasks (docs)](https://docs.python.org/3/library/asyncio-task.html)
- [PyBreaker Circuit Breaker (GitHub)](https://github.com/danielfm/pybreaker)
- [aiobreaker for async circuit breaking](https://pypi.org/project/aiobreaker/)
- [ARQ Async Redis Queue](https://pypi.org/project/arq/)
- [Celery vs ARQ Comparison (Leapcell)](https://leapcell.io/blog/celery-versus-arq-choosing-the-right-task-queue-for-python-applications)
- [OneUptime: Circuit Breakers in Python](https://oneuptime.com/blog/post/2026-01-23-python-circuit-breakers/view)
- [Using asyncio Queues with SSE (Medium)](https://medium.com/@Rachita_B/lookout-for-these-cryptids-while-working-with-server-sent-events-43afabb3a868)
- [Inngest: Python asyncio shared state pitfalls](https://www.inngest.com/blog/no-lost-updates-python-asyncio)
