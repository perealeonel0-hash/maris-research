# Canales Técnicos de Referencia
## Para arquitectura, code reading, y refactoring del backend de MARIS

---

## Code Reading & Walkthroughs
- **The Primeagen** — Code reviews en vivo de repos open source, critica arquitecturas, navegación eficiente
- **George Hotz (Archive)** — Sessions de cómo entrar a código desconocido y dominarlo en horas
- **Code Aesthetics** — Legibilidad: por qué ciertos patrones son más fáciles de escanear

## Arquitectura y Diseño de Sistemas
- **Codely (español)** — Arquitectura Hexagonal, DDD, SOLID. Referente en español para integrar AI en sistemas modulares
- **ByteByteGo (Alex Xu)** — System Design con diagramas claros. Arquitecturas de empresas grandes (TikTok, WhatsApp)
- **CodeOpinion (Derek Compo)** — Debate Monolitos Modulares vs Microservicios. Cuándo separar y cuándo no
- **Hussein Nasser** — Lo que pasa bajo el capó: protocolos, bases de datos, proxies. Optimizar comunicación entre servicios

## Python & Refactoring
- **ArjanCodes** — Python: transformar espagueti en arquitectura modular y testeable. Patrones de diseño aplicados
- **James Shore** — Desarrollo evolutivo: la arquitectura debe crecer CON el código, no antes

## Bajo Nivel
- **Low Level Learning** — Memoria, procesos, rendimiento. Perspectiva sólida sobre por qué las cosas son lentas o rápidas

---

## Aplicación a MARIS Backend
- **ArjanCodes** para refactorizar el pipeline de 23 pasos (módulos más testeables)
- **Codely** para evaluar si DDD aplica a la separación de dominios (crisis, scroll, plans, physics)
- **ByteByteGo** para el diseño de la arquitectura cuando MARIS escale (SSE, caching, Supabase, queue)
- **Hussein Nasser** para optimizar la comunicación Railway↔Supabase↔Claude API
