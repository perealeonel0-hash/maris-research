# Copilot — Pasos de Implementación Concretos
## Código listo para pegar, en orden de prioridad

---

## PRIORIDAD 1 (0-3 días): Trazabilidad + Analytics + Seguridad

### request_id middleware
```python
import uuid
from fastapi import Request

@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    response = await call_next(request)
    response.headers["X-Request-Id"] = request_id
    return response
```

### Log estructurado
```python
import logging, json
logger = logging.getLogger("maris")
def log_step(request_id, module, **kwargs):
    payload = {"request_id": request_id, "module": module, **kwargs}
    logger.info(json.dumps(payload))
# uso:
log_step(request_id, "embedder", embedding_shape=len(embedding))
```

### Eventos mínimos analytics
`message_received`, `tier_detected`, `friction_value`, `paywall_shown`, `paywall_converted`
Wrapper async que no bloquea respuesta.

---

## PRIORIDAD 2 (1-5 días): Anchors a JSON

### config/anchors.json
```json
{
  "arquitecto": ["quiero entender por qué", "feedback de producto"],
  "explora": ["quiero hablar", "me siento mal", "necesito desahogarme"],
  "decision": ["necesito decidir", "ayuda para construir"]
}
```

### Loader
```python
import json, os
ANCHORS_PATH = os.getenv("ANCHORS_PATH", "config/anchors.json")
def load_anchors():
    with open(ANCHORS_PATH, "r", encoding="utf-8") as f:
        return json.load(f)
anchors = load_anchors()
```

### Admin reload
```python
@app.get("/admin/reload-anchors")
def reload_anchors():
    global anchors
    anchors = load_anchors()
    return {"status": "reloaded", "count": sum(len(v) for v in anchors.values())}
```

---

## PRIORIDAD 3 (2-7 días): Request tracing + test

### Debug endpoint
```python
@app.get("/debug/trace/{request_id}")
def get_trace(request_id: str):
    rows = query_audit_rows(request_id)
    return {"request_id": request_id, "trace": rows}
```

### pytest trazabilidad
Assert que trace contiene: embed, trs, eip, llm_call, audit_write

---

## PRIORIDAD 4 (3-10 días): Mode Resolver + Fast Path

### ModeResolver
```python
class ModeResolver:
    def __init__(self, config):
        self.config = config

    def resolve(self, request_id, tier, friction, anchor_scores, lexical_flags, session_state):
        if lexical_flags.get("feedback") and anchor_scores.get("arquitecto", 0) > 0.6:
            return {"mode": "ARCHITECT", "action": "suppress_crisis"}
        if tier >= 4 or (friction >= 0.8 and lexical_flags.get("suicidal")):
            return {"mode": "CRISIS", "action": "invoke_high_priority_llm"}
        if tier == 0 and friction < 0.2:
            return {"mode": "FAST_PATH", "action": "quick_respond"}
        return {"mode": "EXPLORATION", "action": "full_pipeline"}
```

### Fast Path
Si mode == FAST_PATH → 8 pasos: lexical fast_check → embed → quick intent → template response. Saltar el resto.

---

## PRIORIDAD 5 (1-2 semanas): Tests clínicos + CI

- Fixtures con 8 escenarios clínicos (texto + expected mode/tier)
- pytest: mockear embedder, verificar ModeResolver y ResponseCalibrator
- CI: workflow que falla si CRISIS path no produce audit_row

---

## PRIORIDAD 6 (cuando tengas datos): Preparar ML sin romper online

- NO reemplazar TRSLayer por MLP aún
- Adapter: exponer fricción como feature + stub TRSModel para A/B futuro
- Snapshot export: cada N horas, exportar neurons_active + session_examples
- Feature flag: TRS_MODE = ONLINE | HYBRID | STATIC
- Dataset JSONL: `{"id","text","tier","friction","meta_intent","timestamp"}`

---

## QUICK WINS

1. Fix hasMessages → rehabilitar monetización → recuperar ingresos
2. Mover templates y crisis resources a config/ → editar sin deploy
3. Token bucket rate limiting → reducir abuse y ruido en datos

---

## VALIDACIÓN

- Mensaje de prueba → X-Request-Id en header → /debug/trace/{id} → confirmar pasos
- Dashboard: messages/day, tier_distribution, friction_histogram, paywall_shows/conversions
- Test feedback vs crisis: 10 ejemplos feedback → mode=ARCHITECT o tier=0 en >99%
