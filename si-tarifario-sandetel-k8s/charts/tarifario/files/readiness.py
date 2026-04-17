import subprocess
import sys

cmd = [
    "mysql",
    "-u", "tarifario",
    "-ppassword",
    "-D", "concesionario",
    "-e", "SHOW TABLES LIKE 'personas';"
]

result = subprocess.run(cmd, capture_output=True, text=True)

if result.returncode != 0:
    print("Error ejecutando mysql")
    sys.exit(1)

if "personas" not in result.stdout:
    print("Tabla personas no encontrada")
    sys.exit(1)

print("OK")
sys.exit(0)