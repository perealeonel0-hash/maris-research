# ArjanCodes — Python Architecture & Refactoring Patterns
## Aplicado al backend de MARIS (FastAPI, 23-step pipeline)

---

## 1. DEPENDENCY INJECTION SIN FRAMEWORKS

Constructor injection con Protocol classes. No necesitas librería.

```python
from typing import Protocol

class MemoryStore(Protocol):
    def recall(self, user_id: str, query: str) -> list[str]: ...
    def store(self, user_id: str, entry: dict) -> None: ...

class Brain:
    def __init__(self, memory: MemoryStore, safety: SafetyChecker):
        self.memory = memory
        self.safety = safety
```

Composition root en main.py — un solo lugar donde todo se conecta.
Testing con fakes que satisfacen el Protocol sin herencia.

## 2. PROTOCOL vs ABC vs DUCK TYPING

| Usar | Cuando |
|------|--------|
| **Protocol** | Quieres type checking SIN forzar herencia. Default choice. |
| **ABC** | Necesitas forzar implementación Y tienes lógica compartida en la base. |
| **Duck typing** | Scripts rápidos, helpers internos. No para fronteras de módulo. |

**MARIS: Protocol en todas las fronteras de módulo** (safety, memory, flow, core).

## 3. STRATEGY PATTERN → REEMPLAZAR IF/ELSE CHAINS

Directamente aplicable a resolve_state / select_mode:

```python
class ModeStrategy(Protocol):
    def matches(self, state: UserState) -> bool: ...
    def execute(self, ctx: PipelineContext) -> PipelineContext: ...

class ModeResolver:
    def __init__(self, strategies: list[ModeStrategy]):
        self.strategies = strategies
    def resolve(self, state: UserState) -> ModeStrategy:
        for s in self.strategies:
            if s.matches(state):
                return s
        return CasualMode()
```

Composition root define el orden de prioridad:
```python
resolver = ModeResolver([CrisisMode(), OnboardingMode(), SupportMode(), CasualMode()])
```

Cada modo es independientemente testeable. Agregar uno nuevo = 1 clase + 1 línea.

## 4. PROJECT STRUCTURE (src layout)

```
src/maris/
├── main.py              # composition root
├── config.py            # Pydantic Settings
├── pipeline/
│   ├── context.py       # PipelineContext dataclass
│   ├── runner.py        # PipelineRunner
│   └── steps/           # cada paso = 1 archivo
├── safety/
│   ├── protocols.py     # SafetyChecker Protocol
│   └── evaluator.py
├── memory/
│   ├── protocols.py
│   └── supabase_store.py
├── brain/
│   ├── protocols.py
│   └── modes/
└── shared/
    ├── types.py
    └── errors.py
```

- `protocols.py` en cada módulo define qué espera del mundo exterior
- `main.py` es el único que conoce todas las implementaciones concretas
- Módulos nunca importan implementaciones de otros, solo protocols

## 5. CONFIGURACIÓN

Pydantic Settings > dataclasses > raw env vars:

```python
class Settings(BaseSettings):
    supabase_url: str
    safety_threshold: float = Field(default=0.85)
    enable_physics_brain: bool = False
    model_config = {"env_file": ".env", "env_prefix": "MARIS_"}
```

Datos internos: frozen dataclasses:
```python
@dataclass(frozen=True, slots=True)
class SafetyResult:
    is_safe: bool
    crisis_level: float
    requires_veto: bool = False
```

## 6. REFACTORING WORKFLOW

1. **Identify smell** — long method, feature envy, shotgun surgery, large if/else
2. **Extract** — cada responsabilidad a su propia clase con interfaz clara
3. **Inject** — dependencias por constructor via Protocol
4. **Test** — cada pieza en aislamiento con fakes

## 7. SOLID EN PYTHON

- **S**: Cada pipeline step hace UNA cosa
- **O**: ModeResolver abierto a extensión (nueva clase), cerrado a modificación
- **L**: Cualquier clase que satisfaga Protocol puede sustituir a otra
- **I**: No un Protocol gordo — separar: MemoryReader / MemoryWriter
- **D**: Módulos de alto nivel dependen de Protocols, no de implementaciones concretas

## 8. MODERN PYTHON

- Type hints siempre en fronteras públicas
- `dataclass` para datos, class para comportamiento
- `str | None` no `Optional[str]`
- `slots=True` en dataclasses
- `StrEnum` para choices fijos, no string literals
- `match` statements para pattern matching simple

---

## PLAN CONCRETO PARA MARIS

1. Definir `PipelineContext` dataclass que fluye por los 23 pasos
2. Cada paso = clase implementando `PipelineStep` Protocol
3. Reemplazar resolve_state/select_mode if/else con Strategy + ordered resolver
4. Protocols en cada módulo. Runner solo conoce `PipelineStep`
5. Wiring en main.py (composition root)
6. Test cada step con fakes — sin Supabase, sin Claude, sin sentence-transformers
