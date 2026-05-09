# Arquitectura — Qué significa "hacer un buen trabajo"

> Este documento define el estándar de calidad. Los agentes revisores
> evalúan código contra este archivo. Si no está aquí, no es un requisito.

## Principios

1. **Capas claras.** Define las capas de tu proyecto en este documento.
   No introducir capas adicionales (servicios, repositorios, ORMs) hasta que
   haya una razón concreta documentada en `feature_list.json`.

2. **Sin dependencias externas (por defecto).** Solo stdlib. Si una feature
   requiere una dependencia, primero se discute (estado `blocked`).

3. **Errores explícitos.** Las funciones que pueden fallar lanzan
   excepciones nombradas, no devuelven `None`.

4. **Inmutabilidad por defecto.** Los modelos de dominio preferentemente
   inmutables. Modificar = crear una nueva instancia.

5. **Atomicidad en disco.** Toda escritura a archivos de datos se hace primero
   en un archivo temporal y luego `os.replace()`. Nunca dejar un archivo
   a medio escribir.

## Flujo de datos

```
usuario  ─→  interfaz (CLI / API / etc.)
               │
               ├─ construye modelo de dominio
               │
               └─→  persistencia (JSON / etc.)
                        │
                        └─→  archivo de datos (en CWD)
```

## Qué NO hacer

- No usar `print()` para errores. Usa `sys.stderr` y exit code != 0.
- No mezclar IO con lógica de dominio.
- No leer/escribir el archivo en cada operación dentro de un bucle.
  Carga al inicio, modifica en memoria, guarda al final.
- No añadir un sistema de configuración innecesario. Las rutas y constantes
  se pasan explícitamente o usan valores por defecto documentados.
