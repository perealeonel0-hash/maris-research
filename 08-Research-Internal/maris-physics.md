# MARIS — Physics Brain

## Estado actual implementado

### Decaimiento exponencial de capacidad
```
H_ef = H₀ · e^(-Fr/H₀)
```
- H₀ = capacidad teórica (1.0)
- Fr = fricción actual
- H_ef = capacidad REAL de soporte
- Implementado en Brain.py forward()

### Velocity tracking
```
dFr/dt = (friction_actual - friction_anterior) / delta_time
```
- Positivo = empeorando
- Negativo = mejorando
- is_freefall = velocity > 0.01
- is_recovering = velocity < -0.005

### Capacity awareness
- capacity_critical = H_ef < 0.3 (near collapse)
- resolve_state usa physics para decisiones

### WarmthGuard physics
- Temperature velocity: dT/dt
- Effective warmth: e^(-T)
- escalating / deescalating flags

## Formalización propuesta por Gemini (no implementada)

### Ecuación diferencial
```
∂R/∂t = f(H, Fl, Fr)
```
La realidad R es tasa de cambio continua de Hardware, Flow, Fricción.

### Tensor de segundo rango
```
T_μν = | H     ∇Fl   ΔFr  |
       | ∇Fl   Fl    δH   |
       | ΔFr   δH    Fr   |
```
Captura interdependencia — cambio en fricción deforma hardware Y flow simultáneamente.

### Ecuación de campo (adaptación Einstein)
```
G(H) = κT(Fl, Fr)
```
La estructura responde a densidad de flujo/fricción.

### Observador
```
R = g^μν · T_μν
```
La métrica del observador determina qué colapsa en realidad.

## Pregunta abierta de Gemini
Vectores no-lineales y matrices de tercer grado. La fricción como fenómeno no-lineal requiere tensores, no vectores simples. El TRSLayer actual hace matmul (lineal). ¿Podría un tensor de tercer grado capturar las interacciones cruzadas H×Fl×Fr que un matmul no puede?

## Circadian time layer (implementado)
- 3am = 0.95 risk, deep night (1-5am) auto-escalation
- iPhone envía hora local (int 0-23)
- resolve_state escala en deep night + fricción

## Datos biológicos (planificado, no implementado)
- HealthKit: sueño, pasos, HRV
- 3 días sin dormir = efecto -0.94 en mood
- 7000+ pasos/día = 31% menos riesgo depresión
- HRV bajo = estrés alto
