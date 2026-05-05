# Primeagen + Code Aesthetics — Code Reading & Readability
## Principios para revisar y refactorizar el backend de MARIS

---

## PRIMEAGEN: NAVEGACIÓN DE CODEBASES

### Método "Entry Point + Trace"
No leer top-to-bottom. Encontrar el entry point (route handler) y trazar UN path completo por el sistema.
- Marcar cada módulo: I/O boundary, pure transform, o side effect
- Solo después de trazar un path completo, leer branching logic
- **Test:** Si no puedes explicar qué pasa con un mensaje desde HTTP request hasta response en <2 min, el código está enredado

### Abstracción: "La abstracción incorrecta es peor que la duplicación"
- No abstraer hasta tener 3+ casos concretos (Rule of Three)
- Si tienes que leer la implementación de la abstracción para entender al caller, la abstracción falló
- **"Indirection is not abstraction"** — wrappear algo en función/clase sin simplificar el modelo mental es esconder complejidad
- Para MARIS: crisis_detector, veto_module, safety_filter pueden tener patrones similares pero lógica distinta. Mantenerlos separados ES correcto.

### Testing: "Test Behavior, Not Implementation"
- Test boundaries (input/output del sistema), no wiring interno
- Integration tests > unit tests para sistemas reales
- Si refactorizar rompe tus tests pero no tu comportamiento, tus tests están mal
- No testear métodos privados — si son tan complejos, extráelos con interfaz pública
- Para MARIS: VERA tests mandan mensaje completo y assertan sobre response (tono, safety flags, crisis) — NO sobre si step 12 llamó a step 13

### "Boring Code Wins"
- Código clever es liability — si toma >5s entender una línea, reescribir
- Explícito > implícito — 40 líneas obvias de if/elif > 10 líneas de metaclass dispatch
- State es el enemigo — cada estado mutable es un bug potencial
- "El mejor código es código que puedes borrar" — módulos que se pueden remover sin cascading failures

---

## CODE AESTHETICS: LEGIBILIDAD

### Never Nesting (Guard Clauses)
```python
# MAL: 4 niveles de indentación
def process(msg, user):
    if user is not None:
        if user.is_active:
            if not user.is_banned:
                return do_work(msg)
    return None

# BIEN: guard clauses, happy path al nivel 0
def process(msg, user):
    if user is None: return None
    if not user.is_active: return None
    if user.is_banned: return None
    return do_work(msg)
```
**Regla:** Happy path al nivel de indentación más a la izquierda. Max 2 niveles en cualquier función.

### Naming
- **Funciones = verbos:** `detect_crisis()`, `evaluate_safety()` — NO `crisis_handler()`
- **Booleans = preguntas:** `is_in_crisis`, `should_escalate` — NO `crisis_flag`
- **No nombres genéricos:** `data`, `result`, `info` no dicen nada. Usar `user_mood_vector`, `safety_verdict`
- **Nombrar el QUÉ, no el CÓMO:** `calculate_emotional_distance()` NO `run_cosine_similarity()`

### Estructura de Funciones (regla del periódico)
- Signature = headline (QUÉ), primeras líneas = WHY, body = HOW
- Una función = UNA cosa en UN nivel de abstracción
- Max 20-25 líneas por función
- Max 3-4 parámetros — si más, usar dataclass
- Return type obvio por el nombre de la función

---

## 10 REGLAS PARA REVIEW DEL PIPELINE

1. Trazar un mensaje end-to-end antes de leer módulos aislados
2. Cada paso: guard clauses arriba, happy path sin nesting, max 2 niveles
3. Steps = stateless transforms: `step(context) -> context`
4. Test en boundaries: mensaje in, respuesta out. Mock solo APIs externas
5. Booleans como preguntas: `is_in_crisis` no `crisis_flag`
6. Funciones como verbos: `detect_`, `evaluate_`, `resolve_`, `select_`
7. Max 25 líneas/función, max 4 parámetros
8. No abstraer hasta tener 3 casos — duplicación en safety es OK si la lógica es distinta
9. Si puedes borrar un módulo sin tocar otros, la arquitectura está bien
10. Todos los steps siguen el mismo patrón estructural — consistencia aburrida > variación clever
