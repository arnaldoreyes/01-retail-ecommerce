# LEEME — carpeta de datos

Esta carpeta se versiona **parcialmente**. Las reglas:

| Carpeta | Que va aqui | Se sube a GitHub |
|---|---|---|
| `raw/` | El archivo original, tal como se descargo. **Nunca se edita.** | NO |
| `staging/` | Los datos ya limpios y tipados, sin agregaciones. | NO |
| `marts/` | Las tablas finales del modelo (dimensiones y hechos), en CSV. | SI, si pesan menos de 5 MB |

## Por que

El `raw/` es la evidencia: si alguien duda de tu resultado, puede volver al original. Si lo editas a mano, pierdes la trazabilidad y el analisis deja de ser reproducible. GitHub no es un disco duro: los archivos grandes hacen el repo lento e inutilizable.

## Como obtener el original

El script `tools/descargar_datasets.py` del portafolio descarga la fuente oficial y verifica el contenido. Copia el archivo que necesites a `raw/`.

**Fuente y licencia:** ver `docs/01-contexto-y-dataset.md`. UCI Machine Learning Repository, licencia CC BY 4.0 — se debe citar la fuente.
