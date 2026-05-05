# Copilot — Arquitectura de Cajas Negras para MARIS Pipeline
## Refactor de listen() (388 LOC) en 9 módulos con contratos claros

---

## LAS 9 CAJAS NEGRAS

### 1. Ingest (API Gateway / Fast Check)
```
IN:  { request_id, user_id, text, metadata }
OUT: { request_id, text, lexical_flags, sanitized_text }
```
Validación, rate limit, sanitización, detección lexical rápida.

### 2. Embedder
```
IN:  { request_id, sanitized_text }
OUT: { request_id, embedding: float[384] }
```
Vector semántico único por mensaje. Cacheable.

### 3. Feature Engine
```
IN:  { request_id, embedding, sanitized_text, metadata }
OUT: { request_id, features }
     features = { min_distances, anchor_scores, friction_proxy, time_of_day, session_turn }
```
Distancias a anchors/centroides, features para TRS/EIP/selector.

### 4. State Engine (TRS + Physics)
```
IN:  { request_id, features, session_state }
OUT: { request_id, friction, effective_capacity, physics_state }
```
Estado temporal, neurogenesis/decay, score continuo.

### 5. Safety/EIP Classifier
```
IN:  { request_id, embedding, features }
OUT: { request_id, tier, severity_probs, reasons }
```
Nearest-centroid + lexical cross-check. Tier 0-5 + explicaciones.

### 6. Mode Resolver (Orquestador)
```
IN:  { request_id, friction, tier, features, session_state }
OUT: { request_id, mode, action }
     mode ∈ {FAST_PATH, EXPLORATION, CRISIS, ARCHITECT, PAYWALL, ESCALATE}
```
Reglas/ML para elegir modo. Decide si LLM o fallback.

### 7. Prompt Builder / LLM Router
```
IN:  { request_id, mode, context, templates }
OUT: { request_id, llm_request_id }
```
Construir prompt, seleccionar modelo, enviar y stream.

### 8. Response Calibrator & Audit
```
IN:  { request_id, llm_response, mode, tier }
OUT: { request_id, final_response, audit_row_id }
```
Post-process, enforce safety, write audit WORM.

### 9. Persistence / Observability
```
IN:  eventos de cada caja
OUT: dashboards, dataset para ML, audit trail
```
Analytics, dataset collection, drift detection.

---

## REGLAS DEL MODE RESOLVER

```python
# Implementables como reglas codificadas + feature flags
CRISIS     if tier >= 4 OR (friction >= 0.8 AND lexical_flag in {suicidal, plan})
ARCHITECT  if anchor_scores["arquitecto"] > 0.6 AND lexical_flag = product_feedback
FAST_PATH  if tier == 0 AND friction < 0.2 AND anchor_scores["explora"] < 0.5
PAYWALL    if session_turn >= free_limit AND not premium
ESCALATE   if llm_error OR fallback_used AND tier >= 3
EXPLORATION default
```

---

## CONTRATOS JSON (ejemplos)

### Feature Engine output
```json
{
  "request_id": "r123",
  "min_distances": [0.12, 0.87, 0.45],
  "anchor_scores": {"arquitecto": 0.02, "explora": 0.6, "decision": 0.1},
  "friction_proxy": 0.34,
  "time_of_day": "03:12",
  "session_turn": 4
}
```

### State Engine output
```json
{
  "request_id": "r123",
  "friction": 0.72,
  "effective_capacity": 0.45,
  "physics_state": {"velocity": 0.02, "freefall": false}
}
```

### Mode Resolver decision
```json
{
  "request_id": "r123",
  "mode": "CRISIS",
  "action": "invoke_llm_high_priority_with_resources"
}
```

---

## NEUROGENESIS: NO SACRIFICAR

Opciones para mantener adaptabilidad online:
- **Hybrid State Engine**: neurogenesis como fuente primaria de friction + adapter para futuro modelo entrenable
- **Hooks offline**: cada N días, exportar snapshots de neuronas para dataset
- **Feature flag**: `TRS_MODE = {ONLINE, STATIC_MLP, HYBRID}` para A/B sin romper producción

---

## IMPLEMENTACIÓN INCREMENTAL

| # | Paso | Esfuerzo |
|---|------|----------|
| 1 | Encapsular listen() en las 9 cajas | 1-3 días |
| 2 | Agregar request_id tracing | 1 día |
| 3 | Mode Resolver con reglas | 2-3 días |
| 4 | Fast Path (8-10 pasos) + feature flag | 2-4 días |
| 5 | Externalizar anchors + config admin | 1-2 días |
| 6 | Tests escenarios clínicos + CI | 1-2 semanas |

---

## VALIDACIÓN

- **Trace test**: mensaje de prueba → logs muestran cada caja con mismo request_id
- **Unit tests**: mocks Embedder → Feature Engine → State Engine → Mode Resolver; asserts sobre mode
- **Scenario tests**: 8 escenarios clínicos como fixtures; validar mode + final_response
- **A/B**: fast_path vs full_pipeline en tráfico real para medir latencia y retention

---

## ALINEACIÓN CON VAULT

| Caja | Vault source |
|------|-------------|
| Ingest | Primeagen (guard clauses), ByteByteGo (rate limiting) |
| Embedder | ArjanCodes (Protocol, cacheable) |
| Feature Engine | ArjanCodes (Strategy for anchor scoring) |
| State Engine | ArjanCodes (Protocol for TRS_MODE swap) |
| Safety/EIP | Codely (bounded context: Clinical) |
| Mode Resolver | ArjanCodes (Strategy pattern replaces if/else) |
| Prompt Builder | Voss vault (accusation audit, labeling, calibrated questions) |
| Response Calibrator | Codely (bounded context: Clinical post-processing) |
| Persistence | ByteByteGo (fire-and-forget queue), Concurrency (Message Bus) |
