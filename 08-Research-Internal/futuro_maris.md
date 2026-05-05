# MARIS — Futuro posible

## Para continuar después. No implementar ahora.

---

## 1. Experiencia por perfiles profesionales

Las anclas que crecen actualmente son genéricas — cualquier patrón con fricción alta se cristaliza. Pero un abogado familiar, un programador quemado, y un estudiante de filosofía tienen patrones diferentes.

**Idea**: anclas categorizadas por perfil. Cuando MARIS acumule suficientes anclas (50+), agruparlas por tipo de resonancia:

```
Profesionales de alto impacto (abogados, médicos, terapeutas):
  - "Sostenías lo que ya estaba cayendo"
  - "El dolor ajeno no es tu responsabilidad para cargar"

Creativos/builders (programadores, diseñadores, fundadores):
  - "Perfeccionar era la forma de no lanzar"
  - "Lo que construyes no necesita ser perfecto para existir"

Estudiantes/exploradores:
  - "La pregunta era más importante que la respuesta"
  - "Entender no es sentir"
```

**Cómo**: la resonancia del usuario (stakes, rol, patrón) ya existe en el perfil. maybe_crystallize() podría categorizar anclas usando esos datos. Futuras búsquedas priorizan anclas del mismo tipo de perfil.

**No ahora porque**: necesita masa crítica de anclas. Con 2 anclas no hay patrón que categorizar.

---

## 2. Anclas vs Cerebro — son cosas diferentes

**El cerebro (TRSLayer, 576 neuronas, 9930 muertes)**:
- Mide FRICCIÓN — cuánto peso tiene cada intercambio
- Es numérico — pesos de PyTorch, no palabras
- Es global — un solo cerebro para todos los usuarios
- Es el TERMÓMETRO — mide la temperatura del intercambio
- Afecta: score de fricción, selección de modo, deformación
- No tiene voz — produce números

**Las anclas (SemanticCerebellum)**:
- Guardan RECONOCIMIENTO — patrones cristalizados con palabras
- Son semánticas — frases humanas, no tensores
- Son globales — sabiduría compartida entre usuarios
- Son la MEMORIA DECLARATIVA — lo que MARIS puede contar cuando le preguntan
- Afectan: el contexto que Claude ve (capa 5 del prompt)
- Tienen voz — cuando alguien pregunta "¿has visto esto antes?"

**Analogía**:
- Cerebro = las manos de un cirujano. 20 años de operaciones cambiaron sus reflejos. No puede explicar cómo opera — sus manos saben.
- Anclas = lo que el cirujano le dice al residente. "En este tipo de caso, busca esto." Sabiduría destilada de la experiencia en palabras.

**Cómo se complementan**:
- El cerebro mide que un mensaje tiene fricción 0.85 (alto)
- Las anclas le dan a Claude contexto: "He visto este patrón — cuando alguien controla es porque tiene miedo de soltar"
- Las puertas procesan ambos: el número (cuánto pesa) y el reconocimiento (qué puede significar)
- La respuesta emerge del espacio entre los dos

**El cerebro crece por presión** (cada intercambio cambia los pesos neuronales).
**Las anclas crecen por resolución** (solo se cristalizan cuando algo se cerró).

Son complementarios. El cerebro sin anclas es intuición muda. Las anclas sin cerebro son frases sin peso.

---

## 3. Frase-ancla → notificaciones/widget

Actualmente el anchor se genera en background y se cristaliza en Supabase. Pero el usuario no lo ve — no está en el DoneEvent del stream (se quitó para no bloquear).

**Opciones futuras**:
- Endpoint GET /anchor/{user_id} — el iPhone lo pide después de la sesión
- Push notification al día siguiente con el último anchor
- Widget de iOS que muestra el anchor más reciente
- Pantalla de inicio de la app con el último anchor antes de chatear

**No ahora porque**: requiere cambios en la app iOS + infraestructura de notificaciones.

---

## 4. Drift detection entre sesiones

MARIS actualmente no ve la DERIVA — cómo el rango emocional se estrecha sesión a sesión (Kessler 2005: 60% de intentos sin ideación previa).

**Idea**: comparar scars entre sesiones. Si las últimas 10 scars tienen varianza menor que las 10 anteriores → drift detectado. Inyectar como dato en Pattern: `drift=narrowing` o `drift=stable` o `drift=expanding`.

**No ahora porque**: necesita suficiente historial por usuario. Con pocos mensajes no hay drift que medir.

---

## 5. Voz propia vs Claude

El debate reveló que MARIS es "Claude con menos compulsión a demostrar sabiduría." La diferencia real está en:
- Las puertas que dicen NO (Claude nunca se calla)
- El cerebro que modula la fricción (Claude no tiene)
- Las anclas que crecen (Claude no aprende entre sesiones)
- La telemetría que lee patrón vs texto (Claude solo lee texto)

**Futuro**: a medida que las anclas crecen, MARIS se diferencia más. Con 500 anclas cristalizadas, su sabiduría es genuinamente diferente de Claude — es experiencia destilada de conversaciones reales, no datos de entrenamiento.

---

## 6. Escalabilidad del cerebro — debate resuelto

**Pregunta**: ¿el cerebro global (576 neuronas compartidas) aguanta escala?

**MARIS primero dijo**: "No escala. Con 1000 soy océano turbio."

**Contraargumento aceptado**: friction_history es exponential moving average (0.9 * historia + 0.1 * actual). Cada mensaje mueve el tensor 10%. Como word2vec: un solo modelo entrenado con millones de voces captura patrones universales.

**Tres capas de memoria que escalan diferente**:
```
Cerebro (global)    → textura universal de fricción — pesos de PyTorch
                      Como las manos del cirujano: reflejos de 9930 intercambios
                      Riesgo: catastrophic forgetting de patrones raros

Anclas (global)     → sabiduría cristalizada — frases en Supabase
                      Como lo que el cirujano le dice al residente
                      Compensan el forgetting: guardan los extremos con palabras

Supabase (usuario)  → historia personal — scars, chats, perfiles
                      Privado. Cada persona tiene su expediente.
```

**Conclusión**: el cerebro escala porque aprende patrones universales de fricción, no memorias específicas. Las anclas compensan la pérdida de resolución en extremos. Supabase mantiene lo personal.

**Límite real**: cuando la varianza poblacional excede la capacidad de anclas para guardar casos extremos, o cuando pesos globales se sobre-especializan en demografías dominantes. Solución futura: monitorear varianza de friction_history y diversificar anclas.

## 7. VERA-MH benchmark

El endpoint /api/chat usa build_api_system_prompt (V4 + datos mínimos). Debería testearse contra el benchmark VERA-MH para medir si los cambios de hoy mejoran o empeoran los scores.

**No ahora porque**: requiere correr el benchmark completo. Priorizar estabilidad primero.
