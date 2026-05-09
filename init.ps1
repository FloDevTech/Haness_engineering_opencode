# init.ps1 — Verificación e inicialización del entorno (Windows)
#
# Este script lo ejecuta el agente al COMENZAR una sesión y antes de
# declarar cualquier tarea como `done`. Si falla, la sesión no debe avanzar.
#
# Salida esperada: bloques marcados con [OK]/[FAIL]/[WARN].

$ErrorActionPreference = "Stop"

function ok    ($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function warn  ($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function fail  ($msg) { Write-Host "[FAIL]  $msg" -ForegroundColor Red }

$EXIT_CODE = 0

Write-Host "== 1. Verificando entorno ============================================"

# Buscar Python real (evita alias del Microsoft Store)
function Find-RealPython {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -and (Test-Path $cmd.Source)) {
        $oldEAP = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        try {
            $ver = & $cmd.Source --version 2>$null
            if ($ver -and ($ver -match "Python \d+\.\d+")) {
                $ErrorActionPreference = $oldEAP
                return $cmd.Source
            }
        } catch {}
        $ErrorActionPreference = $oldEAP
    }
    return $null
}

$PYTHON = Find-RealPython -Name "python3"
if (-not $PYTHON) {
    $PYTHON = Find-RealPython -Name "python"
}

if (-not $PYTHON) {
    fail "No se encontro Python real instalado (ni python3 ni python en PATH con version valida)"
    exit 1
}

$PY_VER = & $PYTHON --version 2>&1
ok "Python -> $PY_VER ($PYTHON)"

# Versión mínima 3.9
$PY_VERSION_OK = & $PYTHON -c 'import sys; print(int(sys.version_info >= (3, 9)))'
if ($PY_VERSION_OK -ne "1") {
    fail "Se requiere Python >= 3.9"
    exit 1
}
ok "Version de Python compatible"

Write-Host ""
Write-Host "== 2. Verificando archivos base del arnes ============================"

$requiredFiles = @(
    "AGENTS.md",
    "feature_list.json",
    "progress/current.md",
    "docs/architecture.md",
    "docs/conventions.md",
    "docs/verification.md",
    "CHECKPOINTS.md"
)

foreach ($f in $requiredFiles) {
    if (Test-Path $f) {
        ok "Existe $f"
    } else {
        fail "Falta archivo base: $f"
        $EXIT_CODE = 1
    }
}

Write-Host ""
Write-Host "== 3. Validando feature_list.json ===================================="

$FL_SCRIPT = @'
import json, sys
try:
    data = json.load(open("feature_list.json"))
    valid = {"pending", "in_progress", "done", "blocked"}
    in_progress = [f for f in data["features"] if f["status"] == "in_progress"]
    if len(in_progress) > 1:
        print(f"[FAIL]  Hay {len(in_progress)} features en in_progress (maximo 1)")
        sys.exit(1)
    for f in data["features"]:
        if f["status"] not in valid:
            print(f"[FAIL]  Estado invalido en feature {f['id']}: {f['status']}")
            sys.exit(1)
    print(f"[OK]    feature_list.json valido ({len(data['features'])} features)")
except Exception as e:
    print(f"[FAIL]  feature_list.json invalido: {e}")
    sys.exit(1)
'@

$FL_FILE = [System.IO.Path]::GetTempFileName() + ".py"
Set-Content -Path $FL_FILE -Value $FL_SCRIPT -NoNewline
& $PYTHON $FL_FILE
Remove-Item $FL_FILE
if ($LASTEXITCODE -ne 0) { $EXIT_CODE = 1 }

Write-Host ""
Write-Host "== 4. Ejecutando tests ==============================================="

if (Test-Path "tests") {
    $testFiles = Get-ChildItem "tests" -Filter "test_*.py" -ErrorAction SilentlyContinue
    if ($testFiles.Count -eq 0) {
        warn "Carpeta tests/ existe pero no contiene test_*.py todavia"
    } else {
        & $PYTHON -m unittest discover -s tests -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            ok "Todos los tests pasan"
        } else {
            fail "Hay tests rotos"
            $EXIT_CODE = 1
        }
    }
} else {
    warn "Carpeta tests/ no existe todavia"
}

Write-Host ""
Write-Host "== 5. Resumen ========================================================"

if ($EXIT_CODE -eq 0) {
    ok "Entorno listo. Puedes empezar a trabajar."
} else {
    fail "Entorno NO esta listo. Resuelve los errores antes de avanzar."
}

exit $EXIT_CODE
