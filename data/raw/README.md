# data/raw

Aquí va el dataset original, tal como se descarga. **No se versiona.**

## Por qué

GitHub no es un disco duro: un archivo de 43 MB hace el repositorio lento y difícil de clonar. Además, el original es la evidencia: quien revise el análisis puede volver a él y sacar sus propias conclusiones.

## Cómo obtenerlo

```bash
python scripts/descargar_datos.py
```

El script descarga la fuente oficial, extrae el archivo y verifica que esté completo.

**Fuente y licencia:** Online Retail II, UCI Machine Learning Repository, CC BY 4.0. Ver [`docs/diccionario-de-datos.md`](../../docs/diccionario-de-datos.md).
