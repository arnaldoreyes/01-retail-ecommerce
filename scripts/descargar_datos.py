"""Descarga el dataset original de este proyecto a data/raw/.

Solo usa la libreria estandar de Python: no necesita pandas, ni pip, ni nada
instalado. Funciona con cualquier Python 3.8 o superior.

Uso:
    python scripts/descargar_datos.py

Fuente: UCI Machine Learning Repository (acceso libre, licencia CC BY 4.0).
    Chen, D. (2012). Online Retail II [Dataset]. UCI ML Repository.
    https://doi.org/10.24432/C5CG6D
"""

from __future__ import annotations

import os
import sys
import urllib.request
import zipfile

URL = "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
ARCHIVO = "online_retail_II.xlsx"
TAMANO_MINIMO_MB = 40  # si pesa menos, la descarga vino corta

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DESTINO = os.path.join(RAIZ, "data", "raw")
ZIP = os.path.join(DESTINO, "_descarga.zip")


def descargar(url: str, ruta: str) -> None:
    print(f"[1/3] Descargando {url}")
    with urllib.request.urlopen(url, timeout=120) as respuesta, open(ruta, "wb") as salida:
        while True:
            trozo = respuesta.read(1024 * 256)
            if not trozo:
                break
            salida.write(trozo)
    print(f"      -> {os.path.getsize(ruta) / 1024 / 1024:.1f} MB")


def extraer(zip_path: str, carpeta: str) -> None:
    print("[2/3] Extrayendo")
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(carpeta)
    for raiz, _, archivos in os.walk(carpeta):
        for archivo in archivos:
            if archivo.lower().endswith(".zip") and os.path.join(raiz, archivo) != zip_path:
                with zipfile.ZipFile(os.path.join(raiz, archivo)) as z:
                    z.extractall(raiz)


def main() -> int:
    os.makedirs(DESTINO, exist_ok=True)
    final = os.path.join(DESTINO, ARCHIVO)

    if os.path.exists(final) and os.path.getsize(final) > TAMANO_MINIMO_MB * 1024 * 1024:
        print(f"[=] Ya existe {ARCHIVO} ({os.path.getsize(final) / 1024 / 1024:.1f} MB). Nada que hacer.")
    else:
        descargar(URL, ZIP)
        extraer(ZIP, DESTINO)
        if os.path.exists(ZIP):
            os.remove(ZIP)

    print("[3/3] Verificando")
    if not os.path.exists(final):
        print(f"      [X] No se encontro {ARCHIVO} en data/raw/")
        return 1
    mb = os.path.getsize(final) / 1024 / 1024
    if mb < TAMANO_MINIMO_MB:
        print(f"      [X] {ARCHIVO} pesa {mb:.1f} MB: la descarga esta incompleta.")
        return 1
    print(f"      OK  {ARCHIVO}  {mb:.1f} MB")
    print()
    print("Siguiente paso: guarda cada hoja del Excel como CSV UTF-8 en data/staging/")
    print("y ejecuta sql/00_setup/00_crear_esquema.sql en MySQL Workbench.")
    print("Despues de cargar, corre sql/00_setup/01_validar_carga.sql: tiene que dar 10/10 OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
