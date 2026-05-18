# Correr el Servidor (Backend)

Este backend está construido con Python (FastAPI).

## Pre-requisitos
- Python 3.10+ instalado.
- Base de datos PostgreSQL instalada y corriendo.

## Pasos de Instalación

1. Navegar a la carpeta `Server/API`:
   ```bash
   cd Server/API
   ```

2. Crear y activar un entorno virtual (recomendado):
   ```bash
   python -m venv venv
   # En Windows:
   venv\Scripts\activate
   # En macOS/Linux:
   source venv/bin/activate
   ```

3. Instalar las dependencias:
   ```bash
   pip install -r requirements.txt
   ```

4. Configurar Base de Datos:
   Abre el archivo de configuración `.env` (si existe, o créalo) y configura la cadena de conexión a tu base de datos PostgreSQL:
   ```env
   DATABASE_URL=postgresql://usuario:contraseña@localhost/nombre_bd
   SECRET_KEY=tu_super_secreto_aqui
   ```
   *Nota: Recuerda correr el script `Docs/db_scripts.md` en tu base de datos antes de iniciar la API por primera vez.*

5. Iniciar el Servidor:
   ```bash
   uvicorn main:app --reload
   ```

6. Probar la API:
   Abre tu navegador y ve a `http://localhost:8000/docs` para ver la interfaz interactiva de Swagger UI donde podrás probar todos los endpoints y verificar la documentación automática.
