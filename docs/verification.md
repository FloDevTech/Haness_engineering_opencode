# Verificación — Cómo demostrar que el trabajo funciona

> Regla de oro: **el agente no dice "funciona", lo demuestra**.
> Toda feature termina con evidencia ejecutable, no con afirmaciones.

## Niveles de verificación

### Nivel 1 — Tests unitarios (obligatorio)

Toda función pública en `src/` tiene al menos un test en `tests/` que:

1. Cubre el camino feliz.
2. Cubre al menos un camino de error si la función puede fallar.

Comando:
```bash
python3 -m unittest discover -s tests -v
```

### Nivel 2 — Test de integración de la interfaz (obligatorio para features de UI/CLI)

Las features que añaden comandos o endpoints se verifican ejecutando la
interfaz real contra datos temporales:

```python
import subprocess, tempfile, os
with tempfile.TemporaryDirectory() as d:
    env = {**os.environ, "DATA_FILE": os.path.join(d, "data.json")}
    out = subprocess.check_output(
        ["python3", "-m", "src.cli", "add", "hola"],
        env=env, text=True,
    )
    assert "id=" in out
```

### Nivel 3 — Smoke test manual (opcional pero recomendado)

Antes de cerrar la sesión, ejecuta un flujo end-to-end con un archivo
temporal:

```bash
# macOS / Linux
DATA_FILE=/tmp/data_demo.json python3 -m src.cli add "test"

# Windows PowerShell
$env:DATA_FILE="$env:TEMP\data_demo.json"; python -m src.cli add "test"
```

## Anti-patrones (no hacer)

- ❌ "He añadido el comando, debería funcionar." → falta test ejecutable.
- ❌ Test que solo verifica que la función no lanza excepción. → tiene que
  comprobar el resultado concreto.
- ❌ `mock` del filesystem. → usa `tempfile.TemporaryDirectory()` real.
- ❌ Marcar la feature como `done` sin pasar `./init.sh` (o `.\init.ps1` en Windows).

## Verificación final antes de cerrar

```bash
./init.sh           # debe terminar con [OK] Entorno listo (macOS/Linux)
.\init.ps1          # debe terminar con [OK] Entorno listo (Windows)
```

Si `./init.sh` (o `.\init.ps1`) está rojo, **no** marques nada como `done`.
Anota el bloqueo en `progress/current.md` con estado `blocked` en `feature_list.json`.
