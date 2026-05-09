# Harness Engineering Template — OpenCode

Plantilla base para aplicar los principios de **Harness Engineering** en
proyectos nuevos con OpenCode.

> Lo importante de este repo no es **qué** hace la aplicación, sino **cómo**
> está estructurado para que un agente de IA pueda trabajar sobre él de forma
> autónoma y verificable.

## Cómo está organizado el arnés

| Pilar | Manifestación en este repo |
|-------|----------------------------|
| **1. El repositorio ES el sistema** | `AGENTS.md`, `init.sh` / `init.ps1`, `feature_list.json`, `progress/`, `docs/` |
| **2. Orquestación multi-agente**    | `.opencode/agents/leader.md`, `implementer.md`, `reviewer.md` |
| **3. Supervisión y mejora**         | `CHECKPOINTS.md`, `tests/` |

## Estructura

```
.
├── AGENTS.md              # Mapa para agentes (divulgación progresiva)
├── CHECKPOINTS.md         # Criterios de "estado final correcto"
├── feature_list.json      # Alcance: una feature a la vez
├── init.sh                # Verificación e inicialización (macOS/Linux)
├── init.ps1               # Verificación e inicialización (Windows)
├── OPENCODE.md            # Instrucciones de arranque para OpenCode
├── progress/
│   ├── current.md         # Sesión activa (estado vivo)
│   └── history.md         # Bitácora append-only
├── docs/
│   ├── architecture.md    # Qué significa "buen trabajo"
│   ├── conventions.md     # Estilo, nombres, errores
│   └── verification.md    # Cómo demostrar que funciona
├── .opencode/
│   └── agents/            # Definiciones de líder, implementador, revisor
├── src/                   # Código de la aplicación (vacío al inicio)
└── tests/                 # Tests automáticos (vacío al inicio)
```

---

## Flujo de trabajo: De la idea al código

Este arnés se usa en **dos modos**. Nunca los mezcles en la misma sesión.

| Modo | Cuándo usar | Qué hace OpenCode | Qué archivos toca |
|------|-------------|-------------------|-------------------|
| **Plan** | Al inicio del proyecto, para definir alcance | Discute, propone, planifica | `feature_list.json`, `docs/*.md`, `progress/current.md` |
| **Ejecución** | Cuando hay features `pending` | Implementa, testea, revisa | `src/`, `tests/`, `progress/impl_*.md`, `progress/review_*.md` |

> **Regla clave:** Si estás en modo plan, no pidas "implementa". Si estás en ejecución, no pidas "redefine todo el alcance".

---

### Fase 1: Instanciar la plantilla

```bash
# Clonar la plantilla
git clone https://github.com/FloDevTech/Haness_engineering_opencode.git mi-proyecto
cd mi-proyecto

# Opcional: reiniciar git para que sea un repo nuevo
rm -rf .git && git init

# Verificar que el arnés base está sano (Windows)
.\init.ps1

# o en macOS / Linux
# ./init.sh
```

Si todo está verde, el arnés está listo.

---

### Fase 2: Definir features con OpenCode (modo plan)

> **No escribas `feature_list.json` a mano.**  
> Abre OpenCode en la raíz del repo y pidele que planifique contigo.

**Ejemplo de cómo empezar:**

> *"Quiero hacer una API REST para gestión de tareas. Ayúdame a definir las features iniciales y escríbelas en `feature_list.json`."*

**OpenCode hará:**
1. Leer `docs/architecture.md` para entender los principios del arnés.
2. Preguntarte para clarificar alcance (stack, requisitos, prioridades).
3. Proponerte un plan con features numeradas y criterios de aceptación.
4. **Escribir directamente** las features en `feature_list.json` con `status: "pending"`.
5. **Anotar en `progress/current.md`** el plan de la sesión y las decisiones tomadas.

**Ejemplo de `feature_list.json` resultante:**

```json
{
  "project": "mi-api",
  "description": "API REST para gestión de tareas",
  "rules": {
    "one_feature_at_a_time": true,
    "require_tests_to_close": true,
    "valid_status": ["pending", "in_progress", "done", "blocked"]
  },
  "features": [
    {
      "id": 1,
      "name": "config_basica",
      "title": "Configuración base del proyecto",
      "description": "Estructura de carpetas y archivo de configuración inicial",
      "acceptance": [
        "Existe src/main.py",
        "Existe tests/test_main.py",
        "./init.ps1 termina verde"
      ],
      "status": "pending"
    },
    {
      "id": 2,
      "name": "endpoint_tareas",
      "title": "CRUD de tareas",
      "description": "Endpoints REST para crear, leer, actualizar y eliminar tareas",
      "acceptance": [
        "POST /tareas crea una tarea",
        "GET /tareas lista todas las tareas",
        "tests/test_api.py cubre los 4 métodos"
      ],
      "status": "pending"
    }
  ]
}
```

---

### Fase 3: Adaptar el arnés a tu stack

Una vez definidas las features, OpenCode te ayudará a adaptar los documentos base:

- `docs/architecture.md` — capas de tu stack (ej: FastAPI, React, CLI, etc.)
- `docs/conventions.md` — estilo específico de tu lenguaje/framework
- `docs/verification.md` — comandos de test de tu stack

**Todo esto sigue siendo en modo plan/chat** — no se toca `src/` ni `tests/` todavía.

---

### Fase 4: Implementar features (modo ejecución)

Cuando todo esté definido y `feature_list.json` tenga al menos una feature `pending`:

**Tú dices:**
> *"Implementa la siguiente feature pendiente."*

**OpenCode (como líder) hará:**
1. Leer `AGENTS.md`, `feature_list.json` y `progress/current.md`.
2. Ejecutar `init.ps1` para verificar estado del arnés.
3. Lanzar subagente `implementer` → escribe código en `src/` + tests en `tests/`.
4. El implementer guarda su informe en `progress/impl_<feature>.md`.
5. Lanzar subagente `reviewer` → valida contra `CHECKPOINTS.md`.
6. El reviewer guarda su veredicto en `progress/review_<feature>.md`.
7. Si aprueba: cambiar feature a `status: "done"` en `feature_list.json`.
8. Mover resumen de `progress/current.md` a `progress/history.md`.
9. Resetear `progress/current.md` a la plantilla base.

**Tú revisas** los informes en `progress/` para auditar el trabajo. Por chat **no pasa código** — solo referencias del tipo `done -> progress/impl_<feature>.md`.

---

## El archivo vivo: `progress/current.md`

> **`progress/current.md` es el centro de gravedad del arnés.**  
> No es un archivo para que lo lea solo el agente. **Tú también lo lees** para saber en qué va la sesión sin depender del chat.

**Durante la sesión:** el agente lo actualiza después de cada paso significativo.  
**Si te desconectas:** al volver, lees `current.md` y sabes exactamente dónde quedó todo.  
**Si el chat se pierde:** el estado sobrevive en disco.

**Contenido típico (generado por el agente):**

```markdown
- Feature en curso: 1 — config_basica
- Inicio: 2026-05-09 10:00
- Agente: implementer

## Plan
- Crear src/main.py con estructura base
- Escribir tests/test_main.py
- Verificar con init.ps1

## Bitácora
- 10:05: creado src/main.py
- 10:10: test pasa, pero init.ps1 muestra advertencia
- 10:15: corregido, todo verde

## Próximo paso
Llamar al reviewer para validar.
```

**Al cerrar sesión (manual o automático):**
1. Copiar el contenido de `current.md` al final de `history.md`.
2. Resetear `current.md` dejando solo la plantilla.

---

## Dónde queda la traza de cada subagente

| Archivo                          | Quién lo escribe | Qué contiene                                        |
|----------------------------------|------------------|-----------------------------------------------------|
| `progress/current.md`            | implementer      | Plan vivo de la sesión actual                       |
| `progress/impl_<feature>.md`     | implementer      | Archivos tocados + output de los tests              |
| `progress/review_<feature>.md`   | reviewer         | Checklist contra `docs/` y `CHECKPOINTS.md`         |
| `feature_list.json`              | implementer      | `pending` → `in_progress` → `done`                  |
| `progress/history.md`            | leader / usuario | Resumen append-only de sesiones cerradas            |

Abre `progress/` en tu editor mientras trabaja el agente: cada informe aparece en cuanto el subagente termina. Así puedes auditar paso a paso quién decidió qué — el contenido no circula por chat, vive en disco y queda versionado.

---

## Checklist antes de empezar tu primer proyecto

- [ ] Copié la plantilla en una carpeta nueva
- [ ] Ejecuté `init.ps1` (o `init.sh`) y salió verde
- [ ] Abrí OpenCode en modo **plan** en la raíz del repo
- [ ] Definí features chateando con OpenCode (escribió `feature_list.json`)
- [ ] Adapté `docs/architecture.md` y `docs/conventions.md` a mi stack
- [ ] Verifiqué que hay al menos una feature con `status: "pending"`
- [ ] Pasé a modo **ejecución** y dije: *"implementa la siguiente feature pendiente"*

---

## Troubleshooting

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| `init.ps1` falla en "Verificando archivos base" | Falta algún archivo del arnés (AGENTS.md, docs/, etc.) | Revisa que copiaste la plantilla completa |
| `feature_list.json invalido` | Más de una feature en `in_progress`, o estado no válido | Abre el JSON y corrige los estados |
| "No hay features pendientes" | Todas las features están en `done` o el array está vacío | Vuelve a modo **plan** y define nuevas features |
| "El agente no sabe qué hacer" | No leíste `AGENTS.md` antes de empezar | Lee `AGENTS.md` — es el mapa de entrada |
| `current.md` tiene basura de sesiones viejas | No se cerró la sesión anterior correctamente | Mueve el contenido a `history.md` y resetea `current.md` |
| Tests rotos tras implementación | El implementer no verificó antes de declarar done | Revisa `progress/impl_<feature>.md` para ver qué falló |

---

## Al abrir un chat nuevo con OpenCode

Escribe literalmente una de estas frases. El agente hará el resto.

| Si quieres... | Escribe esto exactamente |
|---------------|--------------------------|
| Ver el estado actual | `"Lee AGENTS.md y dime el estado actual del proyecto"` |
| Continuar desarrollo | `"Implementa la siguiente feature pendiente"` |
| Planificar features | `"Ayúdame a planificar las features de este proyecto"` |

> **No inventes prompts.** Estas frases están diseñadas para activar el protocolo correcto del agente.

---

## Aprendizajes que ilustra esta plantilla

- **Divulgación progresiva** en `AGENTS.md`: el agente no recibe todas las reglas de golpe, recibe un mapa para buscarlas bajo demanda.
- **Una feature a la vez** validado por `init.ps1` / `init.ps1` (rechaza más de un `in_progress` en `feature_list.json`).
- **Estado en disco**, no en chat: `progress/current.md` y `history.md` sobreviven a reinicios y context windows reventadas.
- **Verificación ejecutable**: `init.sh` / `init.ps1` corre los tests reales, no se fía de lo que diga el agente.
- **Patrón Líder-Trabajador-Revisor**: el líder no implementa, el implementador no se autoaprueba, el revisor no edita código.
- **Anti teléfono-descompuesto**: los subagentes escriben sus resultados en archivos y solo devuelven una referencia ligera.
